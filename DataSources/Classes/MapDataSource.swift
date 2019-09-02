//
//  MapDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation
import Delegates

/**
 A data source that stores key/value pairs.
 */
public final class MapDataSource<Key, Item>: MapBasedDataSource<Key, Item>, ExpressibleByDictionaryLiteral where Key: Hashable {
    public var delegates = Delegates<MapDataSourceDelegate>()

    public typealias ListDataSource = MapItemListDataSource<Key, Item>
    
    public required init(dictionaryLiteral elements: (Key, Item)...) {
        super.init()
        elements.forEach { items[$0] = $1 }
    }
    
    public override init() {
        super.init()
    }
    
    public override func forEachDelegate(_ block: (MapDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}
