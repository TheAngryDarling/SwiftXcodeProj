//
//  XcodeObject.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation

/// The base class for all Xcode Project Objects
public class XcodeObject {
    /// The Xcode project this object belongs to
    internal let project: XcodeProject
    internal init(_ project: XcodeProject) { self.project = project }
}
