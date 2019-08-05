//
//  PBXLegacyTarget.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// PBX File Legacy Target
public final class PBXLegacyTarget: PBXTarget {
    internal enum LegacyTargetCodingKeys: String, CodingKey {
        public typealias parent = PBXTarget.TargetCodingKeys
        case buildToolPath
        case buildArgumentsString
        case passBuildSettingsInEnvironment
        case buildWorkingDirectory
    }
    
    private typealias CodingKeys = LegacyTargetCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.buildToolPath)
        rtn.append(CodingKeys.buildArgumentsString)
        rtn.append(CodingKeys.passBuildSettingsInEnvironment)
        rtn.append(CodingKeys.buildWorkingDirectory)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.buildToolPath)
        rtn.append(CodingKeys.buildArgumentsString)
        rtn.append(CodingKeys.passBuildSettingsInEnvironment)
        rtn.append(CodingKeys.buildWorkingDirectory)
        return rtn
    }
    
    
    /// Path to the build tool that is invoked (required)
    public var buildToolPath: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Build arguments to be passed to the build tool.
    public var buildArgumentsString: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Whether or not to pass Xcode build settings as environment variables down to the tool when invoked
    public var passBuildSettingsInEnvironment: Bool {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// The directory where the build tool will be invoked during a build
    public var buildWorkingDirectory: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    //public var productInstallPath: String?
    
    /// Create a new instance of a Legacy Target
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - name: Name of target
    ///   - buildConfigurationList: Reference to the build configuration (XCConfigurationList)
    ///   - buildPhases: An array of references to Build Phases (PBXBuildPhase)
    ///   - buildRules: An array of references to Build Rules (PBXBuildRule)
    ///   - dependencies: An arary of references to Dependencies (PBXTargetDependency)
    ///   - buildToolPath: Path to tool to use
    ///   - buildArgumentsString: Arguments to pass to tool
    ///   - passBuildSettingsInEnvironment: Indicator if build settings should be passed in env
    ///   - buildWorkingDirectory: Path for build working directory
    internal init(id: PBXReference,
                name: String,
                buildConfigurationList: PBXReference,
                buildPhases:  [PBXReference] = [],
                buildRules: [PBXReference] = [],
                dependencies: [PBXReference] = [],
                /*productName: String? = nil,
                productReference: PBXReference? = nil,
                productType: PBXProductType? = nil,*/
                buildToolPath: String? = nil,
                buildArgumentsString: String? = nil,
                passBuildSettingsInEnvironment: Bool = false,
                buildWorkingDirectory: String? = nil) {
        
        self.buildToolPath = buildToolPath
        self.buildArgumentsString = buildArgumentsString
        self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironment
        self.buildWorkingDirectory = buildWorkingDirectory
        
        super.init(id: id,
                   name: name,
                   targetType: .legacyTarget,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies:dependencies/*,
                   productName: productName,
                   productReference: productReference,
                   productType: productType*/)
        
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.buildToolPath = try container.decodeIfPresent(String.self, forKey: .buildToolPath)
        self.buildArgumentsString = try container.decodeIfPresent(String.self, forKey: .buildArgumentsString)
        if let iPassBuildSettingsInEnvironment = try container.decodeIfPresent(Int.self, forKey: .passBuildSettingsInEnvironment) {
            self.passBuildSettingsInEnvironment = (iPassBuildSettingsInEnvironment > 0)
        } else {
            self.passBuildSettingsInEnvironment = false
        }
        //self.passBuildSettingsInEnvironment = (try container.decodeIfPresent(Bool.self, forKey: .passBuildSettingsInEnvironment)) ?? false
        self.buildWorkingDirectory = try container.decodeIfPresent(String.self, forKey: .buildWorkingDirectory)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.buildToolPath, forKey: .buildToolPath)
        try container.encodeIfPresent(self.buildArgumentsString, forKey: .buildArgumentsString)
        if self.passBuildSettingsInEnvironment { try container.encode(1, forKey: .passBuildSettingsInEnvironment) }
        else { try container.encode(0, forKey: .passBuildSettingsInEnvironment) }
        
        try container.encodeIfPresent(self.buildWorkingDirectory, forKey: .buildWorkingDirectory)
        
        try super.encode(to: encoder)
    }
}
