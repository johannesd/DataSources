//
//  ListDataSourceDelegateCollectionViewUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 19.09.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

/**
 Conforming to `ListDataSourceDelegateCollectionViewUpdating` provides conformance to `ListDataSourceDelegate`
 with the addition that the underlying collectionView will be updated automatically.
 - Note: This protocol is typically used with a UICollectionViewController subclass in order to update the
 collectionView automatically when the data source changes.
 */
public protocol ListDataSourceDelegateCollectionViewUpdating: ListDataSourceDelegateUpdating {
    associatedtype CollectionView: UICollectionView
    
    /**
     The collectionView that should be updated
     */
    var collectionView: CollectionView! { get }
}

extension ListDataSourceDelegateCollectionViewUpdating {
    public func insert(at indexPaths: [IndexPath]) {
        collectionView.insertItems(at: indexPaths)
    }
    
    public func delete(at indexPaths: [IndexPath]) {
        collectionView.deleteItems(at: indexPaths)
    }
    
    public func reload(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
    public func move(from indexPath: IndexPath, to newIndexPath: IndexPath) {
        collectionView.moveItem(at: indexPath, to: indexPath)
    }
    
    public func performBatchUpdates(_ updates: (() -> Void), completion: ((Bool) -> Void)?) {
        collectionView.performBatchUpdates(updates, completion: completion)
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    public func select(at indexPath: IndexPath?) {
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
    
    public var selectedIndexPaths: [IndexPath]? {
        return collectionView.indexPathsForSelectedItems
    }
}
