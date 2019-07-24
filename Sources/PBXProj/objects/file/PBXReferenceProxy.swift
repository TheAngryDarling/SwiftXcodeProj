//
//  PBXReferenceProxy.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

public final class PBXReferenceProxy: PBXFileElement {
    
    /// Reference proxy coding keys
    internal enum ReferenceProxyCodingKeys: String, CodingKey {
        public typealias parent = PBXFileElement.FileElementCodingKeys
        case fileType
        case remoteReference

    }
    
    private typealias CodingKeys = ReferenceProxyCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.fileType)
        rtn.append(CodingKeys.remoteReference)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.fileType)
        rtn.append(CodingKeys.remoteReference)
        return rtn
    }
    
    
    /// Element file type
    public var fileType: PBXFileType?
    
    /// Element remote reference.
    public private(set) var remoteReference: PBXReference?
    public var remote: PBXContainerItemProxy? {
        get {
            guard let r = self.remoteReference else { return nil }
            return self.objectList.object(withReference: r, asType: PBXContainerItemProxy.self)!
        }
        set {
            self.remoteReference = newValue?.id
        }
    }
    
   
    
    /// Create a new instance of a Reference Proxy
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - namePath: The name and/or path of this reference proxy
    ///   - sourceTree: The source tree for this reference proxy
    ///   - fileType: The file type of this object
    ///   - remoteReference: The reference to the remote container item proxy (PBXContainerItemProxy)
    internal init(id: PBXReference,
                namePath: PBXNamePath,
                sourceTree: PBXSourceTree? = nil,
                fileType: PBXFileType? = nil,
                remoteReference: PBXReference? = nil) {
        self.fileType = fileType
        self.remoteReference = remoteReference
       
        super.init(id: id,
                   fileType: .referenceProxy,
                   namePath: namePath,
                   sourceTree: sourceTree)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.fileType = try container.decodeIfPresent(PBXFileType.self, forKey: .fileType)
        self.remoteReference = try container.decodeIfPresent(PBXReference.self, forKey: .remoteReference)
        
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.fileType, forKey: .fileType)
        try container.encodeIfPresent(self.remoteReference, forKey: .remoteReference)
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        if let r = remote {
            //Remove PBXContainerItemProxy for reference proxy
            self.objectList.remove(r)
        }
        super.deleting()
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.remoteReference == objectReference { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.count == 3 && path[2] == CodingKeys.remoteReference {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                                     inData: data,
                                                     userInfo: userInfo)
        }
        
        return super.getPBXEncodingComments(forValue: value,
                                            atPath: path,
                                            inObject: object,
                                            inObjectList: objectList,
                                            inData: data,
                                            userInfo: userInfo)
    }
    
    internal override class func isPBXEncodinStringEscaping(_ value: String,
                                                            hasKeyIndicators: Bool,
                                                            atPath path: [String],
                                                            inObject object: [String: Any],
                                                            inObjectList objectList: [String: Any],
                                                            inData: [String: Any],
                                                            userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if path.last == CodingKeys.remoteReference { return false }
        return hasKeyIndicators
    }
}
