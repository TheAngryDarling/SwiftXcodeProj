//
//  Dictionary+XcodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation

internal extension Dictionary {
    /// Creates a copy of the dictionary and sets a key/value
    func setting(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = self
        rtn[key] = value
        return rtn
    }
}
