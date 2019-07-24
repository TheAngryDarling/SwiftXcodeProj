//
//  Array+XcodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-01.
//

import Foundation

internal extension Array {
    /// Creates a copy of the current array removing the first element
    func removingFirst() -> Array<Element> {
        var rtn = self
        rtn.removeFirst()
        return rtn
    }
}
