//
//  ListBasedDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation

// TODO: Add support for most Array functions, like append(contentsOf:) etc
// TODO: Add support for subscript with collection as index input. That way, multiple
// elements could be set within one update cycle. 

/**
 A base class for data sources that stores a list.
 */
open class ListBasedDataSource<Item>: ReadonlyListBasedDataSource<Item> {
    open override subscript(index: Int) -> Item {
        get {
            return super[index]
        }
        set(newValue) {
            super[index] = newValue
        }
    }
    
    open override func append(_ newItem: Item) {
        super.append(newItem)
    }
    
    open override func insert(_ newItem: Item, at index: Int) {
        super.insert(newItem, at: index)
    }
    
    open override func remove(at index: Int) {
        super.remove(at: index)
    }
}

extension ListBasedDataSource where Item: Codable {
    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        let data = try JSONEncoder().encode(items)
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
        self.items = try decoder.decode([Item].self, from: data)
        let indexPaths = Array(0..<items.count).map { IndexPath(index: $0) }
        forEachDelegate { $0.dataSource(self, didInsertItemsAtIndexPaths: indexPaths) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
}

open class ReadonlyListBasedDataSource<Item>: DataSourceDelegating {
    public typealias Item = Item
    
    public var dataSourceDelegates = DataSourceDelegates()
    internal var items = [Item]()
    
    open internal(set) subscript(index: Int) -> Item {
        get {
            return items[index]
        }
        set(newValue) {
            forEachDelegate { $0.dataSourceWillUpdateItems(self) }
            items[index] = newValue
            forEachDelegate { $0.dataSource(self, didUpdateItemsAtIndexPaths: [IndexPathUpdate(IndexPath(index: index))]) }
            forEachDelegate { $0.dataSourceDidUpdateItems(self) }
        }
    }
    
    open func item(at indexPath: IndexPath) -> Item {
        return self[indexPath.index]
    }

    internal func append(_ newItem: Item) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        items.append(newItem)
        forEachDelegate { $0.dataSource(self, didInsertItemsAtIndexPaths: [IndexPath(index: items.count - 1)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    internal func insert(_ newItem: Item, at index: Int) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        items.insert(newItem, at: index)
        forEachDelegate { $0.dataSource(self, didInsertItemsAtIndexPaths: [IndexPath(index: index)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    internal func remove(at index: Int) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        items.remove(at: index)
        forEachDelegate { $0.dataSource(self, didDeleteItemsAtIndexPaths: [IndexPath(index: index)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open func removeAll() {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        let indexPaths = Array(0..<items.count).map { IndexPath(index: $0) }
        items.removeAll()
        forEachDelegate { $0.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open func move(_ fromIndex: Int, to toIndex: Int) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        let element = items.remove(at: fromIndex)
        items.insert(element, at: toIndex)
        forEachDelegate { $0.dataSource(self, didMoveItemAtIndexPath: IndexPath(index: fromIndex), toIndexPath: IndexPath(index: toIndex)) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open var count: Int {
        return items.count
    }
    
    open func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) -> Void {
        forEachDataSourceDelegate(block)
    }
}

extension Array {
    public init(_ readonlyListBasedDataSource: ReadonlyListBasedDataSource<Element>) {
        self = readonlyListBasedDataSource.items
    }
}
