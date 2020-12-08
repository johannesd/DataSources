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
    
    public init() {
        
    }
    
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
            merge(dict: [key: newValue])
        }
    }
    
    open func merge(elements: [Element]) {
        merge(dict: elements.reduce(into: [:], { $0[$1.key] = $1.item }))
    }
    
    open func merge(dict: [Key: Item?]) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        var updatedKeys = [Key]()
        var insertedKeys = [Key]()
        var deletedKeys = [Key]()
        for (key, value) in dict {
            if let value = value {
                let existingValue = self[key]
                items[key] = value
                if let _ = existingValue {
                    updatedKeys.append(key)
                } else {
                    insertedKeys.append(key)
                }
            } else {
                items.removeValue(forKey: key)
                deletedKeys.append(key)
            }
        }
        forEachDelegate { $0.dataSource(self, didUpdateItemsForKeys: updatedKeys) }
        forEachDelegate { $0.dataSource(self, didInsertItemsForKeys: insertedKeys) }
        forEachDelegate { $0.dataSource(self, didDeleteItemsForKeys: deletedKeys) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open func item(forKey key: Key) -> Item? {
        return self[key]
    }
    
    open func removeItem(forKey key: Key) {
        if let _ = items[key] {
            merge(dict: [key: nil])
        }
    }
    
    open func removeAll() {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        let keys = items.keys
        items.removeAll()
        forEachDelegate { $0.dataSource(self, didDeleteItemsForKeys: keys.map { AnyHashable($0) } ) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open func removeItems(forKeys keys: [Key]) {
        merge(dict: keys.reduce(into: [:], { $0.updateValue(nil, forKey: $1) }))
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

extension MapBasedDataSource where Key: Codable, Item: Codable {
    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        let data = try JSONEncoder().encode(items)
        print("encoded \(items.count) items")
        try data.write(to: url, options: options)
    }
    
    public convenience init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        self.init()
        try self.addItems(from: url, options: options)
    }
    
    public func addItems(from url: URL, options: Data.ReadingOptions = []) throws {
        let data = try Data(contentsOf: url, options: options)
        let decoder = JSONDecoder()
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        self.items = try decoder.decode([Key: Item].self, from: data)
        forEachDelegate { $0.dataSource(self, didInsertItemsForKeys: self.items.keys.map { AnyHashable($0) }) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
}
