//
//  PBXContainerItemProxy.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

public final class PBXContainerItemProxy: PBXUnknownObject {
    
    /// Container Item Proxy Coding Keys
    internal enum ContainerItemProxyCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case containerPortal
        case proxyType
        case remoteGlobalIDString
        case remoteInfo
    }
    
    private typealias CodingKeys = ContainerItemProxyCodingKeys
    
    
    /// The proxy type
    ///
    /// - nativeTarget: Proxy is local
    /// - reference: Proxy is remote
    public struct PBXProxyType {
        fileprivate let rawValue: Int
        public init(_ rawValue: Int) { self.rawValue = rawValue }
        
        public static let nativeTarget: PBXProxyType = 1
        public static let reference: PBXProxyType = 2
    }
    
    
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.containerPortal)
        rtn.append(CodingKeys.proxyType)
        rtn.append(CodingKeys.remoteGlobalIDString)
        rtn.append(CodingKeys.remoteInfo)
        return rtn
    }
    
    /// The object is a reference to a PBXProject element.
    public let containerPortalReference: PBXReference
    /*
    public var containerPortal: PBXProject! {
        return self.objectList.object(withReference: self.containerPortalReference, asType: PBXProject.self)
    }*/
    
    /// Element proxy type.
    public let proxyType: PBXProxyType
    
    /// Element remote global ID reference.
    public let remoteGlobalIDString: PBXReference
    
    /// Element remote info.
    public let remoteInfo: String?
    
    /// Create a new instance of a Container Item Proxy
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - containerPortal: The refernce to its project.  This could be the reference to the local project, OR the reference to the File Reference of a remote project
    ///   - proxyType: The proxy type.  nativeTarget for local targets, and reference for remote targets
    ///   - remoteGlobalIDString: The Target Reference
    ///   - remoteInfo: Optional (Usual the package name)
    internal init(id: PBXReference,
                containerPortal: PBXReference,
                proxyType: PBXProxyType = .nativeTarget,
                remoteGlobalIDString: PBXReference,
                remoteInfo: String? = nil) {
        self.containerPortalReference = containerPortal
        self.proxyType = proxyType
        self.remoteGlobalIDString = remoteGlobalIDString
        self.remoteInfo = remoteInfo
        super.init(id: id, type: .containerItemProxy)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        
        self.containerPortalReference = try container.decode(PBXReference.self, forKey: .containerPortal)
        self.proxyType = try container.decode(PBXProxyType.self, forKey: .proxyType)
        self.remoteGlobalIDString = try container.decode(PBXReference.self, forKey: .remoteGlobalIDString)
        self.remoteInfo = try container.decodeIfPresent(String.self, forKey: .remoteInfo)
        
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.containerPortalReference, forKey: .containerPortal)
        try container.encode(self.proxyType, forKey: .proxyType)
        try container.encode(self.remoteGlobalIDString, forKey: .remoteGlobalIDString)
        try container.encodeIfPresent(self.remoteInfo, forKey: .remoteInfo)
        
        try super.encode(to: encoder)
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if (self.containerPortalReference == objectReference ||
            self.remoteGlobalIDString == objectReference) { return true }
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
        if path.count == 2  { return PBXObjectType.containerItemProxy.rawValue }
        else if path.count == 3 && path[path.count-1] == CodingKeys.containerPortal {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                      atPath: [PBXProj.CodingKeys.objects.rawValue, value],
                                                      inData: data,
                                                      havingObjectVersion: objectVersion,
                                                      havingArchiveVersion: archiveVersion,
                                                      userInfo: userInfo)
             /*return ReadWritter.getComments(forValue: value,
                                            atPath:  [PBXProj.CodingKeys.objects.rawValue, value] ,
                                            inData: data,
                                            enoder: encoder)*/
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
        if path.last == CodingKeys.containerPortal ||  path.last == CodingKeys.remoteGlobalIDString { return false }
        return hasKeyIndicators
    }
}

extension PBXContainerItemProxy.PBXProxyType: CustomStringConvertible {
    public var description: String { return self.rawValue.description }
}

extension PBXContainerItemProxy.PBXProxyType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self.init(rawValue)
    }
}

extension PBXContainerItemProxy.PBXProxyType: Equatable {
    public static func ==(lhs: PBXContainerItemProxy.PBXProxyType, rhs: PBXContainerItemProxy.PBXProxyType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXContainerItemProxy.PBXProxyType, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: Int, rhs: PBXContainerItemProxy.PBXProxyType) -> Bool {
        return lhs == rhs.rawValue
    }
}
extension PBXContainerItemProxy.PBXProxyType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
