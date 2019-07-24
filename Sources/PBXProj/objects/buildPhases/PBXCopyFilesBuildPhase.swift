//
//  PBXCopyFilesBuildPhase.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// The Copy Files Build Phase
public final class PBXCopyFilesBuildPhase: PBXBuildPhase {
    
    /// Copy Files Build Phase Coding Keys
    internal enum CopyFilesBuildPhaseCodingKeys: String, CodingKey {
        public typealias parent = PBXBuildPhase.BuildPhaseCodingKeys
        case name
        case dstPath
        case dstSubfolderSpec
    }
    
    private typealias CodingKeys = CopyFilesBuildPhaseCodingKeys
    
    /// The subfolder specification
    public struct PBXSubFolder {
        fileprivate let rawValue: Int
        public init(_ rawValue: Int) { self.rawValue = rawValue }
        
        public static let absolutePath: PBXSubFolder = 0
        public static let productsDirectory: PBXSubFolder = 16
        public static let wrapper: PBXSubFolder = 1
        public static let executables: PBXSubFolder = 6
        public static let resources: PBXSubFolder = 7
        public static let javaResources: PBXSubFolder = 15
        public static let frameworks: PBXSubFolder = 10
        public static let sharedFrameworks: PBXSubFolder = 11
        public static let sharedSupport: PBXSubFolder = 12
        public static let plugins: PBXSubFolder = 13
        
    }
    
    /// The default building action mask
    public static let DEFAULT_BUILD_ACTION_MAKS: UInt = 2147483647
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        let keys: [CodingKeys] = [.dstPath, .dstSubfolderSpec]
        if let idx = rtn.index(of: BuildPhaseCodingKeys.files) {
            rtn.insert(contentsOf: keys, at: idx)
        } else {
            rtn.append(contentsOf: keys)
        }
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.dstPath)
        rtn.append(CodingKeys.dstSubfolderSpec)
        return rtn
    }
    
    /// Element name
    public var name: String?
    
    /// Element destination path
    public var dstPath: String
    
    /// Element destination subfolder spec
    public var dstSubfolderSpec: PBXSubFolder
    
    /// Creates a new instance of a PBXCopyFilesBuildPhase
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - name: The name of the build rule (Optional)
    ///   - buildActionMask: he build action for this build phase (Default: DEFAULT_BUILD_ACTION_MAKS)
    ///   - files: An array of references to Build Files
    ///   - runOnlyForDeploymentPostprocessing: An indicator if should run only for deployment post processing
    ///   - dstPath: Destination path
    ///   - dstSubfolderSpec: Destination subfolder specification
    internal init(id: PBXReference,
                name: String? = nil,
                buildActionMask: UInt = PBXCopyFilesBuildPhase.DEFAULT_BUILD_ACTION_MAKS,
                files: [PBXReference] = [],
                runOnlyForDeploymentPostprocessing: UInt = 0,
                dstPath: String,
                dstSubfolderSpec: PBXSubFolder) {
        
        self.name = name
        self.dstPath = dstPath
        self.dstSubfolderSpec = dstSubfolderSpec
        
        super.init(id: id,
                   buildPhaseType: .copyFilesBuildPhase,
                   buildActionMask: buildActionMask,
                   files: files,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.dstPath = try container.decode(String.self, forKey: .dstPath)
        self.dstSubfolderSpec = try container.decode(PBXSubFolder.self, forKey: .dstSubfolderSpec)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encode(self.dstPath, forKey: .dstPath)
        try container.encode(self.dstSubfolderSpec, forKey: .dstSubfolderSpec)
        try super.encode(to: encoder)
    }
    
    internal override class func getPBXEncodingComments(forValue value: String,
                                                        atPath path: [String],
                                                        inObject object: [String: Any],
                                                        inObjectList objectList: [String: Any],
                                                        inData data: [String: Any],
                                                        userInfo: [CodingUserInfoKey: Any]) -> String? {
        if path.count == 2  { return PBXBuildPhase.PBXBuildPhaseType.copyFilesBuildPhase.rawValue }
        return super.getPBXEncodingComments(forValue: value,
                                            atPath: path,
                                            inObject: object,
                                            inObjectList: objectList,
                                            inData: data,
                                            userInfo: userInfo)
    }
}

extension PBXCopyFilesBuildPhase.PBXSubFolder: CustomStringConvertible {
    public var description: String { return self.rawValue.description }
}

extension PBXCopyFilesBuildPhase.PBXSubFolder: Codable {
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

extension PBXCopyFilesBuildPhase.PBXSubFolder: Equatable {
    public static func ==(lhs: PBXCopyFilesBuildPhase.PBXSubFolder, rhs: PBXCopyFilesBuildPhase.PBXSubFolder) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXCopyFilesBuildPhase.PBXSubFolder, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: Int, rhs: PBXCopyFilesBuildPhase.PBXSubFolder) -> Bool {
        return lhs == rhs.rawValue
    }
}
extension PBXCopyFilesBuildPhase.PBXSubFolder: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
