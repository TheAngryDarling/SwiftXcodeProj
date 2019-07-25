import Foundation
import CodableHelpers
import PBXProj
import CodeTimer
//import LeveledCustomStringConvertible

public class XcodeProject {
    
    public typealias XcodeRegion = PBXProject.PBXRegion
    public typealias ProjectBuildConfigurationOptions = PBXProj.ProjectBuildConfigurationOptions
    
    public typealias TargetBuildConfigurationListOptions = PBXProject.BuildConfigurationListOptions
    
    public enum Error: Swift.Error {
        case missingPBXProjectFile(URL)
    }
    
    /// The PBX Project File encoding settings
    public struct PBXFileSettings {
        var encoding: String.Encoding
        var tabbing: String
        
        public init(encoding: String.Encoding = String.Encoding.utf8,
                    tabbing: String = "\t") {
            self.encoding = encoding
            self.tabbing = tabbing
        }
    }
    
    /// The PBX Project File file name
    private static let PBX_PROJECT_FILE_NAME: String = "project.pbxproj"
    /// The Xcode project package extension
    public static let XCODE_PROJECT_EXT: String = "xcodeproj"
    /// The Xcode project workspace file name
    private static let PROJECT_WORKSPACE_PACKAGE_NAME: String = "project.xcworkspace"
    
    
    /// The file system provider used while working with this project
    internal private(set) var fsProvider: XcodeFileSystemProvider
    /// The Xcode project package path
    internal private(set) var url: XcodeFileSystemURLResource
    /// The parent (project) folder
    internal var parentURL: XcodeFileSystemURLResource { return self.url.deletingLastPathComponent() }
    
    /// The PBX Project file
    internal let proj: PBXProj
    /// The PBX Project file encoding settings
    public let projFileSettings: PBXFileSettings
    
    /// The Xcode workspace if there is one
    internal weak var xCodeWorkspace: XcodeWorkspace? = nil
    
    /// The name of the Xcode project
    public var name: String
    
    /// The project workspace
    private var _workspace: XCWorkspace? = nil
    /// The project shared data
    private var _sharedData: XCSharedData? = nil
    /// The project user data list
    private var _userdataList: XCUserDataList? = nil
    
    /// Access to the file resources for this project
    public private(set) var resources: XcodeMainProjectGroup! = nil
    /// An array of all the different targets of this project
    public internal(set) var targets: [XcodeTarget] = []
    
    /// Any pending save actions (Used when created a new project)
    internal var pendingSaveActions: [XcodeFileSystemProviderAction] = []
    /// Indicator if this is a new project or not
    internal var isNewProject: Bool = false
    
    
    /// Open up an Xcode project
    ///
    /// - Parameters:
    ///   - url: The url to the project to open
    ///   - provider: The file system provider to use to read the project
    ///   - withPBXFile: The PBX Project File
    ///   - havingPBXSettings: The PBX Project File encoding settings
    ///   - workspace: The project workspace (Optional)
    ///   - sharedData: The project shared data (Optional)
    ///   - userdataList: The project user data list (Optional)
    ///   - targetInfos: An array of all target user info's
    ///   - isNewProject: An indicator if this is a new project or not
    internal init(fromURL url: XcodeFileSystemURLResource,
                  usingFSProvider provider: XcodeFileSystemProvider,
                  withPBXFile: PBXProj,
                  havingPBXSettings: PBXFileSettings,
                  workspace: XCWorkspace? = nil,
                  sharedData: XCSharedData? = nil,
                  userdataList: XCUserDataList? = nil,
                  targetInfos: [String: [String: Any]] = [:],
                  isNewProject: Bool) throws {
        
        
        self.url = url
        self.fsProvider = provider
        
        self.name = NSString(string: url.lastPathComponent).deletingPathExtension
        
        self.proj = withPBXFile
        self.projFileSettings = havingPBXSettings
        
        self.isNewProject = isNewProject
        
        
        // setup resources
        /// Create main group from PBX main group. This will also go through all sub items in the PBX group and create Xcode equivilatns for
        self.resources = XcodeMainProjectGroup(self, self.proj.mainGroup)
        let _ = Timer.time {
            // Load Targers
            for t in self.proj.objects.targets {
                if let aT = t as? PBXAggregateTarget {
                    self.targets.append(XcodeAggregatedTarget(self, aT, targetInfos[t.name] ?? [:], isNew: isNewProject))
                } else if let lT = t as? PBXLegacyTarget {
                    self.targets.append(XcodeLegacyTarget(self, lT, targetInfos[t.name] ?? [:], isNew: isNewProject))
                } else if let nT = t as? PBXNativeTarget {
                    self.targets.append(XcodeNativeTarget(self, nT, targetInfos[t.name] ?? [:], isNew: isNewProject))
                } else {
                    self.targets.append(XcodeTarget(self, t, targetInfos[t.name] ?? [:], isNew: isNewProject))
                }
            }
        }
    }
    
    /// Create a new Xcode project
    ///
    /// - parameters:
    ///   - url: The resource path of the project.  The name is that last component of the path
    ///   - provider: The resource provider.  Used for reading/writing to the filesystem
    ///   - havingPBXSettings: The PBX File settings. Stores the tabbing and encoding
    ///   - workspace: The Xcode Workspace
    ///   - sharedData: The Xcode Shared Data
    ///   - userdataList: The Xcode user data list
    ///   - pbxArchiveVersion: The PBX Project file archive version
    ///   - pbxObjectVersion: The PBX Project file object version
    ///   - pbxClasses: The PBX Project file classes properties
    ///   - buildSettings: The build settings for the Project
    ///   - xCodeCompatibilityVersion: The Xcode version compatibility string
    ///   - developmentRegion: The development region (Default to current local if possible)
    ///   - hasScannedForEncodings: Indicator if has scanned for encodings
    ///   - knownRegions: The known development regions (Default to current local if possible)
    ///   - projectDirPath: The project dir path (Default: nil)
    ///   - projectRoot: The project dir path (Default: nil)
    ///   - attributes: The project attributes
    public convenience init(fromURL url: XcodeFileSystemURLResource,
                            usingFSProvider provider: XcodeFileSystemProvider,
                            havingPBXSettings: PBXFileSettings = PBXFileSettings(),
                            workspace: XCWorkspace? = nil,
                            sharedData: XCSharedData? = nil,
                            userdataList: XCUserDataList? = nil,
                            pbxArchiveVersion: Int,
                            pbxObjectVersion: Int,
                            pbxClasses: [String: Any] = [:],
                            buildSettings: ProjectBuildConfigurationOptions,
                            xCodeCompatibilityVersion: String,
                            developmentRegion: XcodeRegion? = XcodeRegion.shortRegion(),
                            hasScannedForEncodings: Int? = nil,
                            knownRegions: [PBXProject.PBXRegion] = PBXProject.PBXRegion.knownRegions(),
                            projectDirPath: String? = nil,
                            projectRoot: String? = nil,
                            attributes: [String: Any] = [:] ) throws {
        
        
        let pbx = PBXProj(archiveVersion: pbxArchiveVersion,
                          objectVersion: pbxObjectVersion,
                          classes: pbxClasses,
                          settings: buildSettings,
                          compatibilityVersion: xCodeCompatibilityVersion,
                          developmentRegion: developmentRegion,
                          hasScannedForEncodings: hasScannedForEncodings,
                          knownRegions: knownRegions,
                          projectDirPath: projectDirPath,
                          projectReferences: [],
                          projectRoot: projectRoot,
                          attributes: attributes)
        
        let xcodeProjFolder = url.appendingPathComponent(url.lastPathComponent + "." + XcodeProject.XCODE_PROJECT_EXT, isDirectory: true)
        
        try self.init(fromURL: xcodeProjFolder,
                      usingFSProvider: provider,
                      withPBXFile: pbx,
                      havingPBXSettings: havingPBXSettings,
                      workspace: workspace,
                      sharedData: sharedData,
                      userdataList: userdataList,
                      targetInfos: [:],
                      isNewProject: true)
        
        
        
        
        /// Create project folder
        self.pendingSaveActions.append(.createDirectory(at: url, withIntermediateDirectories: false))
        /// Create .xcodeproj folder
        self.pendingSaveActions.append(.createDirectory(at: xcodeProjFolder, withIntermediateDirectories: false))
        
    }
    
    /// Open up an Xcode project
    ///
    /// - Parameters:
    ///   - url: The url to the project to open
    ///   - provider: The file system provider to use to read the project
    public init(fromURL url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider = LocalXcodeFileSystemProvider.newInstance) throws {
       // let initStart: Date = Date()
        self.url = url
        // xcode project files are actually folders
        if !self.url.isDirectory {
            self.url = .directory(self.url.realURL, self.url.modificationDate)
        }
        //self.url = XcodeFileSystemURLResource.directory(url, provider)
        self.fsProvider = provider
        
        self.name = NSString(string: url.lastPathComponent).deletingPathExtension
        
        
        // Read PBXProj file
        let pbxProjFileURL = self.url.appendingPathComponent(XcodeProject.PBX_PROJECT_FILE_NAME, isDirectory: false)
        
        guard let dta = try provider.dataIfExists(from: pbxProjFileURL) else {
            throw Error.missingPBXProjectFile(pbxProjFileURL.realURL)
        }
        

        let decoder = PBXProjDecoder()
        let pbxT: (TimeInterval, PBXProj) = try Timer.timeWithResults {
            //return try decoder.decode(PBXProj.self, from: dta)
            return try decoder.decode(from: dta)
        }
        //debugPrint("Load time for XcodeProject.proj: \(pbxT.0) s")
        self.proj = pbxT.1
        self.projFileSettings = PBXFileSettings(encoding: decoder.encoding, tabbing: decoder.tabs)
        
        
        // setup resources
        /// Create main group from PBX main group. This will also go through all sub items in the PBX group and create Xcode equivilatns for
        self.resources = XcodeMainProjectGroup(self, self.proj.mainGroup)
        let _ /*tgT*/ = try Timer.time {
            // Load Targers
            for t in self.proj.objects.targets {
                if let aT = t as? PBXAggregateTarget {
                    self.targets.append(try XcodeAggregatedTarget(self, aT))
                } else if let lT = t as? PBXLegacyTarget {
                    self.targets.append(try XcodeLegacyTarget(self, lT))
                } else if let nT = t as? PBXNativeTarget {
                    self.targets.append(try XcodeNativeTarget(self, nT))
                } else {
                    self.targets.append(try XcodeTarget(self, t))
                }
            }
        }
        //debugPrint("Load time for XcodeProject.targets: \(tgT) s")
        
        //let initDuration = initStart.timeIntervalSinceNow.magnitude
        //debugPrint("XcodeProject.init: \(initDuration) s")
        
    }
    
    /// Open up an Xcode project
    ///
    /// - Parameters:
    ///   - url: The url to the project to open
    ///   - provider: The file system provider to use to read the project
    public convenience init(fromURL url: URL,
                            usingFSProvider provider: XcodeFileSystemProvider = LocalXcodeFileSystemProvider.newInstance) throws {
        try self.init(fromURL: .directory(url, nil), usingFSProvider: provider)
    }
    
    
    
    
    /// The project workspace
    ///
    /// This will open if needed and then return the workspace for this project
    /// - Returns: Returns the workspace for this project
    @discardableResult
    public func workspace() throws -> XCWorkspace {
        if let r = self._workspace { return r }
        
        let rtn = try XCWorkspace(fromURL: self.url.appendingPathComponent(XcodeProject.PROJECT_WORKSPACE_PACKAGE_NAME, isDirectory: true),
                                  usingFSProvider: self.fsProvider)
        self._workspace = rtn
        
        return rtn
    }
    
    /// The project shared data
    ///
    /// This will open if needed and then return the shared data for this project
    /// - Returns: Returns the shared data for this project
    @discardableResult
    public func sharedData() throws -> XCSharedData {
        if let r = self._sharedData { return r }
        
        let rtn = try XCSharedData(fromURL: self.url.appendingPathComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME, isDirectory: true),
                                   usingFSProvider: self.fsProvider)
        self._sharedData = rtn
        
        return rtn
    }
    
    /// The project user data list
    ///
    /// This will open if needed and then return the user data list for this project
    /// - Returns: Returns the user data list for this project
    @discardableResult
    public func userdataList() throws -> XCUserDataList {
        if let r = self._userdataList { return r }
        
        let rtn = try XCUserDataList(fromURL: self.url.appendingPathComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME, isDirectory: true),
                                     usingFSProvider: self.fsProvider)
        self._userdataList = rtn
        
        return rtn
    }
    
    /// Create a new instance of a Native Target
    ///
    /// - Parameters:
    ///   - target: Name of target
    ///   - buildConfigurationList: The build configuration options for this target
    ///   - buildPhases: An array of Build Phases (PBXBuildPhase) (Default: Empty Array)
    ///   - buildRules: An array of Build Rules (PBXBuildRule) (Default: Empty Array)
    ///   - dependencies: An array of Target Dependencies (PBXTargetDependency) (Default: Empty Array)
    ///   - productType: Product type for this target
    ///   - productFileReferenceNaming: The reference naming options for the product file (Default: .target)
    ///   - targetReferenceNaming: The reference naming options for the target (Default: .generated)
    ///   - createProxy: Indicator if a container item proxy should be created (Default: true)
    ///   - havingInfo: Having target info settings
    ///   - savePBXFile: Save the project file after creation (Default: true)
    /// - returns: A newly created native target
    @discardableResult
    public func createNativeTarget(withTargetName target: String,
                                   buildConfigurationList: TargetBuildConfigurationListOptions,
                                   buildPhases:  [XcodeBuildPhase] = [],
                                   buildRules: [XcodeBuildRule] = [],
                                   dependencies: [XcodeTargetDependency] = [],
                                   productType: XcodeProductType,
                                   productFileReferenceNaming: XcodeTarget.TargetReferenceNaming = .target,
                                   targetReferenceNaming: XcodeTarget.TargetReferenceNaming = .generated,
                                   createProxy: Bool = true,
                                   havingInfo info: [String: String],
                                   savePBXFile: Bool = true) throws -> XcodeNativeTarget {
        
        let pbxTarget = try self.proj.project.createNativeTarget(withTargetName: target,
                                                                 buildConfigurationList: buildConfigurationList,
                                                                 buildPhases: buildPhases,
                                                                 buildRules: buildRules,
                                                                 dependencies: dependencies.map({ return $0.pbxTargetDependancy }),
                                                                 productType: productType,
                                                                 productFileReferenceNaming: productFileReferenceNaming,
                                                                 targetReferenceNaming: targetReferenceNaming,
                                                                 createProxy: createProxy)
        
        let rtn = XcodeNativeTarget(self, newTarget: pbxTarget, havingInfo: info)
        self.targets.append(rtn)
        
        if savePBXFile {
            try self.save()
        }
        
        return rtn
        
    }
    
    /// Create a new instance of an Aggregate Target
    ///
    /// - Parameters:
    ///   - target: Name of target
    ///   - buildConfigurationList: The build configuration options for this target
    ///   - buildPhases: An array of Build Phases (PBXBuildPhase) (Default: Empty Array)
    ///   - buildRules: An array of Build Rules (PBXBuildRule) (Default: Empty Array)
    ///   - dependencies: An array of Target Dependencies (PBXTargetDependency) (Default: Empty Array)
    ///   - targetReferenceNaming: The reference naming options for the target (Default: .generated)
    ///   - havingInfo: Having target info settings
    ///   - savePBXFile: Save the project file after creation (Default: true)
    /// - returns: A newly created aggregate target
    @discardableResult
    public func createAggregateTarget(withTargetName target: String,
                                      buildConfigurationList: TargetBuildConfigurationListOptions,
                                      buildPhases:  [XcodeBuildPhase] = [],
                                      buildRules: [XcodeBuildRule] = [],
                                      dependencies: [XcodeTargetDependency] = [],
                                      //productType: PBXProductType,
                                        targetReferenceNaming: XcodeTarget.TargetReferenceNaming = .generated,
                                        havingInfo info: [String: String],
                                        savePBXFile: Bool = true) throws -> XcodeAggregatedTarget {
        
        let pbxTarget = try self.proj.project.createAggregateTarget(withTargetName: target,
                                                                 buildConfigurationList: buildConfigurationList,
                                                                 buildPhases: buildPhases,
                                                                 buildRules: buildRules,
                                                                 dependencies: dependencies.map({ return $0.pbxTargetDependancy }),
                                                                 //productType: productType,
                                                                 targetReferenceNaming: targetReferenceNaming)
        
        let rtn = XcodeAggregatedTarget(self, newTarget: pbxTarget, havingInfo: info)
        self.targets.append(rtn)
        if savePBXFile {
            try self.save()
        }
        return rtn
        
    }
    
    /// Create a new instance of an Aggregate Target
    ///
    /// - Parameters:
    ///   - target: Name of target
    ///   - buildConfigurationList: The build configuration options for this target
    ///   - buildPhases: An array of Build Phases (PBXBuildPhase) (Default: Empty Array)
    ///   - buildRules: An array of Build Rules (PBXBuildRule) (Default: Empty Array)
    ///   - dependencies: An array of Target Dependencies (PBXTargetDependency) (Default: Empty Array)
    ///   - buildToolPath: Path to tool to use
    ///   - buildArgumentsString: Arguments to pass to tool
    ///   - passBuildSettingsInEnvironment: Indicator if build settings should be passed in env
    ///   - buildWorkingDirectory: Path for build working directory
    ///   - targetReferenceNaming: The reference naming options for the target (Default: .generated)
    ///   - havingInfo: Having target info settings
    ///   - savePBXFile: Save the project file after creation (Default: true)
    /// - returns: A newly created legacy target
    @discardableResult
    public func createLegacyTarget(withTargetName target: String,
                                   buildConfigurationList: TargetBuildConfigurationListOptions,
                                   buildPhases:  [XcodeBuildPhase] = [],
                                   buildRules: [XcodeBuildRule] = [],
                                   dependencies: [XcodeTargetDependency] = [],
                                   buildToolPath: String? = nil,
                                   buildArgumentsString: String? = nil,
                                   passBuildSettingsInEnvironment: Bool = false,
                                   buildWorkingDirectory: String? = nil,
                                   havingInfo info: [String: String],
                                   savePBXFile: Bool = true) throws -> XcodeLegacyTarget {
        
        let pbxTarget = try self.proj.project.createLegacyTarget(withTargetName: target,
                                                                    buildConfigurationList: buildConfigurationList,
                                                                    buildPhases: buildPhases,
                                                                    buildRules: buildRules,
                                                                    dependencies: dependencies.map({ return $0.pbxTargetDependancy }),
                                                                    buildToolPath: buildToolPath,
                                                                    buildArgumentsString: buildArgumentsString,
                                                                    passBuildSettingsInEnvironment: passBuildSettingsInEnvironment,
                                                                    buildWorkingDirectory: buildWorkingDirectory)
        
        let rtn = XcodeLegacyTarget(self, newTarget: pbxTarget, havingInfo: info)
        self.targets.append(rtn)
        if savePBXFile {
            try self.save()
        }
        return rtn
        
    }
    
    
    
    
    /*public func savePBXFile() throws {
        try self.savePBXFile([])
    }*/
    
    /// Gets a save BPX Project File action
    ///
    /// - Returns: Returns an action that represtnts the saving of the PBX Project File
    private func saveFileAction() throws -> XcodeFileSystemProviderAction {
        let pbxURL = self.url.appendingPathComponent(XcodeProject.PBX_PROJECT_FILE_NAME,
                                                     isDirectory: false)
        
        // Write PBXProj file
        let encoder = PBXProjEncoder()
        encoder.encoding = self.projFileSettings.encoding
        encoder.tabs = self.projFileSettings.tabbing
        
        let dta = try encoder.encode(self.proj)
        
        return .write(data: dta, to: pbxURL, writeOptions: .atomic)
    }
    
    
    /// Get all save actions that are needed for this project
    ///
    /// - Parameter overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
    /// - Returns: Returns an array of all save action required
    internal func saveAllActions(overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
        var allActions: [XcodeFileSystemProviderAction] = self.pendingSaveActions
        allActions.append(try self.saveFileAction())
        self.pendingSaveActions = []
        
        
        // Setup target save actions
        for t in self.targets {
            if let a = try t.saveAction(overrideChangeCheck: overrideChangeCheck) {
                allActions.append(a)
            }
            
        }
        
        // Setup XCWorkspace save actions
        if let o = self._workspace {
            let actions = try o.saveActions(to: self.url.appendingPathComponent(XcodeProject.PROJECT_WORKSPACE_PACKAGE_NAME, isDirectory: true),
                                            overrideChangeCheck: overrideChangeCheck)
            allActions.append(contentsOf: actions)
        }
        
        // Setup Shared Data save actions
        if let o = self._sharedData {
            let actions = try o.saveActions(to: self.url.appendingPathComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME, isDirectory: true),
                                            overrideChangeCheck: overrideChangeCheck)
            allActions.append(contentsOf: actions)
        }
        
        // Setup User Data List save actions
        if let o = self._userdataList {
            let actions = try o.saveActions(to: self.url.appendingPathComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME, isDirectory: true),
                                            overrideChangeCheck: overrideChangeCheck)
            allActions.append(contentsOf: actions)
        }
        
        return allActions
    }
    
    /// Saves the pending save actions as well as any additional provided actions
    ///
    /// - Parameters:
    ///   - overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
    ///   - additionalActions: Any additional actions that need to be executed during the save process
    public func save(overrideChangeCheck: Bool = false, _ additionalActions: [XcodeFileSystemProviderAction] = []) throws {
        var allActions = try self.saveAllActions(overrideChangeCheck: overrideChangeCheck)
        allActions.append(contentsOf: additionalActions)
        //print(allActions)
        try self.fsProvider.actions(allActions)
        self.isNewProject = false
    }
    
    /// Saves the pending save actions as well as any additional provided actions
    ///
    /// - Parameters:
    ///   - overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
    ///   - actions: Any additional actions that need to be executed during the save process
    public func save(overrideChangeCheck: Bool = false, withAdditionalActions actions: XcodeFileSystemProviderAction...) throws {
        try self.save(overrideChangeCheck: overrideChangeCheck, actions)
    }
    
}

extension XcodeProject: LeveledDescripition {
    public func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        var rtn: String = ""
        if indentOpening { rtn += String(repeating: indent, count: level) }
        rtn += "XcodeProject(\(self.url.path))"
        return rtn
    }
    
    
    public func leveledDebugDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        let tabs: String = String(repeating: indent, count: level)
        var rtn: String = ""
        if indentOpening { rtn += tabs }
        rtn += self.name
        let configs = self.proj.project.buildConfigurationList.buildConfigurations
        if configs.count > 0 {
            rtn += "\n" + tabs + indent + "Build Configurations:"
            for config in configs {
                
                rtn += "\n" + tabs + indent + indent + "\(config.name): "
                /*rtn += formatDictionaryDescription(config.completeBuildSettings,
                                                   indentCount: count + 2,
                                                   indent: indent,
                                                   indentOpening: false)*/
                rtn += config.completeBuildSettings.leveledDebugDescription(level + 2,
                                                                            indent: indent,
                                                                            indentOpening: false,
                                                                            sortKeys: sortKeys)
            }
        }
        if self.targets.count > 0 {
            rtn += "\n" + tabs + indent + "Targets:"
            for r in self.targets {
                rtn += "\n" + r.leveledDebugDescription(level + 2,
                                                        indent: indent,
                                                        indentOpening: true,
                                                        sortKeys: sortKeys)
            }
        }
        if self.resources.children.count > 0 {
            rtn += "\n" + tabs + indent + "File Structure:"
            for r in self.resources.children {
                rtn += "\n" + r.leveledDebugDescription(level + 2,
                                                        indent: indent,
                                                        indentOpening: true,
                                                        sortKeys: sortKeys)
            }
        }
        
        return rtn
    }
}
