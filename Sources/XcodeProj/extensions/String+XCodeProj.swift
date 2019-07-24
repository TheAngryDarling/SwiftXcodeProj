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
}
