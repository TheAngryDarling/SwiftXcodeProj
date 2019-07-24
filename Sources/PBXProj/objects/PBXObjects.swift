//
//  XcodePrjObjects.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-20.
//

import Foundation
import CodableHelpers
import RawRepresentableHelpers

public final class PBXObjects: Codable {
    public enum ObjectError: Error {
        case objectNotFound(PBXReference)
        case castingFailure(PBXObject, Any.Type)
    }
    
    //private static let OBJECT_KEY: String = PBXObject.REFRENCE_CODING_KEY
    
    /// An array of all the objects
    fileprivate var objects: [PBXObject] = []
    /// A reference to the pbx project
    internal var proj: PBXProj!
    
    /// An array of all the targets
    public var targets: [PBXTarget] { return self.of(type: PBXTarget.self) }
    /// An array of all build phases
    public var buildPhases: [PBXBuildPhase] { return self.of(type: PBXBuildPhase.self) }
    /// An array of all file elements
    public var fileElements: [PBXFileElement] { return self.of(type: PBXFileElement.self) }
    /// An array of all groups
    public var groups: [PBXGroup] { return self.of(type: PBXGroup.self) }
    /// An array of all container proxy items
    public var containerProxyItems: [PBXContainerItemProxy] { return self.of(type: PBXContainerItemProxy.self) }
    
    /// Create new instance of PBXObjects
    internal init() { }
    /// Create new instance of PBXObjects
    ///
    /// - Parameter objects: The objects to initialize with
    fileprivate init(_ objects: [PBXObject]) {
        self.objects = objects
        for o in self.objects {
            o.objectList = self
        }
        
        let projs = self.of(type: PBXProject.self)
        for proj in projs {
            if let main = proj.mainGroup {
                main.assignParentToChildren()
            }
        }
    }
    

    required public convenience init(from decoder: Decoder) throws {
        let objs: [PBXObject] = try CodableHelpers.sequences.dynamicElementDecoding(from: decoder,
                                                                                    usingKey: PBXObject.ObjectCodingKeys.id) { (dec: Decoder) throws -> PBXObject in
            let container = try dec.container(keyedBy: PBXObject.ObjectCodingKeys.self)
            let isaType = try container.decode(PBXObjectType.self, forKey: .type)
            return try isaType.objectContainerType.init(from: dec)
            
            //return try XcodeProjObject(from: dec)
        }
        
        self.init(objs)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        try CodableHelpers.sequences.dynamicElementEncoding(self.objects,
                                                            to: encoder,
                                                            usingKey: PBXObject.ObjectCodingKeys.id)
    }
    
    /// Returns the number of objects in the list
    internal var count: Int { return self.objects.count }
    /// Gets the object at a given index
    ///
    /// - Parameter index: The position in the list of the object to return
    internal subscript(index: Int) -> PBXObject {
        return self.objects[index]
    }
    
    /// Find an objects with the given reference
    ///
    /// - Parameter reference: The reference of the object to look for
    /// - Returns: Returns the found object or nil in not found
    public func object(withReference reference: PBXReference) -> PBXObject? {
        for o in self.objects {
            if o.id == reference { return o }
        }
        return nil
    }
    
    /// Check to see if an object with the given reference exists
    ///
    /// - Parameter reference: The reference of the object to look for
    /// - Returns: Returns true if an object with the given reference was found, othrwise false
    public func containsObject(withReference reference: PBXReference) -> Bool {
        return (self.object(withReference: reference) != nil)
    }
    
    /// Get all objects with the given references
    ///
    /// - Parameter references: A list of references to look for
    /// - Returns: An array of PBXObject that were found given the list of references
    public func objects(withReferences references: [PBXReference]) -> [PBXObject] {
        var rtn: [PBXObject] = []
        for reference in references {
            for o in self.objects {
                if o.id == reference { rtn.append(o) }
            }
        }
        return rtn
    }
    
    /// Get an object with a specific reference casted to a specific type
    ///
    /// - Parameters:
    ///   - reference: the reference of the object to look for
    ///   - type: The type to cast the object to
    /// - Returns: Returns the object if found and can cast ast the given type, otherwise nil
    public func object<T>(withReference reference: PBXReference, asType type: T.Type) -> T? {
        for o in self.objects {
            if o.id == reference { return o as? T }
        }
        return nil
    }
    
    /// Get an object with a specific reference casted to a specific type
    ///
    /// - Parameters:
    ///   - reference: the reference of the object to look for
    ///   - type: The type to cast the object to
    ///   - errorOnNotFound: A method to get an error for when object not found.  This error will be thrown (Default: ObjectError.objectNotFound)
    ///   - errorOnCastingFailure: A method to get an error for when casting fails.  This error will be thrown (Default: ObjectError.castingFailure)
    /// - Returns: Returns an array of objects if found and can cast ast the given type
    public func objectWithErrorHandling<T>(withReference reference: PBXReference,
                                    asType type: T.Type,
                                    errorOnNotFound: (PBXReference) -> Swift.Error = { (ref: PBXReference) -> Swift.Error in return ObjectError.objectNotFound(ref) },
                                    errorOnCastingFailure: (PBXObject, Any.Type) -> Swift.Error = { (obj: PBXObject, tp: Any.Type) -> Swift.Error in return ObjectError.castingFailure(obj, tp)  } ) throws -> T {
        for o in self.objects {
            if o.id == reference {
                if let r =  o as? T { return r }
                throw errorOnCastingFailure(o, type)
            }
        }
        throw errorOnNotFound(reference)
       
    }
    
    /// Get objects with the given references as a specific type.
    ///
    /// - Parameters:
    ///   - references: An array of references of object to get
    ///   - type: The type to cast the objects to
    /// - Returns: Returns the object if found and can cast ast the given type, otherwise nil
    public func objects<T>(withReferences references: [PBXReference], asType type: T.Type) -> [T] {
        var rtn: [T] = []
        for reference in references {
            for o in self.objects {
                if o.id == reference, let v = o as? T{ rtn.append(v) }
            }
        }
        return rtn
    }
    
    /// Get objects with the given references as a specific type.
    ///
    /// - Parameters:
    ///   - references: An array of references of object to get
    ///   - type: The type to cast the objects to
    ///   - errorOnCastingFailure: A method to get an error for when casting fails.  This error will be thrown (Default: ObjectError.castingFailure)
    /// - Returns: Returns an array of objects if found and can cast ast the given type
    public func objectsWithErrorHandling<T>(withReferences references: [PBXReference],
                                              asType type: T.Type,
                                              errorOnCastingFailure: (PBXObject, Any.Type) -> Swift.Error = { (obj: PBXObject, tp: Any.Type) -> Swift.Error in return ObjectError.castingFailure(obj, tp)  } ) throws -> [T] {
        var rtn: [T] = []
        for reference in references {
            for o in self.objects {
                if o.id == reference {
                    if let v = o as? T { rtn.append(v) }
                    else { throw errorOnCastingFailure(o, type) }
                }
            }
        }
        return rtn
    }
    
    /// Add an object to the list
    ///
    /// - Parameter object: The object to add
    public func append(_ object: PBXObject) {
        self.objects.append(object)
        object.objectList = self
    }
    
    /// Addes a list of objects
    ///
    /// - Parameter newElements: A list of object to add
    public func append<S>(contentsOf newElements: S) where S : Sequence, S.Element: PBXObject {
        for o in newElements {
            self.append(o)
        }
    }
    
    /// Removes an object from the list
    ///
    /// - Parameter object: The object to remove
    public func remove(_ object: PBXObject!) {
        guard let obj = object else { return }
        obj.deleting()
        var idx = 0
        while idx < self.objects.endIndex {
            if self.objects[idx].id == object.id {
                self.objects.remove(at: idx)
            } else {
                idx += 1
            }
        }
        //self.objects.removeAll(where: { $0.id == obj.id })
        obj.objectList = nil
    }
    
    /// Remove all objects with the given reference
    ///
    /// - Parameter reference: The reference of an object to remove
    public func remove(objectWithReference reference: PBXReference) {
        var idx = 0
        while idx < self.objects.endIndex {
            let obj = self.objects[idx]
            if obj.id == reference {
                obj.deleting()
                self.objects.remove(at: idx)
                
            } else {
                idx += 1
            }
        }
    }
    
    /// Removes all objects with the given references
    ///
    /// - Parameter references: An array of references of objects to remove
    public func remove(objectsWithReferences references: [PBXReference]) {
        for ref in references {
            remove(objectWithReference: ref)
        }
    }
    
    /// Get any objects of a specific type
    ///
    /// - Parameter type: The type of object to find
    /// - Returns: Returns an array of objects for a given type
    public func of<T>(type: T.Type) -> [T] {
        var rtn: [T] = []
        for o in self.objects {
            if let t = o as? T {
                rtn.append(t)
            }
        }
        return rtn
    }
    
    
    
    /// Method for returning the property coding keys in the order they should be written to file in
    ///
    /// - Parameters:
    ///   - content: The content of the given object (key/value) paris
    ///   - data: The data of all objects in the file
    ///   - path: The path of the given object in the file
    /// - Returns: Reutrns an array of the keys in the order they should be written in
    internal static func getPBXEncodingOrderKeys(_ content: [String: Any],
                                                inData data: [String: Any],
                                                atPath path: [String]) -> [String] {
        // If we are encoding at a path level of /objects/{object} then we will sort based on object type, then reference id
        if path.count == 1 && path[0] == PBXProj.CodingKeys.objects {
            var rtn: [String] = []
            rtn.append(contentsOf: content.keys)
            rtn.sort { (lhs: String, rhs: String) -> Bool in
                var lhsVal: Int = 0
                var rhsVal: Int = 0
                
                if let object = content[lhs] as? [String: Any],
                    let isa = object["isa"] as? String {
                    lhsVal = PBXObjectType(isa).orderValue
                }
                
                if let object = content[rhs] as? [String: Any],
                    let isa = object["isa"] as? String {
                    rhsVal = PBXObjectType(isa).orderValue
                }
                
                if lhsVal < rhsVal { return true }
                else if lhsVal > rhsVal { return false }
                else { return PBXReference(lhs) < PBXReference(rhs)  }
                /*else if lhs.contains("OBJ_") && rhs.contains("\"") { return true }
                else if lhs.contains("\"") && rhs.contains("OBJ_") { return false }
                else if lhs.contains("OBJ_") && rhs.contains("OBJ_") {
                    var sLhs = lhs
                    var sRhs = rhs
                    if sLhs.hasPrefix("\"") && sLhs.hasSuffix("\"") {
                        sLhs = String(sLhs[sLhs.index(after: sLhs.startIndex)..<sLhs.index(before: sLhs.endIndex)])
                    }
                    if sRhs.hasPrefix("\"") && sRhs.hasSuffix("\"") {
                        sRhs = String(sRhs[sRhs.index(after: sRhs.startIndex)..<sRhs.index(before: sRhs.endIndex)])
                    }
                    
                    sLhs = String(sLhs.suffix(sLhs.count - 4))
                    sRhs = String(sRhs.suffix(sRhs.count - 4))
                    
                    if let iLhs = Int(sLhs), let iRhs = Int(sRhs) {
                        return iLhs < iRhs
                    } else {
                        return sLhs < sRhs
                    }
                }
                else if lhs.hasPrefix("\"") && !rhs.hasPrefix("\"") { return false }
                else if !lhs.hasPrefix("\"") && rhs.hasPrefix("\"") { return true }
                else if lhs.contains("OBJ_") { return false }
                else if rhs.contains("OBJ_") { return true }
                else { return lhs < rhs }*/
            }
            return rtn
        } else if path.count >= 2 && path[0] == PBXProj.CodingKeys.objects,
            let objList = data[path[0]] as? [String: Any], // get the object lists (/objects)
            let obj = objList[path[1]] as? [String: Any], // get the current object (/objects/{object})
            let isa = obj[PBXObject.ObjectCodingKeys.type] as? String { // get the object type (/objects/object/isa)
            // If we are at a path /objects/object/... then we will sort based on the object type sort order
            
            return PBXObjectType(isa).objectContainerType.getPBXEncodingOrderKeys(content,
                                                                                  inData: data,
                                                                                  atPath: path)
        } else {
            // Otherwise we will sort based on key names
            return content.keys.sorted()
        }
    }
    /// Gets any comments for the given value
    ///
    /// - Parameters:
    ///   - value: The value to get comments for
    ///   - path: The coding path for the object
    ///   - data: The entire data from the beginning of the encoding process
    ///   - userInfo: Any user info
    /// - Returns: Returns any comments for the value if there is any, otherwise nil
    internal class func getPBXEncodingComments(forValue value: String,
                                                atPath path: [String],
                                                inData data: [String: Any],
                                                userInfo: [CodingUserInfoKey: Any]) -> String? {
        if path.count == 1 && path[0] == PBXProj.CodingKeys.objects {
            return nil
        } else if path.count >= 2 && path[0] == PBXProj.CodingKeys.objects,
            let objList = data[path[0]] as? [String: Any],
            let obj = objList[path[1]] as? [String: Any],
            let isa = obj[PBXObject.ObjectCodingKeys.type] as? String {
            
            return PBXObjectType(isa).objectContainerType.getPBXEncodingComments(forValue: value,
                                                                                 atPath: path,
                                                                                 inObject: obj,
                                                                                 inObjectList: objList,
                                                                                 inData: data,
                                                                                 userInfo: userInfo)
        }
        return nil
    }
    
    
    /// Check to see if the curernt string value nees escaping
    ///
    /// - Parameters:
    ///   - value: The string value to check
    ///   - hasKeyIndicators: An indicator if the string has any key indicators
    ///   - path: the current coding path of the string
    ///   - data: The entire data from the beginning of the encoding process
    ///   - userInfo: Any user info
    /// - Returns: Returns true if the string need escaping
    internal class func isPBXEncodinStringEscaping(_ value: String,
                                                 hasKeyIndicators: Bool,
                                                 atPath path: [String],
                                                 inData data: [String: Any],
                                                 userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if path.count >= 2 && path[0] == PBXProj.CodingKeys.objects,
            let objList = data[path[0]] as? [String: Any],
            let obj = objList[path[1]] as? [String: Any],
            let isa = obj[PBXObject.ObjectCodingKeys.type] as? String {
            
            return PBXObjectType(isa).objectContainerType.isPBXEncodinStringEscaping(value,
                                                                                     hasKeyIndicators: hasKeyIndicators,
                                                                                     atPath: path,
                                                                                     inObject: obj,
                                                                                     inObjectList: objList,
                                                                                     inData: data,
                                                                                     userInfo: userInfo)
        } else {
            return hasKeyIndicators
        }
    }
}

extension PBXObjects: Sequence {
    public func makeIterator() -> Array<PBXObject>.Iterator {
        return self.objects.makeIterator()
    }
}
