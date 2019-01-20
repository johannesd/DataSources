//
//  SectionedListDataSourceDelegateUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 19.09.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol SectionedListDataSourceDelegateUpdating: ListDataSourceDelegateUpdating, SectionedListDataSourceDelegate {
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
}

extension SectionedListDataSourceDelegateUpdating {
    public func convert(_ indexPath: IndexPath, fromDataSource dataSource: Any) -> IndexPath {
        return indexPath
    }
    
    func convert(_ index: Int, fromDataSource dataSource: Any) -> Int {
        return convert(IndexPath(index: index), fromDataSource: dataSource).index
    }
    
    func convert(_ indexSet: IndexSet, fromDataSource dataSource: Any) -> IndexSet {
        return IndexSet(indexSet.map({ convert($0, fromDataSource: dataSource) }))
    }
    
    public func dataSource(_ dataSource: Any, didInsertSections sectionIndices: IndexSet) {
        _dataSource(dataSource, didInsertSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteSections sectionIndices: IndexSet) {
        _dataSource(dataSource, didDeleteSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateSections sectionIndices: IndexSet) {
        _dataSource(dataSource, didUpdateSections: sectionIndices)
    }
    
    public func dataSource(_ dataSource: Any, didMoveSection fromSectionIndex: Int, to toSectionIndex: Int) {
        _dataSource(dataSource, didMoveSection: fromSectionIndex, to: toSectionIndex)
    }
    
    /*
     The following functions contain the actual implementation of the update functions above. If you
     create an own implementation of the above update functions in your class implementing SectionedListDataSourceDelegateUpdating
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSource(_ dataSource: Any, didInsertSections sectionIndices: IndexSet) {
        if isViewLoaded {
            let convertedIndices = convert(sectionIndices, fromDataSource: dataSource)
            changesToPerform.append(.insertSections(convertedIndices))
        }
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteSections sectionIndices: IndexSet) {
        if isViewLoaded {
            let convertedIndices = convert(sectionIndices, fromDataSource: dataSource)
            changesToPerform.append(.deleteSections(convertedIndices))
        }
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateSections sectionIndices: IndexSet) {
        if isViewLoaded {
            let convertedIndices = convert(sectionIndices, fromDataSource: dataSource)
            changesToPerform.append(.reloadSections(convertedIndices))
        }
    }
    
    public func _dataSource(_ dataSource: Any, didMoveSection fromSectionIndex: Int, to toSectionIndex: Int) {
        if isViewLoaded {
            let convertedFromSectionIndex = convert(fromSectionIndex, fromDataSource: dataSource)
            let convertedToSectionIndex = convert(toSectionIndex, fromDataSource: dataSource)
            changesToPerform.append(.moveSection(from: convertedFromSectionIndex, to: convertedToSectionIndex))
        }
    }
}
