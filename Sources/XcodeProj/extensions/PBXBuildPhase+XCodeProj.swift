//
//  PBXBuildPhase+XcodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-07-10.
//

import Foundation
import PBXProj


public extension PBXBuildPhase {
    /// Creates a build file for the given Xcode file in the current build phase
    ///
    /// - Parameters:
    ///   - file: The Xcode file to create a build file for
    ///   - settings: Any settings for the build file
    /// - Returns: Returns a newly created build file
    @discardableResult
    func createBuildFile(for file: XcodeFile,
                         withSettings settings: [String: Any] = [:]) -> PBXBuildFile {
        
        return self.createBuildFile(for: file.pbxFileReference, withSettings: settings)
    }
    
    /// Removes the build file for the given XcodeFile
    /// - Parameter file: The file to remove from the build phase
    /// - Returns: Returns true if the file was removed, otherwise false
    @discardableResult
    func removeBuildFile(for file: XcodeFile) -> Bool {
        return self.removeBuildFile(for: file.pbxFileReference)
    }
}
