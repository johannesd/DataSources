//
//  ListDataSourceDelegateCollectionViewUpdater.swift
//  DataSources
//
//  Created by Johannes Dörr on 20.01.19.
//

import Foundation

public class ListDataSourceDelegateCollectionViewUpdater {
    public var collectionView: UICollectionView?
    
    public init(collectionView: UICollectionView?) {
        self.collectionView = collectionView
    }
}

extension ListDataSourceDelegateCollectionViewUpdater: ListDataSourceDelegateCollectionViewUpdating {
    public var isViewLoaded: Bool {
        return collectionView != nil
    }
}
