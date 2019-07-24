//
//  XcodeFolderReference.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-07.
//

import Foundation
import PBXProj

/// A class that represents a file resource that is in fact a folder
public class XcodeFolderReference: XcodeFileResource {
    
    
    internal override var objectSortingOrder: Int { return 1 }
    
    /// Create a new Folder File Reference
    ///
    /// - Parameters:
    ///   - project: The Xcode project this resource is for
    ///   - fileElement: The PBX File Reference for this resource
    ///   - parent: The parent Xcode group (Optional)
    internal override init(_ project: XcodeProject,
                           _ fileElement: PBXFileElement,
                           havingParent parent: XcodeGroupResource? = nil) {
        super.init(project, fileElement, havingParent: parent)
    }
    
    /// Gets a list of all the child elements of this folder
    ///
    /// - Returns: An array of all the children of this folder
    public func children() throws -> [XcodeFileSystemURLResource] {
        return try self.project.fsProvider.contentsOfDirectory(at: self.fullURL)
    }
}
