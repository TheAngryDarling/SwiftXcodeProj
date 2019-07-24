//
//  XcodeTargetDependancy.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-07-07.
//

import Foundation
import PBXProj

/// An Xcode Target Dependency
public class XcodeTargetDependency: XcodeObject {
    internal let pbxTargetDependancy: PBXTargetDependency
    
    /// The dependency target name
    var name: String { return self.pbxTargetDependancy.target.name }
    
    /// Crete a new Xcode Target Dependency
    ///
    /// - Parameters:
    ///   - project: The Xcode Project this dependency belongs to
    ///   - dependancy: The PBX Project File dependency
    internal init(_  project: XcodeProject, _ dependancy: PBXTargetDependency) {
        self.pbxTargetDependancy = dependancy
        super.init(project)
    }
}
