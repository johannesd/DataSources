//
//  DataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 21.05.19.
//

import Foundation

public protocol DataSourceDelegateForwarding {
    func destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate]
}

extension DataSourceDelegateForwarding {
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
     create an own implementation of the above update functions in your class implementing `DataSourceDelegateForwarding`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSourceWillUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSourceWillUpdateItems(self) }
    }
    
    public func _dataSourceDidUpdateItems(_ dataSource: Any) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSourceDidUpdateItems(self) }
    }
    
    public func _dataSourceDidReloadItems(_ dataSource: Any) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSourceDidReloadItems(self) }
    }
}
