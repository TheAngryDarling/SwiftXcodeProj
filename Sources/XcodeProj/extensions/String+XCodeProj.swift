//
//  String+XcodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-07-07.
//

import Foundation

internal extension String {
    /// Replace the first occurence of a given string witihn this string
    ///
    /// - Parameters:
    ///   - target: The string to find
    ///   - replacement: The string to replace with
    ///   - options: The comparison options (Default: Empty)
    ///   - searchRange: The search range (Optional)
    /// - Returns: Returns the newly modified string
    func replacingFirstOccurrence(of target: String,
                                   with replacement: String,
                                   options: String.CompareOptions = [],
                                   range searchRange: Range<String.Index>? = nil) -> String {
        var rtn: String = self
        if let r = rtn.range(of: target, options: options, range: searchRange) {
            rtn.replaceSubrange(r, with: replacement)
        }
        return rtn
    }
    
    /// Creates a relative path from the given path
    ///
    /// - Parameter path: The path to use a the base for the relative path
    /// - Returns: The relative path if one is possible otherwise the origional string
    func relatvie(to path: String) -> String {
        let destComponents = NSString(string: self).pathComponents
        let baseComponents = NSString(string: path).pathComponents
        
        var i = 0
        while i < destComponents.count && i < baseComponents.count
            && destComponents[i] == baseComponents[i] {
                i += 1
        }
        
        // Build relative path:
        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        
        return relComponents.joined(separator: "/")
    }
    
    func path(from base: String) -> String {
        guard !self.hasPrefix("/") else { return self }
        
        var baseComponents = base.split(separator: "/").map(String.init).filter{ $0 != "." }
        var pathComponents = self.split(separator: "/").map(String.init).filter{ $0 != "." }
        
        // Get rid of any trailing parent directly indictors
        while baseComponents.last == ".." {
            baseComponents.removeLast()
            if baseComponents.count > 0 { baseComponents.removeLast() }
        }
        
        // Get rid of any trailing parent directly indictors
        while pathComponents.last == ".." {
            pathComponents.removeLast()
            if pathComponents.count > 0 { pathComponents.removeLast() }
        }
        
        while pathComponents.first == ".." && baseComponents.count > 0 {
            pathComponents.removeFirst()
            baseComponents.removeLast()
        }
        
        var idx: Int = 1
        while idx < pathComponents.count {
            if pathComponents[idx] == ".." {
                pathComponents.remove(at: idx)
                pathComponents.remove(at: idx - 1)
            } else {
                idx += 1
            }
        }
        
        if baseComponents.count > 0 {
            let ary: [String] = baseComponents + pathComponents
            return ary.reduce("/") {
                guard $0 != "/" else { return "/" + $1 }
                return $0 + "/" + $1
            }
        } else {
            return pathComponents.reduce("") {
                guard $0 != "" else { return $1 }
                return $0 + "/" + $1
            }
        }
    }
}
