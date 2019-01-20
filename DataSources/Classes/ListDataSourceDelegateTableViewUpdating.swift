//
//  ListDataSourceDelegateTableViewUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

/**
 Conforming to `ListDataSourceDelegateTableViewUpdating` provides conformance to `ListDataSourceDelegate`
 with the addition that the underlying tableView will be updated automatically.
 - Note: This protocol is typically used with a UITableViewController subclass in order to update the
 tableView automatically when the data source changes.
 */
public protocol ListDataSourceDelegateTableViewUpdating: ListDataSourceDelegateUpdating {
    associatedtype TableView: UITableView
    
    /**
     The tableView that should be updated
     */
    var tableView: TableView! { get }
}

extension ListDataSourceDelegateTableViewUpdating {
    public func insert(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    
    public func delete(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    public func reload(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    public func move(from indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableView.moveRow(at: indexPath, to: newIndexPath)
    }
    
    public func performBatchUpdates(_ updates: (() -> Void), completion: ((Bool) -> Void)?) {
        tableView.performBatchUpdates(updates, completion: completion)
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func select(at indexPath: IndexPath?) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
 
    public var selectedIndexPaths: [IndexPath]? {
        return tableView.indexPathsForSelectedRows
    }
}
