//
//  Container.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

class Container<S: Storage> {

    let storage: S
    init(storage: S) {
        self.storage = storage
    }
}
