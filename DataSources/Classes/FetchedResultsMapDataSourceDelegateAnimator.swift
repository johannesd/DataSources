//
//  FetchedResultsMapDataSourceDelegateAnimator.swift
//  DataSources
//
//  Created by Johannes Dörr on 16.10.19.
//

import Foundation
import Delegates

/**
 This class offers helper functions for calling update functions (insert/delete etc.)
 of a MapDataSourceDelegate fed by a `NSFetchedResultsController`.
 The class can be directly be used as a delegate of it.
 */
open class FetchedResultsMapDataSourceDelegateAnimator: FetchedResultsAnimator {
    /**
     The data source object
     */
    public weak var dataSource: AnyObject?

    /**
     The DataSourceDelegates the update functions should be called of.
     */
    public let dataSourceDelegates = Delegates<MapDataSourceDelegate>()

    private var getKey: (Any) -> AnyHashable
    
    /**
     Initializes an instance of FetchedResultsDataSourceDelegateAnimator.
     - Parameter dataSource: The data source to pass to the calls to dataSourceDelegate.
     - Parameter dataSourceDelegate: The data source delegate to notify about the changes.
     - Parameter animate: Specifies if the the changes should be animated.
     */
    public init(getKey: @escaping (Any) -> AnyHashable, animate: Bool = true) {
        self.getKey = getKey
        super.init(animate: animate)
    }

    override func beginUpdates() {
        super.beginUpdates()
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSourceWillUpdateItems(dataSource)
        }
    }

    override func insertObject(_ object: Any, at indexPath: IndexPath) {
        super.insertObject(object, at: indexPath)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource, didInsertItemsForKeys: [getKey(object)])
        }
    }

    override func deleteObject(_ object: Any, at indexPath: IndexPath) {
        super.deleteObject(object, at: indexPath)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource, didDeleteItemsForKeys: [getKey(object)])
        }
    }

    override func reloadObject(_ object: Any, at indexPathUpdate: IndexPathUpdate) {
        super.reloadObject(object, at: indexPathUpdate)
        guard let dataSource = dataSource else { return }
        dataSourceDelegates.forEach { (dataSourceDelegate) in
            dataSourceDelegate.dataSource(dataSource, didUpdateItemsForKeys: [getKey(object)])
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
