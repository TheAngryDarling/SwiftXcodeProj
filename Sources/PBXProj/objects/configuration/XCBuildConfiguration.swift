//
//  XCBuildConfiguration.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-27.
//

import Foundation
import CodableHelpers
import RawRepresentableHelpers

/// A Build Configuration for a Project or Target
public final class XCBuildConfiguration: PBXUnknownObject {
    /// Build Configuration Coding Keys
    internal enum BuildConfiguratonCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case baseConfigurationReference
        case buildSettings
        case name
    }
    
    private typealias CodingKeys = BuildConfiguratonCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.baseConfigurationReference)
        rtn.append(CodingKeys.buildSettings)
        rtn.append(CodingKeys.name)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.baseConfigurationReference)
        rtn.append(CodingKeys.buildSettings)
        return rtn
    }
    
    
    /// The reference to a base configuration if required
    public private(set) var baseConfigurationReferenceReference: PBXReference?
    /// The base build configuraton for this configuration if one is set
    public var baseConfigurationReference: XCBuildConfiguration? {
        get {
            guard let r = self.baseConfigurationReferenceReference else { return nil }
            return self.objectList.object(withReference: r, asType: XCBuildConfiguration.self)
        }
        set {
            self.baseConfigurationReferenceReference = newValue?.id
        }
    }
    /// The build settings for this configuration
    public var buildSettings: [String: Any]
    /// The complete build settings for this configuration.  This will take any base configuration settings and combind them with the local settings
    public var completeBuildSettings: [String: Any] {
        var rtn: [String: Any] = [:]
        if let baseSettings = self.baseConfigurationReference {
            rtn = baseSettings.completeBuildSettings
        }
        for (k,v) in self.buildSettings {
            rtn[k] = v
        }
        return rtn
    }
    /// The name of this configuration
    public var name: String
    
    /// Create an instance of a Build Configuration
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - name: the name of this configuration
    ///   - baseConfigurationReference: The base configuration for this one if required (Optional)
    ///   - buildSettings: The settings for this configuration
    internal init(id: PBXReference,
                  name: String,
                  baseConfigurationReference: PBXReference? = nil,
                  buildSettings: [String: Any] = [:]) {
        self.baseConfigurationReferenceReference = baseConfigurationReference
        self.buildSettings = buildSettings
        self.name = name
        
        super.init(id: id, type: .buildConfiguration)
    }
    
    public required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        
        self.baseConfigurationReferenceReference = try container.decodeIfPresent(PBXReference.self,
                                                                                 forKey: .baseConfigurationReference)
        self.buildSettings = (try CodableHelpers.dictionaries.decodeIfPresent(from: &container, forKey: .buildSettings)) ?? [:]
        
        try super.init(from: decoder)
        
        //print("\(decoder.codingPath.stringCodingPath + "/" + self.name): ")
        //print(self.buildSettings)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.baseConfigurationReferenceReference,
                                      forKey: .baseConfigurationReference)
        try CodableHelpers.dictionaries.encode(self.buildSettings, in: &container,
                                           forKey: .buildSettings)
        try container.encode(self.name, forKey: .name)
        
        try super.encode(to: encoder)
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.baseConfigurationReferenceReference == objectReference { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 2, let name = object[CodingKeys.name] as? String {
            return name
        } else if path.count == 3 && path[2] == CodingKeys.baseConfigurationReference {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                                     inData: data,
                                                     userInfo: userInfo)
        }
        
        return nil
    }
    
    internal override class func isPBXEncodinStringEscaping(_ value: String,
                                                            hasKeyIndicators: Bool,
                                                            atPath path: [String],
                                                            inObject object: [String: Any],
                                                            inObjectList objectList: [String: Any],
                                                            inData: [String: Any],
                                                            userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if path.last == CodingKeys.baseConfigurationReference { return false }
        return hasKeyIndicators
    }
}


public extension Array where Element == XCBuildConfiguration {
    /// Get a build configuration based on its name
    ///
    /// - Parameter configName: The name of the configuration to find
    subscript(configName: String) -> XCBuildConfiguration? {
        for c in self {
            if c.name == configName { return c }
        }
        return nil
    }
}
