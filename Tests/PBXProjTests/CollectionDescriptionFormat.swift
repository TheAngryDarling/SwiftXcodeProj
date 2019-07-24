//
//  CollectionDescriptionFormat.swift
//  PBXProjTests
//
//  Created by Tyler Anger on 2019-07-06.
//

import Foundation

internal func formatArrayDescription(_ array: [Any],
                                     indentCount: Int,
                                     indent: String = "\t",
                                     indentOpening: Bool = true) -> String {
    let tabs: String = ((indentCount > 0) ? String(repeating: indent, count: indentCount) : "")
    var rtn: String = ""
    if indentOpening { rtn += tabs }
    rtn += "["
    if array.count > 0 {
        rtn += "\n"
        
        for (index, v) in array.enumerated() {
            if let dict = v as? Dictionary<String, Any> {
                rtn += tabs + indent + formatDictionaryDescription(dict, indentCount: indentCount + 1, indent: indent, indentOpening: false)
            } else if let ary = v as? Array<Any> {
                rtn += tabs + indent +  formatArrayDescription(ary, indentCount: indentCount + 1, indent: indent, indentOpening: false)
            } else if let s = v as? String {
                rtn += tabs + indent + "\"\(s)\""
            } else {
                rtn += tabs + indent + "\(v)"
            }
            if index < (array.count - 1) { rtn += "," }
            rtn += "\n"
        }
        rtn += tabs
    }
    rtn += "]"
    return rtn
}

internal func formatDictionaryDescription(_ dictionary: [String: Any],
                                          indentCount: Int = 0,
                                          indent: String = "\t",
                                          indentOpening: Bool = true) -> String {
    let tabs: String = ((indentCount > 0) ? String(repeating: indent, count: indentCount) : "")
    var rtn: String = ""
    if indentOpening { rtn += tabs }
    rtn += "["
    if dictionary.count > 0 {
        rtn += "\n"
        for (index,key) in dictionary.keys.sorted().enumerated() {
            let k = key
            let v = dictionary[key]!
            if let dict = v as? Dictionary<String, Any> {
                rtn += tabs + indent + "\"\(k)\": " + formatDictionaryDescription(dict, indentCount: indentCount + 1, indent: indent, indentOpening: false)
            } else if let ary = v as? Array<Any> {
                rtn += tabs + indent + "\"\(k)\": " + formatArrayDescription(ary, indentCount: indentCount + 1, indent: indent, indentOpening: false)
            } else if let s = v as? String {
                rtn += tabs + indent + "\"\(k)\": \"\(s)\""
            } else {
                rtn += tabs + indent + "\"\(k)\": \(String(describing: v))"
            }
            if index < dictionary.count - 1 { rtn += "," }
            rtn += "\n"
        }
        rtn += tabs
    } else {
        rtn += ":"
    }
    
    rtn += "]"
    return rtn
    
}
