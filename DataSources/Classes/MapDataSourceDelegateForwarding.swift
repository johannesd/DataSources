//
//  MapDataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 21.05.19.
//

import Foundation

public protocol MapDataSourceDelegateForwarding: DataSourceDelegateForwarding {
    func destinationDataSourceDelegates(for dataSource: Any) -> [MapDataSourceDelegate]

    /**
     Converts the keys of the data source to the keys of the destination data source.
     */
    func convert(_ key: AnyHashable, fromDataSource sourceDataSource: Any, toDataSourceDelegate dataSourceDelegate: MapDataSourceDelegate) -> AnyHashable
}

extension MapDataSourceDelegateForwarding {
    public func destinationDataSourceDelegates(for dataSource: Any) -> [DataSourceDelegate] {
        return _destinationDataSourceDelegates(for: dataSource)
    }

    public func convert(_ key: AnyHashable, fromDataSource dataSource: Any, toDataSourceDelegate dataSourceDelegate: MapDataSourceDelegate) -> AnyHashable {
        return key
    }
    
    func convert(_ keys: [AnyHashable], fromDataSource dataSource: Any, toDataSourceDelegate dataSourceDelegate: MapDataSourceDelegate) -> [AnyHashable] {
        return keys.map { convert($0, fromDataSource: dataSource, toDataSourceDelegate: dataSourceDelegate) }
    }
    
    public func dataSource(_ dataSource: Any, didInsertItemsForKeys keys: [AnyHashable]) {
        _dataSource(dataSource, didInsertItemsForKeys: keys)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsForKeys keys: [AnyHashable]) {
        _dataSource(dataSource, didDeleteItemsForKeys: keys)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable]) {
        _dataSource(dataSource, didUpdateItemsForKeys: keys)
    }
    
    /*
     The following functions contain the actual implementation of the update functions above. If you
     create an own implementation of the above update functions in your class implementing `MapDataSourceDelegateForwarding`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSource(_ dataSource: Any, didInsertItemsForKeys keys: [AnyHashable]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didInsertItemsForKeys: convert(keys, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteItemsForKeys keys: [AnyHashable]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didDeleteItemsForKeys: convert(keys, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateItemsForKeys keys: [AnyHashable]) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didUpdateItemsForKeys: convert(keys, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
}
