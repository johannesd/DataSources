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
// TODO: Function item(at: IndexPath) in order to have same accessor function as other data sources
// TODO: Element should be called Item, so that item(at: IndexPath) is consistent

/**
 A base class for data sources that stores a list.
 */
open class ListBasedDataSource<Element>: ReadonlyListBasedDataSource<Element> {
    open override subscript(index: Int) -> Element {
        get {
            return super[index]
        }
        set(newValue) {
            super[index] = newValue
        }
    }
    
    open override func append(_ newElement: Element) {
        super.append(newElement)
    }
    
    open override func insert(_ newElement: Element, at index: Int) {
        super.insert(newElement, at: index)
    }
    
    open override func remove(at index: Int) {
        super.remove(at: index)
    }
}

open class ReadonlyListBasedDataSource<Element>: DataSourceDelegating {
    public var dataSourceDelegates = DataSourceDelegates()
    internal var elements = [Element]()
    
    open internal(set) subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set(newValue) {
            forEachDelegate { $0.dataSourceWillUpdateItems(self) }
            elements[index] = newValue
            forEachDelegate { $0.dataSource(self, didUpdateItemsAtIndexPaths: [IndexPathUpdate(IndexPath(index: index))]) }
            forEachDelegate { $0.dataSourceDidUpdateItems(self) }
        }
    }
    
    internal func append(_ newElement: Element) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        elements.append(newElement)
        forEachDelegate { $0.dataSource(self, didInsertItemsAtIndexPaths: [IndexPath(index: elements.count - 1)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    internal func insert(_ newElement: Element, at index: Int) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        elements.insert(newElement, at: index)
        forEachDelegate { $0.dataSource(self, didInsertItemsAtIndexPaths: [IndexPath(index: index)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    internal func remove(at index: Int) {
        forEachDelegate { $0.dataSourceWillUpdateItems(self) }
        elements.remove(at: index)
        forEachDelegate { $0.dataSource(self, didDeleteItemsAtIndexPaths: [IndexPath(index: index)]) }
        forEachDelegate { $0.dataSourceDidUpdateItems(self) }
    }
    
    open var count: Int {
        return elements.count
    }
    
    open func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) -> Void {
        forEachDataSourceDelegate(block)
    }
}

extension Array {
    public init(listBasedDataSource: ListBasedDataSource<Element>) {
        self = listBasedDataSource.elements
    }
}
