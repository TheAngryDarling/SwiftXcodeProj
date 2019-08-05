//
//  PBXFileElement.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// This element is an abstract parent for file and group elements.
public class PBXFileElement: PBXUnknownObject {
    internal enum FileElementCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case name
        case sourceTree
        case path
    }
    
    private typealias CodingKeys = FileElementCodingKeys
    
    /// The Group Type
    public enum PBXFileObjectType {
        case group
        case variantGroup
        case versionGroup
        case fileReference
        case referenceProxy
        
        fileprivate var pbxType: PBXObjectType {
            switch self {
                case .group: return PBXObjectType.group
                case .variantGroup: return PBXObjectType.variantGroup
                case .versionGroup: return PBXObjectType.versionGroup
                case .fileReference: return PBXObjectType.fileReference
                case .referenceProxy: return PBXObjectType.referenceProxy
            }
        }
    }
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.path)
        rtn.append(CodingKeys.sourceTree)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.path)
        rtn.append(CodingKeys.sourceTree)
        return rtn
    }
    
    /// Element name.
    public var name: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Element path
    public var path: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Element source tree.
    public var sourceTree: PBXSourceTree? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /*public var parent: PBXGroup! {
        for obj in self.objectList {
            if let group = obj as? PBXGroup,
                group.childrenReferences.contains(self.id)  {
                return group
            }
        }
        return nil
    }*/
    
    /// The parent group to this
    public internal(set) var parent: PBXGroup!
    
    
    /// The built group path
    public var fullGroupPath: String {
        if let p = self.path {
            let n = String(p.split(separator: "/").last!)
            if let p = self.parent {
                return p.fullGroupPath + "/" + n
            } else {
                return n
            }
        } else if let n = self.name {
            if let p = self.parent {
                return p.fullGroupPath + "/" + n
            } else {
                return n
            }
        } else {
            fatalError("File Element missing name or path (\(self))")
        }
    }
    
    /// The built path
    ///
    /// from either self.path or self.parent.fullPath + "/" + self.name
    public var fullPath: String {
        if let n = self.path {
            return n
            /*guard !n.hasPrefix("/") else { return n }
            guard let p = self.parent else { return n }
            return p.fullPath + "/" + n*/
        } else if let n = self.name {
            guard let p = self.parent else { return n }
            let fP = p.fullPath
            guard !fP.isEmpty else { return n }
            return p.fullPath + "/" + n
        } else {
            fatalError("File Element missing name or path (\(self))")
        }
    }
    
    /// Create a new instance of a File Element
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - type: The type of file element 
    ///   - namePath: The name and/or path of this file element
    ///   - sourceTree: The source tree for this file element
    internal init(id: PBXReference,
                fileType type: PBXFileObjectType,
                namePath: PBXNamePath,
                sourceTree: PBXSourceTree? = nil) {
        self.name = namePath.name
        self.path = namePath.path
        self.sourceTree = sourceTree
        super.init(id: id, type: type.pbxType)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.sourceTree = try container.decodeIfPresent(PBXSourceTree.self, forKey: .sourceTree)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.path, forKey: .path)
        try container.encodeIfPresent(self.sourceTree, forKey: .sourceTree)
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        super.deleting()
        self.parent = nil
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
        } else if path.count == 2, let objectPath = object[CodingKeys.path] as? String {
            let fileNameComponents = objectPath.split(separator: "/").map(String.init)
            guard fileNameComponents.count > 0 else  {
                return nil
            }
            return fileNameComponents[fileNameComponents.count - 1]
        }
        
        return nil
    }
    
    
}
