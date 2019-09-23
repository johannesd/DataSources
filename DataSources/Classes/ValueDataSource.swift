//
//  ValueDataSource.swift
//  DataSources
//
//  Created by Johannes Dörr on 01.09.19.
//

import Foundation
import Delegates

@dynamicMemberLookup
public final class ValueDataSource<Value>: DataSourceDelegating {
    public typealias Value = Value
    
    public var delegates = Delegates<ValueDataSourceDelegate>()
    public var dataSourceDelegates = DataSourceDelegates()
    public var value: Value {
        willSet {
            forEachDelegate { $0.dataSourceWillUpdateValue(self) }
        }
        didSet {
            forEachDelegate { $0.dataSourceDidUpdateValue(self) }
        }
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get {
            return value[keyPath: keyPath]
        }
        set {
            value[keyPath: keyPath] = newValue
        }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        return value[keyPath: keyPath]
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func forEachDelegate(_ block: (ValueDataSourceDelegate) -> Void) -> Void {
        forEachDataSourceDelegate(block)
        delegates.forEach(block)
    }
}

extension ValueDataSource where Value: Codable {
    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: options)
    }
    
    class func value(from url: URL, options: Data.ReadingOptions = []) throws -> Value {
        let data = try Data(contentsOf: url, options: options)
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: data)
    }
    
    public convenience init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        let value = try type(of: self).value(from: url, options: options)
        self.init(value)
    }
    
    public func insertValue(from url: URL, options: Data.ReadingOptions = []) throws {
        self.value = try type(of: self).value(from: url, options: options)
    }
}
