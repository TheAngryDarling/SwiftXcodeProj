//
//  Int+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2019-08-06.
//

import Foundation

internal extension Int {
    /// Create new Int based on bool value
    ///
    /// true = 1, false = 0
    /// - Parameter source: Bool value to convert
    init(_ source: Bool) {
        if source { self = 1 }
        else { self = 0 }
    }
}
