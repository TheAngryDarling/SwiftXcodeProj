//
//  XcodeTarget.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation
import PBXProj
import CustomCoders
import AdvancedCodableHelpers
//import LeveledCustomStringConvertible

/// The Xcode representation of a Target
public class XcodeTarget: XcodeObject, LeveledDescripition {
    
    public typealias TargetReferenceNaming = PBXTarget.TargetReferenceNaming
    
    /// The PBX object reference
    internal let pbxTarget: PBXTarget
    /// The url to the info file
    internal var url: XcodeFileSystemURLResource
    
    /// The name of this target
    public var name: String {
        get { return self.pbxTarget.name }
        //set { self.pbxTarget.name = newValue }
    }
    /// The build phases for this target
    public var buildPhases: [XcodeBuildPhase] {
        get { return self.pbxTarget.buildPhases }
        //set { self.pbxTarget.buildPhases = newValue }
    }
    
    /// The build rules of this target
    public var buildRules: [XcodeBuildRule] {
        get { return self.pbxTarget.buildRules }
        //set { self.pbxTarget.buildRules = newValue }
    }
    
    /// The dependencies of this target
    public var dependencies: [XcodeTargetDependency] {
        get { return self.pbxTarget.dependencies.map( { return XcodeTargetDependency(self.project, $0) }) }
        //set { self.pbxTarget.dependencies = newValue.map({ return $0.pbxTargetDependancy }) }
    }
    
    
    /// A list of the build confirations
    public var buildConfigurationList: XCConfigurationList {
        get { return self.pbxTarget.buildConfigurationList }
    }
    
    /// The Xcode target info properties
    public var info: [String: Any] {
        didSet { hasInfoChanged = true }
    }
    /// An indicator if the info property has changed
    private var hasInfoChanged: Bool = false
    
    /// Create a new Xcode Target
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Default: Empty)
    internal init(_ project: XcodeProject,
                  newTarget target: PBXTarget,
                  havingInfo info: [String: Any] = [:]) {
        self.url = project.projectPackage.appendingFileComponent(target.name + "_Info.plist")
        self.pbxTarget = target
        self.info = info
        self.hasInfoChanged = (info.count > 0)
        super.init(project)
    }
    
    /// Craete an existing Xcode Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Optional, If not provided, will try and load from file system)
    internal init(_ project: XcodeProject,
                  _ target: PBXTarget,
                  havingInfo info: [String: Any]? = nil) throws {
        self.url = project.projectPackage.appendingFileComponent(target.name + "_Info.plist")
        self.pbxTarget = target
        if let inf = info {
            self.info = inf
        } else {
            if let dta = try project.fsProvider.dataIfExists(from: url) {
                let plistDecoder = PListDecoder()
                self.info = try CodableHelpers.dictionaries.decode(dta,
                                                                   from: plistDecoder)
            } else {
                self.info = [:]
                
            }
        }
        super.init(project)
        
    }
    
    /// Creates a Xcode Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target
    ///   - isNew: An indicator if this is a new project or not
    internal init(_ project: XcodeProject,
                  _ target: PBXTarget,
                  _ info: [String: Any],
                  isNew: Bool ) {
        self.url = project.projectPackage.appendingFileComponent(target.name + "_Info.plist")
        self.pbxTarget = target
        self.info = info
        self.hasInfoChanged = (info.count > 0 && isNew)
        super.init(project)
    }
    
    /// Gets the Delete action that removes the target _Info.plist file
    ///
    /// - Returns: Returns a File System Action for deleting the target info
    public func deleteAction() -> XcodeFileSystemProviderAction {
        let idx = self.project.targets.firstIndex(where: {$0.pbxTarget.id == self.pbxTarget.id })
        if let idx = idx {
            self.project.targets.remove(at: idx)
        }
        
        // this will remove target from pbx and clean up any reference to it
        self.project.proj.objects.remove(self.pbxTarget)
        
        let url = project.projectPackage.appendingFileComponent(self.name + "_Info.plist")
        let deleteAction = XcodeFileSystemProviderAction.remove(item: url).withDependencies(.exists(item: url))
        
        return deleteAction
    }
    
    /// Tries and deletes the target _Info.plist file and then saves the Xcode PBX Project file
    public func delete() throws {
        //try self.project.savePBXFile(withActions: self.deleteAction())
        try self.project.save(withAdditionalActions: self.deleteAction())
    }
    
     /// Tries and deletes the target _Info.plist file without saving the Xcode PBX Project file
    public func deleteWithoutSavingPBX() throws {
        try self.project.fsProvider.action(self.deleteAction())
    }
    
    
    /// Saves the target _Info.plist file if it has modifications
    public func save() throws {
        guard let action = try self.saveAction() else { return }
    
        try self.project.fsProvider.action(action)
    }
    
    /// Gets the save action to save the target _Info.plist file
    ///
    /// - Parameter overrideChangeCheck: An indicator if we should ignore any has modified checks
     /// - Returns: Returns a File System Action for saving the target info if needed or required
    public func saveAction(overrideChangeCheck: Bool = false) throws -> XcodeFileSystemProviderAction? {
        guard self.hasInfoChanged || overrideChangeCheck else { return nil }
        // Generate Data
        let plistEncoder = PListEncoder()
        plistEncoder.outputFormat = .xml
        let dta = try CodableHelpers.dictionaries.encode(self.info, to: plistEncoder)
        
        let writeAction = XcodeFileSystemProviderAction.write(data: dta, to: self.url, writeOptions: .atomic)
        
        let withCallback = writeAction.withCallback { (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
            if err == nil {
                self.hasInfoChanged = false
            }
        }
        
        return withCallback
    }
    
    
    /// Create a new build rule
    ///
    /// - Parameters:
    ///   - name: Name of the build rule
    ///   - compilerSpec: Compiler Specs
    ///   - fileType: FileType
    ///   - editable: Is editable
    ///   - filePatterns: File Pattern
    ///   - outputFiles: Output Files
    ///   - outputFilesCompilerFlags: Compiler Flags
    ///   - script: Script to execute
    ///   - location:  The location where to add, at the beginning or end (Default: .end)
    /// - Returns: Returns a newly crated build rule
    @discardableResult
    public func createBuildRule(name: String? = nil,
                                compilerSpec: String = "com.apple.compilers.proxy.script",
                                fileType: XcodeFileType,
                                editable: Bool = true,
                                filePatterns: String? = nil,
                                outputFiles: [String] = [],
                                outputFilesCompilerFlags: [String]? = nil,
                                script: String? = nil,
                                atLocation location: AddLocation<XcodeBuildRule> = .end) throws -> XcodeBuildRule {
        return try self.pbxTarget.createBuildRule(name: name,
                                                  compilerSpec: compilerSpec,
                                                  fileType: fileType,
                                                  editable: editable,
                                                  filePatterns: filePatterns,
                                                  outputFiles: outputFiles,
                                                  outputFilesCompilerFlags: outputFilesCompilerFlags,
                                                  script: script,
                                                  atLocation: location)
        
    }
    
    /// Remove the given build rule
    /// - Returns: Returns true if the rule was removed or not
    @discardableResult
    public func removeBuildRule(_ buildRule: XcodeBuildRule) -> Bool {
        return self.pbxTarget.removeBuildRule(buildRule)
    }
    
    
    /*
    /// Create a framework build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build files for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created framework build phase
    @discardableResult
    public func createFrameworkBuildPhase(buildActionMask: UInt = PBXFrameworksBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                             files: [PBXBuildFile] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0) throws -> XcodeFrameworksBuildPhase {
        
        return try self.pbxTarget.createFrameworkBuildPhase(buildActionMask: buildActionMask,
                                                               files: files.map({ return $0.id }),
                                                               runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    */
    /// Returns the framework build phase.  If it does not exists, it will be created first
    @discardableResult
    public func frameworkBuildPhase(atLocation location: AddLocation<PBXBuildPhase> = .end) -> XcodeFrameworksBuildPhase {
        if let sources = self.pbxTarget.buildPhases.first(where: {return $0 is XcodeFrameworksBuildPhase}) {
            return sources as! XcodeFrameworksBuildPhase
        }
        return try! self.pbxTarget.createFrameworkBuildPhase(atLocation: location)
    }
    
    /*
    /// Create a headers build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build files for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created headers build phase
    @discardableResult
    public func createHeadersBuildPhase(buildActionMask: UInt = PBXHeadersBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                           files: [PBXBuildFile] = [],
                                           runOnlyForDeploymentPostprocessing: UInt = 0) throws -> XcodeHeadersBuildPhase {
        return try self.pbxTarget.createHeadersBuildPhase(buildActionMask: buildActionMask,
                                                             files: files.map({ return $0.id }),
                                                             runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    */
    
    /// Returns the headers build phase.  If it does not exists, it will be created first
    @discardableResult
    public func headersBuildPhase(atLocation location: AddLocation<XcodeBuildPhase> = .end) -> XcodeHeadersBuildPhase {
        if let sources = self.pbxTarget.buildPhases.first(where: {return $0 is XcodeHeadersBuildPhase}) {
            return sources as! XcodeHeadersBuildPhase
        }
        return try! self.pbxTarget.createHeadersBuildPhase(atLocation: location)
    }
    
    /*
    /// Create a resources build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build files for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created resources build phase
    @discardableResult
    public func createResourcesBuildPhase(buildActionMask: UInt = PBXResourcesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                             files: [PBXBuildFile] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0) throws -> XcodeResourcesBuildPhase {
        return try self.pbxTarget.createResourcesBuildPhase(buildActionMask: buildActionMask,
                                                              files: files.map({ return $0.id }),
                                                              runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    */
    /// Returns the resources build phase.  If it does not exists, it will be created first
    @discardableResult
    public func resourcesBuildPhase(atLocation location: AddLocation<XcodeBuildPhase> = .end) -> XcodeResourcesBuildPhase {
        if let sources = self.pbxTarget.buildPhases.first(where: {return $0 is XcodeResourcesBuildPhase}) {
            return sources as! XcodeResourcesBuildPhase
        }
        return try! self.pbxTarget.createResourcesBuildPhase(atLocation: location)
    }
    
    /*
    /// Create a rez build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build files for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created rez build phase
    @discardableResult
    public func createRezBuildPhase(buildActionMask: UInt = PBXRezBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                       files: [PBXBuildFile] = [],
                                       runOnlyForDeploymentPostprocessing: UInt = 0) throws -> XcodeRezBuildPhase {
        return try self.pbxTarget.createRezBuildPhase(buildActionMask: buildActionMask,
                                                         files: files.map({ return $0.id }),
                                                         runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    */
    /// Returns the rez build phase.  If it does not exists, it will be created first
    @discardableResult
    public func rezBuildPhase(atLocation location: AddLocation<XcodeBuildPhase> = .end) -> XcodeRezBuildPhase {
        if let sources = self.pbxTarget.buildPhases.first(where: {return $0 is XcodeRezBuildPhase}) {
            return sources as! XcodeRezBuildPhase
        }
        return try! self.pbxTarget.createRezBuildPhase(atLocation: location)
    }
    
    /*
    /// Create a sources build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build files for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created sources build phase
    @discardableResult
    public func createSourcesBuildPhase(buildActionMask: UInt = PBXSourcesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                           files: [PBXBuildFile] = [],
                                           runOnlyForDeploymentPostprocessing: UInt = 0) throws -> XcodeSourcesBuildPhase {
        return try self.pbxTarget.createSourcesBuildPhase(buildActionMask: buildActionMask,
                                                             files: files.map({ return $0.id }),
                                                             runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    */
    
    /// Returns the sources build phase.  If it does not exists, it will be created first
    @discardableResult
    public func sourcesBuildPhase(atLocation location: AddLocation<XcodeBuildPhase> = .end) -> XcodeSourcesBuildPhase {
        if let sources = self.pbxTarget.buildPhases.first(where: {return $0 is XcodeSourcesBuildPhase}) {
            return sources as! XcodeSourcesBuildPhase
        }
        return try! self.pbxTarget.createSourcesBuildPhase(atLocation: location)
    }
    
    /// Create a copy files build phase for this target
    ///
    /// - Parameters:
    ///   - name: The name of the build phase (Optional)
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    ///   - dstPath: Destination path
    ///   - dstSubfolderSpec: Destination subfolder specification
    /// - Returns: Returns the newly created copy files build phase
    @discardableResult
    public func createCopyFilesBuildPhase(name: String? = nil,
                                             buildActionMask: UInt = PBXCopyFilesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                             files: [PBXBuildFile] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0,
                                             dstPath: String = PBXTarget.COPY_FILES_BUILD_PHASE_DEFAULT_DEST_PATH,
                                             dstSubfolderSpec: PBXCopyFilesBuildPhase.PBXSubFolder = .absolutePath,
                                             atLocation location: AddLocation<XcodeBuildPhase> = .end) throws -> XcodeCopyFilesBuildPhase {
        
        return try self.pbxTarget.createCopyFilesBuildPhase(name: name,
                                                           buildActionMask: buildActionMask,
                                                           files: files.map({ return $0.id }),
                                                           runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                                                           dstPath: dstPath,
                                                           dstSubfolderSpec: dstSubfolderSpec,
                                                           atLocation: location)
        
    }
    
    /// Create a shell script build phase for this target
    ///
    /// - Parameters:
    ///   - name: The name of the build action (Optional)
    ///   - buildActionMask: he build action for this build phase (Default: DEFAULT_BUILD_ACTION_MAKS)
    ///   - files: An array of references to Build Files
    ///   - runOnlyForDeploymentPostprocessing: An indicator if should run only for deployment post processing
    ///   - inputFileListPaths: The input file list paths (Default: Empty Array)
    ///   - inputPaths: The input  paths (Default: Empty Array)
    ///   - outputPaths: The output paths (Default: Empty Array)
    ///   - shellPath: The path to the shell to use (Default: DEFAULT_SHELL_PATH)
    ///   - shellScript: The script to execute (Optional)
    /// - Returns: Returns the newly created shell script build phase
    @discardableResult
    public func createShellScriptBuildPhase(name: String? = nil,
                                               buildActionMask: UInt = PBXShellScriptBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                               files: [PBXBuildFile] = [],
                                               runOnlyForDeploymentPostprocessing: UInt = 0,
                                               inputFileListPaths: [String] = [],
                                               inputPaths: [String] = [],
                                               outputPaths: [String] = [],
                                               shellPath: String = PBXShellScriptBuildPhase.DEFAULT_SHELL_PATH,
                                               shellScript: String = "# Type a script or drag a script file from your workspace to insert its path.\n",
                                               atLocation location: AddLocation<XcodeBuildPhase> = .end) throws -> XcodeShellScriptBuildPhase {
        return try self.pbxTarget.createShellScriptBuildPhase(name: name,
                                                                buildActionMask: buildActionMask,
                                                                files: files.map({ return $0.id }),
                                                                runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                                                                inputFileListPaths: inputFileListPaths,
                                                                inputPaths: inputPaths,
                                                                outputPaths: outputPaths,
                                                                shellPath: shellPath,
                                                                shellScript: shellScript,
                                                                atLocation: location)
    }
    
    /// Removes a build phase from the target
    ///
    /// - Parameter buildPhase: The build phase to remove from the target
    /// - Returns: Returns an indicator if the build phase was removed or not
    @discardableResult
    public func removeBuildPhase(_ buildPhase: XcodeBuildPhase) -> Bool {
        return self.pbxTarget.removeBuildPhase(buildPhase)
    }
    
    /// Creates a new dependency for this target
    ///
    /// - Parameters:
    ///   - target: The target this target will rely on
    public func createDependency(_ target: XcodeTarget) {
        guard !self.pbxTarget.dependencies.contains(where: { return $0.targetReference == target.pbxTarget.id }) else { return }
        
        self.pbxTarget.createDependency(target.pbxTarget/*, in: target.project.proj.project*/)
        
    }
    
    /// Removes a dependency from this target
    ///
    /// - Parameter dependency: The dependency to remove
    /// - Returns: And indicator if the dependency was removed or not
    @discardableResult
    public func removeDependancy(_ dependency: XcodeTargetDependency) -> Bool {
        return self.pbxTarget.removeDependancy(dependency.pbxTargetDependancy)
    }
    
    public func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        var rtn: String = ""
        if indentOpening { rtn = String(repeating: indent, count: level) }
        rtn += self.name
        //if let pt = self.productType { rtn += "(\(pt))" }
        return rtn
    }
    
    public func leveledDebugDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        let tabs: String = String(repeating: indent, count: level)
        var rtn: String = ""
        if indentOpening { rtn += tabs }
        rtn += self.name
        //if let pt = self.productType { rtn += "(\(pt))" }
        if self.info.count > 0 {
            rtn += "\n" + tabs + indent + "info: " + self.info.leveledDebugDescription(level + 1, indent: indent, indentOpening: false, sortKeys: true)
        }
        if self.dependencies.count > 0 {
            rtn += "\n" + tabs + indent + "dependencies: " + self.dependencies.map({ $0.name }).sorted().leveledDebugDescription(level + 1, indent: indent, indentOpening: false)
        }
        
        return rtn
    }
    
}

/// An Xcode Aggregated Target
public final class XcodeAggregatedTarget: XcodeTarget {
    
    internal var pbxAggregatedTarget: PBXAggregateTarget { return self.pbxTarget as! PBXAggregateTarget}
    
    /// The target product name if one is available
    public var productName: String? {
        get { return self.pbxAggregatedTarget.productName }
        set { self.pbxAggregatedTarget.productName = newValue }
    }
    
    
    /// Create a new Xcode Aggregated Target
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Default: Empty)
    internal init(_ project: XcodeProject,
                  newTarget target: PBXAggregateTarget,
                  havingInfo info: [String: Any] = [:]) {
        super.init(project, newTarget: target, havingInfo: info)
    }
    
    /// Craete an existing Xcode Aggregated Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Optional, If not provided, will try and load from file system)
    internal init(_ project: XcodeProject,
                  _ target: PBXAggregateTarget,
                  havingInfo info: [String: Any]? = nil) throws {
        try super.init(project, target, havingInfo: info)
    }
    
    /// Creates a Xcode Aggregated Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target
    ///   - isNew: An indicator if this is a new project or not
    internal init(_ project: XcodeProject,
                  _ target: PBXAggregateTarget,
                  _ info: [String: Any], isNew: Bool ) {
        super.init(project, target, info, isNew: isNew)
    }
}

/// An Xcode Legacy Target
public final class XcodeLegacyTarget: XcodeTarget {
    
    internal var pbxLegacyTarget: PBXLegacyTarget { return self.pbxTarget as! PBXLegacyTarget }
    
    /// Create a new Xcode Target
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Default: Empty)
    internal init(_ project: XcodeProject,
                  newTarget target: PBXLegacyTarget,
                  havingInfo info: [String: Any] = [:]) {
        super.init(project, newTarget: target, havingInfo: info)
    }
    
    /// Craete an existing Xcode Legacy Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Optional, If not provided, will try and load from file system)
    internal init(_ project: XcodeProject,
                  _ target: PBXLegacyTarget,
                  havingInfo info: [String: Any]? = nil) throws {
        try super.init(project, target, havingInfo: info)
    }
    
    /// Creates a Xcode Legacy Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target
    ///   - isNew: An indicator if this is a new project or not
    internal init(_ project: XcodeProject,
                  _ target: PBXLegacyTarget,
                  _ info: [String: Any], isNew: Bool ) {
        super.init(project, target, info, isNew: isNew)
    }
}

/// An Xcode Native Target
public final class XcodeNativeTarget: XcodeTarget {
    
    internal var pbxNativeTarget: PBXNativeTarget { return self.pbxTarget as! PBXNativeTarget }
    
    /// Indicates if this target is a testing target
    public var isTestingTarget: Bool {
        //public static let unitTestBundle: PBXProductType = "com.apple.product-type.bundle.unit-test"
        //public static let uiTestBundle: PBXProductType = "com.apple.product-type.bundle.ui-testing"
        return (self.pbxNativeTarget.productType == PBXProductType.unitTestBundle || self.pbxNativeTarget.productType == PBXProductType.uiTestBundle)
    }
    
    /// The target product type if one is available
    public var productType: XcodeProductType? {
        get { return self.pbxNativeTarget.productType }
        set { self.pbxNativeTarget.productType = newValue }
    }
    
    /// The target product name if one is available
    public var productName: String? {
        get { return self.pbxNativeTarget.productName }
        set { self.pbxNativeTarget.productName = newValue }
    }
    
    /// Create a new Xcode Native Target
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Default: Empty)
    internal init(_ project: XcodeProject,
                  newTarget target: PBXNativeTarget,
                  havingInfo info: [String: Any] = [:]) {
        super.init(project, newTarget: target, havingInfo: info)
    }
    
    /// Craete an existing Xcode Native Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target (Optional, If not provided, will try and load from file system)
    internal init(_ project: XcodeProject,
                  _ target: PBXNativeTarget,
                  havingInfo info: [String: Any]? = nil) throws {
        try super.init(project, target, havingInfo: info)
    }
    
    /// Creates a Xcode Native Target object
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this target belongs to
    ///   - target: The BPX Target for this Xcode Target
    ///   - info: The info settings for this target
    ///   - isNew: An indicator if this is a new project or not
    internal init(_ project: XcodeProject,
                  _ target: PBXNativeTarget,
                  _ info: [String: Any],
                  isNew: Bool ) {
        super.init(project, target, info, isNew: isNew)
    }
    
    public override func deleteAction() -> XcodeFileSystemProviderAction {
        
        if let productRef = self.pbxNativeTarget.productReference {
            if self.project.resources.products != nil {
                if let productFile = self.project.resources.products.children.first(where: {$0.pbxFileResource.id == productRef}) {
                    productFile.removeReferenceFromParentWithoutSaving()
                }
            }
        }
        
        return super.deleteAction()
    }
    
    public override func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        var rtn = super.leveledDescription(level, indent: indent, indentOpening: indentOpening, sortKeys: sortKeys)
        
        if let pt = self.productType {
            rtn = rtn.replacingFirstOccurrence(of: self.name, with: (self.name + "(\(pt))"))
        }
        return rtn
    }
    
    public override func leveledDebugDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        var rtn = super.leveledDebugDescription(level, indent: indent, indentOpening: indentOpening, sortKeys: sortKeys)
        
        if let pt = self.productType {
            rtn = rtn.replacingFirstOccurrence(of: self.name, with: (self.name + "(\(pt))"))
        }
        return rtn
    }
}
