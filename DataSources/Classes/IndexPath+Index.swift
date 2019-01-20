//
//  IndexPath+Index.swift
//  DataSources
//
//  Created by Johannes Dörr on 17.06.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

extension IndexPath {
    /**
     The index of an indexPath created by IndexPath(index:)
     */
    public var index: Int {
        return first!
    }
}
