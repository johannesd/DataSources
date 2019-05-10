//
//  ListDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation
import Delegates

/**
 A data source that stores a list.
 */
public final class ListDataSource<Item>: ListBasedDataSource<Item>, ExpressibleByArrayLiteral {
    public var delegates = Delegates<ListDataSourceDelegate>()
    
    public required init(arrayLiteral items: Item...) {
        super.init()
        self.items = items
    }
    
    public override func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}
