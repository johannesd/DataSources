//
//  SectionedListDataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 18.11.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol SectionedListDataSourceDelegateForwarding: ListDataSourceDelegateForwarding {
    func destinationDataSourceDelegate(for dataSource: Any) -> SectionedListDataSourceDelegate?
}

extension SectionedListDataSourceDelegateForwarding {
    public func destinationDataSourceDelegate(for dataSource: Any) -> ListDataSourceDelegate? {
        return destinationDataSourceDelegate(for: dataSource)
    }
    
    public func dataSource(_ dataSource: Any, didInsertSections sectionIndices: IndexSet) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didInsertSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteSections sectionIndices: IndexSet) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didDeleteSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateSections sectionIndices: IndexSet) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didUpdateSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didMoveSection fromSectionIndex: Int, to toSectionIndex: Int) {
        destinationDataSourceDelegate(for: dataSource)?.dataSource(self, didMoveSection: fromSectionIndex, to: toSectionIndex)
    }
}
