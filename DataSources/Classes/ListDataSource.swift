//
//  ListDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 09.05.19.
//

import Foundation
import Delegates

/**
 A data source that stores a list.
 */
public final class ListDataSource<Item>: ListBasedDataSource<Item>, ExpressibleByArrayLiteral {
    public var delegates = Delegates<ListDataSourceDelegate>()
    
    public required init(arrayLiteral items: Item...) {
        super.init()
        self.items = items
    }
    
    public override func forEachDelegate(_ block: (ListDataSourceDelegate) -> Void) {
        super.forEachDelegate(block)
        delegates.forEach(block)
    }
}

extension ListDataSource where Item: Codable {
    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: url, options: options)
    }
    
    public convenience init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        let data = try Data(contentsOf: url, options: options)
        let decoder = JSONDecoder()
        let items = try decoder.decode([Item].self, from: data)
        self.init()
        self.items = items
    }
}
