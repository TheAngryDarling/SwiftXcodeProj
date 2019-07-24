//
//  PBXBuildRule.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-12-02.
//

import Foundation

/// A class storing the building rules
public final class PBXBuildRule: PBXUnknownObject {
    
    /// Build Rules coding keys
    internal enum BuildRuleCodingKeys: String, CodingKey {
        public typealias parent = PBXObject.ObjectCodingKeys
        case compilerSpec
        case filePatterns
        case fileType
        case editable = "isEditable"
        case name
        case outputFiles
        case outputFilesCompilerFlags
        case script
    }
    
    private typealias CodingKeys = BuildRuleCodingKeys
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.compilerSpec)
        rtn.append(CodingKeys.filePatterns)
        rtn.append(CodingKeys.fileType)
        rtn.append(CodingKeys.editable)
        rtn.append(CodingKeys.name)
        rtn.append(CodingKeys.outputFiles)
        rtn.append(CodingKeys.outputFilesCompilerFlags)
        rtn.append(CodingKeys.script)
        return rtn
    }
    
    /// Element compiler spec.
    public var compilerSpec: String
    
    /// Element file patterns.
    public var filePatterns: String?
    
    /// Element file type.
    public var fileType: PBXFileType
    
    /// Element is editable.
    public var editable: Bool
    
    /// Element name.
    public var name: String?
    
    /// Element output files.
    public var outputFiles: [String]
    
    /// Element output files compiler flags.
    public var outputFilesCompilerFlags: [String]?
    
    /// Element script.
    public var script: String?
    
    /// Create a new instance of PBXBuildRule
    ///
    /// - Parameters:
    ///   - id: The unique reference of this object
    ///   - name: The name of the build rule (Optional)
    ///   - compilerSpec: The compiler specs
    ///   - fileType: The file type
    ///   - editable: If its editable or not (Default: true)
    ///   - filePatterns: The file patterns (Optional)
    ///   - outputFiles: The output files (Default: Empty Array)
    ///   - outputFilesCompilerFlags: Output compiler flags (Optional)
    ///   - script: Script string (Optional)
    internal init(id: PBXReference,
                name: String? = nil,
                compilerSpec: String,
                fileType: PBXFileType,
                editable: Bool = true,
                filePatterns: String? = nil,
                outputFiles: [String] = [],
                outputFilesCompilerFlags: [String]? = nil,
                script: String? = nil) {
        self.name = name
        self.compilerSpec = compilerSpec
        self.filePatterns = filePatterns
        self.fileType = fileType
        self.editable = editable
        self.outputFiles = outputFiles
        self.outputFilesCompilerFlags = outputFilesCompilerFlags
        self.script = script
        super.init(id: id, type: .buildRule)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.compilerSpec = try container.decodeIfPresent(String.self, forKey: .compilerSpec) ?? ""
        self.filePatterns = try container.decodeIfPresent(String.self, forKey: .filePatterns)
        self.fileType = try container.decodeIfPresent(PBXFileType.self, forKey: .fileType) ?? PBXFileType()
        self.editable = ((try container.decode(Int.self, forKey: .editable)) == 1)
        self.outputFiles = try container.decodeIfPresent([String].self, forKey: .outputFiles) ?? []
        self.outputFilesCompilerFlags = try container.decodeIfPresent([String].self, forKey: .outputFilesCompilerFlags)
        self.script = try container.decodeIfPresent(String.self, forKey: .script)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.name, forKey: .name)
        if !self.compilerSpec.isEmpty { try container.encode(self.compilerSpec, forKey: .compilerSpec) }
        try container.encodeIfPresent(filePatterns, forKey: .filePatterns)
        if !self.fileType.isEmpty { try container.encode(self.fileType, forKey: .fileType) }
        try container.encode(self.editable ? 1 : 0, forKey: .editable)
        if !self.outputFiles.isEmpty { try container.encode(self.outputFiles, forKey: .outputFiles) }
        try container.encodeIfPresent(self.outputFilesCompilerFlags, forKey: .outputFilesCompilerFlags)
        try container.encodeIfPresent(self.script, forKey: .script)
        
        try super.encode(to: encoder)
    }
}
