//
//  ListDataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 18.11.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol ListDataSourceDelegateForwarding: ListDataSourceDelegate {
    func destinationDataSourceDelegate(for dataSource: Any) -> ListDataSourceDelegate?
}

extension ListDataSourceDelegateForwarding {
    public func dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didUpdateItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceWillUpdateItems(self)
    }
    
    public func dataSourceDidUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceDidUpdateItems(self)
    }
    
    public func dataSourceDidReloadItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceDidReloadItems(self)
    }
}
