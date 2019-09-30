//
//  XCDebugger.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation
import RawRepresentableHelpers


 /// The debugging package where debugging data is stored
public class XCDebugger: NSObject {
    
    /// the debugging package folder name
    public static let DEBUGGER_FOLDER_NAME: String = "xcdebugger"
    /// The breakpoint file name
    private static let BreakpointsFileName: String = "Breakpoints_v2.xcbkptlist"
    
    /// The breakpoints within the project
    let breakpoints: Breakpoints
    
    /// Create a new debugging package
    public override init() {
        self.breakpoints = Breakpoints()
        super.init()
    }
    
    /// Load a debugging package from the given path
    ///
    /// - Parameters:
    ///   - url: The path to the debugging package folder
    ///   - provider: The filesystem provider to used to load the package
    public init(from url: XcodeFileSystemURLResource, usingFSProvider provider: XcodeFileSystemProvider) throws {
        
        self.breakpoints = try Breakpoints(fromURL: url.appendingFileComponent(XCDebugger.BreakpointsFileName),
                                           usingFSProvider: provider)
        super.init()
        
    }
    
    /// Get any save actions that are currently needed
    ///
    /// - Parameters:
    ///   - url: The url to the debugging package folder
    ///   - overrideChangeCheck: An indicator if has changed flags should be ignoed (Default: false)
    /// - Returns: Returns an array of save actions
    public func saveActions(to url: XcodeFileSystemURLResource, overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
        //guard self.hasInfoChanged || overrideChangeCheck else { return nil }
        var rtn: [XcodeFileSystemProviderAction] = []
        
        if let a = try self.breakpoints.saveAction(to: url.appendingFileComponent(XCDebugger.BreakpointsFileName),
                                                   overrideChangeCheck: overrideChangeCheck) {
            rtn.append(a)
        }
        
        return rtn
    }
    
    /// Save the debugging action
    ///
    /// - Parameters:
    ///   - url: The url to the debugging package folder
    ///   - provider: The filesystem provider to used to load the package
    ///   - overrideChangeCheck: An indicator if has changed flags should be ignoed (Default: false)
    public func save(to url: XcodeFileSystemURLResource,
                     usingFSProvider provider: XcodeFileSystemProvider,
                     overrideChangeCheck: Bool = false) throws {
        
        try provider.actions(try self.saveActions(to: url, overrideChangeCheck: overrideChangeCheck))
        
    }
    
    
}

