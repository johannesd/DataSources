//
//  DataSourceDelegates.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.02.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation
import Delegates

public typealias DataSourceDelegates = Dictionary<String, Delegates<AnyObject>>

extension Dictionary where Key == String, Value == Delegates<AnyObject> {
    public mutating func add<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        let key = "\(dataSourceDelegateType)"
        let delegatesForType = self[key, default: DataSourceDelegates.Value()]
        delegatesForType.add(delegate as AnyObject)
        self[key] = delegatesForType
    }
    
    public func remove<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        let key = "\(dataSourceDelegateType)"
        self[key]?.remove(delegate as AnyObject)
    }
    
    public func forEachDataSourceDelegate<DataSourceDelegate>(_ block: (DataSourceDelegate) -> Void) {
        let key = "\(DataSourceDelegate.self)"
        let delegatesForType = self[key, default: DataSourceDelegates.Value()]
        delegatesForType.forEach { (delegate) in
            block(delegate as! DataSourceDelegate)
        }
    }
}
