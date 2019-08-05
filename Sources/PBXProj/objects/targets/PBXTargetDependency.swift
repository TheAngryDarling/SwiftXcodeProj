//
//  PBXTargetDependency.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// This is the element for referencing other target through content proxies.
public final class PBXTargetDependency: PBXUnknownObject {
    internal enum TargetDependencyCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case target
        case targetProxy
    }
    
    private typealias CodingKeys = TargetDependencyCodingKeys
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.target)
        rtn.append(CodingKeys.targetProxy)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.target)
        rtn.append(CodingKeys.targetProxy)
        return rtn
    }
    
    /// Reference to the target associated with this Target Dependency
    public private(set) var targetReference: PBXReference {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Target associated with this Target Dependency
    ///
    /// This is a dynamic property and does object list lookups on every call
    /// When calling the set part of this property, it expects the target already exists in the object list
    public var target: PBXTarget! {
        get {
            return self.objectList.object(withReference: self.targetReference,
                                               asType: PBXTarget.self)
        }
        set {
            self.targetReference = newValue.id
        }
    }
    
    /// Reference to the target proxy associated with this Target Dependency
    public private(set) var targetProxyReference: PBXReference? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Target Proxy associated with this Target Dependency
    ///
    /// This is a dynamic property and does object list lookups on every call
    /// When calling the set part of this property, it expects the target proxy already exists in the object list
    public var targetProxy: PBXContainerItemProxy? {
        get {
            guard let p = self.targetProxyReference else { return nil }
            return self.objectList.object(withReference: p,
                                               asType: PBXContainerItemProxy.self)!
        }
        set {
            if let n = newValue { self.targetProxyReference = n.id }
            else { self.targetProxyReference = nil }
        }
    }
    
    /// Creates a new Target Dependency
    ///
    /// - Parameters:
    ///   - id: The unique reference id of this object
    ///   - target: The reference to the target this target dependency is connected to
    ///   - targetProxy: The reference to the target proxy this target dependency is connected to
    internal init(id: PBXReference,
                target: PBXReference,
                targetProxy: PBXReference) {
        self.targetReference = target
        self.targetProxyReference = targetProxy
        super.init(id: id, type: .targetDependency)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.targetReference = try container.decode(PBXReference.self, forKey: .target)
        self.targetProxyReference = try container.decodeIfPresent(PBXReference.self, forKey: .targetProxy)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.targetReference, forKey: .target)
        try container.encodeIfPresent(self.targetProxyReference, forKey: .targetProxy)
        
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        if let proxy = self.targetProxy {
            proxy.deleting()
        }
        
        super.deleting()
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if (self.targetReference == objectReference ||
            self.targetProxyReference == objectReference) { return true }
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
        if path.count == 2  { return PBXObjectType.targetDependency.rawValue }
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
        if [CodingKeys.target, CodingKeys.targetProxy].contains(path.last) { return false }
        return hasKeyIndicators
    }
}
