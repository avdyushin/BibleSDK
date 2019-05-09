//
//  BibleContainer.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

class BibleContainer {

    let bibles: [Bible]

    init() {
        let bundlePath = Bundle(for: type(of: self)).bundlePath
        bibles = FileManager
            .default
            .enumerator(atPath: bundlePath)!
            .map { $0 as! String }
            .filter { $0.hasSuffix(".db") == true && $0 != "kjv_daily.db" }
            .compactMap { return try? Bible(version: $0) }
    }
}
