//
//  SectionedListDataSourceDelegate.swift
//  DataSources
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

/**
 This protocol allows a data source, that contains a list with sections, to notify the consumer about changes in the data.
 */
public protocol SectionedListDataSourceDelegate: ListDataSourceDelegate {
    func dataSource(_ dataSource: Any, didInsertSections sectionIndices: IndexSet)
    func dataSource(_ dataSource: Any, didDeleteSections sectionIndices: IndexSet)
    func dataSource(_ dataSource: Any, didUpdateSections sectionIndices: IndexSet)
    func dataSource(_ dataSource: Any, didMoveSection fromSectionIndex: Int, to toSectionIndex: Int)
}
