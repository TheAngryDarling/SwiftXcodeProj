//
//  PBXSourceTree.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// Structure storing the PBX Group source tree
public struct PBXSourceTree: Hashable {
    
    #if !swift(>=4.0.4)
    public var hashValue: Int { return self.rawValue.hashValue }
    #endif
    
    internal let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let none: PBXSourceTree = ""
    public static let absolute: PBXSourceTree = "<absolute>"
    public static let group: PBXSourceTree = "<group>"
    public static let sourceRoot: PBXSourceTree = "SOURCE_ROOT"
    public static let buildProductsDir: PBXSourceTree = "BUILT_PRODUCTS_DIR"
    public static let sdkRoot: PBXSourceTree = "SDKROOT"
}

extension PBXSourceTree: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension PBXSourceTree: CustomStringConvertible {
    public var description: String { return self.rawValue }
}

extension PBXSourceTree: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        //let p = container.codingPath
        self.init(rawValue)
    }
}

extension PBXSourceTree: Equatable {
    public static func ==(lhs: PBXSourceTree, rhs: PBXSourceTree) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXSourceTree, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: PBXSourceTree) -> Bool {
        return lhs == rhs.rawValue
    }
}
