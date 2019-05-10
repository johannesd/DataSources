//
//  DataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.02.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation

/**
 This protocol is the base for a data source that can be observed using a DataSourceDelegate
 - Discussion: The `Delegate` type parameter should be limited to `DataSourceDelegate`, but
 this is not possible in Swift currently.
 */
public protocol DataSource: AnyObject {
    func add<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type)
    func remove<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type)
}
