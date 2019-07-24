//
//  PBXNativeTarget.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// This is the element for a build target that produces a binary content (application or library).
public final class PBXNativeTarget: PBXTarget {
    
    private enum NativeTargetCodingKeys: String, CodingKey {
        public typealias parent = PBXTarget.TargetCodingKeys
        case productName
        case productReference
        case productType
    }
    
    private typealias CodingKeys = NativeTargetCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.productName)
        rtn.append(CodingKeys.productReference)
        rtn.append(CodingKeys.productType)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.productName)
        rtn.append(CodingKeys.productReference)
        rtn.append(CodingKeys.productType)
        return rtn
    }
    
    
    /// Target product name.
    public var productName: String?
    
    /// The object is a reference to a PBXFileReference element.
    public private(set) var productReference: PBXReference?
    /// The PBXFileReference for the given object if one exists
    public var product: PBXFileReference! {
        get {
            guard let r = self.productReference else { return nil }
            return self.objectList.object(withReference: r, asType: PBXFileReference.self)
        }
        set {
            self.productReference = newValue?.id
        }
    }
    
    /// Target product type.
    public var productType: PBXProductType?
    
    /// The PBXContainerItemProxy for the given object if one exists
    public var containerProxyItem: PBXContainerItemProxy! {
        return self.objectList.containerProxyItems.first(where: {$0.remoteGlobalIDString == self.id})
    }
    
    /// Create a new instance of a Native Target
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - name: Name of target
    ///   - buildConfigurationList: Reference to the build configuration (XCConfigurationList)
    ///   - buildPhases: An array of references to Build Phases (PBXBuildPhase)
    ///   - buildRules: An array of references to Build Rules (PBXBuildRule)
    ///   - dependencies: An arary of references to Dependencies (PBXTargetDependency)
    ///   - productName: Product name
    ///   - productReference: Reference to the product file (PBXFileReference)
    ///   - productType: Product type for this target
    internal init(id: PBXReference,
                name: String,
                buildConfigurationList: PBXReference,
                buildPhases:  [PBXReference] = [],
                buildRules: [PBXReference] = [],
                dependencies: [PBXReference] = [],
                productName: String? = nil,
                productReference: PBXReference? = nil,
                productType: PBXProductType) {
        
        self.productName = productName
        self.productReference = productReference
        self.productType = productType
        
        super.init(id: id,
                   name: name,
                   targetType: .nativeTarget,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies:dependencies/*,
                   productName: productName,
                   productReference: productReference,
                   productType: productType*/)
        
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        self.productName = try container.decodeIfPresent(String.self, forKey: .productName)
        self.productReference = try container.decodeIfPresent(PBXReference.self, forKey: .productReference)
        self.productType = try container.decodeIfPresent(PBXProductType.self, forKey: .productType)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.productName, forKey: .productName)
        try container.encodeIfPresent(self.productReference, forKey: .productReference)
        try container.encodeIfPresent(self.productType, forKey: .productType)
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        //Remove Product File
        if let p = self.product {
            self.objectList.remove(p)
        }
        
        if let proxy = self.containerProxyItem {
            self.objectList.remove(proxy)
        }
        
        super.deleting()
        
    }
    
    internal override func hasReference(to objectReference: PBXReference) -> Bool {
        if self.productReference == objectReference { return true }
        return super.hasReference(to: objectReference)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        
        if path.last == CodingKeys.productReference {
            return PBXObjects.getPBXEncodingComments(forValue: value,
                                                     atPath:  [PBXProj.CodingKeys.objects.rawValue, value],
                                                     inData: data,
                                                     userInfo: userInfo)
        } else {
            return super.getPBXEncodingComments(forValue: value,
                                                atPath: path,
                                                inObject: object,
                                                inObjectList: objectList,
                                                inData: data,
                                                userInfo: userInfo)
        }
    }
    
    internal override class func isPBXEncodinStringEscaping(_ value: String,
                                                            hasKeyIndicators: Bool,
                                                            atPath path: [String],
                                                            inObject object: [String: Any],
                                                            inObjectList objectList: [String: Any],
                                                            inData: [String: Any],
                                                            userInfo: [CodingUserInfoKey: Any]) -> Bool {
        if [CodingKeys.productReference].contains(path.last) { return false }
        else {
            return super.isPBXEncodinStringEscaping(value,
                                                    hasKeyIndicators: hasKeyIndicators,
                                                    atPath: path,
                                                    inObject: object,
                                                    inObjectList: objectList,
                                                    inData: inData,
                                                    userInfo: userInfo)
        }
        
    }
    
}
