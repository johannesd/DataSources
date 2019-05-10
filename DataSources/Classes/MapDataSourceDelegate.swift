//
//  MapDataSourceDelegate.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation

/**
 This protocol allows a data source, that contains a keyed map, to notify the consumer about changes in the data.
 */
public protocol MapDataSourceDelegate: DataSourceDelegate {
    func dataSource(_ dataSource: Any, didInsertItemsForKeys keys: [AnyHashable])
    func dataSource(_ dataSource: Any, didDeleteItemsForKeys keys: [AnyHashable])
    func dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable])
}
