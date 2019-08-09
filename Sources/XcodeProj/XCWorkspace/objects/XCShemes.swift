//
//  XCShemes.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation
import CodableHelpers

fileprivate extension String {
    func regexEscape() -> String {
        let regExEscapeCharacters: [String] = ["[", "]", "\\", "^", "$", ".", "|", "?", "*", "+", "(", ")", "{", "}"]
        var rtn: String = self
        for esc in regExEscapeCharacters {
            rtn = rtn.replacingOccurrences(of: esc, with: "\\" + esc)
        }
        return rtn
    }
}

public final class XCSchemes {
    
    public static let SCHEMES_FOLDER: String = "xcschemes"
    private static let MANAGEMENT_SETTINGS_FILE: String = "xcschememanagement.plist"
    private static let SCHEME_FILE_EXT: String = "xcscheme"
    
    private var hasManagementChanged: Bool = false
    public var management: [String: Any] {
        didSet { self.hasManagementChanged = true }
    }
    private var hasProjectSchemesChanged: Bool = false
    public private(set) var projectSchemes: [String: XCScheme] {
        didSet { self.hasProjectSchemesChanged = true }
    }
    
    
    /// Create new empty instance of an empty Scheme List
    public init() {
        self.hasManagementChanged = true
        self.management = [:]
        self.projectSchemes = [:]
        self.hasProjectSchemesChanged = true
    }
    
    /// Create new insatance of a Scheme List
    ///
    /// - Parameters:
    ///   - url: The url to the scheme list
    ///   - provider: The file system to use
    public init(from url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        let managementURL = url.appendingFileComponent(XCSchemes.MANAGEMENT_SETTINGS_FILE)
        
        var actions: [XcodeFileSystemProviderAction] = []
        actions.append(.dataIfExists(for: managementURL))
        
        actions.append(XcodeFileSystemProviderAction.directoryDataContents(from: url,
                                              readOptions: [],
                                              withRegExFilter: (pattern: "\\.\(XCSchemes.SCHEME_FILE_EXT)$",
                                                                patternOptions: NSRegularExpression.Options.caseInsensitive,
                                                                matchingOptions: [])).withDependencies(.exists(item: url)))
        
        let responses = try provider.actions(actions)
        if responses[0].isFailedDependancy { self.management = [:] }
        else if case XcodeFileSystemProviderActionResponse.data(let dta, for: _) = responses[0] {
            let coder = PListDecoder()
            self.management = try CodableHelpers.dictionaries.decode(dta, from: coder)
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        if responses[1].isFailedDependancy { self.projectSchemes = [:] }
        else if case XcodeFileSystemProviderActionResponse.directoryDataContents(let children, for: _) = responses[1] {
            var schemes: [String: XCScheme] = [:]
            
            for child in children {
                let schemeName = NSString(string: child.resource.lastPathComponent).deletingPathExtension
                schemes[schemeName] = try XCScheme(fromData: child.data)
            }
            
            self.projectSchemes = schemes
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
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
        
        if self.hasManagementChanged || overrideChangeCheck {
            let managementURL = url.appendingFileComponent(XCSchemes.MANAGEMENT_SETTINGS_FILE)
            var action: XcodeFileSystemProviderAction!
            if self.management.count > 0 {
                let encoder = PListEncoder()
                let dta = try CodableHelpers.dictionaries.encode(self.management, to: encoder)
                //try dta.write(to: managementURL, options: .atomic)
                action = .write(data: dta, to: managementURL, writeOptions: .atomic)
            } else {
                //try? FileManager.default.removeItem(at: managementURL)
                action = .remove(item: managementURL)
            }
            
            action = action.withCallback {
                (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
                if err == nil {
                    self.hasManagementChanged = false
                }
            }
            
            rtn.append(action)
            
            
        }
        
        if self.hasProjectSchemesChanged || overrideChangeCheck {
            
            var pattern: String = "^"
            
            
            for user in self.projectSchemes.keys {
                
                let fileName = user + "." + XCSchemes.SCHEME_FILE_EXT
                 pattern += "(?!\(fileName.regexEscape())$)"
                
            }
            
            pattern += ".+\\.\(XCSchemes.SCHEME_FILE_EXT.regexEscape())$"
            
            var removeAction: XcodeFileSystemProviderAction = .directoryRemoveContents(from: url,
                                                                                       ofType: .file,
                                                                                       withRegExFilter: (pattern: pattern,
                                                                                                         patternOptions: NSRegularExpression.Options.caseInsensitive,
                                                                                                         matchingOptions: []))
            
            removeAction = removeAction.withCallback {
                (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
                self.hasProjectSchemesChanged = false
            }
            
            rtn.append(removeAction)
            
        }
        
        
        for (k,v) in self.projectSchemes {
            let childURL = url.appendingFileComponent(k + "." + XCSchemes.SCHEME_FILE_EXT)
            if let action =  try v.saveAction(to: childURL, overrideChangeCheck: overrideChangeCheck) {
                rtn.append(action)
            }
        }
        
        
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
        try provider.actions(actions)
        
    }
}

extension XCSchemes: CustomDebugStringConvertible {
    public var debugDescription: String {
        var rtn: String = "XCSchemes["
        for (i, scheme) in self.projectSchemes.keys.enumerated() {
            if i > 0 { rtn += ", " }
            rtn += "\(scheme): \(self.projectSchemes[scheme]!)"
        }
        rtn += "]"
        return rtn
    }
}
