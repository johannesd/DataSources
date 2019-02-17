//
//  ListDataSourceDelegateTableViewUpdaterWithConversionTests.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import DataSources

/*
 These tests use an offset between the data source's elements and the table view's cells. The indices
 passed to the delegate functions (e.g. dataSource(_, didInsertItemsAtIndexPaths:)) should be shifted
 before they are passed to TableView functions (e.g. insertRows(at:, with:)).
 */

class ListDataSourceDelegateTableViewUpdaterWithConversionTests: XCTestCase {

    class DummyTableViewController: TableViewController, ListDataSourceDelegateTableViewUpdating {

        var indexOffset = 2

        func convert(_ indexPath: IndexPath, fromDataSource dataSource: Any) -> IndexPath {
            // Since this is a simple list, we only expect indexPaths with length 1
            return indexPath.first.map { IndexPath(row: $0 + indexOffset, section: 0) } ?? indexPath
        }

        var dataSource = [String]() {
            didSet {
                tableViewDataSource.items = [Array(dataSource[indexOffset..<dataSource.count - indexOffset])]
            }
        }

    }

    var tableViewController: DummyTableViewController!

    override func setUp() {
        super.setUp()
        tableViewController = DummyTableViewController()
    }

    override func tearDown() {
        super.tearDown()
        tableViewController = nil
    }

    func testDidInsertItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-", "-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "A"]]
        tableViewController.dataSource(dataSource, didInsertItemsAtIndexPaths: [IndexPath(index: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.insertRows(at: [IndexPath(row: tableViewController.indexOffset, section: 0)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidDeleteItemsAtIndexPaths() {
        tableViewController.tableViewDataSource.items = [["-", "-", "A"]]
        let tableView = tableViewController.tableView as! TableView
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-"]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: [IndexPath(index: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: [IndexPath(row: tableViewController.indexOffset, section: 0)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidUpdateItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "B"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(index: 0))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.indexOffset, section: 0)], with: .automatic),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidMoveItemAtIndexPath() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-", "-", "A", "B"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "B", "A"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: IndexPath(index: 0), toIndexPath: IndexPath(index: 1))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.indexOffset, section: 0),
                              to: IndexPath(row: 1 + tableViewController.indexOffset, section: 0)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: 1 + tableViewController.indexOffset, section: 0)], with: .automatic),
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
        tableViewController.tableViewDataSource.items = [["-", "-", "A", "B", "C"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "B", "A", "C*"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: IndexPath(index: 0), toIndexPath: IndexPath(index: 1))
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(index: 2))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.indexOffset, section: 0),
                              to: IndexPath(row: 1 + tableViewController.indexOffset, section: 0)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: 2 + tableViewController.indexOffset, section: 0)], with: .automatic),
            tableView.reloadRows(at: [IndexPath(row: 1 + tableViewController.indexOffset, section: 0)], with: .automatic),
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
        tableViewController.tableViewDataSource.items = [["-", "-", "B"]]
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
        tableViewController.tableViewDataSource.items = [["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.indexOffset, section: 0), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-"]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: [IndexPath(index: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: [IndexPath(row: tableViewController.indexOffset, section: 0)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testSelectionOnUpdateItemsAtIndexPaths() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-", "-", "A", "B", "C"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.indexOffset + 1, section: 0), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "A", "B*", "C"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(index: 1))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.indexOffset + 1, section: 0)], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: IndexPath(row: tableViewController.indexOffset + 1, section: 0), animated: false, scrollPosition: .none)
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
        tableViewController.tableViewDataSource.items = [["-", "-", "A", "B"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.indexOffset, section: 0), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-", "-", "B", "A"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: IndexPath(index: 0), toIndexPath: IndexPath(index: 1))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.indexOffset, section: 0), to: IndexPath(row: tableViewController.indexOffset + 1, section: 0)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.indexOffset + 1, section: 0)], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: IndexPath(row: tableViewController.indexOffset + 1, section: 0), animated: false, scrollPosition: .none)
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if tableView.calledFunctions.identifiers == expectedCalls.identifiers {
                updateExpectation.fulfill()
            }
        }
        wait(for: [updateExpectation], timeout: 1)
    }

}
