//
//  XcodeResource.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation
import PBXProj
import LeveledCustomStringConvertible

/// The base class for all Xcode File Resources (Groups, Files, etc)
public class XcodeResource: XcodeObject, LeveledCustomStringConvertible, LeveledCustomDebugStringConvertible {
    /// The PBX object reference
    internal var pbxFileResource: PBXFileElement
    /// The name of the resource
    ///
    /// This will get the PBX name if one exists OR get the last component of the PBX path and if all else fails will reuturn empty string
    public var name: String {
        get {
            if let r = self.pbxFileResource.name { return r }
            else if let p = self.pbxFileResource.path, !p.isEmpty { return String(p.split(separator: "/").last!) }
            else { return "" }
            
        }
        set {
            if newValue == "" {
                self.pbxFileResource.name = nil
                self.pbxFileResource.path = nil
            }
            else if self.pbxFileResource.name != nil { self.pbxFileResource.name = newValue }
            else if let p = self.pbxFileResource.path {
                if newValue.contains("/") { self.pbxFileResource.path = newValue }
                else {
                    //Patch the new name onto the path
                    self.pbxFileResource.path = String(p.split(separator: "/").dropLast().joined(separator: "/").dropFirst()) + "/" + newValue
                }
            }
            else if newValue.contains("/") { self.pbxFileResource.path = newValue }
            else { self.pbxFileResource.name = newValue }
        }
    }
    
    /// Gets the PBX path of the resource
    public var path: String? {
        get { return self.pbxFileResource.path }
        set { self.pbxFileResource.path = newValue }
    }
    
    /// The built path
    ///
    /// from either self.path or self.parent.fullPath + "/" + self.name
    public var fullPath: String { return self.pbxFileResource.fullPath }
    
    public var description: String { return leveledDescription() }
    
    internal init(_ project: XcodeProject, _ resource: PBXFileElement) {
        self.pbxFileResource = resource
        super.init(project)
    }
    
    public func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
         var rtn: String = ""
        if indentOpening { rtn += String(repeating: indent, count: level) }
        rtn += "\(self.pbxFileResource.id): " + self.name + "(\(self.fullPath))"
        
        if let f = self as? XcodeFile {
            if let ft = f.lastKnownFileType {
                rtn += " (\(ft))"
            } else if let ft = f.explicitFileType {
                rtn += " (\(ft))"
            }
        }
        
        rtn += ": {\(type(of: self))}"
        
        return rtn
        
        
    }
    
    public func leveledDebugDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        return leveledDescription(level, indent: indent, indentOpening: indentOpening, sortKeys: sortKeys)
    }
}

extension XcodeResource: Equatable {
    public static func == (lhs: XcodeResource, rhs: XcodeResource) -> Bool {
        return lhs.pbxFileResource.id == rhs.pbxFileResource.id
    }
}


