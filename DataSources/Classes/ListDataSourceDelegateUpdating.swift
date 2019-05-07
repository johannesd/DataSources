//
//  ListDataSourceDelegateUpdating.swift
//  DataSources
//
//  Created by Johannes Dörr on 19.09.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

public protocol ListDataSourceDelegateUpdating: ListDataSourceDelegate {
    var isViewLoaded: Bool { get }
    
    /**
     Converts the indexPaths of the data source to the indexPaths of the tableView. By default,
     items are displayed in first section
     */
    func convert(_ indexPath: IndexPath, fromDataSource dataSource: Any) -> IndexPath
    
    func insert(at indexPaths: [IndexPath])
    func delete(at indexPaths: [IndexPath])
    func reload(at indexPaths: [IndexPath])
    func move(from indexPath: IndexPath, to newIndexPath: IndexPath)
    func performBatchUpdates(_ updates: (() -> Void), completion: ((Bool) -> Void)?)
    func reloadData()
    func select(at indexPath: IndexPath?)
    
    var selectedIndexPaths: [IndexPath]? { get }
}

fileprivate var indexPathsToReloadKey: Void?
fileprivate var indexPathsToSelectKey: Void?
fileprivate var changesToPerformKey: Void?
fileprivate var reloadUUIDKey: Void?
fileprivate var batchUpdateCompletionTaskKey: Void?
fileprivate var postponedUpdatesTaskKey: Void?
fileprivate var selectionTaskKey: Void?

public enum ListDataSourceChange {
    case insertSections(IndexSet)
    case deleteSections(IndexSet)
    case reloadSections(IndexSet)
    case moveSection(from: Int, to: Int)
    case insert([IndexPath])
    case delete([IndexPath])
    case reload([IndexPathUpdate])
    case move(from: IndexPath, to: IndexPath)
}

extension ListDataSourceDelegateUpdating {
    internal var indexPathsToReload: [IndexPath] {
        set {
            objc_setAssociatedObject(self, &indexPathsToReloadKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &indexPathsToReloadKey) as? [IndexPath]) ?? []
        }
    }
    
    internal var indexPathsToSelect: [IndexPath] {
        set {
            objc_setAssociatedObject(self, &indexPathsToSelectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &indexPathsToSelectKey) as? [IndexPath]) ?? []
        }
    }
    
    internal var changesToPerform: [ListDataSourceChange] {
        set {
            objc_setAssociatedObject(self, &changesToPerformKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &changesToPerformKey) as? [ListDataSourceChange]) ?? []
        }
    }

    internal var updateUUID: UUID? {
        set {
            objc_setAssociatedObject(self, &reloadUUIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &reloadUUIDKey) as? UUID)
        }
    }
    
    internal var batchUpdateCompletionTask: DispatchWorkItem? {
        set {
            objc_setAssociatedObject(self, &batchUpdateCompletionTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &batchUpdateCompletionTaskKey) as? DispatchWorkItem)
        }
    }

    internal var postponedUpdatesTask: DispatchWorkItem? {
        set {
            objc_setAssociatedObject(self, &postponedUpdatesTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &postponedUpdatesTaskKey) as? DispatchWorkItem)
        }
    }
    
    internal var selectionTask: DispatchWorkItem? {
        set {
            objc_setAssociatedObject(self, &selectionTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &selectionTaskKey) as? DispatchWorkItem) ?? nil
        }
    }

    public func convert(_ indexPath: IndexPath, fromDataSource dataSource: Any) -> IndexPath {
        return IndexPath(row: indexPath.index, section: 0)
    }
    
    func convert(_ indexPaths: [IndexPath], fromDataSource dataSource: Any) -> [IndexPath] {
        return indexPaths.map { convert($0, fromDataSource: dataSource) }
    }
    
    func convert(_ indexPaths: [IndexPathUpdate], fromDataSource dataSource: Any) -> [IndexPathUpdate] {
        return indexPaths.map { IndexPathUpdate(old: convert($0.oldIndexPath, fromDataSource: dataSource),
                                                new: convert($0.newIndexPath, fromDataSource: dataSource)) }
    }
    
    internal func perform(_ change: ListDataSourceChange, isAfterCompletion: Bool) {
        switch change {
        case .insertSections(let sectionIndices):
            (self as? SectionedListDataSourceDelegateUpdating)?.insertSections(sectionIndices)
        case .deleteSections(let sectionIndices):
            (self as? SectionedListDataSourceDelegateUpdating)?.deleteSections(sectionIndices)
        case .reloadSections(let sectionIndices):
            (self as? SectionedListDataSourceDelegateUpdating)?.reloadSections(sectionIndices)
        case .moveSection(let fromSectionIndex, let toSectionIndex):
            (self as? SectionedListDataSourceDelegateUpdating)?.moveSection(fromSectionIndex, toSection: toSectionIndex)
        case .insert(let indexPaths):
            insert(at: indexPaths)
        case .delete(let indexPaths):
            delete(at: indexPaths)
        case .reload(let indexPaths):
            reload(at: indexPaths.map { isAfterCompletion ? $0.newIndexPath : $0.oldIndexPath })
        case .move(let fromIndexPath, let toIndexPath):
            move(from: fromIndexPath, to: toIndexPath)
        }
    }
    
    public func dataSourceWillUpdateItems(_ dataSource: Any) {
        _dataSourceWillUpdateItems(dataSource)
    }
    
    public func dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath]) {
        _dataSource(dataSource, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        _dataSource(dataSource, didDeleteItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        _dataSource(dataSource, didUpdateItemsAtIndexPaths: indexPaths)
    }
    
    public func dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        _dataSource(dataSource, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
    }
    
    public func dataSourceDidUpdateItems(_ dataSource: Any) {
        _dataSourceDidUpdateItems(dataSource)
    }
    
    public func dataSourceDidReloadItems(_ dataSource: Any) {
        _dataSourceDidReloadItems(dataSource)
    }
    
    /*
     The following functions contain the actual implementation of the update functions above. If you
     create an own implementation of the above update functions in your class implementing `ListDataSourceDelegateUpdating`
     (because you want to perform extra work when the data source changes), make sure to call the respective function below.
     This can be see as calling the super implementation in the context of class inheritence. However, this concept is not
     available in Swift for generic protocols, so we have to use this workaround.
     */
    
    public func _dataSourceWillUpdateItems(_ dataSource: Any) {
        // Perform outstanding update tasks before starting a new update:
        self.batchUpdateCompletionTask?.perform()
        self.batchUpdateCompletionTask = nil
        self.postponedUpdatesTask?.perform()
        self.postponedUpdatesTask = nil
        self.selectionTask?.perform()
        self.selectionTask = nil
        
        // Set a new UUID to identify the update cycle:
        updateUUID = UUID()
        
        if isViewLoaded {
            indexPathsToReload = []
            indexPathsToSelect = []
            changesToPerform = []
        }
    }
    
    public func _dataSource(_ dataSource: Any, didInsertItemsAtIndexPaths indexPaths: [IndexPath]) {
        if isViewLoaded {
            let convertedIndexPaths = convert(indexPaths, fromDataSource: dataSource)
            changesToPerform.append(.insert(convertedIndexPaths))
        }
    }
    
    public func _dataSource(_ dataSource: Any, didDeleteItemsAtIndexPaths indexPaths: [IndexPath]) {
        if isViewLoaded {
            let convertedIndexPaths = convert(indexPaths, fromDataSource: dataSource)
            changesToPerform.append(.delete(convertedIndexPaths))
        }
    }
    
    public func _dataSource(_ dataSource: Any, didUpdateItemsAtIndexPaths indexPaths: [IndexPathUpdate]) {
        if isViewLoaded {
            let convertedIndexPaths = convert(indexPaths, fromDataSource: dataSource)
            changesToPerform.append(.reload(convertedIndexPaths))
            if let selectedIndexPaths = selectedIndexPaths {
                indexPathsToSelect.append(contentsOf: convertedIndexPaths.map({ $0.oldIndexPath }).filter({ selectedIndexPaths.contains($0) }))
            }
        }
    }
    
    public func _dataSource(_ dataSource: Any, didMoveItemAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        if isViewLoaded {
            let convertedFromIndexPath = convert(fromIndexPath, fromDataSource: dataSource)
            let convertedToIndexPath = convert(toIndexPath, fromDataSource: dataSource)
            changesToPerform.append(.move(from: convertedFromIndexPath, to: convertedToIndexPath))
            // Besides moving, the item also needs to be reloaded because the data has changed. UITableView does not allow
            // an item to be moved and reloaded in the same update transaction, which is why we will perform it directly
            // after the transaction:
            indexPathsToReload.append(convertedToIndexPath)
            if let selectedIndexPaths = selectedIndexPaths, selectedIndexPaths.contains(convertedFromIndexPath) {
                indexPathsToSelect.append(convertedToIndexPath)
            }
        }
    }
    
    public func _dataSourceDidUpdateItems(_ dataSource: Any) {
        if isViewLoaded {
            let isReload = { (change: ListDataSourceChange) -> Bool in
                switch change {
                case .reload:
                    return true
                case .insertSections, .deleteSections, .reloadSections, .moveSection, .insert, .delete, .move:
                    return false
                }
            }
            // Moving items in a collection or table view while also reloading other items leads to a lot of trouble.
            // For that reason, we perform those changes in two steps. First make all the other (non-update) changes,
            // and then perform the (postponed) updates.
            let reloads = changesToPerform.filter(isReload)
            let others = changesToPerform.filter { !isReload($0) }
            let changesToPerformDuringUpdate: [ListDataSourceChange]
            let reloadsToPerformOnCompletion: [ListDataSourceChange]
            if reloads.count != 0 && others.count != 0 {
                changesToPerformDuringUpdate = others
                reloadsToPerformOnCompletion = reloads
            } else {
                changesToPerformDuringUpdate = changesToPerform
                reloadsToPerformOnCompletion = []
            }
            let performUpdates = {
                changesToPerformDuringUpdate.forEach { self.perform($0, isAfterCompletion: false) }
            }
            
            // Remembering the UUID here allows us to check later, if a new update has alreday started
            // when the async blocks are executed.
            let updateUUID = self.updateUUID
            
            self.batchUpdateCompletionTask = DispatchWorkItem {
                let indexPathsToReload = self.indexPathsToReload
                let indexPathsToSelect = self.indexPathsToSelect
                self.selectionTask = DispatchWorkItem {
                    for row in indexPathsToSelect {
                        self.select(at: row)
                    }
                }
                if reloadsToPerformOnCompletion.count > 0 || indexPathsToReload.count > 0 {
                    self.postponedUpdatesTask = DispatchWorkItem {
                        self.performBatchUpdates({
                            reloadsToPerformOnCompletion.forEach { self.perform($0, isAfterCompletion: true) }
                            if indexPathsToReload.count > 0 {
                                self.reload(at: indexPathsToReload)
                            }
                        }, completion: { _ in
                            if updateUUID == self.updateUUID {
                                self.selectionTask?.perform()
                                self.selectionTask = nil
                            }
                        })
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if updateUUID == self.updateUUID {
                            self.postponedUpdatesTask?.perform()
                            self.postponedUpdatesTask = nil
                        }
                    }
                } else {
                    self.selectionTask?.perform()
                    self.selectionTask = nil
                }
                self.indexPathsToReload = []
                self.indexPathsToSelect = []
            }
            
            performBatchUpdates(performUpdates) { _ in
                if updateUUID == self.updateUUID {
                    self.batchUpdateCompletionTask?.perform()
                    self.batchUpdateCompletionTask = nil
                }
            }
        }
    }
    
    public func _dataSourceDidReloadItems(_ dataSource: Any) {
        reloadData()
    }
}
