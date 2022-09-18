//
//  PBXObjectType.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// Structure storing the PBX Object Type
public struct PBXObjectType: Hashable {
    
    #if !swift(>=4.0.4)
    public var hashValue: Int { return self.rawValue.hashValue }
    #endif
    
    internal let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let aggregateTarget: PBXObjectType = "PBXAggregateTarget"
    public static let nativeTarget: PBXObjectType = "PBXNativeTarget"
    public static let legacyTarget: PBXObjectType = "PBXLegacyTarget"
    public static let referenceProxy: PBXObjectType = "PBXReferenceProxy"
    
    public static let buildFile: PBXObjectType = "PBXBuildFile"
    public static let containerItemProxy: PBXObjectType = "PBXContainerItemProxy"
    public static let buildRule: PBXObjectType = "PBXBuildRule"
    
    public static let copyFilesBuildPhase: PBXObjectType = "PBXCopyFilesBuildPhase"
    public static let frameworksBuildPhase: PBXObjectType = "PBXFrameworksBuildPhase"
    public static let headersBuildPhase: PBXObjectType = "PBXHeadersBuildPhase"
    public static let resourcesBuildPhase: PBXObjectType = "PBXResourcesBuildPhase"
    public static let shellScriptBuildPhase: PBXObjectType = "PBXShellScriptBuildPhase"
    public static let appleScriptBuildPhase: PBXObjectType = "PBXAppleScriptBuildPhase"
    public static let sourceBuildPhase: PBXObjectType = "PBXSourcesBuildPhase"
    public static let carbonResourceBuildPhase: PBXObjectType = "PBXRezBuildPhase"
    
    public static let group: PBXObjectType = "PBXGroup"
    public static let variantGroup: PBXObjectType = "PBXVariantGroup"
    public static let versionGroup: PBXObjectType = "XCVersionGroup"
    
    public static let fileReference: PBXObjectType = "PBXFileReference"
    public static let project: PBXObjectType = "PBXProject"
    public static let targetDependency: PBXObjectType = "PBXTargetDependency"
    public static let buildConfiguration: PBXObjectType = "XCBuildConfiguration"
    public static let configuraitonList: PBXObjectType = "XCConfigurationList"
    
    private static let unknownTypeOrderValue: Int = 99
    
    /// The order value of the given object type.  This is used for sorting object types
    public var orderValue: Int {
        guard let idx = PBXObjectType.WRITE_ORDER.firstIndex(of: self) else { return PBXObjectType.unknownTypeOrderValue }
        return idx
    }
    
    /// The Type that this object type is related to
    public var objectContainerType: PBXObject.Type {
        guard let t = PBXObjectType.CONTAINER_TYPES[self.rawValue] else { return PBXUnknownObject.self }
        return t
    }
    
    private static var CONTAINER_TYPES: [String: PBXObject.Type] = ["PBXGroup": PBXGroup.self,
                                                                    "PBXVariantGroup": PBXGroup.self,
                                                                    "XCVersionGroup": XCVersionGroup.self,
                                                                    "PBXFileReference": PBXFileReference.self,
                                                                    "PBXBuildFile": PBXBuildFile.self,
                                                                    "PBXBuildRule": PBXBuildRule.self,
                                                                    "PBXContainerItemProxy": PBXContainerItemProxy.self,
                                                                    "PBXAggregateTarget": PBXAggregateTarget.self,
                                                                    "PBXNativeTarget": PBXNativeTarget.self,
                                                                    "PBXLegacyTarget": PBXLegacyTarget.self,
                                                                    "PBXTargetDependency": PBXTargetDependency.self,
                                                                    "PBXHeadersBuildPhase": PBXHeadersBuildPhase.self,
                                                                    "PBXCopyFilesBuildPhase": PBXCopyFilesBuildPhase.self,
                                                                    "PBXResourcesBuildPhase": PBXResourcesBuildPhase.self,
                                                                    "PBXSourcesBuildPhase": PBXSourcesBuildPhase.self,
                                                                    "PBXFrameworksBuildPhase": PBXFrameworksBuildPhase.self,
                                                                    "PBXShellScriptBuildPhase": PBXShellScriptBuildPhase.self,
                                                                    "PBXRezBuildPhase": PBXRezBuildPhase.self,
                                                                    "XCConfigurationList": XCConfigurationList.self,
                                                                    "XCBuildConfiguration": XCBuildConfiguration.self,
                                                                    "PBXProject": PBXProject.self]
    
    
    /// A static list of all object types in the order if writing to file
    public static let WRITE_ORDER: [PBXObjectType] = [.aggregateTarget,
                                                      .buildFile,
                                                      .buildRule,
                                                      .containerItemProxy,
                                                      .copyFilesBuildPhase,
                                                      .fileReference,
                                                      .frameworksBuildPhase,
                                                      .group,
                                                      .headersBuildPhase,
                                                      .legacyTarget,
                                                      .nativeTarget,
                                                      .project,
                                                      .resourcesBuildPhase,
                                                      .shellScriptBuildPhase,
                                                      .appleScriptBuildPhase,
                                                      .sourceBuildPhase,
                                                      .carbonResourceBuildPhase,
                                                      .targetDependency,
                                                      .variantGroup,
                                                      .versionGroup,
                                                      .buildConfiguration,
                                                      .configuraitonList]
    
    /// List of all build phases
    public static let BUILD_PHASES: [PBXObjectType] = [.copyFilesBuildPhase,
                                                       .frameworksBuildPhase,
                                                       .headersBuildPhase,
                                                       .resourcesBuildPhase,
                                                       .shellScriptBuildPhase,
                                                       .appleScriptBuildPhase,
                                                       .sourceBuildPhase,
                                                       .carbonResourceBuildPhase]
    
    
    /// List of all targets
    public static let TARGETS: [PBXObjectType] = [.aggregateTarget,
                                                  .nativeTarget,
                                                  .legacyTarget]
    /// List of all groups
    public static let GROUPS: [PBXObjectType] = [.group,
                                                 .variantGroup,
                                                 .versionGroup]
    
}

extension PBXObjectType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension PBXObjectType: CustomStringConvertible {
    public var description: String { return self.rawValue }
}



extension PBXObjectType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue)
    }
}

extension PBXObjectType: Equatable {
    public static func ==(lhs: PBXObjectType, rhs: PBXObjectType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXObjectType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: PBXObjectType) -> Bool {
        return lhs == rhs.rawValue
    }
}

extension PBXObjectType: Comparable {
    public static func < (lhs: PBXObjectType, rhs: PBXObjectType) -> Bool {
        guard lhs.rawValue != rhs.rawValue else { return false }
        return lhs.orderValue < rhs.orderValue
    }
    
    
}
