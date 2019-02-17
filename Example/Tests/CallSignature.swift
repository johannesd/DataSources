//
//  CallSignature.swift
//  DataSourcesTests
//
//  Created by Johannes Dörr on 11.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

/**
 Stores the event of a call of a function. Consists of the date of the call, and the
 name and parameters of the function.
 */
internal typealias CallSignature = (date: Date, identifier: String)

/**
 Defines helper functions for an array of CallSignatures.
 */
extension Array where Element == CallSignature {

    internal var identifiers: [String] {
        return self.map({ $0.identifier })
    }

    internal func interval(betweenIndex elementIndex: Int, andNextWasAtLeast interval: TimeInterval) -> Bool {
        return self[index(after: elementIndex)].date.timeIntervalSince(self[elementIndex].date) >= interval
    }

}

/**
 Defines helper functions for converting an IndexSet to a String
 */

extension IndexSet {

    internal var stringRepresentation: String {
        return self.map({ $0 }).debugDescription
    }

}
