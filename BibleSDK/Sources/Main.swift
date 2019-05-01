//
//  Main.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 30/04/2019.
//

public class Bible {

    var bookProvider: BookProvider?

    public func load(path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            throw SqliteStorage.StorageError.failedOpenConnection(path)
        }
        
        let storage = try SqliteStorage(filename: path)
        bookProvider = BookProvider(storage: storage)
    }
}
