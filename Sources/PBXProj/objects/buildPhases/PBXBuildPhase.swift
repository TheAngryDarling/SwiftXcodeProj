//
//  PBXBuildPhase.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// This is the base class for all the build phases
public class PBXBuildPhase: PBXUnknownObject {
    
    /// Build Phase coding keys
    internal enum BuildPhaseCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case buildActionMask
        case files
        case runOnlyForDeploymentPostprocessing
        
        static let allKeys: [String] = {
            var rtn: [String] = parent.allKeys
            rtn.append(BuildPhaseCodingKeys.buildActionMask)
            rtn.append(BuildPhaseCodingKeys.files)
            rtn.append(BuildPhaseCodingKeys.runOnlyForDeploymentPostprocessing)
            return rtn
        }()
    }
    
    private typealias CodingKeys = BuildPhaseCodingKeys
    
    
    /// Build Phase types
    public enum PBXBuildPhaseType: String {
        case copyFilesBuildPhase = "CopyFiles"
        case frameworksBuildPhase = "Frameworks"
        case headersBuildPhase = "Headers"
        case resourcesBuildPhase = "Resources"
        case shellScriptBuildPhase = "Run Script"
        case appleScriptBuildPhase = "Apple Script"
        case sourceBuildPhase = "Sources"
        case carbonResourceBuildPhase = "Rez"
        
        /// The PBX Object Type for this build phase type
        public var objectType: PBXObjectType {
            switch self {
            case .copyFilesBuildPhase: return PBXObjectType.copyFilesBuildPhase
            case .frameworksBuildPhase: return PBXObjectType.frameworksBuildPhase
            case .headersBuildPhase: return PBXObjectType.headersBuildPhase
            case .resourcesBuildPhase: return PBXObjectType.resourcesBuildPhase
            case .shellScriptBuildPhase: return PBXObjectType.shellScriptBuildPhase
            case .appleScriptBuildPhase: return PBXObjectType.appleScriptBuildPhase
            case .sourceBuildPhase: return PBXObjectType.sourceBuildPhase
            case .carbonResourceBuildPhase: return PBXObjectType.carbonResourceBuildPhase
            }
        }
    }
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.buildActionMask)
        rtn.append(CodingKeys.files)
        rtn.append(CodingKeys.runOnlyForDeploymentPostprocessing)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.buildActionMask)
        rtn.append(CodingKeys.files)
        rtn.append(CodingKeys.runOnlyForDeploymentPostprocessing)
        return rtn
    }
    
    /// Element build action mask
    public var buildActionMask: UInt {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Element file references .
    public internal(set) var fileReferences: [PBXReference] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// The files within this build phase
    ///
    /// This property looks up all  build files from the object list for this build phase
    public var files: [PBXBuildFile] {
        get {
            return self.objectList.objects(withReferences: self.fileReferences, asType: PBXBuildFile.self)
        }
        set {
            self.fileReferences = newValue.map { $0.id }
        }
    }
    
    
    /// Element runOnlyForDeploymentPostprocessing
    public let runOnlyForDeploymentPostprocessing: UInt
    
    /// The target this build phase belongs to
    ///
    /// This property searches the object list for the target that contains this build phase
    public var target: PBXTarget! {
        for obj in self.objectList {
            if let t = obj as? PBXTarget,
                t.buildPhaseReferences.contains(self.id) {
                return t
            }
        }
        return nil
    }
    
    /// Creates a new instance of PBXBuildPhase
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - type: The Build Phase type
    ///   - buildActionMask: The build action for this build phase
    ///   - files: An array of references to Build Files
    ///   - runOnlyForDeploymentPostprocessing: An indicator if should run only for deployment post processing
    internal init(id: PBXReference,
                buildPhaseType type: PBXBuildPhaseType,
                buildActionMask: UInt /*= 0*/,
                files: [PBXReference] = [],
                runOnlyForDeploymentPostprocessing: UInt = 0) {
        self.buildActionMask = buildActionMask
        self.fileReferences = files
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
        super.init(id: id, type: type.objectType)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.buildActionMask = try container.decodeIfPresent(UInt.self, forKey: .buildActionMask) ?? 0
        self.fileReferences = try container.decode([PBXReference].self, forKey: .files)
        //print(container.codingPath)
        self.runOnlyForDeploymentPostprocessing = try container.decodeIfPresent(UInt.self, forKey: .runOnlyForDeploymentPostprocessing) ?? 0
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if self.proj.objectVersion < 46 || self.buildActionMask != 0 {
            try container.encode(self.buildActionMask, forKey: .buildActionMask)
        }
        
        try container.encode(self.fileReferences, forKey: .files)
        
        if self.proj.objectVersion < 46 || self.runOnlyForDeploymentPostprocessing != 0 {
            try container.encode(self.runOnlyForDeploymentPostprocessing, forKey: .runOnlyForDeploymentPostprocessing)
        }
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        let bf = self.files
        for f in bf {
            self.objectList.remove(f)
        }
        super.deleting()
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.fileReferences.contains(objectReference) { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        havingObjectVersion objectVersion: Int,
                                                        havingArchiveVersion archiveVersion: Int,
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 4 && path[path.count-2] == CodingKeys.files {
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
        if path.count > 2 && (path[path.count-2] == CodingKeys.files) { return false }
        return hasKeyIndicators
    }
    
    /// Creates a build file for the given file reference in the current build phase
    ///
    /// - Parameters:
    ///   - file: The file reference to create a build file for
    ///   - settings: Any settings for the build file
    /// - Returns: Returns a newly created build file
    @discardableResult
    public func createBuildFile(for file: PBXFileReference,
                                withSettings settings: [String: Any] = [:]) -> PBXBuildFile {
        let newId = self.proj.generateNewReference()
        let rtn = PBXBuildFile(id: newId, fileRef: file.id, settings: settings)
        self.objectList.append(rtn)
        self.fileReferences.append(rtn.id)
        return rtn
    }
    
    /// Removes the build file from the target/project
    /// - Parameter file: The build file to remove
    /// - returns: Returns true if the file was removed, otherwise false
    @discardableResult
    public func removeBuildFile(for file: PBXBuildFile) -> Bool {
        guard self.fileReferences.contains(file.id) else { return false }
        self.objectList.remove(file) // This will remove the object and all references to it
        return true
    }
    
    /// Removes the refernece to the file from the build phase
    /// - Parameter file: The file to remove
    /// - returns: Returns true if the file was removed, otherwise false
    @discardableResult
    public func removeBuildFile(for file: PBXFileReference) -> Bool {
        let buildFiles = self.files
        guard let bf = buildFiles.first(where: { return $0.fileRef == file.id } ) else {
            return false
        }
        
        return removeBuildFile(for: bf)
    }
    
    
    
    
}
