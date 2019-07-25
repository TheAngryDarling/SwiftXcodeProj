//
//  XcodeMainProjectGroup.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-22.
//

import Foundation
import PBXProj

/// A XcodeGroup specificly for the root group of the project
public class XcodeMainProjectGroup: XcodeGroup {
    /// The Xcode Project products group if it exists
    public var products: XcodeProductsGroup! {
        guard let groupId = self.project.proj.project.productRefGroupReference else { return nil }
       
        return (self.first(where: {return ($0 is XcodeProductsGroup) && $0.pbxFileResource.id == groupId}) as? XcodeProductsGroup)
    }
    
    /// Create a source group
    ///
    /// - Parameters:
    ///   - name: The name of the new source group
    ///   - createFolder: An indicator if a folder should created on the file system
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created group
    public func createSourceGroup(withName name: String,
                            createFolder: Bool = true,
                            savePBXFile: Bool = true) throws -> XcodeGroup {
        
        let childURL = self.fullURL.appendingPathComponent(name, isDirectory: true)
        if createFolder && !savePBXFile && !self.project.isNewProject {
            try self.project.fsProvider.createDirectory(at: childURL)
        }
        
        let pbxChildGroup = try self.pbxGroup.createSubGroup(path: name, sourceTree:.sourceRoot)
        
        let rtn = XcodeGroup(self.project, pbxChildGroup, havingParent: self)
        
        if self.project.proj.project.productRefGroupReference == nil {
            self.children.append(rtn)
        } else {
            var resources = self.pbxGroup.childrenReferences
            resources.removeLast()
            resources.insert(rtn.pbxGroup.id, at: resources.count - 1)
            
            self.pbxGroup.childrenReferences = resources
            self.children.insert(rtn, at: self.children.count - 1)
        }
        
        if savePBXFile {
            var actions: [XcodeFileSystemProviderAction] = []
            if createFolder {
                actions.append(.createDirectory(at: childURL, withIntermediateDirectories: true))
            }
            try self.project.save(actions)
        } else if createFolder && self.project.isNewProject {
            // If we need to create the folder but we are not saving the pbx file yet becauase its a new project, lets append the action to the pending list
            self.project.pendingSaveActions.append(.createDirectory(at: childURL, withIntermediateDirectories: true))
        }
        
        return rtn
    }
    
    public override func resource(atPath path: String) -> XcodeFileResource? {
        let components = path.split(separator: "/").map(String.init)
        return self.resource(atPathComponents: components)
    }
    
    public override func sort() {
        func srtFnc(_ lhs: XcodeFileResource, _ rhs: XcodeFileResource) -> Bool {
            var lhsOrder = lhs.objectSortingOrder
            if lhsOrder == XcodeFile.OBJECT_SORT_ORDER { lhsOrder = 0 }
            var rhsOrder = rhs.objectSortingOrder
            if rhsOrder == XcodeFile.OBJECT_SORT_ORDER { rhsOrder = 0 }
            if lhsOrder < rhsOrder { return true }
            else if lhsOrder > rhsOrder { return false }
            else { return lhs.name.lowercased() < rhs.name.lowercased() }
        }
        super.sort() // This will sort main group + all sub groups
        self.sort(by: srtFnc) // Resort main group
        
    }
}
