//
//  SectionedListDataSourceDelegateForwarding.swift
//  DataSources
//
//  Created by Johannes Dörr on 18.11.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol SectionedListDataSourceDelegateForwarding: ListDataSourceDelegateForwarding {
    func destinationDataSourceDelegates(for dataSource: Any) -> [SectionedListDataSourceDelegate]
}

extension SectionedListDataSourceDelegateForwarding {
    public func destinationDataSourceDelegates(for dataSource: Any) -> [ListDataSourceDelegate] {
        return destinationDataSourceDelegates(for: dataSource) as [SectionedListDataSourceDelegate]
    }
    
    func convert(_ index: Int, fromDataSource dataSource: Any, toDataSourceDelegate dataSourceDelegate: ListDataSourceDelegate) -> Int {
        return convert(IndexPath(index: index), fromDataSource: dataSource, toDataSourceDelegate: dataSourceDelegate).index
    }
    
    func convert(_ indexSet: IndexSet, fromDataSource dataSource: Any, toDataSourceDelegate dataSourceDelegate: ListDataSourceDelegate) -> IndexSet {
        return IndexSet(indexSet.map({ convert($0, fromDataSource: dataSource, toDataSourceDelegate: dataSourceDelegate) }))
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
     create an own implementation of the above update functions in your class implementing `SectionedListDataSourceDelegateForwarding`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSource(_ dataSource: Any, didInsertSections sectionIndices: IndexSet) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didInsertSections: convert(sectionIndices, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteSections sectionIndices: IndexSet) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didDeleteSections: convert(sectionIndices, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateSections sectionIndices: IndexSet) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self, didUpdateSections: convert(sectionIndices, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
    
    public func _dataSource(_ dataSource: Any, didMoveSection fromSectionIndex: Int, to toSectionIndex: Int) {
        destinationDataSourceDelegates(for: dataSource).forEach { $0.dataSource(self,
                                                                                didMoveSection: convert(fromSectionIndex, fromDataSource: dataSource, toDataSourceDelegate: $0),
                                                                                to: convert(toSectionIndex, fromDataSource: dataSource, toDataSourceDelegate: $0)) }
    }
}
