//
//  ListDataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 18.11.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol ListDataSourceDelegateForwarding: DataSourceDelegateForwarding {
    func destinationDataSourceDelegates(for dataSource: Any) -> [ListDataSourceDelegate]
}

extension ListDataSourceDelegateForwarding {
    public func destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate] {
        return _destinationDataSourceDelegates(for: dataSource)
    }

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
    
    /*
     The following functions contain the actual implementation of the update functions above. If you
     create an own implementation of the above update functions in your class implementing `ListDataSourceDelegateForwarding`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didInsertItemsAtIndexPaths: indexPaths) }
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths) }
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didUpdateItemsAtIndexPaths: indexPaths) }
    }
    
    public func _dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath) }
    }
}
