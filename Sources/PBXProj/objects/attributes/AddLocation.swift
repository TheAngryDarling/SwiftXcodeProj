//
//  AddLocation.swift
//  PBXProj
//
//  Created by Tyler Anger on 2019-08-07.
//

import Foundation

/// Location to add an object to
///
/// - beginning: To the begging of the list
/// - end: To the end of the list
/// - index: At the given index
/// - before: Before the given object
/// - after: After the given object
public enum AddLocation<T> {
    
    public enum Error: Swift.Error {
        case objectNotFound(T)
    }
    
    /// To the begging of the list
    case beginning
    /// To the end of the list
    case end
    /// At the given index
    case index(Int)
    /// Before the given object
    case before(T)
    /// After the given object
    case after(T)
}

public extension AddLocation {
    /// Add the value to the given collection
    ///
    /// - Parameters:
    ///   - value: The value to add
    ///   - collection: The collection to add the value to
    ///   - equals: The method to test of two objects equal.  Used to find the index of an object
    /// - Throws: Throws Location.Error.objectNotFound if the index of an object could not be found
    func add<C>(_ value: T, to collection: inout C, equals: (_ lhs: T, _ rhs: T) -> Bool) throws where C: MutableCollection, C: RangeReplaceableCollection, C.Element == T, C.Index == Int {
        switch self {
        case .beginning: collection.insert(value, at: collection.startIndex)
        case .end: collection.append(value)
        case .index(let idx): collection.insert(value, at: idx)
        case .before(let o):
            guard let idx = collection.firstIndex(where: { return equals($0, o) }) else {
                throw Error.objectNotFound(o)
            }
            collection.insert(value, at: idx)
        case .after(let o):
            guard let idx = collection.firstIndex(where: { return equals($0, o) }) else {
                throw Error.objectNotFound(o)
            }
            if idx < collection.endIndex { collection.insert(value, at: idx + 1) }
            else { collection.append(value) }
        }
    }
}

public extension AddLocation where T: Equatable {
    /// Add the value to the given collection
    ///
    /// - Parameters:
    ///   - value: The value to add
    ///   - collection: The collection to add the value to
    /// - Throws: Throws Location.Error.objectNotFound if the index of an object could not be found
    func add<C>(_ value: T, to collection: inout C) throws where C: MutableCollection, C: RangeReplaceableCollection, C.Element == T, C.Index == Int {
        return try add(value, to: &collection) { return $0 == $1 }
    }
}

internal extension AddLocation where T: PBXObject {
    /// Returns the Location<PBXReference> to this location
    var referencedLocation: AddLocation<PBXReference> {
        switch self {
            case .beginning: return AddLocation<PBXReference>.beginning
            case .end: return AddLocation<PBXReference>.end
            case .index(let idx): return AddLocation<PBXReference>.index(idx)
            case .before(let o): return AddLocation<PBXReference>.before(o.id)
            case .after(let o): return AddLocation<PBXReference>.after(o.id)
        }
    }
}
