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
    
    public init(_ mapDataSource: MapBasedDataSource<Key, Item>, sortedBy areInIncreasingOrder: @escaping (MapDataSource.Element, MapDataSource.Element) -> Bool) {
        self.mapDataSource = mapDataSource
        self.areInIncreasingOrder = areInIncreasingOrder
        super.init()
        items = mapDataSource.elements.sorted(by: areInIncreasingOrder)
        mapDataSource.add(self, as: MapDataSourceDelegate.self)
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
        let insertedItems = keys.map({ (_key) -> MapDataSource.Element in
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let item = mapDataSource[key] else { fatalError("Item not found") }
            return .init(key: key, item: item)
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
        let deletedIndices = elementKeys.map { (key) -> Int in
            guard let index = elementKeys.firstIndex(of: key) else { fatalError("Key not found") }
            return index
        }
        for index in deletedIndices.reversed() {
            remove(at: index)
        }
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        let elementKeys = items.map { $0.key }
        for _key in keys {
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let item = mapDataSource[key] else { fatalError("Item not found") }
            guard let index = elementKeys.firstIndex(of: key) else { fatalError("Key not found") }
            self[index] = .init(key: key, item: item)
        }
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidReloadItems(_ dataSource: Any) { }
}

extension MapItemListDataSource where Key: Comparable {
    public convenience init(_ mapDataSource: MapBasedDataSource<Key, Item>) {
        self.init(mapDataSource, sortedBy: { $0.key < $1.key })
    }
}
