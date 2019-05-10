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
public final class MapDataSource<Key, Value>: MapBasedDataSource<Key, Value>, ExpressibleByDictionaryLiteral where Key: Hashable {
    public var delegates = Delegates<MapDataSourceDelegate>()

    public typealias ListDataSource = MapItemListDataSource<Key, Value>
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        super.init()
        elements.forEach { values[$0] = $1 }
    }
    
    public override func forEachDelegate(_ block: (MapDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}
