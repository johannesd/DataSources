//
//  MapItemsDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation
import Delegates

/**
 A data source that provides the items of a `MapDataSource` as a sorted list.
 */
public final class MapItemListDataSource<Key, Item>: ReadonlyListBasedDataSource<MapBasedDataSource<Key, Item>.Element> where Key: Hashable {
    public var delegates = Delegates<ListDataSourceDelegate>()
    public typealias MapDataSource = MapBasedDataSource<Key, Item>
    public private(set) var mapDataSource: MapDataSource
    private let areInIncreasingOrder: (MapDataSource.Element, MapDataSource.Element) -> Bool
    private let isIncluded: (MapDataSource.Element) -> Bool
    
    public init(_ mapDataSource: MapBasedDataSource<Key, Item>,
                filteredBy isIncluded: @escaping (MapBasedDataSource<Key, Item>.Element) -> Bool = { _ in true },
                sortedBy areInIncreasingOrder: @escaping (MapBasedDataSource<Key, Item>.Element, MapBasedDataSource<Key, Item>.Element) -> Bool) {
        self.mapDataSource = mapDataSource
        self.isIncluded = isIncluded
        self.areInIncreasingOrder = areInIncreasingOrder
        super.init()
        loadItems()
        mapDataSource.add(self, as: MapDataSourceDelegate.self)
    }
    
    public func reloadItems() {
        loadItems()
        forEachDelegate { $0.dataSourceDidReloadItems(self) }
    }
    
    func loadItems() {
        items = mapDataSource.elements.filter({ isIncluded($0) }).sorted(by: areInIncreasingOrder)
    }
    
    public override func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}

extension MapItemListDataSource: MapDataSourceDelegate {
    public func dataSource(_ dataSource: Any, didInsertItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        let insertedItems = keys.compactMap({ (_key) -> MapDataSource.Element? in
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let item = mapDataSource[key] else { fatalError("Item not found") }
            let element = MapDataSource.Element(key: key, item: item)
            if isIncluded(element) {
                return element
            } else {
                return nil
            }
        })
        let elementKeys = (items + insertedItems).sorted(by: areInIncreasingOrder).map { $0.key }
        for item in insertedItems.reversed() {
            guard let index = elementKeys.firstIndex(of: item.key) else { fatalError("Key not found") }
            insert(item, at: index)
        }
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        let elementKeys = items.map { $0.key }
        let deletedIndices = keys.compactMap { (key) -> Int? in
            guard let _key = key as? Key else { fatalError("Wrong key type") }
            guard let index = elementKeys.firstIndex(of: _key) else { return nil }
            return index
        }
        for index in deletedIndices.sorted().reversed() {
            remove(at: index)
        }
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        for _key in keys {
            let elementKeys = items.map { $0.key }
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let item = mapDataSource[key] else { fatalError("Item not found") }
            let currentIndex = elementKeys.firstIndex(of: key)
            let newElement = MapBasedDataSource<Key,Item>.Element(key: key, item: item)
            switch (currentIndex, isIncluded(newElement)) {
            case (.none, true):
                let newElementKeys = (items + [newElement]).sorted(by: areInIncreasingOrder).map { $0.key }
                let newIndex = newElementKeys.firstIndex(of: newElement.key)!
                insert(newElement, at: newIndex)
            case (.some(let index), false):
                remove(at: index)
            case (.some(let index), true):
                var _items = items
                _items.remove(at: index)
                let newElementKeys = (_items + [newElement]).sorted(by: areInIncreasingOrder).map { $0.key }
                let newIndex = newElementKeys.firstIndex(of: newElement.key)!
                if index == newIndex {
                    self[index] = newElement
                } else {
                    move(index, to: newIndex)
                }
            case (.none, false):
                break
            }
        }
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidReloadItems(_ dataSource: Any) { }
}

extension MapItemListDataSource where Key: Comparable {
    public convenience init(_ mapDataSource: MapBasedDataSource<Key, Item>, filteredBy isIncluded: @escaping (MapBasedDataSource<Key, Item>.Element) -> Bool = { _ in true }) {
        self.init(mapDataSource, filteredBy: isIncluded, sortedBy: { $0.key < $1.key })
    }
}
