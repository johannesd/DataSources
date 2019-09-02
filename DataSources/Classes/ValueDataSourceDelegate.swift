//
//  ValueDataSourceDelegate.swift
//  DataSources
//
//  Created by Johannes Dörr on 01.09.19.
//

import Foundation

/**
 This protocol allows a data source, that contains a value, to notify the consumer about changes in the data.
 */
public protocol ValueDataSourceDelegate {
    func dataSourceWillUpdateValue(_ dataSource: Any)
    func dataSourceDidUpdateValue(_ dataSource: Any)
}

extension ValueDataSourceDelegate {
    public func dataSourceWillUpdateValue(_ dataSource: Any) { }
}
