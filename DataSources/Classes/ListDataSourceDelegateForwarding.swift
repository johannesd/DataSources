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
        _dataSource(dataSource, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        _dataSource(dataSource, didDeleteItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        _dataSource(dataSource, didUpdateItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        _dataSource(dataSource, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) {
        _dataSourceWillUpdateItems(dataSource)
    }
    
    public func dataSourceDidUpdateItems(_ dataSource: Any) {
        _dataSourceDidUpdateItems(dataSource)
    }
    
    public func dataSourceDidReloadItems(_ dataSource: Any) {
        _dataSourceDidReloadItems(dataSource)
    }
    
    /*
     The following functions contain the actual implementation of the update functions above. If you
     create an own implementation of the above update functions in your class implementing `ListDataSourceDelegateForwarding`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */

    public func _dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths)
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didUpdateItemsAtIndexPaths: indexPaths)
    }
    
    public func _dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
    }
    
    public func _dataSourceWillUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceWillUpdateItems(self)
    }
    
    public func _dataSourceDidUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceDidUpdateItems(self)
    }
    
    public func _dataSourceDidReloadItems(_ dataSource: Any) {
        destinationDataSourceDelegate(for: dataSource)?.dataSourceDidReloadItems(self)
    }
}
