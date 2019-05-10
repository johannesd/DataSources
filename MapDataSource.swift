//
//  MapDataSource.swift
//  DataProviders
//
//  Created by Johannes Dörr on 09.05.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation
import DataSources

open class MapDataSource<Key, Value> where Key : Hashable {
    private var values = [Key: Value]()
    
    public typealias Item = (key: Key, value: Value)
    
    subscript(key: Key) -> Value? {
        get {
            return values[key]
        }
        set(newValue) {
            if let newValue = newValue {
                let existingValue = self[key]
                values[key] = newValue
                if let _ = existingValue {
                    forEachDelegate({ $0.dataSource(self, didInsertItemsForKeys: [key]) })
                } else {
                    forEachDelegate({ $0.dataSource(self, didUpdateItemsForKeys: [key]) })
                }
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    open func removeValue(forKey key: Key) {
        if let _ = values[key] {
            values.removeValue(forKey: key)
            forEachDelegate({ $0.dataSource(self, didDeleteItemsForKeys: [key]) })
        }
    }
    
    open var forEachDelegate: ((MapDataSourceDelegate) -> Void) -> Void {
        return { _ in }
    }
    
    open var all: [Item] {
        return values.map { Item(key: $0, value: $1) }
    }
}
