//
//  PBXTarget.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// PBX File Target
/// This is a base class for all Targets in the file
public class PBXTarget: PBXUnknownObject {
    
    public enum TargetReferenceNaming {
        case generated
        case target
        case projectTarget(project: String)
        case projectTargetProduct(project: String, product: String)
        
        internal func generateId(_ proj: PBXProj, targetName: String) -> PBXReference {
            switch self {
            case .generated:
                return proj.generateNewReference()
            case .target:
                return proj.generateNewReference(withTargetPath: targetName)
            case .projectTarget(project: let project):
                return proj.generateNewReference(withProjectName: project, targetName: targetName)
            case .projectTargetProduct(project: let project, product: let product):
                return proj.generateNewReference(withProjectName: project, targetName: targetName, productName: product)
            }
        }
    }
    
    internal enum TargetCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case buildConfigurationList
        case buildPhases
        case buildRules
        case dependencies
        case name
        //case productName
        //case productReference
        //case productType
    }
    
    private typealias CodingKeys = TargetCodingKeys
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.buildConfigurationList)
        rtn.append(CodingKeys.buildPhases)
        rtn.append(CodingKeys.buildRules)
        rtn.append(CodingKeys.dependencies)
        rtn.append(CodingKeys.name)
        return rtn
    }
    
    public enum Error: Swift.Error {
        case invalidObjectType(PBXObjectType)
        case buildPhaseAlreadyExists(PBXBuildPhase.Type)
        case buildRuleAlreadyExists(PBXFileType)
    }
    
    /*public enum BuildPhase {
        case copyFiles
        case frameworks
        case headers
        case resources
        case rez
        case shellScript
        case sources
        
        fileprivate var phaseType: PBXBuildPhase.Type {
            switch self {
            case .copyFiles: return PBXCopyFilesBuildPhase.self
            case .frameworks: return PBXFrameworksBuildPhase.self
            case .headers: return PBXHeadersBuildPhase.self
            case .resources: return PBXResourcesBuildPhase.self
            case .rez: return PBXRezBuildPhase.self
            case .shellScript: return PBXShellScriptBuildPhase.self
            case .sources: return PBXSourcesBuildPhase.self
            }
        }
    }*/
    
    public enum PBXTargetType {
        case aggregateTarget
        case nativeTarget
        case legacyTarget
        
        fileprivate var pbxType: PBXObjectType {
            switch self {
            case .aggregateTarget: return PBXObjectType.aggregateTarget
            case .nativeTarget: return PBXObjectType.nativeTarget
            case .legacyTarget: return PBXObjectType.legacyTarget
            }
        }
    }
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.buildConfigurationList)
        rtn.append(CodingKeys.buildPhases)
        rtn.append(CodingKeys.buildRules)
        rtn.append(CodingKeys.dependencies)
        rtn.append(CodingKeys.name)
        //rtn.append(CodingKeys.productName)
        //rtn.append(CodingKeys.productReference)
        //rtn.append(CodingKeys.productType)
        return rtn
    }
    
    public static let COPY_FILES_BUILD_PHASE_DEFAULT_DEST_PATH: String = "/usr/share/man/man1/"
    
    /// The object is a reference to a XCConfigurationList element.
    public var buildConfigurationListReference: PBXReference {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// The XCConfigurationList for the given object if one exists
    public var buildConfigurationList: XCConfigurationList! {
        get {
            return self.objectList.object(withReference: self.buildConfigurationListReference,
                                               asType: XCConfigurationList.self)
        }
        set {
            self.buildConfigurationListReference = newValue.id
        }
    }

    /// The objects are a reference to a PBXBuildPhase elements.
    public private(set) var buildPhaseReferences: [PBXReference] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// An array of all the PBXBuildPhase's for this object
    public var buildPhases: [PBXBuildPhase] {
        get {
            return self.objectList.objects(withReferences: self.buildPhaseReferences,
                                                asType: PBXBuildPhase.self)
        }
        set {
            
            var oldIds = self.buildPhaseReferences
            var newIds: [PBXReference] = []
            for v in newValue {
                newIds.append(v.id)
                if v.objectList == nil && self.objectList != nil { self.objectList.append(v)  }
            }
            
            if self.objectList != nil {
                oldIds.removeAll(newIds)
                self.objectList.remove(objectsWithReferences: oldIds)
            }
            self.buildPhaseReferences = newIds
        }
    }
    
    
    
    /// The objects are a reference to a PBXBuildRule elements.
    public private(set) var buildRuleReferences: [PBXReference] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// An array of all the PBXBuildRule's for this object
    public var buildRules: [PBXBuildRule] {
        get {
            return self.objectList.objects(withReferences: self.buildRuleReferences, asType: PBXBuildRule.self)
        }
        set {
            
            var oldIds = self.buildRuleReferences
            var newIds: [PBXReference] = []
            for v in newValue {
                newIds.append(v.id)
                if v.objectList == nil && self.objectList != nil { self.objectList.append(v)  }
            }
            
            if self.objectList != nil {
                oldIds.removeAll(newIds)
                self.objectList.remove(objectsWithReferences: oldIds)
            }
            self.buildRuleReferences = newIds
        }
    }
    
    /// The objects are a reference to a PBXTargetDependency elements.
    public private(set)  var dependencyRefernces: [PBXReference] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// An array of all the PBXTargetDependency's for this object
    public var dependencies: [PBXTargetDependency] {
        get {
            return self.objectList.objects(withReferences: self.dependencyRefernces,
                                                asType: PBXTargetDependency.self)
        }
        set {
            
            var oldIds = self.dependencyRefernces
            var newIds: [PBXReference] = []
            for v in newValue {
                newIds.append(v.id)
                if v.objectList == nil && self.objectList != nil { self.objectList.append(v)  }
            }
            
            if self.objectList != nil {
                oldIds.removeAll(newIds)
                self.objectList.remove(objectsWithReferences: oldIds)
            }
            self.dependencyRefernces = newIds
        }
    }
    
    public var project: PBXProject! {
        let projects = self.proj.objects.of(type: PBXProject.self)
        for project in projects {
            if project.targets.contains(self.id) {
                return project
            }
        }
        
        return nil
    }
    
    /// Target name.
    public var name: String {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /*
    /// Target product name.
    public var productName: String?
    
    /// The object is a reference to a PBXFileReference element.
    public private(set) var productReference: PBXReference?
    /// The PBXFileReference for the given object if one exists
    public var product: PBXFileReference! {
        get {
            guard let r = self.productReference else { return nil }
            return self.objectList.object(withReference: r, asType: PBXFileReference.self)
        }
        set {
            self.productReference = newValue?.id
        }
    }
    
    /// Target product type.
    public var productType: PBXProductType?
    */
    
    
    /// Creates a new PBXTarget
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - name: Name of target
    ///   - type: The target type of this target
    ///   - buildConfigurationList: Reference to the build configuration (XCConfigurationList)
    ///   - buildPhases: An array of references to Build Phases (PBXBuildPhase)
    ///   - buildRules: An array of references to Build Rules (PBXBuildRule)
    ///   - dependencies: An arary of references to Dependencies (PBXTargetDependency)
    internal init(id: PBXReference,
                  name: String,
                targetType type: PBXTargetType,
                buildConfigurationList: PBXReference,
                buildPhases:  [PBXReference] = [],
                buildRules: [PBXReference] = [],
                dependencies: [PBXReference] = []/*,
                productName: String? = nil,
                productReference: PBXReference? = nil,
                productType: PBXProductType? = nil*/) {
        
        
        self.buildConfigurationListReference = buildConfigurationList
        self.buildPhaseReferences = buildPhases
        self.buildRuleReferences = buildRules
        self.dependencyRefernces = dependencies
        self.name = name
        /*self.productName = productName
        self.productReference = productReference
        self.productType = productType*/
        super.init(id: id, type: type.pbxType)
        
        
    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.buildConfigurationListReference = try container.decode(PBXReference.self, forKey: .buildConfigurationList)
        self.buildPhaseReferences = try container.decode([PBXReference].self, forKey: .buildPhases)
        self.buildRuleReferences = (try container.decodeIfPresent([PBXReference].self, forKey: .buildRules)) ?? []
        self.dependencyRefernces = try container.decode([PBXReference].self, forKey: .dependencies)
        self.name = try container.decode(String.self, forKey: .name)
        //self.productName = try container.decodeIfPresent(String.self, forKey: .productName)
        //self.productReference = try container.decodeIfPresent(PBXReference.self, forKey: .productReference)
        //self.productType = try container.decodeIfPresent(PBXProductType.self, forKey: .productType)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.buildConfigurationListReference, forKey: .buildConfigurationList)
        try container.encode(self.buildPhaseReferences, forKey: .buildPhases)
        if self.buildRuleReferences.count > 0 {
            try container.encode(self.buildRuleReferences, forKey: .buildRules)
        }
        try container.encode(self.dependencyRefernces, forKey: .dependencies)
        try container.encode(self.name, forKey: .name)
        //try container.encodeIfPresent(self.productName, forKey: .productName)
        //try container.encodeIfPresent(self.productReference, forKey: .productReference)
        //try container.encodeIfPresent(self.productType, forKey: .productType)
        
        try super.encode(to: encoder)
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if (self.buildConfigurationListReference == objectReference ||
            self.buildPhaseReferences.contains(objectReference) ||
            self.buildRuleReferences.contains(objectReference) ||
            self.dependencyRefernces.contains(objectReference)) { return true }
        return super.hasReference(to: objectReference)
    }
    
    
    /// Find all build phases of a given type for this target
    ///
    /// - Parameter type: The PBXBuildPhase type to find
    /// - Returns: Returns an array of build phases of the given type, otherwise and empty array
    public func getBuildPhases<T>(forType type: T.Type) -> [T] where T: PBXBuildPhase {
        var rtn: [T] = []
        let phases = self.buildPhases
        for p in phases {
            if let t = p as? T {
                rtn.append(t)
            }
        }
        return rtn
    }
    
    /// Finds the first build phase of the given type for this target
    ///
    /// - Parameter type: The PBXBuildPhase type to find
    /// - Returns: Returns the build phase or nil if not found
    public func firstBuildPhase<T>(forType type: T.Type) -> T? where T: PBXBuildPhase {
        return self.getBuildPhases(forType: type).first
    }
    
    public func getBuildRules(forFileType fileType: PBXFileType) -> [PBXBuildRule] {
        var rtn: [PBXBuildRule] = []
        
        let rules = self.buildRules
        for rule in rules {
            if rule.fileType == fileType { rtn.append(rule) }
        }
        
        return rtn
    }
    public func firstBuildRule(forFileType fileType: PBXFileType) -> PBXBuildRule? {
        return getBuildRules(forFileType: fileType).first
    }

    
    override func deleting() {
        //Remove build configuration list
        self.objectList.remove(self.buildConfigurationList)
        
        //Remote build phases
        let bfList = self.buildPhases
        for bf in bfList { self.objectList.remove(bf) }
        
        //Remove build rules
        let brList = self.buildRules
        for br in brList { self.objectList.remove(br) }
        
        //Remove dependancies
        let dList = self.dependencies
        for d in dList { self.objectList.remove(d) }
        
        //Remove Product File
        /*if let p = self.product {
            self.objectList.remove(p)
        }*/
        
        super.deleting()
        
        
    }
    
    public func createBuildRule(name: String? = nil,
                                compilerSpec: String = "com.apple.compilers.proxy.script",
                                fileType: PBXFileType,
                                editable: Bool = true,
                                filePatterns: String? = nil,
                                outputFiles: [String] = [],
                                outputFilesCompilerFlags: [String]? = nil,
                                script: String? = nil) throws -> PBXBuildRule {
        
        
       var scrpt = script
        if scrpt == nil {
            if fileType == PBXFileType.Pattern.proxy {
                scrpt = "# Type a script or drag a script file from your workspace to insert its path.\n"
            } else if fileType == PBXFileType.SourceCode.Various.metal {
                scrpt = "# metal\n"
            } else if fileType == PBXFileType.Text.plist {
                scrpt = "# builtin-copyPlist\n"
            } else if fileType == PBXFileType.SourceCode.Various.dtrace{
                scrpt = "/usr/sbin/dtrace\n"
            }
        }
       let rule = PBXBuildRule(id: self.proj.generateNewReference(),
                                 name: name,
                                 compilerSpec: compilerSpec,
                                 fileType: fileType,
                                 editable: editable,
                                 filePatterns: filePatterns,
                                 outputFiles: outputFiles,
                                 outputFilesCompilerFlags: outputFilesCompilerFlags,
                                 script: scrpt)
        self.objectList.append(rule)
        self.buildRuleReferences.append(rule.id)
        return rule
        
    }
    
    @discardableResult
    public func removeBuildRule(_ buildRule: PBXBuildRule) -> Bool {
        for d in self.buildRuleReferences {
            if d == buildRule.id {
                self.objectList.remove(buildRule)
                return true
            }
        }
        return false
    }
    
    /// Create a framework build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created framework build phase
    @discardableResult
    public func createFrameworkBuildPhase(buildActionMask: UInt = PBXFrameworksBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                             files: [PBXReference] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0) throws -> PBXFrameworksBuildPhase {
        
        guard self.firstBuildPhase(forType: PBXFrameworksBuildPhase.self) == nil else {
            throw Error.buildPhaseAlreadyExists(PBXFrameworksBuildPhase.self)
        }
        let rtn  = PBXFrameworksBuildPhase(id: self.proj.generateNewReference(),
                                          buildActionMask: buildActionMask,
                                          files: files,
                                          runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
    }
    
    /// Create a headers build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created headers build phase
    @discardableResult
    public func createHeadersBuildPhase(buildActionMask: UInt = PBXHeadersBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                            files: [PBXReference] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0) throws -> PBXHeadersBuildPhase {
        guard self.firstBuildPhase(forType: PBXHeadersBuildPhase.self) == nil else {
            throw Error.buildPhaseAlreadyExists(PBXHeadersBuildPhase.self)
        }
        let rtn  = PBXHeadersBuildPhase(id: self.proj.generateNewReference(),
                                        buildActionMask: buildActionMask,
                                        files: files,
                                        runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
    }
    
    /// Create a resources build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created resources build phase
    @discardableResult
    public func createResourcesBuildPhase(buildActionMask: UInt = PBXResourcesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                           files: [PBXReference] = [],
                                           runOnlyForDeploymentPostprocessing: UInt = 0) throws -> PBXResourcesBuildPhase {
        guard self.firstBuildPhase(forType: PBXResourcesBuildPhase.self) == nil else {
            throw Error.buildPhaseAlreadyExists(PBXResourcesBuildPhase.self)
        }
        let rtn  = PBXResourcesBuildPhase(id: self.proj.generateNewReference(),
                                          buildActionMask: buildActionMask,
                                          files: files,
                                          runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
    }
    
    /// Create a rez build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created rez build phase
    @discardableResult
    public func createRezBuildPhase(buildActionMask: UInt = PBXRezBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                             files: [PBXReference] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0) throws -> PBXRezBuildPhase {
        guard self.firstBuildPhase(forType: PBXRezBuildPhase.self) == nil else {
            throw Error.buildPhaseAlreadyExists(PBXRezBuildPhase.self)
        }
        let rtn  = PBXRezBuildPhase(id: self.proj.generateNewReference(),
                                      buildActionMask: buildActionMask,
                                      files: files,
                                      runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
    }
    
    /// Create a sources build phase for this target
    ///
    /// - Parameters:
    ///   - buildActionMask: The action mask (Has Default)
    ///   - files: Any build file id's for this build phase
    ///   - runOnlyForDeploymentPostprocessing: The Run oly for deployment post processing (Default: 0)
    /// - Returns: Returns the newly created sources build phase
    @discardableResult
    public func createSourcesBuildPhase(buildActionMask: UInt = PBXSourcesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                                           files: [PBXReference] = [],
                                           runOnlyForDeploymentPostprocessing: UInt = 0) throws -> PBXSourcesBuildPhase {
        guard self.firstBuildPhase(forType: PBXSourcesBuildPhase.self) == nil else {
            throw Error.buildPhaseAlreadyExists(PBXSourcesBuildPhase.self)
        }
        let rtn  = PBXSourcesBuildPhase(id: self.proj.generateNewReference(),
                                        buildActionMask: buildActionMask,
                                        files: files,
                                        runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
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
                                             files: [PBXReference] = [],
                                             runOnlyForDeploymentPostprocessing: UInt = 0,
                                             dstPath: String = COPY_FILES_BUILD_PHASE_DEFAULT_DEST_PATH,
                                             dstSubfolderSpec: PBXCopyFilesBuildPhase.PBXSubFolder = .absolutePath) -> PBXCopyFilesBuildPhase {
        
        let rtn  = PBXCopyFilesBuildPhase(id: self.proj.generateNewReference(),
                                          name: name,
                                          buildActionMask: buildActionMask,
                                          files: files,
                                          runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                                          dstPath: dstPath,
                                          dstSubfolderSpec: dstSubfolderSpec)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
        
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
                                               files: [PBXReference] = [],
                                               runOnlyForDeploymentPostprocessing: UInt = 0,
                                               inputFileListPaths: [String] = [],
                                               inputPaths: [String] = [],
                                               outputPaths: [String] = [],
                                               shellPath: String = PBXShellScriptBuildPhase.DEFAULT_SHELL_PATH,
                                               shellScript: String? = nil) -> PBXShellScriptBuildPhase {
        let rtn  = PBXShellScriptBuildPhase(id: self.proj.generateNewReference(),
                                            name: name,
                                            buildActionMask: buildActionMask,
                                            files: files,
                                            runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
                                            inputFileListPaths: inputFileListPaths,
                                            inputPaths: inputPaths,
                                            outputPaths: outputPaths,
                                            shellPath: shellPath,
                                            shellScript: shellScript)
        
        self.objectList.append(rtn)
        self.buildPhaseReferences.append(rtn.id)
        return rtn
    }
    
    /// Removes a build phase from the target
    ///
    /// - Parameter buildPhase: The build phase to remove from the target
    /// - Returns: Returns an indicator if the build phase was removed or not
    @discardableResult
    public func removeBuildPhase(_ buildPhase: PBXBuildPhase) -> Bool {
        for d in self.buildPhaseReferences {
            if d == buildPhase.id {
                self.objectList.remove(buildPhase)
                return true
            }
        }
        return false
    }
    
    /// Creates a new dependency for this target
    ///
    /// - Parameters:
    ///   - target: The target this target will rely on
    /// - Returns: Returns the target dependency
    @discardableResult
    public func createDependency(_ target: PBXTarget) -> PBXTargetDependency {
        
        let remoteInfo: String? = (target as? PBXNativeTarget)?.productName
        let proxyType = PBXContainerItemProxy.PBXProxyType.nativeTarget
        
        let proxy: PBXContainerItemProxy = PBXContainerItemProxy(id: self.proj.generateNewReference(),
                                                                  containerPortal: project.id,
                                                                  proxyType: proxyType,
                                                                  remoteGlobalIDString: target.id,
                                                                  remoteInfo: remoteInfo)
        
        self.objectList.append(proxy)
        
        let rtn = PBXTargetDependency(id: self.proj.generateNewReference(),
                                        target: target.id,
                                        targetProxy: proxy.id)
        
        self.objectList.append(rtn)
        
        self.dependencyRefernces.append(rtn.id)
        
        return rtn
        
    }
    
    /// Removes a dependency from this target
    ///
    /// - Parameter dependency: The dependency to remove
    /// - Returns: And indicator if the dependency was removed or not
    @discardableResult
    public func removeDependancy(_ dependency: PBXTargetDependency) -> Bool {
        for d in self.dependencyRefernces {
            if d == dependency.id {
                self.objectList.remove(dependency)
                return true
            }
        }
        return false
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        havingObjectVersion objectVersion: Int,
                                                        havingArchiveVersion archiveVersion: Int,
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 2, let name = object[CodingKeys.name] as? String {
            return name
        } else if path.last == CodingKeys.buildConfigurationList,
               let name = object[CodingKeys.name] as? String ,
               let isa = object[CodingKeys.parent.type] as? String {
            return "Build configuration list for \(isa) \"\(name)\""
        /*} else if path.last == CodingKeys.productReference {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                                     inData: data,
                                                     userInfo: userInfo)*/
        } else if [CodingKeys.buildPhases,
                   CodingKeys.buildRules,
                   CodingKeys.dependencies].contains(path.itemOrNil(at: 2)) {
             return PBXObjects.getPBXEncodingComments(forValue: value,
                                                      atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                                      inData: data,
                                                      havingObjectVersion: objectVersion,
                                                      havingArchiveVersion: archiveVersion,
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
                                                            havingObjectVersion objectVersion: Int,
                                                            havingArchiveVersion archiveVersion: Int,
                                                            userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if [CodingKeys.buildConfigurationList/*,
            CodingKeys.productReference*/].contains(path.last) { return false }
        else if [CodingKeys.buildPhases,
                 CodingKeys.buildRules,
                 CodingKeys.dependencies].contains(path.itemOrNil(at: -2)) { return false }
        return hasKeyIndicators
        /*if path.last == CodingKeys.buildConfigurationList ||
            path.last == CodingKeys.productReference { return false }
        else if path.count > 2 && (path[path.count-2] == CodingKeys.buildPhases || path[path.count-2] == CodingKeys.buildRules || path[path.count-2] == CodingKeys.dependencies) { return false }
        return hasKeyIndicators*/
        
    }
    
}


