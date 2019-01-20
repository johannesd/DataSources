//
//  SectionedListDataSourceDelegateTableViewUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

/**
 Conforming to `SectionedListDataSourceDelegateTableViewUpdating` provides conformance to `SectionedListDataSourceDelegate`
 with the addition that the underlying tableView will be updated automatically.
 - Note: This protocol is typically used with a UITableViewController subclass in order to update the
 tableView automatically when the data source changes.
 */
public protocol SectionedListDataSourceDelegateTableViewUpdating: ListDataSourceDelegateTableViewUpdating, SectionedListDataSourceDelegateUpdating { }

extension SectionedListDataSourceDelegateTableViewUpdating {
    public func insertSections(_ sections: IndexSet) {
        tableView.insertSections(sections, with: .fade)
    }
    
    public func deleteSections(_ sections: IndexSet) {
        tableView.deleteSections(sections, with: .fade)
    }
    
    public func reloadSections(_ sections: IndexSet) {
        tableView.reloadSections(sections, with: .fade)
    }
    
    public func moveSection(_ section: Int, toSection newSection: Int) {
        tableView.moveSection(section, toSection: newSection)
    }
}
