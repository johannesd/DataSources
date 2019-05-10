//
//  DataSourceDelegating.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.02.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation
import Delegates

public protocol DataSourceDelegating: DataSource {
    var dataSourceDelegates: DataSourceDelegates { get set }
}

extension DataSourceDelegating {
    public func add<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        dataSourceDelegates.add(delegate, as: dataSourceDelegateType)
    }
    
    public func remove<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type) {
        dataSourceDelegates.remove(delegate, as: dataSourceDelegateType)
    }
    
    public func forEachDataSourceDelegate<DataSourceDelegate>(_ block: (DataSourceDelegate) -> Void) {
        dataSourceDelegates.forEachDataSourceDelegate(block)
    }
}
