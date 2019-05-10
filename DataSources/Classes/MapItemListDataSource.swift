//
//  MapItemsDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation
import Delegates

// TODO: This should subclass of a ListBasedDataSource that is readonly from outside

/**
 A data source that provides the items of a `MapDataSource` as a sorted list.
 */
public final class MapItemListDataSource<Key, Value>: ReadonlyListBasedDataSource<MapBasedDataSource<Key, Value>.Item> where Key: Hashable {
    public var delegates = Delegates<ListDataSourceDelegate>()
    public typealias MapDataSource = MapBasedDataSource<Key, Value>
    public private(set) var mapDataSource: MapDataSource
    private let areInIncreasingOrder: (MapDataSource.Item, MapDataSource.Item) -> Bool
    
    public init(_ mapDataSource: MapBasedDataSource<Key, Value>, sortedBy areInIncreasingOrder: @escaping (MapDataSource.Item, MapDataSource.Item) -> Bool) {
        self.mapDataSource = mapDataSource
        self.areInIncreasingOrder = areInIncreasingOrder
        super.init()
        elements = mapDataSource.items.sorted(by: areInIncreasingOrder)
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
        let insertedItems = keys.map({ (_key) -> MapDataSource.Item in
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let value = mapDataSource[key] else { fatalError("Value not found") }
            return .init(key: key, value: value)
        }).sorted(by: areInIncreasingOrder)
        let elementKeys = (elements + insertedItems).sorted(by: areInIncreasingOrder).map { $0.key }
        for item in insertedItems.reversed() {
            guard let index = elementKeys.index(of: item.key) else { fatalError("Key not found") }
            insert(item, at: index)
        }
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        let elementKeys = elements.map { $0.key }
        let deletedKeys = keys.map({ (_key) -> MapDataSource.Item in
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let value = mapDataSource[key] else { fatalError("Value not found") }
            return .init(key: key, value: value)
        }).sorted(by: areInIncreasingOrder).map({ $0.key })
        for key in deletedKeys.reversed() {
            guard let index = elementKeys.index(of: key) else { fatalError("Key not found") }
            remove(at: index)
        }
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable]) {
        // TODO: This produces an independent update for each key, but should only
        // create one update, so that animations won't break. See TODO at top of file.
        let elementKeys = elements.map { $0.key }
        for _key in keys {
            guard let key = _key as? Key else { fatalError("Wrong key type") }
            guard let value = mapDataSource[key] else { fatalError("Value not found") }
            guard let index = elementKeys.index(of: key) else { fatalError("Key not found") }
            self[index] = .init(key: key, value: value)
        }
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidUpdateItems(_ dataSource: Any) { }
    public func dataSourceDidReloadItems(_ dataSource: Any) { }
}

extension MapItemListDataSource where Key: Comparable {
    public convenience init(_ mapDataSource: MapBasedDataSource<Key, Value>) {
        self.init(mapDataSource, sortedBy: { $0.key < $1.key })
    }
}
