//
//  Array+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-15.
//

import Foundation

internal extension Array {
    
    /// Creates a new array out of the current and appens the given element to it
    ///
    /// - Parameter element: The new element to append to the copy of the array
    /// - Returns: A new copy of the array with the new element at the end
    func appending(_ element: Element) -> Array<Element> {
        var rtn: Array<Element> = Array<Element>()
        rtn.append(contentsOf: self)
        rtn.append(element)
        return rtn
    }
    /// - Returns: Returns a copy of this array without the first element
    func removingFirst() -> Array<Element> {
        
        guard self.count > 0 else { return Array<Element>() }
        
        var rtn: Array<Element> = Array<Element>()
        rtn.append(contentsOf: self)
        rtn.removeFirst()
        return rtn
    }
    /// - Returns: Returns a copy of this array without the last element
    func removingLast() -> Array<Element> {
        guard self.count > 0 else { return Array<Element>() }
        var rtn: Array<Element> = Array<Element>()
        rtn.append(contentsOf: self)
        rtn.removeLast()
        return rtn
    }
    
    /// Get an object at a given index, or nil of the index is out of bounds
    ///
    /// - Parameter index: The index positon of the element (Positive numbers will be 0 + number for index, Negative numbers will be count - !number for index)
    /// - Returns: Returns the element at the given index or nil if not found
    func itemOrNil(at index: Int) -> Element? {
        var pos = index
        if pos < 0 { pos = self.count + pos }
        
        guard index < self.count else { return nil }
        return self[pos]
    }
}

internal extension Array where Element: Equatable {
    /// Checks to see if the element is within the array or not
    ///
    /// If the element is nil, the method will automatically return false
    ///
    /// - Parameter element: Optional element looking for
    /// - Returns: Returns true if the element is found, otherwise false
    func contains(_ element: Element?) -> Bool {
        guard let e = element else { return false }
        return self.contains(e)
    }
}

internal extension Array where Element == PBXReference {
    /// Removes all instances of this element within the array
    ///
    /// - Parameter element: The element to remove
    mutating func remove(_ element: PBXReference) {
        var idx: Int = 0
        while idx < self.endIndex {
            if self[idx] == element {
                self.remove(at: idx)
            } else {
                idx += 1
            }
        }
        //self.removeAll(where: { $0 == element })
    }
    
    /// Remove all elements from within the array
    ///
    /// - Parameter elements: The elements to remove
    mutating func removeAll(_ elements: [PBXReference]) {
        var idx: Int = 0
        while idx < self.endIndex {
            if elements.contains(self[idx]) {
                self.remove(at: idx)
            } else {
                idx += 1
            }
        }
    }
}

internal extension Array where Element: PBXObject {
    /// Find the index of a PBXObject that has a specific PBXReference
    ///
    /// - Parameter reference: The reference to look for
    /// - Returns: Returns the index of the objet with the given reference or nil if not found
    func index(of reference: PBXReference) -> Int? {
        var idx: Int = 0
        while idx < self.endIndex {
            if self[idx].id == reference { return idx }
            idx += 1
        }
        
        return nil

    }
    /// Checks to see if there is an object that has a given PBXReference
    ///
    /// - Parameter element: The reference to look for
    /// - Returns: Returns true if an object contains the given reference, otherwise false
    func contains(_ element: PBXReference) -> Bool {
        return (self.index(of: element) != nil)
    }
}
