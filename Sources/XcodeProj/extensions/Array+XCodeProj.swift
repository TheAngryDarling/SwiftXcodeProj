//
//  Array+XcodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-01.
//

import Foundation
import PBXProj

public extension Array where Element == XcodeBuildPhase {
    /// Returns the first build phase of a specific type
    /// - Parameter type: The type of build phase to find
    func first(of type: XcodeBuildPhaseType) -> XcodeBuildPhase? {
        return self.first(where: { return $0.type == type.objectType })
    }
}
internal extension Array {
    /// Creates a copy of the current array removing the first element
    func removingFirst() -> Array<Element> {
        var rtn = self
        rtn.removeFirst()
        return rtn
    }
}

internal extension Array where Element == XcodeProjectBuilders.DefaultDetailsChoice {
    /// Checks to see if a given choice/option is contained within the array
    /// - Parameter option: The choice(s)/option(s) to check for
    func has(_ option: XcodeProjectBuilders.DefaultDetailsChoice) -> Bool {
        for element in self {
            if element.has(option) { return true }
        }
        return false
    }
    
    /// Removes any choices/options provides from the given array
    /// - Parameter options: The choice(s)/option(s) to remove
    /// - Returns: A newly created array with the leftover choice(s)/option(s)
    func removing(_ options: [XcodeProjectBuilders.DefaultDetailsChoice]) -> [XcodeProjectBuilders.DefaultDetailsChoice] {
        var rtn: [XcodeProjectBuilders.DefaultDetailsChoice] = self
        /// Remove any items in lhs that exist in rhs
        var idx: Int = 0
        while idx < rtn.count {
            if options.has(rtn[idx]) {
                rtn.remove(at: idx)
            } else {
                idx += 1
            }
        }
        return rtn
    }
    
    /// Removes any choices/options provides from the given array
    /// - Parameter option: The choice(s)/option(s) to remove
    /// - Returns: A newly created array with the leftover choice(s)/option(s)
    func removing(_ option: XcodeProjectBuilders.DefaultDetailsChoice) -> [XcodeProjectBuilders.DefaultDetailsChoice] {
        return self.removing([option])
    }
}

internal extension Array {
    func appending(_ newElement: Element) -> [Element] {
        var rtn: [Element] = self
        rtn.append(newElement)
        return rtn
    }
    func appending<S>(contentsOf newElements: S) -> [Element] where Element == S.Element, S : Sequence {
        var rtn: [Element] = self
        rtn.append(contentsOf: newElements)
        return rtn
    }
}
