//
//  FetchedResultsAnimator.swift
//  DataSources
//
//  Created by Johannes Dörr on 13.03.18.
//  Copyright © 2018 COYO. All rights reserved.
//

import UIKit
import CoreData

/**
 Informs the delegate about the update process
 */
public protocol FetchedResultsAnimatorDelegate: AnyObject {
    func fetchedResultsAnimatorWillUpdate(_ animator: FetchedResultsAnimator)
    func fetchedResultsAnimatorDidUpdate(_ animator: FetchedResultsAnimator)
}

extension FetchedResultsAnimatorDelegate {
    public func fetchedResultsAnimatorWillUpdate(_ animator: FetchedResultsAnimator) { }
    public func fetchedResultsAnimatorDidUpdate(_ animator: FetchedResultsAnimator) { }
}

/**
 This class offers helper functions for animating content updates (insert/delete/move etc.)
 triggered by a `NSFetchedResultsController`. This class is abstract. Use the appropriate
 subclasses. Those can be directly be used as a delegate of `NSFetchedResultsController`.
 */
open class FetchedResultsAnimator: NSObject {
    /**
     Specifies if the changes should be animated (i.e. if the update functions
     for insertions/deletions etc. should be used instead of a simple reloadData).
     */
    public let animate: Bool

    public weak var delegate: FetchedResultsAnimatorDelegate?

    /**
     Initializes an instance of FetchedResultsAnimator.
     - Parameter animate: Specifies if the the changes should be animated.
     */
    public init(animate: Bool = true) {
        self.animate = animate
        super.init()
    }

    /**
     Handles the start of batched updates.
     */
    public func handleWillChangeContent() {
        if animate {
            beginUpdates()
        }
    }

    /**
     Handles section updates.
     */
    public func handle(didChangeSection section: NSFetchedResultsSectionInfo, at sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if animate {
            switch type {
            case .insert:
                insertSection(section, at: sectionIndex)
            case .delete:
                deleteSection(section, at: sectionIndex)
            case .move:
                break
            case .update:
                break
            @unknown default:
                break
            }
        }
    }

    /**
     Handles object updates.
     */
    public func handle(didChangeObject object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if animate {
            switch type {
            case .insert:
                insertObject(object, at: newIndexPath!)
            case .delete:
                deleteObject(object, at: indexPath!)
            case .update:
                reloadObject(object, at: IndexPathUpdate(old: indexPath!, new: newIndexPath!))
            case .move:
                moveObject(object, from: indexPath!, to: newIndexPath!)
            @unknown default:
                break
            }
        }
    }

    /**
     Handles the end of batched updates.
     */
    public func handleDidChangeContent() {
        if animate {
            endUpdates()
        } else {
            reloadData()
        }
    }

    func beginUpdates() {
        delegate?.fetchedResultsAnimatorWillUpdate(self)
    }

    func insertSection(_ section: NSFetchedResultsSectionInfo, at sectionIndex: Int) {

    }

    func deleteSection(_ section: NSFetchedResultsSectionInfo, at sectionIndex: Int) {

    }

    func insertObject(_ object: Any, at indexPath: IndexPath) {

    }

    func deleteObject(_ object: Any, at indexPath: IndexPath) {

    }

    func reloadObject(_ object: Any, at indexPathUpdate: IndexPathUpdate) {

    }

    func moveObject(_ object: Any, from fromIndexPath: IndexPath, to toIndexPath: IndexPath) {

    }

    func endUpdates() {
        delegate?.fetchedResultsAnimatorDidUpdate(self)
    }

    func reloadData() {
        delegate?.fetchedResultsAnimatorWillUpdate(self)
        delegate?.fetchedResultsAnimatorDidUpdate(self)
    }
}

extension FetchedResultsAnimator: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleWillChangeContent()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        handle(didChangeSection: sectionInfo, at: sectionIndex, for: type)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        handle(didChangeObject: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleDidChangeContent()
    }
}
