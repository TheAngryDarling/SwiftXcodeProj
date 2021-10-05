//
//  PBXBuildFile.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import AdvancedCodableHelpers
import RawRepresentableHelpers

/// A build file for a specific file reference
public final class PBXBuildFile: PBXUnknownObject {
    /// Build File coding keys
    internal enum BuildFileCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case fileRef
        case settings
    }
    
    private typealias CodingKeys = BuildFileCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.fileRef)
        rtn.append(CodingKeys.settings)
        return rtn
    }
    
    /// Element file reference.
    public private(set) var fileRef: PBXReference {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// The file reference for this build file
    ///
    /// This uses the fileRef to lookup the File Reference within the object list
    public var file: PBXFileReference {
        get {
            return self.objectList.object(withReference: self.fileRef, asType: PBXFileReference.self)!
        }
        set {
            self.fileRef = newValue.id
        }
    }
    
    /// Element settings
    public var settings: [String: Any] {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Link to the build phase for this build file.
    ///
    /// This searches the object list for the build phase that has this build file in its file references
    public var buildPhase: PBXBuildPhase! {
        for obj in self.objectList {
            if let b = obj as? PBXBuildPhase,
                b.fileReferences.contains(self.id) {
                return b
            }
        }
        return nil
    }
    
    /// Gets the target for this build file
    ///
    /// This method relies on getting the Build Phase and then getting the target of the build phase
    public var target: PBXTarget! {
        guard let bP = self.buildPhase else { return nil }
        return bP.target
    }
    
    /// Create new instance of a Build File
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - fileRef: The reference to the File Reference object
    ///   - settings: Settings for this object
    internal init(id: PBXReference,
                fileRef: PBXReference,
                settings: [String: Any] = [:]) {
        self.fileRef = fileRef
        self.settings = settings
        super.init(id: id, type: .buildFile)
    }
    
    /// Create new instance of a Build File
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - fileRef: The file reference for this build file
    ///   - settings: Settings for this object
    internal convenience init(id: PBXReference,
                            fileRef: PBXFileReference,
                            settings: [String: Any] = [:]) {
        self.init(id: id, fileRef: fileRef.id, settings: settings)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.fileRef = try container.decode(PBXReference.self, forKey: .fileRef)
        self.settings = try container.decodeAnyDictionaryIfPresent(forKey: .settings, withDefaultValue: [:])
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.fileRef, forKey: .fileRef)
        if self.settings.count > 0 {
            try container.encodeAnyDictionary(self.settings, forKey: .settings)
        }
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        if let bp = self.buildPhase {
            bp.fileReferences.remove(self.id)
        }
        super.deleting()
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.fileRef == objectReference { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func isPBXEncodingMultiLineObject(_ content: [String: Any],
                                                              atPath path: [String],
                                                              havingObjectVersion objectVersion: Int,
                                                              havingArchiveVersion archiveVersion: Int,
                                                              userInfo: [CodingUserInfoKey: Any]) -> Bool {
        return (content[CodingKeys.settings] != nil)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                       atPath path: [String],
                                                       inObject object: [String: Any],
                                                       inObjectList objectList: [String: Any],
                                                       inData data: [String: Any],
                                                       havingObjectVersion objectVersion: Int,
                                                       havingArchiveVersion archiveVersion: Int,
                                                       userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 2 , let fileRef = object[CodingKeys.fileRef] as? String,
            let fileRefObj = objectList[fileRef] as? [String: Any],
            let objectPath = fileRefObj["path"] as? String {
            
            let fileNameComponents = objectPath.split(separator: "/").map(String.init)
            var r = fileNameComponents[fileNameComponents.count - 1]
            if path.count == 2 || path[path.count-1].hasSuffix("]") {
                r += " in "
                if let type = fileRefObj["lastKnownFileType"] as? String, type == PBXFileType.Wrapper.framework { r += "Frameworks"  }
                else { r += "Sources" }
            }
            
            return r
            
            
        } else if path.count == 3 && path.last == CodingKeys.fileRef {
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
        if path.last == CodingKeys.fileRef { return false }
        return hasKeyIndicators
    }
}
