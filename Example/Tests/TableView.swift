//
//  TableView.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import UIKit

/**
 TableView that can track calls to its functions.
 */
class TableView: UITableView {

    /**
     Will keep track of the calls to beginUpdates, insertRows(at:, with:) etc.
     */
    var calledFunctions = [CallSignature]()

    func beginUpdates() -> CallSignature {
        return (date: Date(), identifier: "beginUpdates()")
    }

    override func beginUpdates() {
        calledFunctions.append(beginUpdates())
        super.beginUpdates()
    }

    func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) -> CallSignature {
        return (date: Date(), identifier: "insertSections(\(sections.stringRepresentation), with: \(animation.rawValue))")
    }

    override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        calledFunctions.append(insertSections(sections, with: animation))
        super.insertSections(sections, with: animation)
    }

    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) -> CallSignature {
        return (date: Date(), identifier: "deleteSections(\(sections.stringRepresentation), with: \(animation.rawValue))")
    }

    override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        calledFunctions.append(deleteSections(sections, with: animation))
        super.deleteSections(sections, with: animation)
    }

    func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) -> CallSignature {
        return (date: Date(), identifier: "insertRows(at: \(indexPaths), with: \(animation.rawValue))")
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        calledFunctions.append(insertRows(at: indexPaths, with: animation))
        super.insertRows(at: indexPaths, with: animation)
    }

    func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) -> CallSignature {
        return (date: Date(), identifier: "deleteRows(at: \(indexPaths), with: \(animation.rawValue))")
    }

    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        calledFunctions.append(deleteRows(at: indexPaths, with: animation))
        super.deleteRows(at: indexPaths, with: animation)
    }

    func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) -> CallSignature {
        return (date: Date(), identifier: "reloadRows(at: \(indexPaths), with: \(animation.rawValue))")
    }

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        calledFunctions.append(reloadRows(at: indexPaths, with: animation))
        super.reloadRows(at: indexPaths, with: animation)
    }

    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) -> CallSignature {
        return (date: Date(), identifier: "moveRow(at: \(indexPath), to: \(newIndexPath))")
    }

    override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        calledFunctions.append(moveRow(at: indexPath, to: newIndexPath))
        super.moveRow(at: indexPath, to: newIndexPath)
    }

    func endUpdates() -> CallSignature {
        return (date: Date(), identifier: "endUpdates()")
    }

    override func endUpdates() {
        calledFunctions.append(endUpdates())
        super.endUpdates()
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.performBatchUpdates(updates, completion: completion)
        calledFunctions.append(endUpdates())
    }

    func reloadData() -> CallSignature {
        return (date: Date(), identifier: "reloadData()")
    }

    override func reloadData() {
        calledFunctions.append(reloadData())
        super.reloadData()
    }

    func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) -> CallSignature {
        return (date: Date(), identifier: "selectRow(at: \(indexPath?.debugDescription ?? "nil"), animated: \(animated), scrollPosition: \(scrollPosition)")
    }

    override func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        calledFunctions.append(selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition))
        super.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

}
