//
//  Main.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 30/04/2019.
//

public class BibleSDK {

    var bookProvider: BookProvider?
    let abbreviation = try! BibleAbbreviation()

    // show list of installed versions
    // load version

    // get books list (for version)
    // get texts by string ref (interate all versions?)
    // get texts by ref (for version)

    public func load(path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            throw SqliteStorage.StorageError.failedOpenConnection(path)
        }
        
        let storage = try SqliteStorage(filename: path)
        bookProvider = BookProvider(storage: storage)
    }

    public func findByReference(_ string: String) -> [Verse] {
        precondition(!string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        guard let provider = bookProvider else {
            return []
        }

        return abbreviation
            .matches(string) // String -> RawReference
            //.reduce([], { $0.contains($1) ? $0 : $0 + [$1] }) // Ignore duplicates
            .compactMap { provider.findBookReference(by: $0) } // -> Reference
            .flatMap { provider.findVerses(by: $0) } // -> Verses
    }
}
