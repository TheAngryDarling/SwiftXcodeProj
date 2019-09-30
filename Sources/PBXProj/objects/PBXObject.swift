//
//  XcodeProjObject.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-20.
//

import Foundation

/// A base class for all PBX Objects
public class PBXObject: NSObject, Codable {
    
    /// Base PBX Object Coding Keys
    internal enum ObjectCodingKeys: String, CodingKey {
        case id
        case type = "isa"
        
        static let allKeys: [String] = [ObjectCodingKeys.id.rawValue, ObjectCodingKeys.type.rawValue]
    }
   
    //internal static let REFRENCE_CODING_KEY: String = ObjectCodingKeys.id.rawValue
    //internal static let ISA_CODING_KEY: String = ObjectCodingKeys.type.rawValue
    
    /// List of all coding keys in the order they should be written to the file
    internal class var CODING_KEY_ORDER: [String] {
        return [ObjectCodingKeys.id.rawValue, ObjectCodingKeys.type.rawValue]
    }
    
    /// Element reference. The unique id of the current object (A 96 bits identifier)
    public let id: PBXReference
    /// Element isa. The object type of the current object
    public let type: PBXObjectType
    /// A reference to the object list.  This may be nil until the object is added to the object list
    public var objectList: PBXObjects!
    /// A reference to the main PBXProj file.  This may be nil until the object is added to the object list
    internal var proj: PBXProj! { return self.objectList?.proj }
    
    /// Create a new instance of a PBXObject
    ///
    /// - Parameters:
    ///   - id: The unqiue refrence to this object
    ///   - type: The type of this object
    internal init(id: PBXReference, type: PBXObjectType) {
        self.id = id
        self.type = type
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  ObjectCodingKeys.self)
        
        self.id = try container.decode(PBXReference.self, forKey: .id)
        self.type = try container.decode(PBXObjectType.self, forKey: .type)
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ObjectCodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
    }
    
    
    /// Deletes any connected reference to the current object
    ///
    /// Overridable method for ensuring that when this object if removed, it can clean up any references to it elsewhere.
    /// This method should be overridden in child classe and call the inherited deleted after local clean up is done
    internal func deleting() {
        // Override this in sub classes to remove any reference from other objects
    }
    
    /// Method for returning the property coding keys in the order they should be written to file in
    ///
    /// - Parameters:
    ///   - content: The content of the given object (key/value) paris
    ///   - data: The data of all objects in the file
    ///   - path: The path of the given object in the file
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    /// - Returns: Reutrns an array of the keys in the order they should be written in
    internal static func getPBXEncodingOrderKeys(_ content: [String: Any],
                                                inData data: [String: Any],
                                                atPath path: [String],
                                                havingObjectVersion objectVersion: Int,
                                                havingArchiveVersion archiveVersion: Int) -> [String] {
        if path.count == 2 {
            var workingKeys: [String] = []
            workingKeys.append(contentsOf: content.keys)
            var definedKeys: [String] = []
            
            for k in self.CODING_KEY_ORDER {
                //ensure definedKeys only contains keys within workingKeys
                if let idx = workingKeys.index(of: k) {
                    definedKeys.append(k)
                    //Remove key from workingKeys.  it will be put back in later
                    workingKeys.remove(at: idx)
                }
            }
            var rtn = getPBXEncodingOrderKeys(workingKeys,
                                              content, atPath: path,
                                              havingObjectVersion: objectVersion,
                                              havingArchiveVersion: archiveVersion)
            //Add back in the defined keys
            rtn.insert(contentsOf: definedKeys, at: 0)
            return rtn
        } else {
            return content.keys.sorted()
        }
        
    }
    
    /// Method for returning the property coding keys in the order they should be written to file in
    ///
    /// This method will ensure that any id (Reference) key and ISA keys are at the very beginning
    ///
    /// - Parameters:
    ///   - workingKeys: All current keys in the object
    ///   - content: The content of the object
    ///   - path: Current path of the object
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    /// - Returns: Reutrns an array of the keys in the order they should be written in
    internal class func getPBXEncodingOrderKeys(_ workingKeys: [String],
                                                _ content: [String: Any],
                                                atPath path: [String],
                                                havingObjectVersion objectVersion: Int,
                                                havingArchiveVersion archiveVersion: Int) -> [String] {
        guard workingKeys.count > 0 else { return [] }
        var workingKeys = workingKeys
       
        var hasRefrense: Bool = false
        if let idx = workingKeys.index(of: ObjectCodingKeys.id) {
            workingKeys.remove(at: idx)
            hasRefrense = true
        }
        
        
        var hasISA: Bool = false
        if let idx = workingKeys.index(of: ObjectCodingKeys.type) {
            workingKeys.remove(at: idx)
            hasISA = true
        }
        var fieldKeys: [String] = []
        var arrayKeys: [String] = []
        var objectKeys: [String] = []
        //Group keys by value types (Dictionaries, Arrays, Simple)
        for key in workingKeys {
            if let v = content[key] {
                if let _ = v as? [String: Any] {
                    objectKeys.append(key)
                } else if let _ = v as? [Any] {
                    arrayKeys.append(key)
                } else {
                    fieldKeys.append(key)
                }
            }
        }
        
        fieldKeys.sort()
        arrayKeys.sort()
        objectKeys.sort()
        
        var rtn: [String] = []
        if hasRefrense { rtn.append(ObjectCodingKeys.id) }
        if hasISA { rtn.append(ObjectCodingKeys.type) }
        rtn.append(contentsOf: fieldKeys)
        rtn.append(contentsOf: arrayKeys)
        rtn.append(contentsOf: objectKeys)
        
        return rtn
    }
    
    /// Method to indicate if this object type is a multi-line object when writing to file
    ///
    /// - Parameters:
    ///   - content: The content of this object
    ///   - path: The path of this object with the file
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Custom user properites
    /// - Returns: Returns true if this is a multi-line object, otherwise false
    internal class func isPBXEncodingMultiLineObject(_ content: [String: Any],
                                                     atPath path: [String],
                                                     havingObjectVersion objectVersion: Int,
                                                     havingArchiveVersion archiveVersion: Int,
                                                     userInfo: [CodingUserInfoKey: Any])-> Bool {
        return true
    }
    
    /// Returns the PBX comments for the given object
    ///
    /// - Parameters:
    ///   - value: The value being written
    ///   - path: The path of this object within the file
    ///   - object: The current object the value is being written from
    ///   - objectList: The current PBX Object List data
    ///   - inData: Dictionary of all data from the file
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Custom user properites
    /// - Returns: Returns the object comments if any exists
    internal class func getPBXEncodingComments(forValue value: String,
                                               atPath path: [String],
                                               inObject object: [String: Any],
                                               inObjectList objectList: [String: Any],
                                               inData: [String: Any],
                                               havingObjectVersion objectVersion: Int,
                                               havingArchiveVersion archiveVersion: Int,
                                               userInfo: [CodingUserInfoKey: Any]) -> String? {
        return nil
    }
    
    
    /// Mehod to determin if the value should be string escaped
    ///
    /// - Parameters:
    ///   - value: value to check
    ///   - hasKeyIndicators: Indicator whether this value had characters that needed to be escaped
    ///   - path: Path of the current object
    ///   - object: Current object data
    ///   - objectList: Object List data
    ///   - inData: File Data
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Custom user properties
    /// - Returns: Reutrns true if the value should be escaped, otherwise false
    internal class func isPBXEncodinStringEscaping(_ value: String,
                                                 hasKeyIndicators: Bool,
                                                 atPath path: [String],
                                                 inObject object: [String: Any],
                                                 inObjectList objectList: [String: Any],
                                                 inData: [String: Any],
                                                 havingObjectVersion objectVersion: Int,
                                                 havingArchiveVersion archiveVersion: Int,
                                                 userInfo: [CodingUserInfoKey: Any]) -> Bool {
        return hasKeyIndicators
    }
    
    /// Checks to see if current object has any reference to the provided object reference
    ///
    /// - Parameter objectReference: The object id to see if there is a reference connection
    /// - Returns: Returns true if there is a reference connection, otherwise false
    internal func hasReference(to objectReference: PBXReference) -> Bool {
        return false
    }
    
    /// Checks to see if current object has any reference to the provided object
    ///
    /// - Parameter object: The object to see if there is a reference connection
    /// - Returns: Returns true if there is a reference connection, otherwise false
    internal func hasReference(to object: PBXObject) -> Bool {
        return hasReference(to: object.id)
    }
}








