//
//  XcodeFile.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation
import PBXProj

/// A class that represents a file within the project
public class XcodeFile: XcodeFileResource {
    
    /// An indicator for the kind of file
    //public typealias FileType = PBXFileType
    /// New Line Indications
    ///
    /// - macOS: \n
    /// - classic: ?
    /// - windows: \r\n
    public typealias LineEnding = PBXFileReference.PBXLineEnding
    
    /// The default sorting order of any file
    internal static let OBJECT_SORT_ORDER: Int = 4
    
    /// The PBX object reference
    internal var pbxFileReference: PBXFileReference
    
    internal override var objectSortingOrder: Int { return XcodeFile.OBJECT_SORT_ORDER }
    
    /// Element file encoding.
    public var encoding: String.Encoding? {
        get { return self.pbxFileReference.fileEncoding }
        set { self.pbxFileReference.fileEncoding = newValue }
    }
    /// Element explicit file type.
    public var explicitFileType: XcodeFileType? {
        get { return self.pbxFileReference.explicitFileType }
        set { self.pbxFileReference.explicitFileType = newValue }
    }
    /// Element last known file type.
    public var lastKnownFileType: XcodeFileType? {
        get { return self.pbxFileReference.lastKnownFileType }
        set { self.pbxFileReference.lastKnownFileType = newValue }
    }
    /// Element line ending
    public var lineEnding: LineEnding? {
        get { return self.pbxFileReference.lineEnding }
        set { self.pbxFileReference.lineEnding = newValue }
    }
    
    
    
    /// Indicator whether to use tabs in file or not
    public var usingTabs: Bool {
        get { return self.pbxFileReference.usingTabs }
        set { self.pbxFileReference.usingTabs = newValue }
    }
    /// Indent width in file
    public var indentWidth: UInt? {
        get { return self.pbxFileReference.indentWidth }
        set { self.pbxFileReference.indentWidth = newValue }
    }
    /// Tab width in file
    public var tabWidth: UInt? {
        get { return self.pbxFileReference.tabWidth }
        set { self.pbxFileReference.tabWidth = newValue }
    }
    
    /// Wrap lines in file
    public var wrapsLines: Bool {
        get { return self.pbxFileReference.wrapsLines }
        set { self.pbxFileReference.wrapsLines = newValue }
    }
    
    /// The language of the file
    public var languageSpecificationIdentifier: String? {
        get { return self.pbxFileReference.languageSpecificationIdentifier }
        set { self.pbxFileReference.languageSpecificationIdentifier = newValue }
    }
    
    /// A list of all targets this file belongs to
    public var targetMemberships: [XcodeTarget] {
        get {
            let pbxTargets = self.pbxFileReference.targetMembership
            var rtn: [XcodeTarget] = []
            let allTargets = self.project.targets
            for pbxTarget in pbxTargets {
                if let t = allTargets.first(where: { $0.pbxTarget.id == pbxTarget.id }) {
                    rtn.append(t)
                }
            }
            return rtn
        }
    }
    
    
    /// Create a new instance of an Xcode File
    ///
    /// - Parameters:
    ///   - project: The Xcode project this file is for
    ///   - fileReference: The PBX File Reference for this XcodeFile
    ///   - parent: The parent Xcode group (Optional)
    internal init(_ project: XcodeProject,_ fileReference: PBXFileReference, havingParent parent: XcodeGroupResource? = nil) {
        self.pbxFileReference = fileReference
        super.init(project, fileReference, havingParent: parent)
    }
    
    
    /// Remove this file
    ///
    /// This will remove the file refernece from the PBX Project file and then try and delete the file from the file system and save the updated PBX Project File
    /// - Parameter deletingFiles: An indicator if this method should delete any physical file (Default: true)
    public func remove(deletingFiles: Bool = true, savePBXFile: Bool = true) throws {
        if deletingFiles && !savePBXFile {
            try self.project.fsProvider.remove(item: self.fullURL)
        }
        
        self.removeReferenceFromParentWithoutSaving()
        self.project.proj.objects.remove(self.pbxFileResource)
        
        if savePBXFile {
            var actions: [XcodeFileSystemProviderAction] = []
            if deletingFiles {
                actions.append(.removeIfExists(item: self.fullURL))
            }
            try self.project.save(actions)
        }
        
        
    }
}
