//
//  ListDataSourceDelegateTableViewUpdater.swift
//  DataSources
//
//  Created by Johannes Dörr on 20.01.19.
//

import Foundation

public class ListDataSourceDelegateTableViewUpdater {
    public var tableView: UITableView!
    
    public init(tableView: UITableView!) {
        self.tableView = tableView
    }
}

extension ListDataSourceDelegateTableViewUpdater: ListDataSourceDelegateTableViewUpdating {
    public var isViewLoaded: Bool {
        return tableView != nil
    }
}
