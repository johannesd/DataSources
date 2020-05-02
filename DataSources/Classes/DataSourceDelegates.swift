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
    
    public func allDataSourceDelegates<Delegate>(ofType type: Delegate.Type) -> [Delegate] {
        let key = "\(type)"
        let delegatesForType = self[key, default: DataSourceDelegates.Value()]
        return delegatesForType.allObjects.map { $0 as! Delegate }
    }
    
    public func anyDataSourceDelegate<DataSourceDelegate>(_ block: (DataSourceDelegate) -> Bool) -> Bool {
        let key = "\(DataSourceDelegate.self)"
        let delegatesForType = self[key, default: DataSourceDelegates.Value()]
        return delegatesForType.any({ delegate in block(delegate as! DataSourceDelegate) })
    }
    
    public func allDataSourceDelegates<DataSourceDelegate>(_ block: (DataSourceDelegate) -> Bool) -> Bool {
        let key = "\(DataSourceDelegate.self)"
        let delegatesForType = self[key, default: DataSourceDelegates.Value()]
        return delegatesForType.all({ delegate in block(delegate as! DataSourceDelegate) })
    }
}
