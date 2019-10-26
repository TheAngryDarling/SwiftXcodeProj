//
//  XcodeFileResource.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation
import PBXProj

/// A base clss for all Xcode File Resources (eg, File, Folder)
public class XcodeFileResource: XcodeResource {
    /// The parent group resource if one is set
    public internal(set) var parent: XcodeGroupResource!
    
    /// The parent as an XcodeGroup if the parent is set AND it is a XcodeGroup
    ///
    /// This will simplify when needing access to the parent group because there will be no need to cast
    public var parentGroup: XcodeGroup! { return self.parent as? XcodeGroup }
    
    /// Gets the main group for the project
    public var mainGroup: XcodeMainProjectGroup! { return self.project.resources }
    
    /// Simple way to help sort objects.  This shoud be overridded in sub classes to group different object types together
    internal var objectSortingOrder: Int { return 0 }
    
    /// An indicator if this resource has an apsolute path (the pbx file resource path property starts with a /)
    public var isAbsolutePath: Bool {
        guard let pbxPath = self.pbxFileResource.path, pbxPath.contains("/") else { return false }
        return pbxPath.hasPrefix("/")
    }
    
    /// The source tree for the given resource
    public var sourceTree: XcodeSourceTree? {
        get { return self.pbxFileResource.sourceTree }
        set { self.pbxFileResource.sourceTree = newValue }
    }
    
    /// Provides the full XcodeFileSystemURLResource URL path of this resource.
    ///
    /// This is build using the current resource path/name as well as its parent fullURL to build the reutrning value
    public var fullURL: XcodeFileSystemURLResource {
        let isFolder: Bool = (self is XcodeGroupResource)
        
        if let pbxPath = self.pbxFileResource.path, pbxPath.contains("/") {
            if pbxPath.hasPrefix("/") {
                var comps = URLComponents(url: self.project.projectPackage.url, resolvingAgainstBaseURL: false)
                comps?.path = pbxPath
                guard let newURL = comps?.url else {
                    fatalError("Failed to create XcodeFileResource.fullURL for absolute path '\(pbxPath)' having project Parent: \(self.project.projectPackage)")
                }
                return XcodeFileSystemURLResource(path: newURL.path, isDirectory: isFolder)
                //return URL(fileURLWithPath: pbxPath, isDirectory: isFolder)
            }
            else {
                return self.project.projectPackage
                    .deletingLastPathComponent()
                    .appendingPathComponent(pbxPath, isDirectory: isFolder)
            }
        }
        if self.parent != nil {
            return self.parent.fullURL.appendingPathComponent(self.name, isDirectory: isFolder)
        } else {
            let n = self.name
            var rtn = self.project.projectPackage.deletingLastPathComponent()
            if !n.isEmpty {
                rtn.appendPathComponent(n, isDirectory: isFolder)
            }
            return rtn
        }
    }
    
    
    /// The full path (This takes th fullURL and reutrns the path string of it)
    public override var fullPath: String { return self.fullURL.path }
    
    
    /// Creates a new instance of a Xcode File Resource
    ///
    /// This should not be called directly.  This should only be called by inherited classes
    ///
    /// - Parameters:
    ///   - project: The Xcode project this resource is for
    ///   - fileElement: The PBX File Reference for this resource
    ///   - parent: The parent Xcode group (Optional)
    internal init(_ project: XcodeProject,
                  _ fileElement: PBXFileElement,
                  havingParent parent: XcodeGroupResource? = nil) {
        self.parent = parent
        super.init(project, fileElement)
    }
    
    /// Checks to see if the files this resources references exists on the file system
    ///
    /// - Returns: Returns true if the resource exists, otherwise false
    public func exists() throws -> Bool {
        return try self.project.fsProvider.itemExists(at: self.fullURL)
    }
    
    
    /// Remove this resource from its parent group without saving the PBX Project File
    ///
    /// - Returns: Returns true if the file was removed otherwise false
    @discardableResult
    internal func removeReferenceFromParentWithoutSaving() -> Bool {
        guard self.parent != nil else { return false }
        guard let idx = self.parent.children.firstIndex(of: self) else { return false }
        self.parent.children.remove(at: idx)
        if let pbxIdx = self.parent.pbxGroup.childrenReferences.firstIndex(of: self.pbxFileResource.id) {
            self.parent.pbxGroup.childrenReferences.remove(at: pbxIdx)
        }
        return true
    }

}
