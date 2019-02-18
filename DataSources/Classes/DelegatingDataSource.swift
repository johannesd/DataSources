//
//  DelegatingDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.02.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol DelegatingDataSource: AnyObject {
    func add<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type)
    func remove<Delegate>(_ delegate: Delegate, as dataSourceDelegateType: Delegate.Type)
}
