//
//  PBXNamePath.swift
//  PBXProj
//
//  Created by Tyler Anger on 2019-07-10.
//

import Foundation

/// Structure for passing Name and/or path to functions / constructors
///
/// This ensures that at leaset one of the required values is provided
public struct PBXNamePath {
    internal let name: String?
    internal let path: String?
    
    private init(name: String?, path: String?) {
        self.name = name
        self.path = path
    }
    
    public static var empty: PBXNamePath { return PBXNamePath(name: nil, path: nil) }
    public static func name(_ name: String) -> PBXNamePath {
        return PBXNamePath(name: name, path: nil)
    }
    public static func path(_ path: String) -> PBXNamePath {
        return PBXNamePath(name: nil, path: path)
    }
    public static func both(name: String, path: String) -> PBXNamePath {
        return PBXNamePath(name: name, path: path)
    }
    
    
}
