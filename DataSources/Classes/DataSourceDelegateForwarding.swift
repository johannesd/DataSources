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
    
    /**
     Must be called by inheriting protocol and returned by its implementation of
     `destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate]`.
     - Discussion: A class can implement multiple protocols that inherit this protocol, like
     `ListDataSourceDelegateForwarding` together with `MapDataSourceDelegateForwarding`. Both protocols
     will add an implementation for `destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate]`,
     but only one will be called. In order to ensure both `ListDataSourceDelegateForwarding` and
     `MapDataSourceDelegateForwarding` to function, collecting their delegates has to be done
     here in the super protocol, instead of in the sub protocols. Otherwise, only one of them would work.
     */
    public func _destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate] {
        var dataSourceDelegates = [DataSourceDelegate]()
        if let _self = self as? ListDataSourceDelegateForwarding {
            dataSourceDelegates.append(contentsOf: _self.destinationDataSourceDelegates(for: dataSource) as [ListDataSourceDelegate])
        }
        if let _self = self as? SectionedListDataSourceDelegateForwarding {
            dataSourceDelegates.append(contentsOf: _self.destinationDataSourceDelegates(for: dataSource) as [SectionedListDataSourceDelegate])
        }
        if let _self = self as? MapDataSourceDelegateForwarding {
            dataSourceDelegates.append(contentsOf: _self.destinationDataSourceDelegates(for: dataSource) as [MapDataSourceDelegate])
        }
        return dataSourceDelegates
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
