//
//  SectionedListDataSourceDelegateTableViewUpdaterWithConversionTests.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 12.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import DataSources

class SectionedListDataSourceDelegateTableViewUpdaterWithConversionTests: XCTestCase {

    class DummyTableViewController: TableViewController, SectionedListDataSourceDelegateTableViewUpdating {

        var sectionOffset = 1
        var rowOffset = 2

        func convert(_ indexPath: IndexPath, fromDataSource dataSource: Any) -> IndexPath {
            if indexPath.count == 2 {
                return IndexPath(row: indexPath.row + rowOffset, section: indexPath.section + sectionOffset)
            }
            return indexPath.first.map { IndexPath(index: $0 + sectionOffset) } ?? indexPath
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

    /*
     These tests are the same as in `ListDataSourceDelegateTableViewUpdaterWithConversionTests`, with the difference that
     the `IndexPaths` include two indices (section and row), and not only one index.
     */

    func testDidInsertItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"]]
        tableViewController.dataSource(dataSource, didInsertItemsAtIndexPaths: [IndexPath(row: 0, section: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.insertRows(at: [IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidDeleteItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-"]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: [IndexPath(row: 0, section: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: [IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidUpdateItemsAtIndexPaths() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "B"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(row: 0, section: 0))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .automatic),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidMoveItemAtIndexPath() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A", "B"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "B", "A"]]
        tableViewController.dataSource(dataSource,
                                       didMoveItemAtIndexPath: IndexPath(row: 0, section: 0),
                                       toIndexPath: IndexPath(row: 1, section: 0))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset),
                              to: IndexPath(row: 1 + tableViewController.rowOffset, section: tableViewController.sectionOffset)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: 1 + tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .automatic),
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
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A", "B", "C"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "B", "A", "C*"]]
        tableViewController.dataSource(dataSource,
                                       didMoveItemAtIndexPath: IndexPath(row: 0, section: 0),
                                       toIndexPath: IndexPath(row: 1, section: 0))
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(row: 2, section: 0))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset),
                              to: IndexPath(row: 1 + tableViewController.rowOffset, section: tableViewController.sectionOffset)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: 2 + tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .automatic),
            tableView.reloadRows(at: [IndexPath(row: 1 + tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .automatic),
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
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "B"]]
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
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-"]]
        tableViewController.dataSource(dataSource, didDeleteItemsAtIndexPaths: [IndexPath(row: 0, section: 0)])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteRows(at: [IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset)], with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testSelectionOnUpdateItemsAtIndexPaths() {
        let updateExpectation = expectation(description: "The received calls were not as expected.")

        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A", "B", "C"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A", "B*", "C"]]
        tableViewController.dataSource(dataSource, didUpdateItemsAtIndexPaths: [.init(IndexPath(row: 1, section: 0))])
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset)], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset), animated: false, scrollPosition: .none)
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
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A", "B"]]
        tableView.reloadData() as Void
        tableView.selectRow(at: IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset), animated: false, scrollPosition: .none) as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "B", "A"]]
        tableViewController.dataSource(dataSource, didMoveItemAtIndexPath: IndexPath(row: 0, section: 0), toIndexPath: IndexPath(row: 1, section: 0))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.moveRow(at: IndexPath(row: tableViewController.rowOffset, section: tableViewController.sectionOffset),
                              to: IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset)),
            tableView.endUpdates(),
            tableView.beginUpdates(),
            tableView.reloadRows(at: [IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset)], with: .automatic),
            tableView.endUpdates(),
            tableView.selectRow(at: IndexPath(row: tableViewController.rowOffset + 1, section: tableViewController.sectionOffset), animated: false, scrollPosition: .none)
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
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-", "-", "A"], ["B"]]
        tableViewController.dataSource(dataSource, didInsertSections: IndexSet(integer: 1))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.insertSections(IndexSet(integer: 1 + tableViewController.sectionOffset), with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

    func testDidDeleteSections() {
        let tableView = tableViewController.tableView as! TableView
        tableViewController.tableViewDataSource.items = [["-"], ["-"], ["-"]]
        tableView.reloadData() as Void
        tableView.calledFunctions = []

        let dataSource = NSObject()
        tableViewController.dataSourceWillUpdateItems(dataSource)
        tableViewController.tableViewDataSource.items = [["-"], ["-"]]
        tableViewController.dataSource(dataSource, didDeleteSections: IndexSet(integer: 1))
        tableViewController.dataSourceDidUpdateItems(dataSource)

        let expectedCalls: [CallSignature] = [
            tableView.beginUpdates(),
            tableView.deleteSections(IndexSet(integer: 1 + tableViewController.sectionOffset), with: .fade),
            tableView.endUpdates()
            ]
        XCTAssert(tableView.calledFunctions.identifiers == expectedCalls.identifiers,
                  "The received calls were not as expected.")
    }

}
