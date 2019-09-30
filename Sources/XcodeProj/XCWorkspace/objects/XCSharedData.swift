//
//  XCSharedData.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation
import CustomCoders
import AdvancedCodableHelpers

public final class XCSharedData: NSObject {
    
    private static let IDE_WORKSPACE_CHECKS_FILE_NAME: String = "IDEWorkspaceChecks.plist"
    private static let WORKSPACE_SETTINGS_FILE_NAME: String = "WorkspaceSettings.xcsettings"
    
    public let schemes: XCSchemes
    
    private var hasIDEWorkspaceChecksChagned: Bool = false
    public var ideWorkspaceChecks: [String: Any] {
        didSet { self.hasIDEWorkspaceChecksChagned = true }
    }
    private var hasWorkspaceSettingsChanged: Bool = false
    public var workspaceSettings: [String: Any] {
        didSet { self.hasWorkspaceSettingsChanged = true }
    }
    
    public override var debugDescription: String { return "XCSharedData(\(self.schemes.debugDescription))" }
    
    public override init() {
        self.schemes = XCSchemes()
        self.ideWorkspaceChecks = [:]
        self.workspaceSettings = [:]
        
        // Setup defaults
        self.ideWorkspaceChecks["IDEDidComputeMac32BitWarning"] = true
        super.init()

    }
    
    /// Load the shared data from the given path
    ///
    /// - Parameters:
    ///   - url: The path to the shared data package folder
    ///   - provider: The filesystem provider to used to load the package
    public init(fromURL url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        let plistDecoder = PListDecoder()
        
        
        let ideWorkspaceChecksURL = url.appendingFileComponent(XCSharedData.IDE_WORKSPACE_CHECKS_FILE_NAME)
        let workspaceSettingsURL = url.appendingFileComponent(XCSharedData.WORKSPACE_SETTINGS_FILE_NAME)
        
        var dataActions: [XcodeFileSystemProviderAction] = []
        dataActions.append(.dataIfExists(for: ideWorkspaceChecksURL))
        dataActions.append(.dataIfExists(for: workspaceSettingsURL))
        
        
        let responses = try provider.actions(dataActions)
        
        if responses[0].isFailedDependancy { self.ideWorkspaceChecks = [:] }
        else if case XcodeFileSystemProviderActionResponse.data(let dta, for: _) = responses[0] {
            self.ideWorkspaceChecks = try CodableHelpers.dictionaries.decode(dta,
                                                                             from: plistDecoder)
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        if responses[1].isFailedDependancy {  self.workspaceSettings = [:] }
        else if case XcodeFileSystemProviderActionResponse.data(let dta, for: _) = responses[1] {
            self.workspaceSettings = try CodableHelpers.dictionaries.decode(dta,
                                                                            from: plistDecoder)
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        
        self.schemes = try XCSchemes(from: url.appendingDirComponent(XCSchemes.SCHEMES_FOLDER),
                                     usingFSProvider: provider)
        super.init()
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
        
        let encoder = PListEncoder()
        
        if self.hasIDEWorkspaceChecksChagned || overrideChangeCheck {
            let ideWorkspaceChecksURL = url.appendingFileComponent(XCSharedData.IDE_WORKSPACE_CHECKS_FILE_NAME)
            var action: XcodeFileSystemProviderAction!
            if self.ideWorkspaceChecks.count > 0 {
                let dta = try CodableHelpers.dictionaries.encode(self.ideWorkspaceChecks, to: encoder)
                action = .write(data: dta, to: ideWorkspaceChecksURL, writeOptions: .atomic)
            } else {
                action = .removeIfExists(item: ideWorkspaceChecksURL)
            }
            
            action = action.withCallback {
                (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
                if err == nil {
                    self.hasIDEWorkspaceChecksChagned  = false
                }
            }
            
            rtn.append(action)
        }
        
        if self.hasWorkspaceSettingsChanged || overrideChangeCheck {
            let workspaceSettingsURL = url.appendingFileComponent(XCSharedData.WORKSPACE_SETTINGS_FILE_NAME)
            var action: XcodeFileSystemProviderAction!
            if self.workspaceSettings.count > 0 {
                let dta = try CodableHelpers.dictionaries.encode(self.workspaceSettings, to: encoder)
                action = .write(data: dta, to: workspaceSettingsURL, writeOptions: .atomic)
            } else {
                action = .removeIfExists(item: workspaceSettingsURL)
            }
            
            action = action.withCallback {
                (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
                if err == nil {
                    self.hasWorkspaceSettingsChanged  = false
                }
            }
            
            rtn.append(action)
        }
        
        let schemeActions = try self.schemes.saveActions(to: url.appendingDirComponent(XCSchemes.SCHEMES_FOLDER),
                                                         overrideChangeCheck: overrideChangeCheck)
        
        rtn.append(contentsOf: schemeActions)
        
        return rtn
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
        
        let actions = try self.saveActions(to: url,
                                           overrideChangeCheck: overrideChangeCheck)
        guard actions.count > 0 else { return }
        
        try provider.actions(actions)
    
    }
}
