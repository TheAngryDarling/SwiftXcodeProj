//
//  XCConfigurationList.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-27.
//

import Foundation
import RawRepresentableHelpers

/// A Build Configuration List
public final class XCConfigurationList: PBXUnknownObject {
    /// Configuration List Coding Keys
    internal enum ConfigurationListCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case buildConfigurations
        case defaultConfigurationIsVisible
        case defaultConfigurationName
    }
    
    private typealias CodingKeys = ConfigurationListCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.buildConfigurations)
        rtn.append(CodingKeys.defaultConfigurationIsVisible)
        rtn.append(CodingKeys.defaultConfigurationName)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.buildConfigurations)
        rtn.append(CodingKeys.defaultConfigurationIsVisible)
        rtn.append(CodingKeys.defaultConfigurationName)
        return rtn
    }
    
    /// Default configuration is visible value: 0
    public static let DEFAULT_CONFIGURATION_IS_VISIBLE: Int = 0
    /// Default Configration name value: Debug
    public static let DEFAULT_CONFIGURATION_NAME: String = "Debug"
    
    /// An array of references to build configurations
    public private(set) var buildConfigurationReferences: [PBXReference]
    /// An array of build configurations for this list
    ///
    /// This will use the buildConfigurationReferences and search through the object list to find all build configurations
    public var buildConfigurations: [XCBuildConfiguration] {
        get {
            return self.objectList.objects(withReferences: self.buildConfigurationReferences,
                                                asType: XCBuildConfiguration.self)
        }
        set {
            self.buildConfigurationReferences = newValue.map { $0.id }
        }
    }
    /// Indicator if the default configuration is visible
    public let defaultConfigurationIsVisible: Int
    /// The name of the default configuration
    public var defaultConfigurationName: String
    
    /// Create a new instance of Configuration List
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - buildConfigurations: An array of references to Build Configurations (Default: Empty Array)
    ///   - defaultConfigurationIsVisible: Indicator if the default configuration is visible (Default: DEFAULT_CONFIGURATION_IS_VISIBLE)
    ///   - defaultConfigurationName: The name of default configuration (Default: DEFAULT_CONFIGURATION_NAME)
    internal init(id: PBXReference,
                buildConfigurations: [PBXReference] = [],
                defaultConfigurationIsVisible: Int = XCConfigurationList.DEFAULT_CONFIGURATION_IS_VISIBLE,
                defaultConfigurationName: String = XCConfigurationList.DEFAULT_CONFIGURATION_NAME) {
        self.buildConfigurationReferences = buildConfigurations
        self.defaultConfigurationIsVisible = defaultConfigurationIsVisible
        self.defaultConfigurationName = defaultConfigurationName
        
        super.init(id: id, type: .configuraitonList)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buildConfigurationReferences = try container.decode([PBXReference].self, forKey: .buildConfigurations)
        self.defaultConfigurationIsVisible = try container.decode(Int.self, forKey: .defaultConfigurationIsVisible)
        self.defaultConfigurationName = try container.decode(String.self, forKey: .defaultConfigurationName)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.buildConfigurationReferences, forKey: .buildConfigurations)
        try container.encode(self.defaultConfigurationIsVisible, forKey: .defaultConfigurationIsVisible)
        try container.encode(self.defaultConfigurationName, forKey: .defaultConfigurationName)
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        let cfgs = self.buildConfigurations
        // Remove all configurations from the configuration list
        for cfg in cfgs {
            self.objectList.remove(cfg)
        }
        super.deleting()
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.buildConfigurationReferences.contains(objectReference) { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 2 {
            for (_, v) in objectList {
                if let dV = v as? [String: Any],
                    let isa = dV[CodingKeys.parent.type] as? String,
                    isa.hasSuffix("Target"),
                    let buildConfig = dV[PBXTarget.TargetCodingKeys.buildConfigurationList] as? String,
                    buildConfig == value,
                    let targetName = dV[PBXTarget.TargetCodingKeys.name] as? String{
                    return "Build configuration list for \(isa) \"\(targetName)\""
                    
                } else if let dV = v as? [String: Any],
                    let isa = dV[CodingKeys.parent.type] as? String,
                    isa == PBXObjectType.project, /*"PBXProject",*/
                    let buildConfig = dV[PBXProject.ProjectCodingKeys.buildConfigurationList] as? String,
                    buildConfig == value {
                    
                    if let key = CodingUserInfoKey(rawValue: "Project"), let p = userInfo[key] as? String {
                        return "Build configuration list for \(isa) \"\(p)\""
                    } else {
                        // The real comment has the project file name as well. but we don't have access to it here
                        return "Build configuration list for \(isa)"
                    }
                    
                }
            }
            return nil
        } else if path.count == 4 && path[2] == CodingKeys.buildConfigurations {
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
        if path.count > 2 && path[path.count-2] == CodingKeys.buildConfigurations { return false }
        return hasKeyIndicators
    }
}
