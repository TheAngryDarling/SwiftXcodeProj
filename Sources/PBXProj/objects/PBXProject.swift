//
//  PBXProject.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import CodableHelpers
import RawRepresentableHelpers


extension PBXProject {
    
    
    /// Build ConfiguraitonList Helper
    /// - use: Use the given configuration list
    /// - createWith: Create a configuration list with the following build configurations
    /// - create: Create a configuration list with the following settings
    public enum BuildConfigurationListOptions {
        /// Default configuration to use
        ///
        /// - debug:
        /// - release:
        public enum DefaultConfig: String {
            case debug = "Debug"
            case release = "Release"
        }
        
        public enum Errors: Error {
            case configNotFound(String)
        }
        case use(XCConfigurationList)
        case createWith(configs: [XCBuildConfiguration], default: String)
        case create(debugBase: XCBuildConfiguration?, debug: [String: Any], releaseBase: XCBuildConfiguration?, release: [String: Any], default: DefaultConfig)
        
        /// Create an empty build configuration list option
        public static var empty: BuildConfigurationListOptions {
            return BuildConfigurationListOptions()
        }
        
        /// Create an empty build configuration list option
        public init() {
            self.init(common: [:], default: .debug)
        }
        
        /// Creates a new BuildConfigurationListOptions.use
        public init(_ config: XCConfigurationList) { self = .use(config) }
        
        /// Creates a new BuildConfigurationListOptions.createWith
        ///
        /// - Parameters:
        ///   - configs: the configurations to use
        ///   - defaultConfig: The default configuration name
        /// - Throws: throws Errors.configNotFound if the default configuraiton name not found
        public init(_ configs: [XCBuildConfiguration], default defaultConfig: String) throws {
            guard configs.first(where: { $0.name == defaultConfig }) != nil else {
                throw Errors.configNotFound(defaultConfig)
            }
            self = .createWith(configs: configs, default: defaultConfig)
        }
        
        /// Creates a new BuildConfigurationListOptions.create
        ///
        /// - Parameters:
        ///   - common: The common settings to use for both debug and release
        ///   - defaultConfig: The default configuration name
        ///   - base: A base configuraiton if one is needed (Optional)
        public init(common: [String: Any],
                    default defaultConfig: DefaultConfig = .release,
                    base: XCBuildConfiguration? = nil) {
            self = .create(debugBase: base, debug: common, releaseBase: base, release: common, default: defaultConfig)
        }
        /// Creates a new BuildConfigurationListOptions.create
        ///
        /// - Parameters:
        ///   - debug: The debug settings to use
        ///   - debugBase: A base configuraiton if one is needed
        ///   - release: The debug settings to use
        ///   - releaseBase: A base configuraiton if one is needed
        ///   - defaultConfig: The default configuration name
        public init(debug: [String: Any],
                    debugBase: XCBuildConfiguration? = nil,
                    release: [String: Any],
                    releaseBase: XCBuildConfiguration? = nil,
                    default defaultConfig: DefaultConfig = .release) {
            self = .create(debugBase: debugBase, debug: debug, releaseBase: releaseBase, release: release, default: defaultConfig)
        }
        
        /// Get/create the configuraiton list for these optons
        ///
        /// - Parameter proj: The project to create the list with
        /// - Returns: Returns the configuration list
        fileprivate func getConfigList(_ proj: PBXProj) throws -> XCConfigurationList {
            switch self {
            case .use(let c): return c
            case .createWith(configs: let cfg, default: let def):
                return try proj.createConfigurationList(buildConfigurations: cfg, defaultConfigurationName: def)
            case .create(debugBase: let debugBase, debug: let cfgDebug, releaseBase: let releaseBase, release: let cfgRelease, default: let def):
                let debug = proj.createBuildConfiguration(baseConfiguration: debugBase,
                                                             buildSettings: cfgDebug,
                                                             name: DefaultConfig.debug.rawValue)
                let release = proj.createBuildConfiguration(baseConfiguration: releaseBase,
                                                               buildSettings: cfgRelease,
                                                               name: DefaultConfig.release.rawValue)
                return try proj.createConfigurationList(buildConfigurations: [debug,release],
                                                           defaultConfigurationName: def.rawValue)
            
                
            }
        }
    }
}

public final class PBXProject: PBXUnknownObject {
    
    public enum Errors: Error {
        case objectNotFound
    }
    
    /// Development Region
    public struct PBXRegion {
        private let rawValue: String
        public init(_ rawValue: String) { self.rawValue = rawValue }
        
        private static let namedRegionCodes: [(name: String, code: String)] = [
                                                        ("English", "en"),
                                                        ("Japanese", "ja"),
                                                        ("French", "fr"),
                                                        ("German", "de"),
                                                        ("Chinese", "zh"),
                                                        ("Czech", "cs"),
                                                        ("Danish", "da"),
                                                        ("Dutch", "nl"),
                                                        ("Greek", "el"),
                                                        ("Italian", "it"),
                                                        ("Korean", "ko"),
                                                        ("Polish", "pl"),
                                                        ("Russian", "ru"),
                                                        ("Swedish", "sv"),
                                                        ("Turkish", "tr"),
                                                        ("Ukrainian", "uk"),
                                                        ("Vietnamese", "vi")
        ]

        /// Defined long region codes
        public struct long {
            private init() { }
            
            public static let english: PBXRegion = "English"
            public static let japanese: PBXRegion = "Japanese"
            public static let french: PBXRegion = "French"
            public static let german: PBXRegion = "German"
            public static let chinese: PBXRegion = "Chinese"
            public static let czech: PBXRegion = "Czech"
            public static let danish: PBXRegion = "Danish"
            public static let dutch: PBXRegion = "Dutch"
            public static let greek: PBXRegion = "Greek"
            public static let italian: PBXRegion = "Italian"
            public static let korean: PBXRegion = "Korean"
            public static let polish: PBXRegion = "Polish"
            public static let russian: PBXRegion = "Russian"
            public static let swedish: PBXRegion = "Swedish"
            public static let turkish: PBXRegion = "Turkish"
            public static let ukrainian: PBXRegion = "Ukrainian"
            public static let vietnamese: PBXRegion = "Vietnamese"
        }
        
        /// Defined short region codes
        public struct short {
            private init() { }
            
            public static let en: PBXRegion = "en"
            public static let ja: PBXRegion = "ja"
            public static let fr: PBXRegion = "fr"
            public static let de: PBXRegion = "de"
            public static let zh: PBXRegion = "zh"
            public static let cs: PBXRegion = "cs"
            public static let da: PBXRegion = "da"
            public static let nl: PBXRegion = "nl"
            public static let el: PBXRegion = "el"
            public static let it: PBXRegion = "it"
            public static let ko: PBXRegion = "ko"
            public static let pl: PBXRegion = "pl"
            public static let ru: PBXRegion = "ru"
            public static let sv: PBXRegion = "sv"
            public static let tr: PBXRegion = "tr"
            public static let uk: PBXRegion = "uk"
            public static let vi: PBXRegion = "vi"
        }
        
        
        
        
        
        /// Returns the short 2 character region for the given locale if one can be found
        ///
        /// - Parameter locale: The locale to use (Default: current)
        /// - Returns: Returns a region based on the locale language code if a lanauge is returned
        public static func shortRegion(from locale: Locale = Locale.current) -> PBXRegion? {
            guard let r = locale.languageCode else { return nil }
            return PBXRegion(r)
        }
        
        /// Returns a full language Region for the given locale if one can be found
        ///
        /// - Parameter locale: The locale to use (Default: current)
        /// - Returns: Returns a region based on the locale language code if a lanauge is returned
        public static func longRegion(from locale: Locale = Locale.current) -> PBXRegion? {
            guard let region = locale.languageCode else { return nil }
           
            
            for r in namedRegionCodes {
                if r.code == region.lowercased() {
                    return PBXRegion(r.name)
                }
            }
            
            return nil
        }
        
        /// Tries and get both short and long regions for a given locale
        ///
        /// - Parameter locale: The locale to use (Default: current)
        /// - Returns: Returns an array of possible regions for the given locale
        public static func knownRegions(from locale: Locale = Locale.current) -> [PBXRegion] {
        
            var rtn: [PBXProject.PBXRegion] = []
            if let r = PBXRegion.shortRegion(from: locale) {
                rtn.append(r)
                if let l = PBXRegion.longRegion(from: locale) {
                    rtn.append(l)
                }
            }
            return rtn
            
        }
        
        
    }
    
    public struct PBXProjectReference: Codable {
        private enum CodingKeys: String, CodingKey {
            case group = "ProductGroup"
            case ref = "ProjectRef"
        }
        public let group: PBXReference
        public let ref: PBXReference
        
        public init(group: PBXReference, ref: PBXReference) {
            self.group = group
            self.ref = ref
        }
    }
    
    /// Project Codable Keys
    internal enum ProjectCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case buildConfigurationList
        case compatibilityVersion
        case developmentRegion
        case hasScannedForEncodings
        case knownRegions
        case mainGroup
        case productRefGroup
        case projectDirPath
        case projectReferences
        case projectRoot
        case targets
        case attributes
    }
    
    private typealias CodingKeys = ProjectCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.attributes)
        rtn.append(CodingKeys.buildConfigurationList)
        rtn.append(CodingKeys.compatibilityVersion)
        rtn.append(CodingKeys.developmentRegion)
        rtn.append(CodingKeys.hasScannedForEncodings)
        rtn.append(CodingKeys.knownRegions)
        rtn.append(CodingKeys.mainGroup)
        rtn.append(CodingKeys.productRefGroup)
        rtn.append(CodingKeys.projectDirPath)
        rtn.append(CodingKeys.projectReferences)
        rtn.append(CodingKeys.projectRoot)
        rtn.append(CodingKeys.targets)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.attributes)
        rtn.append(CodingKeys.buildConfigurationList)
        rtn.append(CodingKeys.compatibilityVersion)
        rtn.append(CodingKeys.developmentRegion)
        rtn.append(CodingKeys.hasScannedForEncodings)
        rtn.append(CodingKeys.knownRegions)
        rtn.append(CodingKeys.mainGroup)
        rtn.append(CodingKeys.productRefGroup)
        rtn.append(CodingKeys.projectDirPath)
        rtn.append(CodingKeys.projectReferences)
        rtn.append(CodingKeys.projectRoot)
        rtn.append(CodingKeys.targets)
        return rtn
    }
    
    /// The object is a reference to a XCConfigurationList element.
    public private(set) var buildConfigurationListReference: PBXReference
    public var buildConfigurationList: XCConfigurationList {
        return self.objectList.object(withReference: self.buildConfigurationListReference,
                                      asType: XCConfigurationList.self)!
    }
    
    /// A string representation of the XcodeCompatibilityVersion.
    public var compatibilityVersion: String
    
    /// The region of development.
    public var developmentRegion: PBXRegion?
    
    /// Whether file encodings have been scanned.
    public var hasScannedForEncodings: Int?
    
    /// The known regions for localized files.
    public var knownRegions: [PBXRegion]
    
    /// The object is a reference to a PBXGroup element.
    public private(set) var mainGroupReference: PBXReference
    public var mainGroup: PBXGroup! {
        return self.objectList.object(withReference: self.mainGroupReference, asType: PBXGroup.self)
    }
    
    /// The object is a reference to the product PBXGroup element.
    public private(set) var productRefGroupReference: PBXReference?
    /// The product PBXGroup object if one is defined
    public var productRefGroup: PBXGroup? {
        get {
            guard let pr = self.productRefGroupReference else { return nil }
            return self.objectList.object(withReference: pr, asType: PBXGroup.self)
        }
        set {
            self.productRefGroupReference = newValue?.id
        }
    }
    
    /// The relative path of the project.
    public var projectDirPath: String?
    
    /// Project references.
    public var projectReferences: [PBXProjectReference]
    
    /// The relative root path of the project.
    public var projectRoot: String?
    
    /// The objects are a reference to a PBXTarget element.
    public private(set) var targetReferences: [PBXReference]
    /// The target objects for this project
    public var targets: [PBXTarget] {
        get {
            return self.objectList.objects(withReferences: self.targetReferences, asType: PBXTarget.self)
        }
        set {
            self.targetReferences = newValue.map { $0.id }
        }
    }
    
    /// Project attributes.
    public var attributes: [String: Any]
    
    private static let targetAttributesKey = "TargetAttributes"
    
    /// The target attributes stored within the attributes property
    public var targetAttributes: [PBXReference: [String: Any]] {
        get {
            guard let targetAttributes = self.attributes[PBXProject.targetAttributesKey] as? [String: Any] else { return [:] }
            var rtn: [PBXReference: [String: Any]] = [:]
            for (k,v) in targetAttributes {
                if let dV = v as? [String: Any] {
                    rtn[PBXReference(k)] = dV
                }
            }
            return rtn
            
        }
        set {
            var tA: [String: Any] = [:]
            for (k,v) in newValue {
                tA[k.description] = v
            }
            
            self.attributes[PBXProject.targetAttributesKey] = tA
        }
    }
    
    
    
    /// Create a new instance of PBXProject
    ///
    /// - Parameters:
    ///   - id: The unqiue refrence to this object
    ///   - buildConfigurationList: The reference to the build configuration list
    ///   - compatibilityVersion: The Xcode compatibility version
    ///   - developmentRegion: The development Region (Optional)
    ///   - hasScannedForEncodings: Indicator if has scanned for encodings (1 or 0) (Optional)
    ///   - knownRegions: The known development regions (Optional)
    ///   - mainGroup: The reference to the main group. All files and folders should be under here
    ///   - productRefGroup: The reference to the product group (Optional, Empty projects do not have this)
    ///   - projectDirPath: The path to the project (Optional)
    ///   - projectReferences: The Project references (Default: empty array)
    ///   - projectRoot: The Project Root (Optional)
    ///   - targets: An array of references to the targets for this project
    ///   - attributes: The project attributes
    internal init(id: PBXReference,
                buildConfigurationList: PBXReference,
                compatibilityVersion: String,
                developmentRegion: PBXRegion? = nil,
                hasScannedForEncodings: Int? = nil,
                knownRegions: [PBXRegion] = [],
                mainGroup: PBXReference,
                productRefGroup: PBXReference? = nil,
                projectDirPath: String? = nil,
                projectReferences: [PBXProjectReference] = [],
                projectRoot: String? = nil,
                targets: [PBXReference] = [],
                attributes: [String: Any] = [:]) {
        
        self.buildConfigurationListReference = buildConfigurationList
        self.compatibilityVersion = compatibilityVersion
        self.developmentRegion = developmentRegion
        self.hasScannedForEncodings = hasScannedForEncodings
        self.knownRegions = knownRegions
        self.mainGroupReference = mainGroup
        self.productRefGroupReference = productRefGroup
        self.projectDirPath = projectDirPath
        self.projectReferences = projectReferences
        self.projectRoot = projectRoot
        self.targetReferences = targets
        self.attributes = attributes
        
        super.init(id: id, type: .project)
    }
    
    public required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.buildConfigurationListReference = try container.decode(PBXReference.self, forKey: .buildConfigurationList)
        self.compatibilityVersion = try container.decode(String.self, forKey: .compatibilityVersion)
        self.developmentRegion = try container.decodeIfPresent(PBXRegion.self, forKey: .developmentRegion)
        self.hasScannedForEncodings = try container.decodeIfPresent(Int.self, forKey: .hasScannedForEncodings)
        self.knownRegions = (try container.decodeIfPresent([PBXRegion].self, forKey: .knownRegions)) ?? []
        self.mainGroupReference = try container.decode(PBXReference.self, forKey: .mainGroup)
        self.productRefGroupReference = try container.decodeIfPresent(PBXReference.self, forKey: .productRefGroup)
        self.projectDirPath = try container.decodeIfPresent(String.self, forKey: .projectDirPath)
        self.projectReferences = (try container.decodeIfPresent([PBXProjectReference].self, forKey: .projectReferences)) ?? []
        self.projectRoot = try container.decodeIfPresent(String.self, forKey: .projectRoot)
        self.targetReferences = try container.decode([PBXReference].self, forKey: .targets)
        self.attributes = (try CodableHelpers.dictionaries.decodeIfPresent(from: &container, forKey: .attributes)) ?? [:]
        
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.buildConfigurationListReference, forKey: .buildConfigurationList)
        try container.encode(self.compatibilityVersion, forKey: .compatibilityVersion)
        try container.encodeIfPresent(self.developmentRegion, forKey: .developmentRegion)
        try container.encodeIfPresent(self.hasScannedForEncodings, forKey: .hasScannedForEncodings)
        if self.knownRegions.count > 0 {  try container.encode(self.knownRegions, forKey: .knownRegions) }
        try container.encode(self.mainGroupReference, forKey: .mainGroup)
        try container.encodeIfPresent(self.productRefGroupReference, forKey: .productRefGroup)
        try container.encodeIfPresent(self.projectDirPath, forKey: .projectDirPath)
        if self.projectReferences.count > 0 { try container.encode(self.projectReferences, forKey: .projectReferences) }
        try container.encodeIfPresent(self.projectRoot, forKey: .projectRoot)
        try container.encode(self.targetReferences, forKey: .targets)
        if self.attributes.count > 0 { try CodableHelpers.dictionaries.encode(self.attributes, in: &container, forKey: .attributes) }
        
        try super.encode(to: encoder)
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if (self.mainGroupReference == objectReference ||
            self.productRefGroupReference == objectReference ||
            self.buildConfigurationListReference == objectReference ||
            self.targetReferences.contains(objectReference) ||
            self.projectReferences.contains(where: { return ($0.group == objectReference || $0.ref == objectReference ) })) { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 2  { return "Project object" }
        else if path.count == 3 && [ProjectCodingKeys.buildConfigurationList,
                                    ProjectCodingKeys.mainGroup,
                                    ProjectCodingKeys.productRefGroup].contains(path.last) {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                                     inData: data,
                                                     userInfo: userInfo)
        } else if path.count == 4 && path[2] == ProjectCodingKeys.targets {
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
        if path.count == 3 && [CodingKeys.buildConfigurationList,
                               CodingKeys.mainGroup,
                               CodingKeys.productRefGroup].contains(path.last) {
            return false
        } else if path.count == 4 && path[2] == CodingKeys.targets {
            return false
        }
        return hasKeyIndicators
    }
    
}

// MARK: - Targets
extension PBXProject {
    
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
    /// - returns: A newly created native target
    @discardableResult
    public func createNativeTarget(withTargetName target: String,
                                      buildConfigurationList: BuildConfigurationListOptions,
                                      buildPhases:  [PBXBuildPhase] = [],
                                      buildRules: [PBXBuildRule] = [],
                                      dependencies: [PBXTargetDependency] = [],
                                      productType: PBXProductType,
                                      productFileReferenceNaming: PBXTarget.TargetReferenceNaming = .target,
                                      targetReferenceNaming: PBXTarget.TargetReferenceNaming = .generated,
                                      createProxy: Bool = true) throws -> PBXNativeTarget {
        
        if self.objectList != nil {
            for object in buildPhases {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in buildRules {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in dependencies {
                if object.objectList == nil { self.objectList.append(object) }
            }
        }
        
        let productsFolder = self.proj.getProductsFolder()
        /*guard let productsFolder = self.mainGroup.findFolder(atPath: "Products") else {
            throw Errors.objectNotFound
        }*/
        
        let productFileId: PBXReference = productFileReferenceNaming.generateId(self.proj, targetName: target)
        
        var path: String = target
        if let ext = productType.fileExtension {
            path += "." + ext
        }
        let productFile = PBXFileReference(id: productFileId,
                                           namePath: PBXNamePath.path(path),
                                           sourceTree: .buildProductsDir,
                                           lastKnownFileType: productType.fileType)
        self.objectList.append(productFile)
        productsFolder.childrenReferences.append(productFile.id)
        
        
        
        //let newId = self.proj.generateNewReference(withProjectName: project, targetName: target)
        
        let newId = targetReferenceNaming.generateId(self.proj, targetName: target)
        let rtn = PBXNativeTarget(id: newId,
                                  name: target,
                                  buildConfigurationList: try buildConfigurationList.getConfigList(self.proj).id,
                                  buildPhases: buildPhases.map { $0.id },
                                  buildRules: buildRules.map { $0.id },
                                  dependencies: dependencies.map { $0.id },
                                  productName: target,
                                  productReference: productFile.id,
                                  productType: productType)
        self.objectList.append(rtn)
        self.targetReferences.append(rtn.id)
        
        if createProxy {
            let containerItemProxy = PBXContainerItemProxy(id: self.proj.generateNewReference(),
                                                           containerPortal: self.id,
                                                           proxyType: .nativeTarget,
                                                           remoteGlobalIDString: newId,
                                                           remoteInfo: target)
            self.objectList.append(containerItemProxy)
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
    /// - returns: A newly created aggregate target
    @discardableResult
    public func createAggregateTarget(withTargetName target: String,
                                         buildConfigurationList: BuildConfigurationListOptions,
                                         buildPhases:  [PBXBuildPhase] = [],
                                         buildRules: [PBXBuildRule] = [],
                                         dependencies: [PBXTargetDependency] = [],
                                        //productType: PBXProductType,
                                        targetReferenceNaming: PBXTarget.TargetReferenceNaming = .generated) throws -> PBXAggregateTarget {
        
        if self.objectList != nil {
            for object in buildPhases {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in buildRules {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in dependencies {
                if object.objectList == nil { self.objectList.append(object) }
            }
        }
        /*let newId = self.proj.generateNewReference(withProjectName: project,
                                                   targetName: target,
                                                   productName: productName)*/
        let newId = targetReferenceNaming.generateId(self.proj, targetName: target)
        let rtn = PBXAggregateTarget(id: newId,
                                     name: target,
                                      buildConfigurationList: try buildConfigurationList.getConfigList(self.proj).id,
                                      buildPhases: buildPhases.map { $0.id },
                                      buildRules: buildRules.map { $0.id },
                                      dependencies: dependencies.map { $0.id }/*,
                                      productName: target,
                                      productReference: nil,
                                      productType: productType*/)
        self.objectList.append(rtn)
        self.targetReferences.append(rtn.id)
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
    /// - returns: A newly created legacy target
    @discardableResult
    public func createLegacyTarget(withTargetName target: String,
                                      buildConfigurationList: BuildConfigurationListOptions,
                                      buildPhases:  [PBXBuildPhase] = [],
                                      buildRules: [PBXBuildRule] = [],
                                      dependencies: [PBXTargetDependency] = [],
                                      buildToolPath: String? = nil,
                                      buildArgumentsString: String? = nil,
                                      passBuildSettingsInEnvironment: Bool = false,
                                      buildWorkingDirectory: String? = nil,
                                      targetReferenceNaming: PBXTarget.TargetReferenceNaming = .generated) throws -> PBXLegacyTarget {
        
        if self.objectList != nil {
            for object in buildPhases {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in buildRules {
                if object.objectList == nil { self.objectList.append(object) }
            }
            for object in dependencies {
                if object.objectList == nil { self.objectList.append(object) }
            }
        }
       
        let newId = targetReferenceNaming.generateId(self.proj, targetName: target)
        
        let rtn = PBXLegacyTarget(id: newId,
                                  name: target,
                                  buildConfigurationList: try buildConfigurationList.getConfigList(self.proj).id,
                                  buildPhases: buildPhases.map { $0.id },
                                  buildRules: buildRules.map { $0.id },
                                  dependencies: dependencies.map { $0.id },/*
                                  productName: target,
                                  productReference: nil,
                                  productType: productType,*/
                                  buildToolPath: buildToolPath,
                                  buildArgumentsString: buildArgumentsString,
                                  passBuildSettingsInEnvironment: passBuildSettingsInEnvironment,
                                  buildWorkingDirectory: buildWorkingDirectory)

        self.objectList.append(rtn)
        self.targetReferences.append(rtn.id)
        return rtn
    }
    
    
}

extension PBXProject.PBXRegion: CustomStringConvertible {
    public var description: String { return self.rawValue }
}

extension PBXProject.PBXRegion: Codable {
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

extension PBXProject.PBXRegion: Equatable {
    public static func ==(lhs: PBXProject.PBXRegion, rhs: PBXProject.PBXRegion) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXProject.PBXRegion, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: PBXProject.PBXRegion) -> Bool {
        return lhs == rhs.rawValue
    }
}
extension PBXProject.PBXRegion: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

