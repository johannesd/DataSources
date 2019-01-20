//
//  SectionedListDataSourceDelegateCollectionViewUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 19.09.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

/**
 Conforming to `SectionedListDataSourceDelegateCollectionViewUpdating` provides conformance to `SectionedListDataSourceDelegate`
 with the addition that the underlying collectionView will be updated automatically.
 - Note: This protocol is typically used with a UICollectionViewController subclass in order to update the
 collectionView automatically when the data source changes.
 */
public protocol SectionedListDataSourceDelegateCollectionViewUpdating: ListDataSourceDelegateCollectionViewUpdating, SectionedListDataSourceDelegateUpdating {}

extension SectionedListDataSourceDelegateCollectionViewUpdating {
    public func insertSections(_ sections: IndexSet) {
        collectionView?.insertSections(sections)
    }
    
    public func deleteSections(_ sections: IndexSet) {
        collectionView?.deleteSections(sections)
    }
    
    public func reloadSections(_ sections: IndexSet) {
        collectionView?.reloadSections(sections)
    }
    
    public func moveSection(_ section: Int, toSection newSection: Int) {
        collectionView?.moveSection(section, toSection: newSection)
    }
}
