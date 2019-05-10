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
public final class ListDataSource<Element>: ListBasedDataSource<Element>, ExpressibleByArrayLiteral {
    public var delegates = Delegates<ListDataSourceDelegate>()
    
    public required init(arrayLiteral elements: Element...) {
        super.init()
        self.elements = elements
    }
    
    public override func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}
