//
//  PBXUnknownObject.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import AdvancedCodableHelpers
import RawRepresentableHelpers

public class PBXUnknownObject: PBXObject {
    /// All the unknown properties of the object.
    public let properties: [String: Any]
    
    /// An array of the known properties of the object.
    ///
    /// This property should be overriden in subclasses to return all the properties that should NOT be loaded into the properties property
    internal class var knownProperties: [String] { return [PBXObject.ObjectCodingKeys.id.rawValue,
                                                           PBXObject.ObjectCodingKeys.type.rawValue] }
    
    /// Create a new instance of a PBXObject
    ///
    /// - Parameters:
    ///   - id: The unqiue refrence to this object
    ///   - type: The type of this object
    internal override init(id: PBXReference, type: PBXObjectType) {
        self.properties = [:]
        super.init(id: id, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        var props: [String: Any] = try CodableHelpers.dictionaries.decode(from: decoder, excludingKeys: Swift.type(of: self).knownProperties)
        //if props.keys.contains(PBXObject.ObjectCodingKeys.id) { props.removeValue(forKey: PBXObject.ObjectCodingKeys.id) }
        //if props.keys.contains(PBXObject.ObjectCodingKeys.type) { props.removeValue(forKey: PBXObject.ObjectCodingKeys.type) }
        
        // A patch to fix issue where Empty String arrays get parsed as Empty Data objects from the CodableHelpers.dictionaries.decode method
        for key in props.keys {
            if let v = props[key] as? Data, v.count == 0 {
                props[key] = Array<String>()
            }
         }
        self.properties = props
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var props = self.properties
       
        for prop in  Swift.type(of: self).knownProperties {
            props.removeValue(forKey: prop)
        }
        //if props.keys.contains(PBXObject.ObjectCodingKeys.id) { props.removeValue(forKey: PBXObject.ObjectCodingKeys.id) }
        //if props.keys.contains(PBXObject.ObjectCodingKeys.type) { props.removeValue(forKey: PBXObject.ObjectCodingKeys.type) }
        //var enc = encoder
        try CodableHelpers.dictionaries.encode(props, to: encoder)
        try super.encode(to: encoder)
    }
}
