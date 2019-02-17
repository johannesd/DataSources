//
//  TableViewController.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 12.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

class TableViewController {

    let tableView: UITableView! = TableView()
    let tableViewDataSource = TableViewDataSource()

    var isViewLoaded: Bool = true

    init() {
        tableView.dataSource = tableViewDataSource
    }

}
