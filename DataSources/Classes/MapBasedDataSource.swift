//
//  MapDataSource.swift
//  DataProviders
//
//  Created by Johannes Dörr on 09.05.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation

// TODO: Add support for most Dictionary functions, like merge etc
// TODO: Add support for subscript with collection as key input. That way, multiple
// elements could be set within one update cycle. (or is merge enough for this?)

// TODO: Function item(at: IndexPath) in order to have same accessor function as other data sources
// TODO: Value should be called Item, so that item(at: IndexPath) is consistent. Item should be Entry

/**
 A base class for data sources that store key/value pairs.
 */
open class MapBasedDataSource<Key, Value>: DataSourceDelegating where Key: Hashable {
    public var dataSourceDelegates = DataSourceDelegates()
    internal var values = [Key: Value]()
    
    public struct Item {
        public let key: Key
        public let value: Value
        
        public init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
    
    open subscript(key: Key) -> Value? {
        get {
            return values[key]
        }
        set(newValue) {
            if let newValue = newValue {
                let existingValue = self[key]
                forEachDelegate { $0.dataSourceWillUpdateItems(self) }
                values[key] = newValue
                if let _ = existingValue {
                    forEachDelegate { $0.dataSource(self, didUpdateItemsForKeys: [key]) }
                } else {
                    forEachDelegate { $0.dataSource(self, didInsertItemsForKeys: [key]) }
                }
                forEachDelegate { $0.dataSourceDidUpdateItems(self) }
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    open func removeValue(forKey key: Key) {
        if let _ = values[key] {
            forEachDelegate { $0.dataSourceWillUpdateItems(self) }
            values.removeValue(forKey: key)
            forEachDelegate { $0.dataSource(self, didDeleteItemsForKeys: [key]) }
            forEachDelegate { $0.dataSourceDidUpdateItems(self) }
        }
    }
    
    open var count: Int {
        return values.count
    }
    
    open var items: [Item] {
        return values.map { Item(key: $0, value: $1) }
    }
    
    open func forEachDelegate(_ block: (MapDataSourceDelegate) -> Void) -> Void {
        forEachDataSourceDelegate(block)
    }
}

extension MapBasedDataSource.Item: Equatable {
    public static func == (lhs: MapBasedDataSource<Key, Value>.Item, rhs: MapBasedDataSource<Key, Value>.Item) -> Bool {
        return lhs.key == rhs.key
    }
}
