//
//  XcodeWorkspace.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation



public class XcodeWorkspace  {
    
    private enum CodingKeys: String, CodingKey {
        case workspace = "Workspace"
        case version = "version"
        case fileRef = "FileRef"
        case location = "location"
    }
    
    public enum Errors: Swift.Error {
        public enum Parsing: Swift.Error {
            case fileRefMissingLocationAttribute
            case invalidFileRefLocationAttribute(Any?)
        }
        //case unableToLoadXML(at: URL)
        //case unknownXMLParsingErrorOccured
        case workspaceDocumentMissingRootNode
        case mustBeFileURL(URL)
    }
    
    /// A Workspace project
    ///
    /// - existing: Represents an existing project
    /// - missing: Represents a project that could not be found
    /// - loadError: Represents a project that had a problem loading
    /// - badURL: Represents a project with a bad url
    public enum WorkspaceProject {
        case existing(XcodeProject)
        case missing(XcodeFileSystemURLResource)
        case loadError(XcodeFileSystemURLResource, Swift.Error?)
        case badURL(String)
        
        /// Gets the relative path of the project to a given url
        ///
        /// - Parameter url: The url to get that relative path from
        /// - Returns: Returns a relative path from url otherwise the full path if its not possible
        fileprivate func url(relativeTo url: XcodeFileSystemURLResource) -> String {
            switch self {
                case .existing(let p): return p.projectPackage.relative(to: url).path
                case .missing(let u): return u.relative(to: url).path
                case .loadError(let u, _): return u.relative(to: url).path
                case .badURL(let s): return s
            }
        }
        
        
        
        /// Get all save actions that are needed for this project
        ///
        /// - Parameter overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
        /// - Returns: Returns an array of all save action required
        fileprivate func saveAllActions(overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
            
            if case WorkspaceProject.existing(let p) = self {
                return try p.saveAllActions(overrideChangeCheck: overrideChangeCheck)
            } else {
                return []
            }
        }
        /// Save the current project if possible
        ///
        /// - Parameter overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
        fileprivate func save(overrideChangeCheck: Bool = false) throws {
            if case WorkspaceProject.existing(let p) = self {
                try p.save(overrideChangeCheck: overrideChangeCheck)
            }
        }
    }
    
    private static let CONTENTS_FILE_NAME: String = "contents.xcworkspacedata"
    
    
    /// The filesystem provider used for reading and writing projects
    internal private(set) var fsProvider: XcodeFileSystemProvider
    /// The url to the workspace
    internal private(set) var url: XcodeFileSystemURLResource
    //internal var parentURL: XcodeFileSystemURLResource { return self.url.deletingLastPathComponent() }
    
    /// An indicator if this workspace has changed
    private var hasInfoChanged: Bool = false
    
    /// The workspace version
    private var workspaceVersion: Decimal = 1.0 {
        didSet { self.hasInfoChanged = true }
    }
    
    /// An array of the workspace projects
    public fileprivate(set) var projects: [WorkspaceProject] = [] {
        didSet { self.hasInfoChanged = true }
    }
    
    /// The project shared data
    private var _sharedData: XCSharedData? = nil
    /// The project user data list
    private var _userdataList: XCUserDataList? = nil
    
    /// Open up an Xcode Workspace
    ///
    /// - Parameters:
    ///   - url: The url to the workspace to open
    ///   - provider: The file system provider to use to read the project
    public init(fromURL url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        
        self.url = url
        self.fsProvider = provider
        
        // Read XCWorkspace
        self._sharedData = try XCSharedData(fromURL: url.appendingDirComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME),
                                            usingFSProvider: provider)
        self._userdataList = try XCUserDataList(fromURL: url.appendingDirComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME),
                                               usingFSProvider: provider)
        
        let parentFolder = url.deletingLastPathComponent()
        
        let xmlDocument = try XMLDocument(data: try provider.data(from: url.appendingFileComponent(XcodeWorkspace.CONTENTS_FILE_NAME)),
                                          options: [])
        guard let xmlRoot = xmlDocument.rootElement() else {
            throw Errors.workspaceDocumentMissingRootNode
        }
        
        if let verAttrib = xmlRoot.attribute(forName: CodingKeys.version) {
            if let sValue = verAttrib.stringValue, let dValue = Decimal(string: sValue) {
                self.workspaceVersion = dValue
            }
        }
        
        let workspaceElements = xmlRoot.elements(forName: CodingKeys.fileRef)
        for element in workspaceElements {
            guard let locAttrib = element.attribute(forName: CodingKeys.location) else {
                throw Errors.Parsing.fileRefMissingLocationAttribute
            }
            guard var locStr = locAttrib.stringValue else {
                throw Errors.Parsing.invalidFileRefLocationAttribute(locAttrib.objectValue)
            }
            
            if locStr.hasPrefix("group:") { locStr.removeFirst(6) }
            
            //guard let projURL = URL(string: locStr, relativeTo: parentFolder) else {
            let projURL = XcodeFileSystemURLResource(directory: locStr, base: parentFolder)
            
            guard projURL.isDirectory || (FileManager.default.fileExists(atPath: projURL.path)) else {
                self.projects.append(.missing(projURL))
                continue
            }
            
            do {
                let p = try XcodeProject(fromURL: projURL, usingFSProvider: provider)
                p.xCodeWorkspace = self
                self.projects.append(.existing(p))
            } catch {
                self.projects.append(.loadError(projURL, error))
            }
            
        }
    
    }
    
    /// Open up an Xcode Workspace
    ///
    /// - Parameters:
    ///   - url: The url to the project to open
    public convenience init(fromURL url: URL) throws {
        guard url.isFileURL else {
            throw Errors.mustBeFileURL(url)
        }
        try self.init(fromURL: XcodeFileSystemURLResource(directory: url.path),
                      usingFSProvider: LocalXcodeFileSystemProvider.default)
    }
    
    /// Open up an Xcode Workspace
    ///
    /// - Parameter path: The path to the Xcode Workspace Package
    public convenience init(fromPath path: String) throws {
        try self.init(fromURL: XcodeFileSystemURLResource(directory: path),
                      usingFSProvider: LocalXcodeFileSystemProvider.default)
    }
    
    /// The workspace shared data
    ///
    /// This will open if needed and then return the shared data for this workspace
    /// - Returns: Returns the shared data for this workspace
    @discardableResult
    public func sharedData() throws -> XCSharedData {
        if let r = self._sharedData { return r }
        
        let rtn = try XCSharedData(fromURL: self.url.appendingDirComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME),
                                   usingFSProvider: self.fsProvider)
        self._sharedData = rtn
        
        return rtn
    }
    
    /// The workspace user data list
    ///
    /// This will open if needed and then return the user data list for this workspace
    /// - Returns: Returns the user data list for this workspace
    @discardableResult
    public func userdataList() throws -> XCUserDataList {
        if let r = self._userdataList { return r }
        
        let rtn = try XCUserDataList(fromURL: self.url.appendingDirComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME),
                                     usingFSProvider: self.fsProvider)
        self._userdataList = rtn
        
        return rtn
    }
    
    /// Saves any pending save actions
    ///
    /// - Parameter overrideChangeCheck: An override flag to skip checking for changes and automatically create save actions for all items (Default: false)
    public func save(overrideChangeCheck: Bool = false) throws {
        
        var saveActions:  [XcodeFileSystemProviderAction] = []
        
        if self.hasInfoChanged || overrideChangeCheck {
            let rootElement = XMLTag(CodingKeys.workspace, attribute: (CodingKeys.version, "\(self.workspaceVersion)"))
            
            let xmlDocument = XMLDocument(rootElement: rootElement)
            
            
            let parentFolder = url.deletingLastPathComponent()
            for p in self.projects {
                
                let path = "group:" + p.url(relativeTo: parentFolder)
                
                rootElement.addChild(XMLTag(CodingKeys.fileRef, attribute: (CodingKeys.location, path)))
               
            }
            
            let dta = xmlDocument.xmlData(options: .documentTidyXML)
            
            saveActions.append(.write(data: dta,
                                      to: self.url.appendingFileComponent(XcodeWorkspace.CONTENTS_FILE_NAME),
                                      writeOptions: .atomic))
            
        }
        
        
        
        
        // Write XCWorkspace
        if let actions = try self._sharedData?.saveActions(to: self.url.appendingDirComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME),
                                                           overrideChangeCheck: overrideChangeCheck) {
            saveActions.append(contentsOf: actions)
        }
        
        if let actions = try self._userdataList?.saveActions(to: self.url.appendingDirComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME),
                                                             overrideChangeCheck: overrideChangeCheck) {
            saveActions.append(contentsOf: actions)
        }
        
        
        for p in self.projects {
            // Save loaded projects
            //try p.save()
            let actions = try p.saveAllActions(overrideChangeCheck: overrideChangeCheck)
            saveActions.append(contentsOf: actions)
        }
        
        try self.fsProvider.actions(saveActions)
        

    }
}
