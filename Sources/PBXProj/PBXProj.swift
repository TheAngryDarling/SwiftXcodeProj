//
//  PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-23.
//
// Reference: http://www.monobjc.net/xcode-project-file-format.html
import Foundation
import AdvancedCodableHelpers
import RawRepresentableHelpers
import Dispatch


/// Class that represents an Xcode PBX Project file
public class PBXProj: Codable {
    internal enum CodingKeys: String, CodingKey {
        case archiveVersion
        case objectVersion
        case classes
        case rootObject
        case objects
    }
    
    public enum Errors: Error {
        case defaultConfigurationNotFoundInList(String)
        case invalidNumber(String)
        case typeMismatch(Swift.DecodingError.Context)
    }
    
    
    //public static let STD_CONFIG_NAME_DEBUG = "Debug"
    //public static let STD_CONFIG_NAME_RELEASE = "Release"
    
    public struct ProjectBuildConfigurationOptions {
        public enum DefaultConfig: String {
            case debug = "Debug"
            case release = "Release"
        }
        fileprivate let release: [String: Any]
        fileprivate let debug: [String: Any]
        fileprivate let defaultSettings: DefaultConfig
        
        public init(default defaultSettings: DefaultConfig = .debug, debug: [String: Any], release: [String: Any]) {
            self.release = release
            self.debug = debug
            self.defaultSettings = defaultSettings
        }
        
        public init(default defaultSettings: DefaultConfig = .debug, config: [String: Any]) {
            self.init(default: defaultSettings, debug: config, release: config)
        }
        
        
        public init() {
            self.init(default: .debug, config: [:])
        }
    }
    
    /// Archive version of the given file
    public let archiveVersion: Int
    /// Object version of the given file
    public let objectVersion: Int
    /// Class details (This has always been empty)
    public var classes: [String: Any]
    /// Referenec to the root object (PBXProject) in the object list
    public var rootObject: PBXReference
    /// The object list.  A collection of all objects in the file
    public var objects: PBXObjects
    /// Object ID generator counter.
    ///
    /// When using sequential obejct id's 'OBJ_1', 'OBJ_2' this is the counter to the next available number
    private var objCounter: Int = 1
    
    /// The dispatch queue used to sync lock objCounter
    private let objCounderLock: DispatchQueue = DispatchQueue(label: "PBXProj.ObjCounter.Lock")
    /// This stores the function we will used to generate new reference id's.  It could be the sequential number generator or the guid generator
    private var idGenFunc: (() -> PBXReference)!
    
    //public var project: PBXProject { return self.objects.of(type: PBXProject.self)[0] }
    /// Referene to the Project within the file
    public private(set) var project: PBXProject!
    
    /// Reference to the main group in the project.  This is were file file tree structure is stored
    public var mainGroup: PBXGroup! { return self.project.mainGroup }
    
    
    public init(archiveVersion: Int,
                 objectVersion: Int,
                 classes: [String: Any] = [:],
                 settings: ProjectBuildConfigurationOptions,
                 compatibilityVersion: String,
                 developmentRegion: PBXProject.PBXRegion? = nil,
                 hasScannedForEncodings: Int? = nil,
                 knownRegions: [PBXProject.PBXRegion] = [],
                 projectDirPath: String? = nil,
                 projectReferences: [PBXProject.PBXProjectReference] = [],
                 projectRoot: String? = nil,
                 attributes: [String: Any] = [:]) {
        
        
        
        
        self.archiveVersion = archiveVersion
        self.objectVersion = objectVersion
        self.classes = classes
        self.rootObject = "ROOT_REFERENCE"
        self.objects = PBXObjects()
        
        self.objects.proj = self
        
        if objectVersion >= 50 { self.idGenFunc = generateNewUUIDReference }
        else { self.idGenFunc = generateNewObjNumReference }
        
        self.rootObject = self.generateNewReference() // OBJ_1
        
        
        let projBuildConfigurationListId = self.generateNewReference() //OBJ_2
        let projDebugBuildConfigurationId = self.generateNewReference() //OBJ_3
        let projReleaseBuildConfigurationId = self.generateNewReference() //OBJ_4
        let projRootFolderId = self.generateNewReference() // OBJ_5
        //let projProductsFolderId = self.generateNewReference() // OBJ_6
        
        let projRootFolder = PBXGroup(id: projRootFolderId,
                                      groupType: .basic,
                                      namePath: PBXNamePath.empty,
                                      sourceTree: .group,
                                      children: [])
        
        
        
        let projDebugBuildConfiguration = XCBuildConfiguration(id: projDebugBuildConfigurationId,
                                                               name: ProjectBuildConfigurationOptions.DefaultConfig.debug.rawValue,
                                                               baseConfigurationReference: nil,
                                                               buildSettings: settings.debug)
        
        let projReleaseBuildConfiguration = XCBuildConfiguration(id: projReleaseBuildConfigurationId,
                                                                 name: ProjectBuildConfigurationOptions.DefaultConfig.release.rawValue,
                                                               baseConfigurationReference: nil,
                                                               buildSettings: settings.release)
        
        let projBuildConfigurationList = XCConfigurationList(id: projBuildConfigurationListId,
                                                             buildConfigurations: [projDebugBuildConfigurationId, projReleaseBuildConfigurationId],
                                                             defaultConfigurationName: settings.defaultSettings.rawValue)
        
        let proj = PBXProject(id: self.rootObject,
                              buildConfigurationList: projBuildConfigurationListId,
                              compatibilityVersion: compatibilityVersion,
                              developmentRegion: developmentRegion,
                              hasScannedForEncodings: hasScannedForEncodings,
                              knownRegions: knownRegions,
                              mainGroup: projRootFolderId,
                              productRefGroup: nil /*projProductsFolder.id*/,
                              projectDirPath: projectDirPath,
                              projectReferences: projectReferences,
                              projectRoot: projectRoot,
                              targets: [],
                              attributes: attributes)
        
        self.project = proj
        
        //self.objects.append(projProductsFolder)
        self.objects.append(projRootFolder)
        self.objects.append(projDebugBuildConfiguration)
        self.objects.append(projReleaseBuildConfiguration)
        self.objects.append(projBuildConfigurationList)
        self.objects.append(proj)
    }
    
    internal convenience init(fromURL url: URL) throws {
        
        let decoder = PBXProjOpenDecoder()
        let catcher = try decoder.decode(DecoderCatcher.self, from: try Data(contentsOf: url))
        
        try self.init(from: catcher.decoder)
        
    }
    
    required public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.archiveVersion = try container.decode(Int.self, forKey: .archiveVersion)
        self.objectVersion = try container.decode(Int.self, forKey: .objectVersion)
        
        

        self.classes = (try CodableHelpers.dictionaries.decodeIfPresent(from: &container, forKey: .classes)) ?? [:]
        self.rootObject = try container.decode(PBXReference.self, forKey: .rootObject)
        self.objects = try container.decode(PBXObjects.self, forKey: .objects)
        
        self.objects.proj = self
        
        self.project = self.objects.object(withReference: self.rootObject, asType: PBXProject.self)!
        
        
        let hasUUIDIndicator = self.objects.contains(where: { return (!$0.id.hasPrefix("OBJ_") && !$0.id.contains("::")) })
        if hasUUIDIndicator { self.idGenFunc = generateNewUUIDReference }
        else {
            self.idGenFunc = generateNewObjNumReference
            // Get all object reference id's in the object list
            var references = self.objects.map({ return $0.id })
            //Filter out to only ones that start with OBJ_
            references = references.filter({ return $0.hasPrefix("OBJ_") })
            // Remove the OBJ_ and convert to integers
            var objIds: [Int] = references.map({ return Int(String($0.description.dropFirst(4)))! })
            // Sort to the biggest is on the bottom
            objIds.sort()
            if let lastId = objIds.last {
                self.objCounter = (lastId + 1)
            }
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.archiveVersion, forKey: .archiveVersion)
        try container.encode(self.objectVersion, forKey: .objectVersion)
        if self.classes.count > 0 {
            try CodableHelpers.dictionaries.encode(self.classes, in: &container, forKey: .classes)
        }
        try container.encode(self.rootObject, forKey: .rootObject)
        try container.encode(self.objects, forKey: .objects)
    }
    
    /// Save the PBX Project file
    ///
    /// - Parameters:
    ///   - url: The url to where the PBX Project file should be saved
    ///   - encoding: The String encoding to use when saving (Default: UTF8)
    ///   - tabs: The representation of a tab within the file (Default: SPACE)
    public func save(to url: URL, usingEncoding encoding: String.Encoding = .utf8, withTabRepresentation tabs: String = " ") throws {
        let encoder = PBXProjEncoder()
        encoder.encoding = encoding
        encoder.tabs = tabs
        let dta = try encoder.encode(self)
        try dta.write(to: url, options: .atomic)
    }
    
    /// Get or create the Products folder for the project
    ///
    /// - Returns: Returns a PBXGroup representing the Products folder of the project
    public func getProductsFolder() -> PBXGroup {
        if let grpID = self.project.productRefGroupReference {
            return self.objects.object(withReference: grpID, asType: PBXGroup.self)!
        }
        let projProductsFolder = PBXGroup(id: self.generateNewReference(),
                                          groupType: .basic,
                                          namePath: PBXNamePath.name("Products"),
                                          sourceTree: .buildProductsDir,
                                          children: [])
        
        
        self.project.mainGroup.childrenReferences.append(projProductsFolder.id)
        self.project.productRefGroup = projProductsFolder
        
        self.objects.append(projProductsFolder)
        return projProductsFolder
    }
    
    /// Finds all objects that have no connections to other objects
    ///
    /// - Returns: Returns an array of objects that are not connected to anything
    public func danglingObjects() -> [PBXObject] {
        var rtn: [PBXObject] = []
        for object in self.objects {
            var hasFoundReference: Bool = (object.id == self.rootObject)
            for i in 0..<self.objects.count where !hasFoundReference{
                let obj = self.objects[i]
                guard object.id != obj.id else { continue }
                hasFoundReference = obj.hasReference(to: object)
            }
            
            if !hasFoundReference {
                rtn.append(object)
            }
            
        }
        return rtn
    }
    
    /// Method for returning the property coding keys in the order they should be written to file in
    ///
    /// - Parameters:
    ///   - content: The content of the given object (key/value) paris
    ///   - data: The data of all objects in the file
    ///   - path: The path of the given object in the file
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    /// - Returns: Reutrns an array of the keys in the order they should be written in
    internal static func getPBXEncodingOrderKeys(_ content: [String: Any],
                                                 inData data: [String: Any],
                                                 atPath path: [String],
                                                 havingObjectVersion objectVersion: Int,
                                                 havingArchiveVersion archiveVersion: Int) -> [String] {
        if path.count >= 1 && path[0] == CodingKeys.objects {
            return PBXObjects.getPBXEncodingOrderKeys(content,
                                                      inData: data,
                                                      atPath: path,
                                                      havingObjectVersion: objectVersion,
                                                      havingArchiveVersion: archiveVersion)
        } else {
            return content.keys.sorted()
        }
        /*if let idx = rtn.index(of: "rootObject") {
            //Move rootObject to bottom of list
            rtn.remove(at: idx)
            rtn.append("rootObject")
        }
        return rtn*/
    }
    
    /// Returns the PBX comments for the given object
    ///
    /// - Parameters:
    ///   - value: The value being written
    ///   - path: The path of this object within the file
    ///   - inData: Dictionary of all data from the file
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Custom user properites
    /// - Returns: Returns the object comments if any exists
    internal class func getPBXEncodingComments(forValue value: String,
                                               atPath path: [String],
                                               inData data: [String: Any],
                                               havingObjectVersion objectVersion: Int,
                                               havingArchiveVersion archiveVersion: Int,
                                               userInfo: [CodingUserInfoKey: Any]) -> String? {
        if path.count == 1 && path[0] == CodingKeys.rootObject.rawValue {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath: [CodingKeys.objects.rawValue, value],
                                                     inData: data,
                                                     havingObjectVersion: objectVersion,
                                                     havingArchiveVersion: archiveVersion,
                                                     userInfo: userInfo)
            //return ReadWritter.getComments(forValue: value, atPath: [CodingKeys.objects.rawValue, value] , inData: data)
        } else if path.count >= 1 && path[0] == CodingKeys.objects.rawValue {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath: path,
                                                     inData: data,
                                                     havingObjectVersion: objectVersion,
                                                     havingArchiveVersion: archiveVersion,
                                                     userInfo: userInfo)
        }
        return nil 
    }

    /// Mehod to determin if the value should be string escaped
    ///
    /// - Parameters:
    ///   - value: value to check
    ///   - hasKeyIndicators: Indicator whether this value had characters that needed to be escaped
    ///   - path: Path of the current object
    ///   - inData: File Data
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Custom user properties
    /// - Returns: Reutrns true if the value should be escaped, otherwise false
    internal class func isPBXEncodinStringEscaping(_ value: String,
                                                   hasKeyIndicators: Bool,
                                                   atPath path: [String],
                                                   inData data: [String: Any],
                                                   havingObjectVersion objectVersion: Int,
                                                   havingArchiveVersion archiveVersion: Int,
                                                   userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if path.count >= 1 && path[0] == CodingKeys.objects.rawValue {
            return PBXObjects.isPBXEncodinStringEscaping(value,
                                                         hasKeyIndicators: hasKeyIndicators,
                                                         atPath: path,
                                                         inData: data,
                                                         havingObjectVersion: objectVersion,
                                                         havingArchiveVersion: archiveVersion,
                                                         userInfo: userInfo)
        } else {
            return hasKeyIndicators
        }
    }
    
    /// Sequential PBX Reference number generator.
    ///
    /// This generates references in a sequence OBJ_1, OBJ_2, OBJ_3, ...
    ///
    /// - Returns: Returns a new PBX Reference with the next available OBJ number
    private func generateNewObjNumReference() -> PBXReference {
        return objCounderLock.sync {
            let rtn: String = "OBJ_\(self.objCounter)"
            self.objCounter += 1
            
            return PBXReference(rtn)
        }
    }
    
    /// UUID PBX Reference generator
    ///
    /// - Returns: Returns a new PBX Reference generated by UUID
    private func generateNewUUIDReference() -> PBXReference {
        let uuid = UUID.init().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
        return PBXReference(uuid)
    }
    
    /// Generates a new PBX Reference
    ///
    /// This method will either generate a sequential reference eg OBJ_1, OBJ_2 or a UUID reference
    /// depending on the file.
    ///
    /// - Returns: Returns a new PBX Reference
    public func generateNewReference() -> PBXReference {
        return idGenFunc()
    }
    
    /// Generates a new PBX Reference
    ///
    /// - Parameter target: The target path
    /// - Returns: Returns a new PBX Reference
    public func generateNewReference(withTargetPath target: String) -> PBXReference {
        return PBXReference("\"\(target)\"")
    }
    
    /// Generates a new PBX Reference
    ///
    /// - Parameters:
    ///   - project: The project name
    ///   - target: The target name
    ///   - productName: The product name
    /// - Returns: Returns a new PBX Reference
    public func generateNewReference(withProjectName project: String,
                                     targetName target: String,
                                     productName: String? = nil) -> PBXReference {
        var targetPath = project + "::" + target
        if let p = productName { targetPath += "::" + p }
        return generateNewReference(withTargetPath: targetPath)
    }
    
}

// MARK:- PBXContainerItemProxy
extension PBXProj {
    
    /// Create a new instance of a Container Item Proxy
    ///
    /// - Parameters:
    ///   - containerPortal: The refernce to its project.
    ///   - remoteGlobalIDString: The Target Reference
    ///   - remoteInfo: Optional (Usual the package name)
    public func createContainerItemProxy(containerPortal: PBXProject,
                                        remoteGlobalIDString: PBXReference,
                                        remoteInfo: String? = nil) -> PBXContainerItemProxy {
        let rtn = PBXContainerItemProxy(id: generateNewReference(),
                                        containerPortal: containerPortal.id,
                                        proxyType: .nativeTarget,
                                        remoteGlobalIDString: remoteGlobalIDString,
                                        remoteInfo: remoteInfo)
        self.objects.append(rtn)
        return rtn
    }
    
    /// Create a new instance of a Container Item Proxy
    ///
    /// - Parameters:
    ///   - containerPortal: The refernce to file reference of the remote project.
    ///   - remoteGlobalIDString: The Target Reference
    ///   - remoteInfo: Optional (Usual the package name)
    public func createContainerItemProxy(containerPortal: PBXFileReference,
                                            remoteGlobalIDString: PBXReference,
                                            remoteInfo: String? = nil) -> PBXContainerItemProxy {
        let rtn = PBXContainerItemProxy(id: generateNewReference(),
                                        containerPortal: containerPortal.id,
                                        proxyType: .reference,
                                        remoteGlobalIDString: remoteGlobalIDString,
                                        remoteInfo: remoteInfo)
        self.objects.append(rtn)
        return rtn
    }
    
}

// MARK:- PBXGroup
extension PBXProj {
    
    /// Create a new instance of a group that is not linked in the file structure
    ///
    /// - Parameters:
    ///   - type: The file type of group this is
    ///   - namePath: The name and/or path of this group
    ///   - sourceTree: The source tree for this group
    ///   - children: An arary of references to the group children (PBXFileElement)
    public func createUnlinkedGroup(fileType type: PBXFileElement.PBXFileObjectType,
                                       namePath: PBXNamePath,
                                       sourceTree: PBXSourceTree,
                                       children: [PBXReference] = []) -> PBXGroup {
        
        let rtn = PBXGroup(id: self.generateNewReference(),
                           fileType: type,
                           namePath: namePath,
                           sourceTree: .group,
                           children: children)
        
        self.objects.append(rtn)
        
        return rtn
        
    }
    
}

extension PBXProj {
    
    /// Create a new instance of a Reference Proxy
    ///
    /// - Parameters:
    ///   - namePath: The name and/or path of this reference proxy
    ///   - sourceTree: The source tree for this reference proxy
    ///   - fileType: The file type of this object
    ///   - remoteReference: The reference to the remote container item proxy (PBXContainerItemProxy)
    public func createReferenceProxy(namePath: PBXNamePath,
                                  sourceTree: PBXSourceTree? = nil,
                                  fileType: PBXFileType? = nil,
                                  remoteReference: PBXReference? = nil) -> PBXReferenceProxy {
        let rtn = PBXReferenceProxy(id: generateNewReference(),
                                    namePath: namePath,
                                    sourceTree: sourceTree,
                                    fileType: fileType,
                                    remoteReference: remoteReference)
        self.objects.append(rtn)
        return rtn
    
    }
    
    public func createTargetDependancy(target: PBXTarget, targetProxy: PBXContainerItemProxy) -> PBXTargetDependency {
        let rtn = PBXTargetDependency(id: generateNewReference(),
                                      target: target.id,
                                      targetProxy: targetProxy.id)
        self.objects.append(rtn)
        return rtn
    }
        
}

extension PBXProj {
    
    
    public func createBuildConfiguration(baseConfiguration: XCBuildConfiguration? = nil,
                                            buildSettings: [String: Any] = [:],
                                            name: String) -> XCBuildConfiguration {
        let newId = generateNewReference()
        let rtn = XCBuildConfiguration(id: newId,
                                       name: name,
                                       baseConfigurationReference: baseConfiguration?.id,
                                       buildSettings: buildSettings)
        
        self.objects.append(rtn)
        return rtn
    }
    
    public func createConfigurationList(buildConfigurations: [XCBuildConfiguration],
                                           defaultConfigurationIsVisible: Int = XCConfigurationList.DEFAULT_CONFIGURATION_IS_VISIBLE,
                                           defaultConfigurationName: String) throws -> XCConfigurationList {
        
        guard buildConfigurations.map({$0.name}).contains(defaultConfigurationName) else {
            throw Errors.defaultConfigurationNotFoundInList(defaultConfigurationName)
        }
        let newId = generateNewReference()
        let rtn = XCConfigurationList(id: newId,
                                      buildConfigurations: buildConfigurations.map { $0.id },
                                      defaultConfigurationIsVisible: defaultConfigurationIsVisible,
                                      defaultConfigurationName: defaultConfigurationName)
        
        self.objects.append(rtn)
        return rtn
        
    }
}

public extension Notification.Name {
    struct PBXProj {
        public static let Changed = Notification.Name(rawValue: "org.xcodeproj.pbxproj.notification.name.Changed")
    }
}

extension PBXProj {
    internal func sendChangedNotification() {
        NotificationCenter.default.post(name: Notification.Name.PBXProj.Changed,
                                        object: self)
    }
}
