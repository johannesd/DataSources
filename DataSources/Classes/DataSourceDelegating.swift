//
//  DataSourceDelegating.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.02.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation
import Delegates

public protocol DataSourceDelegating: DelegatingDataSource {
    var dataSourceDelegates: DataSourceDelegates { get set }
}

extension DataSourceDelegating {
    public func add<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        let key = "\(dataSourceDelegateType)"
        let delegatesForType = dataSourceDelegates[key, default: DataSourceDelegates.Value()]
        delegatesForType.add(delegate as AnyObject)
        dataSourceDelegates[key] = delegatesForType
    }
    
    public func remove<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        let key = "\(dataSourceDelegateType)"
        dataSourceDelegates[key]?.remove(delegate as AnyObject)
    }
    
    public func forEachDataSourceDelegate<DataSourceDelegate>(block: (DataSourceDelegate) -> Void) {
        let key = "\(DataSourceDelegate.self)"
        let delegatesForType = dataSourceDelegates[key, default: DataSourceDelegates.Value()]
        delegatesForType.forEach { (delegate) in
            block(delegate as! DataSourceDelegate)
        }
    }
}
