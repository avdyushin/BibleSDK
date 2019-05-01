//
//  Storage.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import SQLite3
import Foundation

public struct Row {
    let values: [String: AnyObject]
    subscript<T>(name: String) -> T? {
        return values[name] as? T
    }
    init(values: [String: AnyObject]) {
        self.values = values
    }
}

public protocol Storage {
    func fetch(_ statement: String) throws -> [Row]
}

public protocol AsyncStorage: Storage {
    @discardableResult
    func execute(_ statement: String, block: @escaping ([Row]) -> Void) throws -> Operation
}

class BaseSqliteStorage: Storage {

    enum StorageError: Error {
        case failedOpenConnection(String)
        case failedPrepare(String, message: String)
    }

    private var db: OpaquePointer? = .none

    init(filename: String) throws {
        precondition(!filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        guard let pointer = open(filename) else {
            throw StorageError.failedOpenConnection(filename)
        }
        self.db = pointer
        injectCustomFunctions()
    }

    fileprivate func open(_ filename: String) -> OpaquePointer? {
        precondition(!filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        var db: OpaquePointer? = .none
        guard sqlite3_open_v2(filename, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return nil
        }
        return db
    }

    fileprivate func injectCustomFunctions() {
        precondition(db != nil)

        sqlite3_create_function(db, "utf8_upper".cString(using: .utf8), 1, SQLITE_UTF8, nil, { context, argc, arguments in
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            let argv = Array(UnsafeBufferPointer(start: arguments, count: Int(argc)))
            let param = String(cString: UnsafePointer(sqlite3_value_text(argv[0])))
            let nsstring = (param as NSString).uppercased
            let result = nsstring
            return sqlite3_result_text(context, result, -1, SQLITE_TRANSIENT)
        }, nil, nil)
    }

    func prepare(_ statement: String) throws -> OpaquePointer {
        var query: OpaquePointer?
        guard sqlite3_prepare(db, statement, -1, &query, nil) == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(db))
            throw StorageError.failedPrepare(statement, message: message)
        }
        return query!
    }

    func fetchRows(query: OpaquePointer) -> [Row] {
        var rows = [Row]()
        while sqlite3_step(query) == SQLITE_ROW {
            let count = sqlite3_column_count(query)
            var values = [String: AnyObject]()
            for col in 0..<count {
                let name = String(cString: UnsafePointer(sqlite3_column_name(query, col)))
                switch sqlite3_column_type(query, col) {
                case SQLITE_INTEGER:
                    values[name] = Int(sqlite3_column_int(query, col)) as AnyObject
                case SQLITE_TEXT, SQLITE3_TEXT:
                    values[name] = String(cString: UnsafePointer(sqlite3_column_text(query, col))) as AnyObject
                default:
                    debugPrint("MISSING CATCH, \(name) -> \(sqlite3_column_type(query, col))")
                }
            }
            rows.append(Row(values: values))
        }
        return rows
    }

    func fetch(_ statement: String) throws -> [Row] {
        precondition(db != nil)
        precondition(!statement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        sqlite3_interrupt(db)

        let query = try prepare(statement)

        defer {
            sqlite3_finalize(query)
        }

        return fetchRows(query: query)
    }
}

class SqliteStorage: BaseSqliteStorage, AsyncStorage {

    private let syncQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "ru.avdyushin.SqliteStorage.sync")
        return queue
    }()

    private let asyncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "ru.avdyushin.SqliteStorage.async.serial"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    override func fetch(_ statement: String) throws -> [Row]{
        var results: [Row] = []
        try syncQueue.sync {
            results = try super.fetch(statement)
        }
        return results
    }

    @discardableResult
    func execute(_ statement: String, block: @escaping ([Row]) -> Void) throws -> Operation {

        let query = try prepare(statement)

        asyncQueue.cancelAllOperations()

        let operation = BlockOperation()
        operation.name = "Exec SQL"
        operation.addExecutionBlock { [weak self] in
            guard let self = self else {
                debugPrint("cancelled no self")
                return

            }
            guard operation.isCancelled == false else {
                debugPrint("cancelled before got results")
                return
            }

            let results = self.fetchRows(query: query)

            guard operation.isCancelled == false else {
                debugPrint("cancelled after got results")
                return
            }

            debugPrint("Executed %@", statement)
            block(results)
        }
        asyncQueue.addOperation(operation)
        return operation
    }
}
