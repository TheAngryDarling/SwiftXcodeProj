//
//  PBXGroup.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// This is the element to group files or groups.
public class PBXGroup: PBXFileElement {
    
    /// Group Coding Keys
    internal  enum GroupCodingKeys: String, CodingKey {
        public typealias parent = PBXFileElement.FileElementCodingKeys
        case children
        
    }
    
    private typealias CodingKeys = GroupCodingKeys
    
    
    /// Location when adding item to list
    public enum CreationLocation {
        public enum Error: Swift.Error {
            case referenceNotFound(PBXReference)
        }
        case beginning
        case end
        case index(Int)
        case before(PBXReference)
        case after(PBXReference)
    }
    
    /// Group Type
    public enum PBXGroupType {
        case basic
        case variant
        
        
        fileprivate var pbxType: PBXFileElement.PBXFileObjectType {
            switch self {
            case .basic: return PBXFileElement.PBXFileObjectType.group
            case .variant: return PBXFileElement.PBXFileObjectType.variantGroup
            }
        }
        
        
    }
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        if let idx = rtn.index(of: CodingKeys.parent.name) {
            rtn.insert(CodingKeys.children, at: idx)
        } else if let idx = rtn.index(of: CodingKeys.parent.path) {
            rtn.insert(CodingKeys.children, at: idx)
        } else {
            rtn.append(CodingKeys.children)
        }
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.children)
        return rtn
    }
    
    /// The objects are a list of references to PBXFileElement elements.
    public var childrenReferences: [PBXReference]
    /// The objects are a list of PBXFileElement elements.
    ///
    /// This property does a look up through the object list to get the values every time
    public var children: [PBXFileElement] {
        get {
            return self.objectList.objects(withReferences: self.childrenReferences, asType: PBXFileElement.self)
        }
        set {
            self.childrenReferences = newValue.map { $0.id }
        }
    }
    
    /// All the files (PBXFileReference) within the list of children
    ///
    /// This property does a look up through the object list to get the values every time
    public var files: [PBXFileReference] {
        get {
            return self.objectList.objects(withReferences: self.childrenReferences,
                                           asType: PBXFileReference.self)
            /*var rtn: [PBXFileReference] = []
            let items = self.children
            for i in items {
                if let f = i as? PBXFileReference { rtn.append(f) }
            }
            return rtn*/
        }
    }
    
    /// All the folders (PBXGroup) within the list of children
    ///
    /// This property does a look up through the object list to get the values every time
    public var folders: [PBXGroup] {
        get {
            return self.objectList.objects(withReferences: self.childrenReferences,
                                            asType: PBXGroup.self)
            /*var rtn: [PBXGroup] = []
            let items = self.children
            for i in items {
                if let f = i as? PBXGroup { rtn.append(f) }
            }
            return rtn*/
        }
    }
    
    /// Create a new instance of a group
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - type: The file type of group this is
    ///   - namePath: The name and/or path of this group
    ///   - sourceTree: The source tree for this group
    ///   - children: An arary of references to the group children (PBXFileElement)
    internal init(id: PBXReference,
                  fileType type: PBXFileElement.PBXFileObjectType,
                  namePath: PBXNamePath,
                  sourceTree: PBXSourceTree,
                  children: [PBXReference] = []) {
        self.childrenReferences = children
        super.init(id: id,
                   fileType: type,
                   namePath: namePath,
                   sourceTree: sourceTree)
        
    }
    
    /// Create a new instance of a group
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - groupType: The group type of this group
    ///   - namePath: The name and/or path of this group
    ///   - sourceTree: The source tree for this group
    ///   - children: An arary of references to the group children (PBXFileElement)
    internal init(id: PBXReference,
                groupType: PBXGroupType,
                namePath: PBXNamePath,
                sourceTree: PBXSourceTree,
                children: [PBXReference] = []) {
       
        self.childrenReferences = children
        super.init(id: id,
                   fileType: groupType.pbxType,
                   namePath: namePath,
                   sourceTree: sourceTree)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.childrenReferences = try container.decode([PBXReference].self, forKey: .children)
       
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.childrenReferences, forKey: .children)
        
        try super.encode(to: encoder)
    }
    
    /// Properly sets the parent property on all child elements
    internal func assignParentToChildren() {
        let children = self.children
        for c in children {
            c.parent = self
            if let g = c as? PBXGroup {
                g.assignParentToChildren()
            }
        }
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        havingObjectVersion objectVersion: Int,
                                                        havingArchiveVersion archiveVersion: Int,
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 4 && path[2] == CodingKeys.children {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value],
                                                     inData: data,
                                                     havingObjectVersion: objectVersion,
                                                     havingArchiveVersion: archiveVersion,
                                                     userInfo: userInfo)
        }
        
        return super.getPBXEncodingComments(forValue: value,
                                            atPath: path,
                                            inObject: object,
                                            inObjectList: objectList,
                                            inData: data,
                                            havingObjectVersion: objectVersion,
                                            havingArchiveVersion: archiveVersion,
                                            userInfo: userInfo)
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
        if path.count > 2 && (path[path.count-2] == CodingKeys.children) { return false }
        return hasKeyIndicators
    }
    
    override func deleting() {
        let ch = self.children
        //Delete all children
        for c in ch {
            self.objectList.remove(c)
        }
        //Remove reference from parent
        if let p = self.parent {
            p.childrenReferences.remove(self.id)
        }
        super.deleting()
        
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.childrenReferences.contains(objectReference) { return true }
        return super.hasReference(to: objectReference)
    }
    
    /// Find an element at the given path
    ///
    /// - Parameter path: The path seperated out into its individual components
    /// - Returns: The found element or nil
    internal func find(atPath path: [String]) -> PBXFileElement? {
        let ch = self.children
        guard let o = ch.first(where: { $0.path == path[0] || $0.name == path[0] }) else { return nil }
        if path.count > 1 {
            if let subFolder = o as? PBXGroup {
                return subFolder.find(atPath: path.removingFirst())
            } else {
                return nil
            }
            
        }
        return o
    }
    
    /// Find an element at the given path
    ///
    /// - Parameter path: The path to the element
    /// - Returns: The found element or nil
    public func find(atPath path: String) -> PBXFileElement? {
        let components: [String] = path.split(separator: "/").map(String.init)
        return find(atPath: components)
    }
    
    /// Find a group at the given path
    ///
    /// - Parameter path: The path to the group
    /// - Returns: The found group or nil if the group was not found or the element was not a group
    public func findFolder(atPath path: String) -> PBXGroup? {
        return self.find(atPath: path) as? PBXGroup
    }
    
    /// Find a file reference at the given path
    ///
    /// - Parameter path: The path to the file reference
    /// - Returns: The found file reference or nil if the file reference was not found or the element was not a file relference
    public func findFile(atPath path: String) -> PBXFileReference? {
        return self.find(atPath: path) as? PBXFileReference
    }
    
    /// Check to see if an element exists at a given path
    ///
    /// - Parameter path: The path to the element
    /// - Returns: Returns true if an element exists at the given path, otherwise false
    public func exists(atPath path: String) -> Bool { return self.find(atPath: path) != nil }
    
}

// MARK: - PBXGroup
extension PBXGroup {
    
    /// Create a sub group
    ///
    /// - Parameters:
    ///   - namePath: The name and/or path of this group
    ///   - type: The group type (Default: .basic)
    ///   - sourceTree: The sourcetree for this group (Default: .group)
    ///   - location: The location where to add, at the beginning or end (Default: .end)
    /// - Returns: Returns the newly created group
    @discardableResult
    public func createSubGroup(namePath: PBXNamePath,
                               type: PBXGroupType = .basic,
                               sourceTree: PBXSourceTree = .group,
                               location: CreationLocation = .end) throws -> PBXGroup {
        if case let .before(ref) = location {
            if !self.childrenReferences.contains(ref) {
                throw CreationLocation.Error.referenceNotFound(ref)
            }
        } else if case let .after(ref) = location {
            if !self.childrenReferences.contains(ref) {
                throw CreationLocation.Error.referenceNotFound(ref)
            }
        }
        let rtn = PBXGroup(id: self.proj.generateNewReference(),
                           groupType: type,
                           namePath: namePath,
                           sourceTree: sourceTree,
                           children: [])
        self.objectList.append(rtn)
        switch location {
            case .beginning: self.childrenReferences.insert(rtn.id, at: 0)
            case .end: self.childrenReferences.append(rtn.id)
            case .index(let index): self.childrenReferences.insert(rtn.id, at: index)
            case .before(let ref):
                guard let index = self.childrenReferences.firstIndex(of: ref) else {
                    throw CreationLocation.Error.referenceNotFound(ref)
                }
                self.childrenReferences.insert(rtn.id, at: index)
            case .after(let ref):
                guard let index = self.childrenReferences.firstIndex(of: ref) else {
                    throw CreationLocation.Error.referenceNotFound(ref)
                }
                self.childrenReferences.insert(rtn.id, at: index + 1)
        }
        rtn.parent = self
        return rtn
    }
    
    /// Create a sub group
    ///
    /// - Parameters:
    ///   - path: The path of the group
    ///   - type: The group type (Default: .basic)
    ///   - sourceTree: The sourcetree for this group (Default: .group)
    ///   - location: The location where to add, at the beginning or end (Default: .end)
    /// - Returns: Returns the newly created group
    @discardableResult
    public func createSubGroup(path: String,
                               type: PBXGroupType = .basic,
                               sourceTree: PBXSourceTree = .group,
                               location: CreationLocation = .end) throws -> PBXGroup {
        
        return try self.createSubGroup(namePath: .path(path),
                                       type: type,
                                       sourceTree: sourceTree,
                                       location: location)
    }
    
    /// Create a sub group
    ///
    /// - Parameters:
    ///   - name: The name of the group
    ///   - type: The group type (Default: .basic)
    ///   - sourceTree: The sourcetree for this group (Default: .group)
    ///   - location: The location where to add, at the beginning or end (Default: .end)
    /// - Returns: Returns the newly created group
    @discardableResult
    public func createSubGroup(name: String,
                               type: PBXGroupType = .basic,
                               sourceTree: PBXSourceTree = .group,
                               location: CreationLocation = .end) throws -> PBXGroup {
        
        return try self.createSubGroup(namePath: .name(name),
                                       type: type,
                                       sourceTree: sourceTree,
                                       location: location)
    }
    
    
}

// MARK: - PBXFileReference
extension PBXGroup {
    
    
    /// Create a new file reference within this group
    ///
    /// - Parameters:
    ///   - namePath: The name and/or path of this file reference
    ///   - sourceTree: The source tree for this file reference
    ///   - fileEncoding: The String encoding of thie file (Optional)
    ///   - explicitFileType: The file type of the file (Optional)
    ///   - lastKnownFileType: The last known file type of thie file (Optional)
    ///   - lineEnding: Line ending indicator for this file (Optional)
    ///   - includeInIndex: Indicator if it should be included in the index (Optional)
    ///   - usingTabs: Indicator if the file uses tabs (Default: true)
    ///   - indentWidth: The indent with (Optional)
    ///   - tabWidth: The tab width (Optional)
    ///   - wrapsLines: Indicator if the IDE should wrap lines (Default: true)
    /// - Returns: Returns the newly created file reference
    @discardableResult
    public func createFileReference(namePath: PBXNamePath,
                                  sourceTree: PBXSourceTree,
                                  fileEncoding: String.Encoding? = nil,
                                  explicitFileType: PBXFileType? = nil,
                                  lastKnownFileType: PBXFileType? = nil,
                                  lineEnding: PBXFileReference.PBXLineEnding? = nil,
                                  includeInIndex: Int? = nil,
                                  usingTabs: Bool = true,
                                  indentWidth: UInt? = nil,
                                  tabWidth: UInt? = nil,
                                  wrapsLines: Bool = true,
                                  location: CreationLocation = .end) throws -> PBXFileReference {
        if case let .before(ref) = location {
            if !self.childrenReferences.contains(ref) {
                throw CreationLocation.Error.referenceNotFound(ref)
            }
        } else if case let .after(ref) = location {
            if !self.childrenReferences.contains(ref) {
                throw CreationLocation.Error.referenceNotFound(ref)
            }
        }
        
        let rtn = PBXFileReference(id: self.proj.generateNewReference(),
                                   namePath: namePath,
                                   sourceTree: sourceTree,
                                   fileEncoding: fileEncoding,
                                   explicitFileType: explicitFileType,
                                   lastKnownFileType: lastKnownFileType,
                                   lineEnding: lineEnding,
                                   includeInIndex: includeInIndex,
                                   usingTabs: usingTabs,
                                   indentWidth: indentWidth,
                                   tabWidth: tabWidth,
                                   wrapsLines: wrapsLines)
        self.objectList.append(rtn)
        switch location {
            case .beginning: self.childrenReferences.insert(rtn.id, at: 0)
            case .end: self.childrenReferences.append(rtn.id)
            case .index(let index): self.childrenReferences.insert(rtn.id, at: index)
            case .before(let ref):
                guard let index = self.childrenReferences.firstIndex(of: ref) else {
                    throw CreationLocation.Error.referenceNotFound(ref)
                }
                self.childrenReferences.insert(rtn.id, at: index)
            case .after(let ref):
                guard let index = self.childrenReferences.firstIndex(of: ref) else {
                    throw CreationLocation.Error.referenceNotFound(ref)
                }
                self.childrenReferences.insert(rtn.id, at: index + 1)
        }
        
        //self.childrenReferences.append(rtn.id)
        rtn.parent = self
        return rtn
        
        /*
        return createFileReference(namePath,
                                    sourceTree,
                                    fileEncoding,
                                    explicitFileType,
                                    lastKnownFileType,
                                    lineEnding,
                                    includeInIndex,
                                    usingTabs,
                                    indentWidth,
                                    tabWidth,
                                    wrapsLines)*/
    }
    
    
    
    
}
