//
//  DataSourceDelegate.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//  Copyright © 2019 Johannes Dörr. All rights reserved.
//

import Foundation

/**
 This protocol allows a data source to notify the consumer about changes in the data.
 */
public protocol DataSourceDelegate: class {
    func dataSourceWillUpdateItems(_ dataSource: Any)
    func dataSourceDidUpdateItems(_ dataSource: Any)
    func dataSourceDidReloadItems(_ dataSource: Any)
}
