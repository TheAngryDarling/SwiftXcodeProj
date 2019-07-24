//
//  PBXReference.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// Structure to store object reference id's
public struct PBXReference {
    
    internal static let OBJ_REFERENCE_PREFIX: String = "OBJ_"
    
    fileprivate let rawValue: String
    
    /// Returns the reference value without any wrapping double quotes
    internal var escapedRawValue: String {
        var rtn: String = self.rawValue
        if rtn.hasPrefix("\"") && rtn.hasSuffix("\'") {
            rtn.removeFirst()
            rtn.removeLast()
        }
        return rtn
    }
    
    /// indicates if the reference is a sequential number reference.  (Meaning starts with OBJ_)
    internal var isObjectNumReference: Bool {
        return self.escapedRawValue.hasPrefix(PBXReference.OBJ_REFERENCE_PREFIX)
    }
    
    /// Gets the sequential object number IF thats the type of refernce this is otherwise this will be nil
    fileprivate var objectNumber: Int! {
        var str = self.escapedRawValue
        guard str.hasPrefix(PBXReference.OBJ_REFERENCE_PREFIX) else { return nil }
        str = String(str.suffix(str.count - PBXReference.OBJ_REFERENCE_PREFIX.count))
        return Int(str)
    }
    
    internal init(_ rawValue: String) { self.rawValue = rawValue }
    
    
}

public extension PBXReference {
    /// Returns a Boolean value indicating whether the string begins with the specified prefix.
    ///
    /// - Parameter prefix: A possible prefix to test against this string.
    /// - Returns: true if the string begins with prefix; otherwise, false.
    func hasPrefix(_ prefix: String) -> Bool { return self.rawValue.hasPrefix(prefix) }
    /// Returns a Boolean value indicating whether the string ends with the specified suffix.
    ///
    /// - Parameter suffix: A possible suffix to test against this string.
    /// - Returns: true if the string ends with suffix; otherwise, false.
    func hasSuffix(_ suffix: String) -> Bool { return self.rawValue.hasSuffix(suffix) }
    /// Returns a Boolean value indicating whether the string cntains the specific value
    ///
    /// - Parameter other: The value to search for
    /// - Returns: true if the string contains the value; otehrwise, false.
    func contains<T>(_ other: T) -> Bool where T : StringProtocol { return self.rawValue.contains(other) }
    
}

extension PBXReference: CustomStringConvertible {
    public var description: String { return self.rawValue }
}

extension PBXReference: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        //let pth = container.codingPath.stringPath
        //print("Reference: " + pth)
        let rawValue = try container.decode(String.self)
        self.init(rawValue)
    }
}

extension PBXReference: Equatable {
    public static func ==(lhs: PBXReference, rhs: PBXReference) -> Bool {
        let lhsStr = lhs.escapedRawValue
        let rhsStr = rhs.escapedRawValue
        /*if lhsStr.hasPrefix("\"") && lhsStr.hasSuffix("\"") {
            lhsStr.removeFirst()
            lhsStr.removeLast()
        }
        if rhsStr.hasPrefix("\"") && rhsStr.hasSuffix("\"") {
            rhsStr.removeFirst()
            rhsStr.removeLast()
        }*/
        return lhsStr == rhsStr
    }
    
    public static func ==(lhs: PBXReference, rhs: PBXReference?) -> Bool {
        guard let r = rhs else { return false }
        return lhs == r
    }
    
    public static func ==(lhs: PBXReference?, rhs: PBXReference) -> Bool {
        guard let l = lhs else { return false }
        return l == rhs
    }
    
    public static func ==(lhs: PBXReference, rhs: String) -> Bool {
        let lhsStr = lhs.escapedRawValue
        
        /*if lhsStr.hasPrefix("\"") && lhsStr.hasSuffix("\"") {
            lhsStr.removeFirst()
            lhsStr.removeLast()
        }*/
        
        return lhsStr == rhs
    }
    public static func ==(lhs: String, rhs: PBXReference) -> Bool {
        let rhsStr = rhs.escapedRawValue
        
        /*if rhsStr.hasPrefix("\"") && rhsStr.hasSuffix("\"") {
            rhsStr.removeFirst()
            rhsStr.removeLast()
        }*/
        return lhs == rhsStr
    }
}

extension PBXReference: Comparable {
    public func compare(to rhs: PBXReference) -> ComparisonResult {
        switch (self.isObjectNumReference, rhs.isObjectNumReference) {
            case (true, false):  return .orderedAscending
            case (false, true): return .orderedDescending
            case (false, false): return self.escapedRawValue.compare(rhs.escapedRawValue)
            case (true, true):
                let lhsN = self.objectNumber!
                let rhsN = rhs.objectNumber!
                if lhsN < rhsN { return .orderedAscending  }
                else if lhsN == rhsN { return .orderedSame }
                else { return .orderedDescending }
        }
    }
    public static func < (lhs: PBXReference, rhs: PBXReference) -> Bool {
        return (lhs.compare(to: rhs) == .orderedAscending)
    }
    
    
}

extension PBXReference: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
extension PBXReference: Hashable {
    #if !swift(>=4.1)
    public var hashValue: Int { return self.rawValue.hashValue }
    #endif
}
