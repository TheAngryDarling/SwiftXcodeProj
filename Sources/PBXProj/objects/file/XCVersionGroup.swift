//
//  XCVersionGroup.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// A Version Group
public final class XCVersionGroup: PBXGroup {
    /// Version Group Coding Keys
    internal enum VersonGroupCodingKeys: String, CodingKey {
        public typealias parent = PBXGroup.GroupCodingKeys
        case currentVersion
        case versionGroupType
    }
    
    private typealias CodingKeys = VersonGroupCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.currentVersion)
        rtn.append(CodingKeys.versionGroupType)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.currentVersion)
        rtn.append(CodingKeys.versionGroupType)
        return rtn
    }
    /// The object is a reference to a curent version PBXGroup element.
    public private(set) var currentVersionReference: PBXReference?
    /// The current version PBXGroup for the given object if one exists
    public var currentVersion: PBXGroup? {
        get {
            guard let v = self.currentVersionReference else { return nil }
            return self.objectList.object(withReference: v, asType: PBXGroup.self)
        }
        set {
            self.currentVersionReference = newValue?.id
        }
    }
    
    /// Version group type.
    public var versionGroupType: String?
    
    /// Create a new instance of a Version Group
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - namePath: The name and/or path of this group
    ///   - sourceTree: The source tree for this group
    ///   - children: An arary of references to the group children (PBXFileElement)
    ///   - currentVersion: The reference to the current version for this group (PBXGroup)
    ///   - versionGroupType: The version group type
    internal init(id: PBXReference,
                namePath: PBXNamePath,
                sourceTree: PBXSourceTree,
                children: [PBXReference] = [],
                currentVersion: PBXReference? = nil,
                versionGroupType: String? = nil) {
        self.currentVersionReference = currentVersion
        self.versionGroupType = versionGroupType
        
        super.init(id: id,
                   fileType: .versionGroup,
                   namePath: namePath,
                   sourceTree: sourceTree,
                   children: children)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentVersionReference = try container.decodeIfPresent(PBXReference.self, forKey: .currentVersion)
        self.versionGroupType = try container.decodeIfPresent(String.self, forKey: .versionGroupType)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.currentVersionReference, forKey: .currentVersion)
        try container.encodeIfPresent(self.versionGroupType, forKey: .versionGroupType)
        
        try super.encode(to: encoder)
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.currentVersionReference == objectReference { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func isPBXEncodinStringEscaping(_ value: String,
                                                            hasKeyIndicators: Bool,
                                                            atPath path: [String],
                                                            inObject object: [String: Any],
                                                            inObjectList objectList: [String: Any],
                                                            inData data: [String: Any],
                                                            userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if path.last == CodingKeys.currentVersion { return false }
        return super.isPBXEncodinStringEscaping(value,
                                                hasKeyIndicators: hasKeyIndicators,
                                                atPath: path,
                                                inObject: object,
                                                inObjectList: objectList,
                                                inData: data,
                                                userInfo: userInfo)
    }
}
