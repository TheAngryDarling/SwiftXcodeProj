//
//  XcodeGroup.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-29.
//

import Foundation
import PBXProj

/// An Xcode Group / Folder
public class XcodeGroup: XcodeGroupResource {
    
    /// Find the resource at a given path component list
    ///
    /// This will assume the start of the path component is relative to the given group.  To move up a level use the .. as the first component
    ///
    /// - Parameter components: The components of the path
    /// - Returns: Returns the found resource, otherwise nil
    internal func resource(atPathComponents components: [String]) -> XcodeFileResource? {
        var comps = components
        if (comps.count > 0 && comps[0] == ".") {
            // First path component indicates the current folder so lets remove it
            comps.removeFirst()
        }
        // We hit and indicator that we want the current group (wether the previous super call had a .. or our current call had a only a .)
        guard comps.count > 0 else { return self }
        
        if comps[0] == ".." {
            guard self.parentGroup != nil else { return nil }
            return self.parentGroup.resource(atPathComponents: comps.removingFirst())
        }
        
        if let child = self.children.first(where: { return $0.name == comps[0] }) {
            guard comps.count > 1 else { return child }
            guard let childGroup = child as? XcodeGroup else { return nil }
            return childGroup.resource(atPathComponents: comps.removingFirst())
        }
        
        return nil
    }
    
    /// Find the resource at the given path
    ///
    /// Child or sub child resources paths start without a /.  To search from the root, the path should start with a /.  This search also supports the .. and . folder indicators
    ///
    /// - Parameter path: The string path representing the resource
    /// - Returns: Returns the found resource, otherwise nil
    public func resource(atPath path: String) -> XcodeFileResource? {
        guard !path.hasPrefix("/") else {
            return self.project.resources.resource(atPath: path)
        }
        let components = path.split(separator: "/").map(String.init)
        return self.resource(atPathComponents: components)
    }
    
    /// Find the file at the given path
    ///
    /// - Parameter path: The string path representing the Xcode File
    /// - Returns: Returns the found file, otherwise nil
    public func file(atPath path: String) -> XcodeFile? {
        guard let file = resource(atPath: path) as? XcodeFile else { return nil }
        return file
    }
    
    /// Find the group at the given path
    ///
    /// - Parameter path: The string path representing the Xcode Group
    /// - Returns: Returns the found group, otherwise nil
    public func group(atPath path: String) -> XcodeGroup? {
        guard let grp = resource(atPath: path) as? XcodeGroup else { return nil }
        return grp
    }
    
    /// Create a child group
    ///
    /// - Parameters:
    ///   - name: The name of the group
    ///   - location: The location witin this group the child group should be set. Either the beginning or end. (Default: .end)
    ///   - createFolder: An indicator if a folder on the file system shoud be created for this group (Default: true)
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created group
    public func createGroup(withName name: String,
                            atLocation location: AddLocation<XcodeFileResource> = .end,
                            createFolder: Bool = true,
                            savePBXFile: Bool = true) throws -> XcodeGroup {
        
        let childURL = self.fullURL.appendingDirComponent(name)
        if createFolder && !savePBXFile && !self.project.isNewProject {
            try self.project.fsProvider.createDirectory(at: childURL)
        }
        
        
        let pbxChildGroup = try self.pbxGroup.createSubGroup(path: name, atLocation: location.pbxLocation)
        
        let rtn = XcodeGroup(self.project, pbxChildGroup, havingParent: self)
        
        try location.add(rtn, to: &self.children)
        
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
    
    internal override func removeFromFileSystemActions() throws -> [XcodeFileSystemProviderAction] {
        var rtn: [XcodeFileSystemProviderAction] = try super.removeFromFileSystemActions()
        // Remove all child references
        for child in self.children {
            rtn.append(contentsOf: try child.removeFromFileSystemActions())
        }
        rtn.append(.removeIfExistsAndEmpty(forFolder: self.fullURL))
        return rtn
    }
    
    /// Remove this group from the project
    ///
    /// - Parameters:
    ///   - deletingFiles: An indicator if any file system resources for this group should be deleted from the file system
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    public override func remove(deletingFiles: Bool, savePBXFile: Bool = true) throws {
        var removeActions: [XcodeFileSystemProviderAction] = []
        
        if deletingFiles {
            removeActions.append(contentsOf: try self.removeFromFileSystemActions())
        }
        // Remove all child references
        for child in self.children {
            try child.remove(deletingFiles: false, savePBXFile: false)
        }
        
        try super.remove(deletingFiles: false, savePBXFile: false)
        
        
        
        if savePBXFile {
            try self.project.save(removeActions)
        } else if deletingFiles && removeActions.count > 0 {
            try self.project.fsProvider.actions(removeActions)
        }
    }
    
    /// Create a new file
    ///
    /// Note: This method does not create a file on the file system
    ///
    /// - Parameters:
    ///   - fileType: The type of file this is
    ///   - name: The name of the file
    ///   - membership: Having memership to the given tarets
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    ///   - actionBeforeModification: An action to call before the PBX Project file is saved
    /// - Returns: Returns the newly created file
    public func createFileReference(ofType fileType: XcodeFileType,
                                    withName name: String,
                                    havingMembership membership: [XcodeTarget],
                                    atLocation location: AddLocation<XcodeFileResource> = .end,
                                    savePBXFile: Bool = true,
                                    actionBeforeModification: (XcodeFile) throws -> Void = { _ in return }) throws -> XcodeFile {
        
        let pbxChildFile: PBXFileReference!
        if self.isAbsolutePath {
            pbxChildFile =  try self.pbxGroup.createFileReference(namePath: .both(name: name,
                                                                              path: self.fullURL.appendingFileComponent(name).path),
                                                                sourceTree: .group,
                                                                lastKnownFileType: fileType,
                                                                atLocation: location.pbxLocation)
        } else {
            pbxChildFile = try self.pbxGroup.createFileReference(namePath: .name(name),
                                                                 sourceTree: .group,
                                                                 lastKnownFileType: fileType,
                                                                 atLocation: location.pbxLocation)
        }
        
        let rtn = XcodeFile(self.project, pbxChildFile, havingParent: self)
        
        try location.add(rtn, to: &self.children)
        
        if fileType.isCodeFile {
            for target in membership {
                let sourcePhases = target.pbxTarget.getBuildPhases(forType: PBXSourcesBuildPhase.self)
                for sourcePhase in sourcePhases {
                    sourcePhase.createBuildFile(for: pbxChildFile)
                }
            }
        }
        
        try actionBeforeModification(rtn)
        
        if savePBXFile {
            try self.project.save()
        }
        
        return rtn
        
    }
    
    /// Create a new file
    ///
    /// - Parameters:
    ///   - fileType: The type of file this is
    ///   - name: The name of the file
    ///   - data: The data for this file
    ///   - membership: Having memership to the given tarets
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    /// - Returns: Returns the newly created file
    @discardableResult
    public func createFile(ofType fileType: XcodeFileType,
                           withName name: String,
                           withInitialData data: Data? = nil,
                           havingMembership membership: [XcodeTarget],
                           atLocation location: AddLocation<XcodeFileResource> = .end) throws -> XcodeFile {
        
        return try createFileReference(ofType: fileType,
                                       withName: name,
                                       havingMembership: membership,
                                       atLocation: location) { (_ xCodeFile: XcodeFile) throws -> Void in
            let workingData = data ?? XcodeDefaultFileContent.getContentFor(fileType: fileType,
                                                                            withName: name,
                                                                            havingMembership: membership,
                                                                            inProject: self.project) ?? Data()
            
            
            if self.project.isNewProject {
                // If we are a new project we will append the writes and save all at once
                self.project.pendingSaveActions.append(.write(data: workingData, to: xCodeFile.fullURL, writeOptions: .atomic))
            } else {
                try self.project.fsProvider.write(workingData, to: xCodeFile.fullURL, withOptions: .atomic)
            }
            
        }
    }
    
    /// Create a new file
    ///
    /// - Parameters:
    ///   - fileType: The type of file this is
    ///   - name: The name of the file
    ///   - data: The data for this file
    ///   - membership: Having memership to the given tarets
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    /// - Returns: Returns the newly created file
    @discardableResult
    public func createFile(ofType fileType: XcodeFileType,
                           withName name: String,
                           withInitialData data: Data? = nil,
                           havingMembership membership: XcodeTarget,
                           atLocation location: AddLocation<XcodeFileResource> = .end) throws -> XcodeFile {
        return try createFile(ofType: fileType,
                              withName: name,
                              withInitialData: data,
                              havingMembership: [membership],
                              atLocation: location)
    }
    
    /// Add an existing Xcode Project to this group
    ///
    ///
    /// - Parameters:
    ///   - path: The path of the Xcode Project
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created file
    @discardableResult
    private func addExistingProject(_ path: XcodeFileSystemURLResource,
                                    atLocation location: AddLocation<XcodeFileResource> = .end,
                                    savePBXFile: Bool = true) throws -> XcodeFileResource {
        
        let ft = PBXFileType.fileType(forExt: path.pathExtension)
        let strPath = path.relative(to: self.project.projectFolder).path
        
        let subPBXProjectPath = path.appendingFileComponent("project.pbxproj")
        
        let pbxFile = try self.pbxGroup.createFileReference(namePath: .both(name: path.lastPathComponent, path: strPath),
                                                        sourceTree: PBXSourceTree.group,
                                                        lastKnownFileType: ft,
                                                        atLocation: location.pbxLocation)
        
        
        if let dta = try self.project.fsProvider.dataIfExists(from: subPBXProjectPath) {
            let pbxDecoder = PBXProjDecoder()
            //let pbxProj = try pbxDecoder.decode(PBXProj.self, from: dta)
            let pbxProj = try pbxDecoder.decode(from: dta)
            
            var targetProxyRefrences: [PBXReference] = []
            
            let targets = pbxProj.objects.targets
            for target in targets {
                //guard target.type == .nativeTarget else { continue }
                guard let nativeTarget = target as? PBXNativeTarget else { continue }
                guard let productReference = nativeTarget.productReference else { continue }
                guard let targetFile = pbxProj.objects.object(withReference: productReference, asType: PBXFileReference.self),
                      let targetFileSource = targetFile.sourceTree, targetFileSource == .buildProductsDir else { continue }
                
                let tName = target.name
                
                
                let proxy = self.project.proj.createContainerItemProxy(containerPortal: pbxFile,
                                                                        remoteGlobalIDString: productReference,
                                                                        remoteInfo: tName)
                
                
                let ref = self.project.proj.createReferenceProxy(namePath: .path(targetFile.path!),
                                                                    sourceTree: .buildProductsDir,
                                                                    fileType: targetFile.explicitFileType!,
                                                                    remoteReference: proxy.id)
                
                targetProxyRefrences.append(ref.id)
                
            }
            
            let grp = self.project.proj.createUnlinkedGroup(fileType: .referenceProxy,
                                                            namePath: .name("Products"),
                                                            sourceTree: .group,
                                                            children: targetProxyRefrences)
            
            let ref = PBXProject.PBXProjectReference(group: grp.id, ref: pbxFile.id)
            
            self.project.proj.project.projectReferences.append(ref)
            
        }
        
        let rtn = XcodeFile(self.project, pbxFile, havingParent: self)
        try location.add(rtn, to: &self.children)
        
        if savePBXFile {
            try self.project.save()
        }
        return rtn
        
    }
    
    /// Add an existing folder to this group
    ///
    /// - Parameters:
    ///   - path: The path to the folder
    ///   - targets: The targets to add to for any child elements
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    ///   - copyLocally: An indicator if the files should be copied locally
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created file
    @discardableResult
    private func addExistingFolder(_ path: XcodeFileSystemURLResource,
                                   includeInTargets targets: [XcodeTarget] = [],
                                   atLocation location: AddLocation<XcodeFileResource> = .end,
                                   copyLocally: Bool,
                                   savePBXFile: Bool = true) throws -> XcodeFileResource {
        
        let pbxSubGroup = try self.pbxGroup.createSubGroup(path: path.lastPathComponent,
                                                           atLocation: location.pbxLocation)
        do {
            let subGroup = XcodeGroup(self.project, pbxSubGroup, havingParent: self)
            try location.add(subGroup, to: &self.children)
            
            let children = try self.project.fsProvider.contentsOfDirectory(at: path)
            for child in children {
                if child.isDirectory {
                    try subGroup.addExistingFolder(child,
                                                   includeInTargets: targets,
                                                   copyLocally: copyLocally,
                                                    savePBXFile: false)
                } else {
                    try subGroup.addExistingFile(child,
                                                 includeInTargets: targets,
                                                 copyLocally: copyLocally,
                                                 savePBXFile: false)
                }
            }
            if savePBXFile {
                try self.project.save()
            }
            return subGroup
        } catch {
            // Clean up on error
            if let idx = self.pbxGroup.childrenReferences.firstIndex(of: pbxSubGroup.id) {
                self.pbxGroup.childrenReferences.remove(at: idx)
            }
            //self.pbxGroup.childrenReferences.removeAll(where: {$0 == pbxSubGroup.id})
            self.pbxGroup.objectList.remove(pbxSubGroup)
            throw error
        }
        
        
    }
    
    /// Add an existing file to this group
    ///
    /// - Parameters:
    ///   - path: The path to the file
    ///   - targets: The targets to add to for this file
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    ///   - copyLocally: An indicator if the files should be copied locally
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created file
    @discardableResult
    private func addExistingFile(_ path: XcodeFileSystemURLResource,
                                 includeInTargets targets: [XcodeTarget] = [],
                                 atLocation location: AddLocation<XcodeFileResource> = .end,
                                 copyLocally: Bool = true,
                                 savePBXFile: Bool = true) throws -> XcodeFileResource {
        //let initalStrPath = path.relative(to: self.project.projectFolder).relativePath
        var strPath = path.relative(to: self.project.projectFolder).relativePath
        if copyLocally  {
            //print("Adding \(path.path) to group \(self.name) with tree: \(self.sourceTree)")
            if let tree = self.sourceTree {
                switch tree {
                    case .group:
                        strPath = path.lastPathComponent
                        //print("[group]: Changing strPath from \(initalStrPath) to \(strPath)")
                    case .absolute:
                        strPath = path.path
                        //print("[absolute]: Changing strPath from \(initalStrPath) to \(strPath)")
                    case .sourceRoot:
                        var basePath = self.project.resources.fullURL
                        if let p = self.path { basePath.appendDirComponent(p) }
                        strPath = path.relative(to: basePath).relativePath
                        //print("[sourceRoot]: Changing strPath from \(initalStrPath) to \(strPath) having basePath \(basePath.path)")
                    default:
                        strPath = path.path
                        //print("Changing strPath to \(strPath)")
                }
            }
            
            // Must copy files in
            if path != self.fullURL.appendingFileComponent(path.lastPathComponent) {
                try self.project.fsProvider.copy(path, to: self.fullURL)
            }
        }
        
        
        let ft = PBXFileType.fileType(forExt: path.pathExtension)
        
        let pbxFile = try self.pbxGroup.createFileReference(namePath: .both(name: path.lastPathComponent, path: strPath),
                                                        sourceTree: PBXSourceTree.group,
                                                        lastKnownFileType: ft,
                                                        atLocation: location.pbxLocation)
        
        
        let compileable = ft?.isCodeFile ?? false
        
        if compileable {
            for t in targets {
                let sourcePhases: [PBXSourcesBuildPhase] = t.pbxTarget.getBuildPhases(forType: PBXSourcesBuildPhase.self)
                for s in sourcePhases {
                    s.createBuildFile(for: pbxFile)
                }
            }
        }
        
        let rtn = XcodeFile(self.project, pbxFile, havingParent: self)
        try location.add(rtn, to: &self.children)
        
        if savePBXFile {
            try self.project.save()
        }
        
        return rtn
        
        
    }
    
    /// Add an existing file system resource to the project
    ///
    /// - Parameters:
    ///   - path: Path to the resource
    ///   - targets: The targets to add to for this file
    ///   - location: The location witin this group the child object should be set. Either the beginning or end. (Default: .end)
    ///   - copyLocally: An indicator if the files should be copied locally
    ///   - savePBXFile: An indicator if the PBX Project File should be saved at this time (Default: true)
    /// - Returns: Returns the newly created file
    @discardableResult public func addExisting(_ path: XcodeFileSystemURLResource,
                                               includeInTargets targets: [XcodeTarget] = [],
                                               atLocation location: AddLocation<XcodeFileResource> = .end,
                                               copyLocally: Bool = true,
                                               savePBXFile: Bool = true) throws -> XcodeFileResource {
        
        var rtn: XcodeFileResource!
        
        if path.isDirectory {
            if path.pathExtension.lowercased() == XcodeProject.XCODE_PROJECT_EXT.lowercased() {
                rtn = try self.addExistingProject(path, atLocation: location, savePBXFile: savePBXFile)
            } else {
                rtn = try self.addExistingFolder(path,
                                                 includeInTargets: targets,
                                                 atLocation: location,
                                                 copyLocally: copyLocally,
                                                 savePBXFile: savePBXFile)
            }
        } else {
            rtn = try self.addExistingFile(path,
                                           includeInTargets: targets,
                                           atLocation: location,
                                           copyLocally: copyLocally,
                                           savePBXFile: savePBXFile)
        }
        
        return rtn
    }
}
