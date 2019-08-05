//
//  PBXAggregateTarget.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// This is the element for a build target that aggregates several others.
public final class PBXAggregateTarget: PBXTarget {
    
    private enum AggregatedTargetCodingKeys: String, CodingKey {
        public typealias parent = PBXTarget.TargetCodingKeys
        case productName
    }
    
    private typealias CodingKeys = AggregatedTargetCodingKeys
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        rtn.append(CodingKeys.productName)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.productName)
        return rtn
    }
    
    /// Target product name.
    public var productName: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Create a new instance of an Aggregate Target
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
    ///   - name: Name of target
    ///   - buildConfigurationList: Reference to the build configuration (XCConfigurationList)
    ///   - buildPhases: An array of references to Build Phases (PBXBuildPhase)
    ///   - buildRules: An array of references to Build Rules (PBXBuildRule)
    ///   - dependencies: An arary of references to Dependencies (PBXTargetDependency)
    internal init(id: PBXReference,
                name: String,
                buildConfigurationList: PBXReference,
                buildPhases:  [PBXReference] = [],
                buildRules: [PBXReference] = [],
                dependencies: [PBXReference] = [],
                productName: String? = nil/*,
                productReference: PBXReference? = nil,
                productType: PBXProductType? = nil*/) {
        
        self.productName = productName
        super.init(id: id,
                   name: name,
                   targetType: .aggregateTarget,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies:dependencies/*,
                   productName: productName,
                   productReference: productReference,
                   productType:productType*/)
        
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy:  CodingKeys.self)
        self.productName = try container.decodeIfPresent(String.self, forKey: .productName)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.productName, forKey: .productName)
        
        try super.encode(to: encoder)
    }
}
