//
//  ListDataSourceDelegate.swift
//  DataSources
//
//  Created by Johannes Dörr on 01.03.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public struct IndexPathUpdate: Equatable {
    public var oldIndexPath: IndexPath
    public var newIndexPath: IndexPath
    
    public init(old oldIndexPath: IndexPath, new newIndexPath: IndexPath) {
        self.oldIndexPath = oldIndexPath
        self.newIndexPath = newIndexPath
    }
    
    public init(_ indexPath: IndexPath) {
        self.oldIndexPath = indexPath
        self.newIndexPath = indexPath
    }
}

/**
 This protocol allows a data source, that contains a list, to notify the consumer about changes in the data.
 */
public protocol ListDataSourceDelegate: class {
    func dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath])
    func dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath])
    func dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate])
    
    // Note that the move of an item implies that is has been updated
    func dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath)
    
    func dataSourceWillUpdateItems(_ dataSource: Any)
    func dataSourceDidUpdateItems(_ dataSource: Any)
    
    func dataSourceDidReloadItems(_ dataSource: Any)
}
