//
//  String+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-13.
//

import Foundation

internal extension String {
    
    /// A range coveing the complete string
    var completeRange: Range<String.Index> {
        return Range<String.Index>(uncheckedBounds: (lower: self.startIndex,
                                                     upper: self.endIndex))
    }
    
    /// An NSRange covering the complete string
    var completeNSRange: NSRange {
        return NSRange(self.completeRange, in: self)
    }
    
    /// Creates a new string repating the current value n number of times
    ///
    /// - Parameter times: The number of times to repeat this string
    /// - Returns: A new string representing the repeated value
    func repeated(_ times: Int) -> String {
        guard times > 0 else { return "" }
        return String(repeating: self, count: times)
        //return Array<String>(repeating: self, count: times).reduce("", +)
    }
    
    /// Count the number of times a given string occurs
    ///
    /// - Parameters:
    ///   - string: The string to look for
    ///   - searchRange: The search range (Default is the whole string)
    /// - Returns: Returns the number of times the search string apepars
    func countOccurrences<Target>(of string: Target,
                                           inRange searchRange: Range<String.Index>? = nil) -> Int where Target : StringProtocol {
        var rtn: Int = 0
        var workingRange: Range<String.Index>? = searchRange ?? self.completeRange /*Range<String.Index>(uncheckedBounds: (lower: self.startIndex,
                                                                                                      upper: self.endIndex))*/
        while workingRange != nil {
            guard let r = self.range(of: string, range: workingRange) else {
                break
            }
            rtn += 1
            if r.upperBound == workingRange!.upperBound { workingRange = nil }
            else {
                workingRange = Range<String.Index>(uncheckedBounds: (lower: r.upperBound,
                                                                     upper: workingRange!.upperBound))
            }
        }
        
        return rtn
    }
    
    /// A quick regular expression match test
    ///
    /// - Parameter pattern: The pattern to test against
    /// - Returns: Returns true if the string matches the pattern, otherwise false
    func match(_ pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        guard let _ = regex.firstMatch(in: self, range: self.completeNSRange) else { return false }
        return true
    }
    
    
}
