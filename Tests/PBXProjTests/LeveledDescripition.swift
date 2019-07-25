//
//  LeveledDescripition.swift
//  PBXProjTests
//
//  Created by Tyler Anger on 2019-07-06.
//

import Foundation

internal protocol LeveledDescripition {
    func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String
}

extension Array: LeveledDescripition {
    func leveledDescription(_ level: Int = 0, indent: String = "\t", indentOpening: Bool = true, sortKeys: Bool = false ) -> String {
        let tabs: String = String(repeating: indent, count: level)
        var rtn: String = ""
        if indentOpening { rtn += tabs }
        rtn += "["
        if self.count > 0 {
            rtn += "\n"
            
            for (index, v) in self.enumerated() {
                if let leveled = v as? LeveledDescripition {
                    rtn += tabs + indent + leveled.leveledDescription(level + 1,
                                                                      indent: indent,
                                                                      indentOpening: false,
                                                                      sortKeys: sortKeys)
                } else if let str = v as? String {
                    rtn += tabs + indent + "\"\(str)\""
                } else if let char = v as? Character {
                    rtn += tabs + indent + "\"\(char)\""
                } else {
                    rtn += tabs + indent + "\(v)"
                }
                if index < (self.count - 1) { rtn += "," }
                rtn += "\n"
            }
            rtn += tabs
        }
        rtn += "]"
        return rtn
    }
}

extension Dictionary: LeveledDescripition {
    
    func leveledDescription(_ level: Int = 0, indent: String = "\t", indentOpening: Bool = true, sortKeys: Bool = false ) -> String {
        let tabs: String = String(repeating: indent, count: level)
        var rtn: String = ""
        if indentOpening { rtn += tabs }
        rtn += "["
        if self.count > 0 {
            rtn += "\n"
            var items = Array<(key: Key, value: Value)>(self)
            if sortKeys {
                items.sort {
                    return String(describing: $0.key) < String(describing: $1.key)
                }
            }
            
            for (index, v) in items.enumerated() {
                rtn += tabs + indent
                if Key.self == String.self { rtn += "\"\(v.key)\"" }
                else { rtn += "\(v.key)" }
                rtn += ": "
                
                if let leveled = v.value as? LeveledDescripition {
                    rtn += leveled.leveledDescription(level + 1,
                                                      indent: indent,
                                                      indentOpening: false,
                                                      sortKeys: sortKeys)
                } else if let str = v.value as? String {
                    rtn += "\"\(str)\""
                } else if let char = v.value as? Character {
                    rtn += "\"\(char)\""
                } else {
                    rtn += "\(v.value)"
                }
                if index < (self.count - 1) { rtn += "," }
                rtn += "\n"
            }
            rtn += tabs
        } else {
            rtn += ":"
        }
        rtn += "]"
        return rtn
    }
}
