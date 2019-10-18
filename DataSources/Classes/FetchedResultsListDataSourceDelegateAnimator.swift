//
//  FetchedResultsListDataSourceDelegateAnimator.swift
//  DataSources
//
//  Created by Johannes Dörr on 13.03.18.
//  Copyright © 2018 COYO. All rights reserved.
//

import Foundation
import CoreData
import Delegates

/**
 This class offers helper functions for calling update functions (insert/delete/move etc.)
 of a ListDataSourceDelegate fed by a `NSFetchedResultsController`.
 The class can be directly be used as a delegate of it.
 */
open class FetchedResultsListDataSourceDelegateAnimator: FetchedResultsAnimator {
    /**
     The data source object
     */
    public weak var dataSource: AnyObject?

    /**
     The DataSourceDelegates the update functions should be called of.
     */
    public let dataSourceDelegates = Delegates<ListDataSourceDelegate>()

    /**
     Converts the indexPaths of the FetchedResultsController to the indexPaths of the data source. If the
     data source delegate conforms to SectionedListDataSourceDelegate, sections are maintained (two indices).
     Otherwise, the indexPaths have only one index.
     */
    private func convert(_ indexPath: IndexPath, for dataSourceDelegate: ListDataSourceDelegate) -> IndexPath {
        if let _ = dataSourceDelegate as? SectionedListDataSourceDelegate {
            return indexPath
        } else {
            // Remove section from index path
            return indexPath.dropFirst()
        }
    }

    private func convert(_ index: Int, for dataSourceDelegate: ListDataSourceDelegate) -> Int {
        return convert(IndexPath(index: index), for: dataSourceDelegate).index
    }

    private func convert(_ indexSet: IndexSet, for dataSourceDelegate: ListDataSourceDelegate) -> IndexSet {
        return IndexSet(indexSet.map({ convert($0, for: dataSourceDelegate) }))
    }

    override func beginUpdates() {
        super.beginUpdates()
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSourceWillUpdateItems(dataSource)
        }
    }

    override func insertSection(_ section: NSFetchedResultsSectionInfo, at sectionIndex: Int) {
        super.insertSection(section, at: sectionIndex)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            if let dataSourceDelegate = dataSourceDelegate as? SectionedListDataSourceDelegate {
                dataSourceDelegate.dataSource(dataSource, didInsertSections: convert(IndexSet(integer: sectionIndex), for: dataSourceDelegate))
            }
        }
    }

    override func deleteSection(_ section: NSFetchedResultsSectionInfo, at sectionIndex: Int) {
        super.deleteSection(section, at: sectionIndex)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            if let dataSourceDelegate = dataSourceDelegate as? SectionedListDataSourceDelegate {
                dataSourceDelegate.dataSource(dataSource, didDeleteSections: convert(IndexSet(integer: sectionIndex), for: dataSourceDelegate))
            }
        }
    }

    override func insertObject(_ object: Any, at indexPath: IndexPath) {
        super.insertObject(object, at: indexPath)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource, didInsertItemsAtIndexPaths: [convert(indexPath, for: dataSourceDelegate)])
        }
    }

    override func deleteObject(_ object: Any, at indexPath: IndexPath) {
        super.deleteObject(object, at: indexPath)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource, didDeleteItemsAtIndexPaths: [convert(indexPath, for: dataSourceDelegate)])
        }
    }

    override func reloadObject(_ object: Any, at indexPathUpdate: IndexPathUpdate) {
        super.reloadObject(object, at: indexPathUpdate)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            let convertedIndexPath = IndexPathUpdate(old: convert(indexPathUpdate.oldIndexPath, for: dataSourceDelegate),
                                                     new: convert(indexPathUpdate.newIndexPath, for: dataSourceDelegate))
            dataSourceDelegate.dataSource(dataSource, didUpdateItemsAtIndexPaths: [convertedIndexPath])
        }
    }

    override func moveObject(_ object: Any, from fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        super.moveObject(object, from: fromIndexPath, to: toIndexPath)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource,
                                          didMoveItemAtIndexPath: convert(fromIndexPath, for: dataSourceDelegate),
                                          toIndexPath: convert(toIndexPath, for: dataSourceDelegate))
        }
    }

    override func endUpdates() {
        super.endUpdates()
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSourceDidUpdateItems(dataSource)
        }
    }

    override func reloadData() {
        super.reloadData()
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSourceDidReloadItems(dataSource)
        }
    }
}
