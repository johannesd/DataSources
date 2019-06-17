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

/**
 A base class for data sources that store key/value pairs.
 */
open class MapBasedDataSource<Key, Item>: DataSourceDelegating where Key: Hashable {
    public typealias Key = Key
    public typealias Item = Item

    public var dataSourceDelegates = DataSourceDelegates()
    internal var items = [Key: Item]()
    
    public struct Element {
        public let key: Key
        public let item: Item
        
        public init(key: Key, item: Item) {
            self.key = key
            self.item = item
        }
    }
    
    open subscript(key: Key) -> Item? {
        get {
            return items[key]
        }
        set(newValue) {
            if let newValue = newValue {
                let existingValue = self[key]
                forEachDelegate { $0.dataSourceWillUpdateItems(self) }
                items[key] = newValue
                if let _ = existingValue {
                    forEachDelegate { $0.dataSource(self, didUpdateItemsForKeys: [key]) }
                } else {
                    forEachDelegate { $0.dataSource(self, didInsertItemsForKeys: [key]) }
                }
                forEachDelegate { $0.dataSourceDidUpdateItems(self) }
            } else {
                removeItem(forKey: key)
            }
        }
    }
    
    open func item(forKey key: Key) -> Item? {
        return self[key]
    }
    
    open func removeItem(forKey key: Key) {
        if let _ = items[key] {
            forEachDelegate { $0.dataSourceWillUpdateItems(self) }
            items.removeValue(forKey: key)
            forEachDelegate { $0.dataSource(self, didDeleteItemsForKeys: [key]) }
            forEachDelegate { $0.dataSourceDidUpdateItems(self) }
        }
    }
    
    open func removeAll() {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        let keys = items.keys
        items.removeAll()
        forEachDelegate { $0.dataSource(self, didDeleteItemsForKeys: keys.map { AnyHashable($0) } ) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open var count: Int {
        return items.count
    }
    
    open var elements: [Element] {
        return items.map { Element(key: $0, item: $1) }
    }
    
    open func forEachDelegate(_ block: (MapDataSourceDelegate) -> Void) -> Void {
        forEachDataSourceDelegate(block)
    }
}

extension MapBasedDataSource.Element: Equatable {
    public static func == (lhs: MapBasedDataSource<Key, Item>.Element, rhs: MapBasedDataSource<Key, Item>.Element) -> Bool {
        return lhs.key == rhs.key
    }
}
