//
//  XCUserData.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation

public final class XCUserData {
    
    public enum Error: Swift.Error {
        //case urlNotFileBased(URL)
        case userDataFolderMissing(XcodeFileSystemURLResource)
        case invalidUserDataPackageExtension(XcodeFileSystemURLResource)
    }
    
    /// The extension for User Data package
    public static let USER_DATA_PACKAGE_EXT: String = "xcuserdatad"
    
    /// The User Name for this scheme
    public let user: String
    /// The Scheme data
    public let schemes: XCSchemes
    /// The debugging data
    public let debugger: XCDebugger
    
    /// Create new instance of a User Data from file
    ///
    /// - Parameters:
    ///   - url: The url to the user data
    ///   - provider: The file system to use
    public init(from url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        /*guard url.isFileURL else {
            throw Error.urlNotFileBased(url)
        }*/
        
        guard try provider.itemExists(at: url) else {
            throw Error.userDataFolderMissing(url)
        }
        
        guard url.lastPathComponent.lowercased().hasSuffix(XCUserData.USER_DATA_PACKAGE_EXT) else {
            throw Error.invalidUserDataPackageExtension(url)
        }
        
        self.user = NSString(string: url.lastPathComponent).deletingPathExtension
        
        // Load schemes
        self.schemes = try XCSchemes(from: url.appendingPathComponent(XCSchemes.SCHEMES_FOLDER, isDirectory: true),
                                     usingFSProvider: provider)
        
        // Load Debugger info
        self.debugger = try XCDebugger(from: url.appendingPathComponent(XCDebugger.DEBUGGER_FOLDER_NAME, isDirectory: true),
                                       usingFSProvider: provider)
        
    }
    
    
    
    /// Create new empty instance User Data
    ///
    /// - Parameter user: The name of the user this data block is for
    public init(forUser user: String)  {
        self.user = user
        self.schemes = XCSchemes()
        self.debugger = XCDebugger()
    }
    
    /// Get all save actions that are needed
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    /// - Returns: Returns an array of all save actions that are required
    public func saveActions(to url: XcodeFileSystemURLResource, overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
        return try self.schemes.saveActions(to: url.appendingPathComponent(XCSchemes.SCHEMES_FOLDER, isDirectory: true),
                                            overrideChangeCheck: overrideChangeCheck)
    }
    
    
    /// Save thisobject to the file system
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - provider: the file system provider to use
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    public func save(to url: XcodeFileSystemURLResource,
                     usingFSProvider provider: XcodeFileSystemProvider,
                     overrideChangeCheck: Bool = false) throws {
        
        let actions = try self.saveActions(to: url, overrideChangeCheck: overrideChangeCheck)
        
        // Save schemes
        try provider.actions(actions)
    
    }
}

extension XCUserData: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "XCUserData(\(self.user): \(self.schemes.debugDescription))"
    }
}
