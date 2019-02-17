//
//  SectionedListDataSourceDelegateTableViewUpdaterTests.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import DataSources

class SectionedListDataSourceDelegateTableViewUpdaterTests: XCTestCase {

    class DummyTableViewController: TableViewController, SectionedListDataSourceDelegateTableViewUpdating { }

    var tableViewController: DummyTableViewController!

    override func setUp() {
        super.setUp()
        tableViewController = DummyTableViewController()
    }

    override func tearDown() {
        super.tearDown()
        tableViewController = nil
    }

    /*
     These tests are the same as in `ListDataSourceDelegateTableViewUpdaterTests`, with the difference that
     the `IndexPaths` include two indices (section and row), and not only one index.
     */

    func testDidInsertItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let newIndexPaths = [IndexPath(row: 0, section: 0)]
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["B", "-"]]
        tableViewController.dataSource(dataSource, didInsertItemsAtIndexPaths: newIndexPaths)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.insertRows(at: newIndexPaths, with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidDeleteItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let deletedIndexPaths = [IndexPath(row: 0, section: 0)]
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [[]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: deletedIndexPaths)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: deletedIndexPaths, with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidUpdateItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let updatedIndexPaths = [IndexPathUpdate(IndexPath(row: 0, section: 0))]
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["B"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: updatedIndexPaths)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: updatedIndexPaths.map { $0.oldIndexPath }, with: .automatic),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidMoveItemAtIndexPath() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A", "B"], ["-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let fromIndexPath = IndexPath(row: 0, section: 0)
        let toIndexPath = IndexPath(row: 1, section: 0)
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["B", "A"], ["-"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: fromIndexPath, to: toIndexPath),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [toIndexPath], with: .automatic),
            tableView.endUpdates()
            ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if tableView.calledFunctions.identifiers == expectedCalls.identifiers {
                updateExpectation.fulfill()
            }
        }
        wait(for: [updateExpectation], timeout: 1)
    }

    func testDidMoveAndUpdateItemAtIndexPath() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A", "B", "C"], ["-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let fromIndexPath = IndexPath(row: 0, section: 0)
        let toIndexPath = IndexPath(row: 1, section: 0)
        let updateIndexPath = IndexPath(row: 2, section: 0)
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["B", "A", "C*"], ["-"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(updateIndexPath)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: fromIndexPath, to: toIndexPath),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [updateIndexPath], with: .automatic),
            tableView.reloadRows(at: [toIndexPath], with: .automatic),
            tableView.endUpdates()
            ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if tableView.calledFunctions.identifiers == expectedCalls.identifiers {
                updateExpectation.fulfill()
            }
        }
        wait(for: [updateExpectation], timeout: 1)
    }

    func testDidReloadItems() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["B"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceDidReloadItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.reloadData()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testSelectionOnDeleteItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A"]]
        tableView.reloadData() as Void
        let deletedIndexPaths = [IndexPath(row: 0, section: 0)]
        for deletedIndexPath in deletedIndexPaths {
            tableView.selectRow(at: deletedIndexPath, animated: false, scrollPosition: .none) as Void
        }
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [[]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: deletedIndexPaths)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: deletedIndexPaths, with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testSelectionOnUpdateItemsAtIndexPaths() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A", "B", "C"]]
        tableView.reloadData() as Void
        let updatedIndexPath = IndexPath(row: 1, section: 0)
        tableView.selectRow(at: updatedIndexPath, animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["A", "B*", "C"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(updatedIndexPath)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: [updatedIndexPath], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: updatedIndexPath, animated: false, scrollPosition: .none)
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if tableView.calledFunctions.identifiers == expectedCalls.identifiers {
                updateExpectation.fulfill()
            }
        }
        wait(for: [updateExpectation], timeout: 1)
    }

    func testSelectionOnMoveItemAtIndexPath() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A", "B"]]
        tableView.reloadData() as Void
        let fromIndexPath = IndexPath(row: 0, section: 0)
        let toIndexPath = IndexPath(row: 1, section: 0)
        tableView.selectRow(at: fromIndexPath, animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["B", "A"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: fromIndexPath, to: toIndexPath),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [toIndexPath], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: toIndexPath, animated: false, scrollPosition: .none)
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if tableView.calledFunctions.identifiers == expectedCalls.identifiers {
                updateExpectation.fulfill()
            }
        }
        wait(for: [updateExpectation], timeout: 1)
    }

    /*
     Tests for sections
     */

    func testDidInsertSections() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let newSections = IndexSet(integer: 1)
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["A"], ["B"]]
        tableViewController.dataSource(dataSource, didInsertSections: newSections)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.insertSections(newSections, with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidDeleteSections() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["A"], ["B"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let deletedSections = IndexSet(integer: 1)
        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["A"]]
        tableViewController.dataSource(dataSource, didDeleteSections: deletedSections)
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteSections(deletedSections, with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

}
