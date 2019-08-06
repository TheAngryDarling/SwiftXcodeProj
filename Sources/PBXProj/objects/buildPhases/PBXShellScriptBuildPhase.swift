//
//  PBXShellScriptBuildPhase.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// A Shell Script Build Phase
public final class PBXShellScriptBuildPhase: PBXBuildPhase {
    /// Shell Script Build Phase Coding Keys
    internal enum ShellScriptBuildPhaseCodingKeys: String, CodingKey {
        public typealias parent = PBXBuildPhase.BuildPhaseCodingKeys
        case name
        case inputFileListPaths
        case inputPaths
        case outputPaths
        case shellPath
        case shellScript
        case showEnvVarsInLog
    }
    
    private typealias CodingKeys = ShellScriptBuildPhaseCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        let pathKeys: [CodingKeys] = [.inputFileListPaths, .inputPaths, .outputPaths]
        if let idx = rtn.index(of: CodingKeys.parent.runOnlyForDeploymentPostprocessing) {
            rtn.insert(contentsOf: pathKeys, at: idx)
        } else {
            rtn.append(contentsOf: pathKeys)
        }
        rtn.append(CodingKeys.shellPath)
        rtn.append(CodingKeys.shellScript)
        rtn.append(CodingKeys.showEnvVarsInLog)
        return rtn

    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.inputFileListPaths)
        rtn.append(CodingKeys.inputPaths)
        rtn.append(CodingKeys.outputPaths)
        rtn.append(CodingKeys.shellPath)
        rtn.append(CodingKeys.shellScript)
        rtn.append(CodingKeys.showEnvVarsInLog)
        return rtn
    }
    
    
    /// The default building action mask
    public static let DEFAULT_BUILD_ACTION_MAKS: UInt = 12
    
    /// The Action mask for Install Script
    public static let INSTALL_BUILD_ACTION_MAKS: UInt = 8
    
    /// The default shell path
    public static let DEFAULT_SHELL_PATH: String = "/bin/sh"
    
    /// Element name
    public var name: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    ///Input files list path
    public var inputFileListPaths: [String] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Input paths
    public var inputPaths: [String] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Output paths
    public var outputPaths: [String] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Path to the shell.
    public var shellPath: String {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Shell script.
    public var shellScript: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Show Environmental variables in log
    public var showEnvVarsInLog: Bool {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Only run script when installing
    public var runScriptOnlyWhenInstalling: Bool {
        get {
            return (self.buildActionMask == PBXShellScriptBuildPhase.INSTALL_BUILD_ACTION_MAKS)
        }
        set {
            guard newValue != runScriptOnlyWhenInstalling else { return }
            if newValue { self.buildActionMask = PBXShellScriptBuildPhase.INSTALL_BUILD_ACTION_MAKS }
            else { self.buildActionMask =  PBXShellScriptBuildPhase.DEFAULT_BUILD_ACTION_MAKS }
        }
    }
    
    /// Create a new insatnce of Shell Script Build Phase
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - name: The name of the build action (Optional)
    ///   - buildActionMask: he build action for this build phase (Default: DEFAULT_BUILD_ACTION_MAKS)
    ///   - files: An array of references to Build Files
    ///   - runOnlyForDeploymentPostprocessing: An indicator if should run only for deployment post processing
    ///   - inputFileListPaths: The input file list paths (Default: Empty Array)
    ///   - inputPaths: The input  paths (Default: Empty Array)
    ///   - outputPaths: The output paths (Default: Empty Array)
    ///   - shellPath: The path to the shell to use (Default: DEFAULT_SHELL_PATH)
    ///   - shellScript: The script to execute (Optional)
    internal init(id: PBXReference,
                name: String? = nil,
                buildActionMask: UInt = PBXShellScriptBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                files: [PBXReference] = [],
                runOnlyForDeploymentPostprocessing: UInt = 0,
                inputFileListPaths: [String] = [],
                inputPaths: [String] = [],
                outputPaths: [String] = [],
                shellPath: String = PBXShellScriptBuildPhase.DEFAULT_SHELL_PATH,
                shellScript: String? = nil,
                showEnvVarsInLog: Bool = true) {
        
        self.name = name
        self.inputFileListPaths = inputFileListPaths
        self.inputPaths = inputPaths
        self.outputPaths = outputPaths
        self.shellPath = shellPath
        self.shellScript = shellScript
        self.showEnvVarsInLog = showEnvVarsInLog
        
        super.init(id: id,
                   buildPhaseType: .shellScriptBuildPhase,
                   buildActionMask: buildActionMask,
                   files: files,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.inputFileListPaths = try container.decodeIfPresent([String].self, forKey: .inputFileListPaths, withDefaultValue: [])
        self.inputPaths = try container.decodeIfPresent([String].self, forKey: .inputPaths, withDefaultValue: [])
        self.outputPaths = try container.decodeIfPresent([String].self, forKey: .outputPaths, withDefaultValue: [])
        self.shellPath = try container.decode(String.self, forKey: .shellPath)
        self.shellScript = try container.decodeIfPresent(String.self, forKey: .shellScript)
        self.showEnvVarsInLog = (try container.decodeIfPresent(Int.self, forKey: .showEnvVarsInLog, withDefaultValue: 1)) > 0
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encode(self.inputFileListPaths, forKey: .inputFileListPaths)
        try container.encode(self.inputPaths, forKey: .inputPaths)
        try container.encode(self.outputPaths, forKey: .outputPaths)
        try container.encode(self.shellPath, forKey: .shellPath)
        try container.encodeIfPresent(self.shellScript, forKey: .shellScript)
        try container.encode(Int(self.showEnvVarsInLog), forKey: .showEnvVarsInLog, ifNot: Int(true))
        /*if !self.showEnvVarsInLog {
            try container.encode(0, forKey: .showEnvVarsInLog)
        }*/
        try super.encode(to: encoder)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        havingObjectVersion objectVersion: Int,
                                                        havingArchiveVersion archiveVersion: Int,
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        if path.count == 2  { return PBXBuildPhase.PBXBuildPhaseType.shellScriptBuildPhase.rawValue }
        return super.getPBXEncodingComments(forValue: value,
                                            atPath: path,
                                            inObject: object,
                                            inObjectList: objectList,
                                            inData: data,
                                            havingObjectVersion: objectVersion,
                                            havingArchiveVersion: archiveVersion,
                                            userInfo: userInfo)
    }
}
