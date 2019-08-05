//
//  PBXFileReference.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation
import RawRepresentableHelpers

/// A PBXFileReference is used to track every external file referenced by the project: source files, resource files, libraries, generated application files, and so on.
public final class PBXFileReference: PBXFileElement {
    
    //public typealias PBXFileEncoding = Int
    
    /// File Reference Coding Keys
    internal enum FileReferenceCodingKeys: String, CodingKey {
        public typealias parent = PBXFileElement.FileElementCodingKeys
        case fileEncoding
        case explicitFileType
        case lastKnownFileType
        case includeInIndex
        case lineEnding
        case usingTabs
        case indentWidth
        case tabWidth
        case wrapsLines
        case languageSpecificationIdentifier = "xcLanguageSpecificationIdentifier"
    }
    
    private typealias CodingKeys = FileReferenceCodingKeys
    
    /// New Line Indications
    ///
    /// - macOS: \n
    /// - classic: ?
    /// - windows: \r\n
    public enum PBXLineEnding: UInt {
        /// Mac line endings: \n
        case macOS = 0
        /// Classic line endings: ?
        case classic = 1
        /// Windows lind endings: \r\n
        case windows = 2
    }
    
    internal override class var CODING_KEY_ORDER: [String] {
        var rtn = super.CODING_KEY_ORDER
        if let idx  = rtn.index(of: PBXObject.ObjectCodingKeys.type) {
            rtn.insert(contentsOf: [CodingKeys.fileEncoding, CodingKeys.indentWidth], at: idx + 1)
        } else {
            rtn.append(contentsOf: [CodingKeys.fileEncoding, CodingKeys.indentWidth])
        }
        if let idx  = (rtn.index(of: FileElementCodingKeys.path) ?? rtn.index(of: FileElementCodingKeys.sourceTree)) {
            rtn.insert(contentsOf: [CodingKeys.explicitFileType, CodingKeys.lastKnownFileType, CodingKeys.lineEnding], at: idx)
            
        } else {
             rtn.append(contentsOf:  [CodingKeys.explicitFileType, CodingKeys.lastKnownFileType, CodingKeys.lineEnding])
        }
        rtn.append(CodingKeys.tabWidth)
        rtn.append(CodingKeys.usingTabs)
        rtn.append(CodingKeys.wrapsLines)
        rtn.append(CodingKeys.languageSpecificationIdentifier)
        return rtn
    }
    
    internal override class var knownProperties: [String] {
        var rtn: [String] = super.knownProperties
        rtn.append(CodingKeys.fileEncoding)
        rtn.append(CodingKeys.explicitFileType)
        rtn.append(CodingKeys.lastKnownFileType)
        rtn.append(CodingKeys.includeInIndex)
        rtn.append(CodingKeys.lineEnding)
        rtn.append(CodingKeys.usingTabs)
        rtn.append(CodingKeys.indentWidth)
        rtn.append(CodingKeys.tabWidth)
        rtn.append(CodingKeys.wrapsLines)
        rtn.append(CodingKeys.languageSpecificationIdentifier)
        return rtn
    }
    
    /// Element file encoding.
    public var fileEncoding: String.Encoding? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Element explicit file type.
    public var explicitFileType: PBXFileType? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Element last known file type.
    public var lastKnownFileType: PBXFileType? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Element line ending
    public var lineEnding: PBXLineEnding? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    
    
    public var includeInIndex: Int? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Indicator whether to use tabs in file or not
    public var usingTabs: Bool {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Indent width in file
    public var indentWidth: UInt? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    /// Tab width in file
    public var tabWidth: UInt? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Wrap lines in file
    public var wrapsLines: Bool {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// The language of the file
    public var languageSpecificationIdentifier: String? {
        didSet {
            self.proj?.sendChangedNotification()
        }
    }
    
    /// Returns the PBXBuildFile references to this file if any exists
    public var buildFiles: [PBXBuildFile] {
        var rtn: [PBXBuildFile] = []
        for obj in self.objectList {
            if let buildFile = obj as? PBXBuildFile,
                buildFile.fileRef == self.id {
                rtn.append(buildFile)
            }
        }
        return rtn
    }
    
    public var targetMembership: [PBXTarget] { return self.buildFiles.map { $0.target } }
    
    
    /// Create a new instance of a File Reference
    ///
    /// - Parameters:
    ///   - id: The unique reference id for this object
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
    internal init(id: PBXReference,
                namePath: PBXNamePath,
                sourceTree: PBXSourceTree,
                fileEncoding: String.Encoding? = nil,
                explicitFileType: PBXFileType? = nil,
                lastKnownFileType: PBXFileType? = nil,
                lineEnding: PBXLineEnding? = nil,
                includeInIndex: Int? = nil,
                usingTabs: Bool = true,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil,
                wrapsLines: Bool = true,
                languageSpecificationIdentifier: String? = nil) {
        self.fileEncoding = fileEncoding
        self.explicitFileType = explicitFileType
        self.lastKnownFileType = lastKnownFileType
        self.includeInIndex = includeInIndex
        self.lineEnding = lineEnding
        self.usingTabs = usingTabs
        self.indentWidth = indentWidth
        self.tabWidth = tabWidth
        self.wrapsLines = wrapsLines
        self.languageSpecificationIdentifier = languageSpecificationIdentifier
        super.init(id: id,
                   fileType: .fileReference,
                   namePath: namePath,
                   sourceTree: sourceTree)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let encoding = try container.decodeIfPresent(UInt.self, forKey: .fileEncoding) {
            self.fileEncoding = String.Encoding(rawValue: encoding)
        } else {
             self.fileEncoding = nil
        }
        self.explicitFileType = try container.decodeIfPresent(PBXFileType.self, forKey: .explicitFileType)
        self.lastKnownFileType = try container.decodeIfPresent(PBXFileType.self, forKey: .lastKnownFileType)
        self.includeInIndex = try container.decodeIfPresent(Int.self, forKey: .includeInIndex)
        if let le = try container.decodeIfPresent(UInt.self, forKey: .lineEnding) {
             self.lineEnding = PBXLineEnding(rawValue: le)
        } else {
             self.lineEnding  = nil
        }
        if let ut = try container.decodeIfPresent(UInt.self, forKey: .usingTabs) {
            self.usingTabs = (ut > 0)
        } else {
            self.usingTabs = true
        }
        self.indentWidth = try container.decodeIfPresent(UInt.self, forKey: .indentWidth)
        self.tabWidth = try container.decodeIfPresent(UInt.self, forKey: .tabWidth)
        
        if let wr = try container.decodeIfPresent(UInt.self, forKey: .wrapsLines) {
            self.wrapsLines = (wr > 0)
        } else {
            self.wrapsLines = true
        }
        
        self.languageSpecificationIdentifier = try container.decodeIfPresent(String.self, forKey: .languageSpecificationIdentifier)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.fileEncoding?.rawValue, forKey: .fileEncoding)
        try container.encodeIfPresent(self.explicitFileType, forKey: .explicitFileType)
        try container.encodeIfPresent(self.lastKnownFileType, forKey: .lastKnownFileType)
        try container.encodeIfPresent(self.includeInIndex, forKey: .includeInIndex)
        try container.encodeIfPresent(self.lineEnding?.rawValue, forKey: .lineEnding)
        
        if !self.usingTabs {
            try container.encode(0, forKey: .usingTabs)
        }
        
        try container.encodeIfPresent(self.indentWidth, forKey: .indentWidth)
        try container.encodeIfPresent(self.tabWidth, forKey: .tabWidth)
        if !self.wrapsLines {
            try container.encode(0, forKey: .wrapsLines)
        }
        
        try container.encodeIfPresent(self.languageSpecificationIdentifier, forKey: .languageSpecificationIdentifier)
        try super.encode(to: encoder)
    }
    
    override func deleting() {
        let bFiles = self.buildFiles
        //Delete all build files associated with this file
        for bFile in bFiles {
            self.objectList.remove(bFile)
        }
        //Remove reference from parent
        if let p = self.parent {
            p.childrenReferences.remove(self.id)
        }
        super.deleting()
        
    }
    
    internal override class func isPBXEncodingMultiLineObject(_ content: [String: Any],
                                                              atPath path: [String],
                                                              havingObjectVersion objectVersion: Int,
                                                              havingArchiveVersion archiveVersion: Int,
                                                              userInfo: [CodingUserInfoKey: Any]) -> Bool {
        return false
    }
    
}

// MARK: - PBXBuildFile
extension PBXFileReference {
    /// Create a build file for this file in the given build phase
    ///
    /// - Parameters:
    ///   - buildPhase: the build phase where to create the build file
    ///   - settings: The settings for the build file
    /// - Returns: Returns the newly created build file
    public func createBuildFile(for buildPhase: PBXBuildPhase,
                                withSettings settings: [String: Any]) -> PBXBuildFile {
        let newId = self.proj.generateNewReference()
        let rtn = PBXBuildFile(id: newId, fileRef: self.id, settings: settings)
        self.objectList.append(rtn)
        buildPhase.fileReferences.append(rtn.id)
        return rtn
    }
}



