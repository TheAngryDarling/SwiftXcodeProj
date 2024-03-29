//
//  PBXFrameworksBuildPhase.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// A Frameworks Build Phase
public final class PBXFrameworksBuildPhase: PBXBuildPhase {
    /// The default building action mask
    public static let DEFAULT_BUILD_ACTION_MAKS: UInt = 0
    
    /// Create a new insatnce of Framework Build Phase
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - buildActionMask: he build action for this build phase (Default: DEFAULT_BUILD_ACTION_MAKS)
    ///   - files: An array of references to Build Files
    ///   - runOnlyForDeploymentPostprocessing: An indicator if should run only for deployment post processing
    internal init(id: PBXReference,
                buildActionMask: UInt = PBXFrameworksBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                files: [PBXReference] = [],
                runOnlyForDeploymentPostprocessing: UInt = 0) {
        
        super.init(id: id,
                   buildPhaseType: .frameworksBuildPhase,
                   buildActionMask: buildActionMask,
                   files: files,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        havingObjectVersion objectVersion: Int,
                                                        havingArchiveVersion archiveVersion: Int,
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        if path.count == 2  { return PBXBuildPhase.PBXBuildPhaseType.frameworksBuildPhase.rawValue }
        return super.getPBXEncodingComments(forValue: value,
                                            atPath: path,
                                            inObject: object,
                                            inObjectList: objectList,
                                            inData: data,
                                            havingObjectVersion: objectVersion,
                                            havingArchiveVersion: archiveVersion,
                                            userInfo: userInfo)
    }
}
