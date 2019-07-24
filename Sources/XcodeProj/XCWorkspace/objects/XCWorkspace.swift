//
//  XCWorkspace.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation


public final class XCWorkspace {
    
    /// Shared Data folder name
    internal static let SHARED_DATA_FOLDER_NAME: String = "xcshareddata"
    /// User Data List folder name
    internal static let USER_DATA_LIST_FOLDER_NAME: String = "xcuserdata"
    
    
    /// Workspace shared data
    public let sharedData: XCSharedData
    /// Workspace user data list
    public let userdataList: XCUserDataList
    
    //internal private(set) var url: URL
    
    /*public init() {
        self.sharedData = XCSharedData()
        self.userdataList = XCUserDataList()
    }*/
    
    /// Create a new instance of Workspace
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - provider: The file system provider to use
    public init(fromURL url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        //self.url = url
        self.sharedData = try XCSharedData(fromURL: url.appendingPathComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME,
                                                                               isDirectory: true), usingFSProvider: provider)
        self.userdataList = try XCUserDataList(fromURL: url.appendingPathComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME, isDirectory: true),
                                               usingFSProvider: provider)
    }
    
    /// Get all save actions that are needed
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    /// - Returns: Returns an array of all save actions that are required
    public func saveActions(to url: XcodeFileSystemURLResource,
                            overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
        var rtn: [XcodeFileSystemProviderAction] = []
        rtn.append(contentsOf: try self.sharedData.saveActions(to: url.appendingPathComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME, isDirectory: true),
                                                               overrideChangeCheck: overrideChangeCheck))
        rtn.append(contentsOf: try self.userdataList.saveActions(to: url.appendingPathComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME,
                                                                                                isDirectory: true),
                                                                 overrideChangeCheck: overrideChangeCheck))
        return rtn
    }
    
    /// Save thisobject to the file system
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - provider: The file system provider to use
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    public func save(to url: XcodeFileSystemURLResource,
                     usingFSProvider provider: XcodeFileSystemProvider,
                     overrideChangeCheck: Bool = false) throws {
        try self.sharedData.save(to: url.appendingPathComponent(XCWorkspace.SHARED_DATA_FOLDER_NAME, isDirectory: true),
                                 usingFSProvider: provider,
                                 overrideChangeCheck: overrideChangeCheck)
        try self.userdataList.save(to: url.appendingPathComponent(XCWorkspace.USER_DATA_LIST_FOLDER_NAME, isDirectory: true),
                                   usingFSProvider: provider,
                                   overrideChangeCheck: overrideChangeCheck)
    }
}
