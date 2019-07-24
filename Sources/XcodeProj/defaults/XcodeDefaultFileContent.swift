//
//  XcodeDefaultFileContent.swift
//  CodableHelpers
//
//  Created by Tyler Anger on 2019-05-19.
//

import Foundation
import PBXProj

public extension PBXFileType.SourceCode.Swift {
    static var main: XcodeFile.FileType { return XcodeFile.FileType("sourcecode.swift.main") }
}
public extension PBXFileType.SourceCode.ObjectiveC {
    static var main: XcodeFile.FileType { return XcodeFile.FileType("sourcecode.c.objc.main") }
}

/// Generates different default file content
public final class XcodeDefaultFileContent {
    public typealias FileContentProvider = (_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data
    
    /// List of pre-defined default file content generators
    private static var DEFAULT_CONTENT: [XcodeFile.FileType: FileContentProvider] = [
        XcodeFile.FileType.SourceCode.Swift.source: newSwiftFile,
        XcodeFile.FileType.SourceCode.Swift.main: newSwiftMainFile,
        XcodeFile.FileType.SourceCode.C.header: newHeaderFile,
        XcodeFile.FileType.SourceCode.C.source: newCFile,
        XcodeFile.FileType.SourceCode.CPP.header: newHeaderFile,
        XcodeFile.FileType.SourceCode.CPP.source: newCFile,
        XcodeFile.FileType.SourceCode.ObjectiveC.main: newObjCMainFile,
        
    ]
    
    /// Register custom file content generator
    private static var CUSTOM_CONTENT: [XcodeFile.FileType: FileContentProvider] = [:]
    
    
    /// Register a new file content generator
    public static func registerCustomContentProvider(for type: XcodeFile.FileType,
                                                     provider: @escaping FileContentProvider) {
        CUSTOM_CONTENT[type] = provider
    }
    /// Unregister a registered file content generator
    public static func unregisterCustomContentProvider(for type: XcodeFile.FileType) {
        CUSTOM_CONTENT.removeValue(forKey: type)
    }
    
    /// Get the default content for a specific fil type
    public static func getContentFor(fileType type: XcodeFile.FileType,
                                     withName name: String,
                                     forUser userName: String? = nil,
                                     havingMembership membership: [XcodeTarget],
                                     inProject project: XcodeProject,
                                     additionalDetails: [String: Any] = [:]) -> Data? {
        
        if let f = CUSTOM_CONTENT[type] {
            return f(name, userName, project, membership, additionalDetails)
        } else if let f = DEFAULT_CONTENT[type] {
            return f(name, userName, project, membership, additionalDetails)
        } else {
            return nil
        }
        
    }
    
    /// Get the default content for a specific fil type
    public static func getContentFor(fileType type: XcodeFile.FileType,
                                     withName name: String,
                                     forUser userName: String? = nil,
                                     havingMembership membership: XcodeTarget,
                                     inProject project: XcodeProject,
                                     additionalDetails: [String: Any] = [:]) -> Data? {
        
        return self.getContentFor(fileType: type,
                                  withName: name,
                                    forUser: userName,
                                    havingMembership: [membership],
                                    inProject: project,
                                    additionalDetails: additionalDetails)
    }
    
    /// Generate new Swift file
    private static func newSwiftFile(_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data {
        var rtn: String = "///\n"
        rtn += "/// " + name + "\n"
        if let target = targets.first {
            rtn += "/// " + target.name + "\n"
        }
        rtn += "///\n"
        rtn += "/// Created "
        if let uName = userName { rtn += "by \(uName) " }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        rtn += "on \(format.string(from: Date()))\n"
        rtn += "///\n\n"
        rtn += "import Foundation\n\n"
        
        return rtn.data(using: .utf8)!
    }
    /// Generate Swift main file
    private static func newSwiftMainFile(_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data {
        
        var rtn: String = "///\n"
        rtn += "/// " + name + "\n"
        if let target = targets.first {
            rtn += "/// " + target.name + "\n"
        }
        rtn += "///\n"
        rtn += "/// Created "
        if let uName = userName { rtn += "by \(uName) " }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        rtn += "on \(format.string(from: Date()))\n"
        format.dateFormat = "yyyy"
        rtn += "/// Copyright © \(format.string(from: Date()))"
        if let uName = userName { rtn += " \(uName)" }
        rtn += ". All rights reserved.\n"
        rtn += "///\n\n"
        rtn += "import Foundation\n\n"
        rtn += "print(\"Hello, World!\")\n"
        
        return rtn.data(using: .utf8)!
    }
    
    /// Generate new header file
    private static func newHeaderFile(_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data {
        var rtn: String = "///\n"
        rtn += "/// " + name + "\n"
        if let target = targets.first {
            rtn += "/// " + target.name + "\n"
        }
        rtn += "///\n"
        rtn += "/// Created "
        if let uName = userName { rtn += "by \(uName) " }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        rtn += "on \(format.string(from: Date()))\n"
        rtn += "///\n"
        rtn += "\n"
        rtn += "#ifndef \(name.replacingOccurrences(of: ".", with: "_"))\n"
        rtn += "#define \(name.replacingOccurrences(of: ".", with: "_"))\n"
        rtn += "\n"
        if let _ = additionalDetails["INCLUDE_STDIN"] {
            rtn += "#include <stdio.h>\n\n"
        }
        rtn += "#endif /* \(name.replacingOccurrences(of: ".", with: "_")) */\n"
        
        return rtn.data(using: .utf8)!
    }
    
    /// Generate new C file
    private static func newCFile(_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data {
        var rtn: String = "///\n"
        rtn += "/// " + name + "\n"
        if let target = targets.first {
            rtn += "/// " + target.name + "\n"
        }
        rtn += "///\n"
        rtn += "/// Created "
        if let uName = userName { rtn += "by \(uName) " }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        rtn += "on \(format.string(from: Date()))\n"
        rtn += "///\n\n"
        if let headerName = additionalDetails["INCLUDE_HEADER"] {
            rtn += "#include \"\(headerName)\"\n\n"
        }
       
        
        return rtn.data(using: .utf8)!
    }
    
    /// Generate Objective C main file
    private static func newObjCMainFile(_ name: String, _ userName: String?, _ project: XcodeProject, _ targets: [XcodeTarget], _ additionalDetails: [String: Any]) -> Data {
        var rtn: String = "///\n"
        rtn += "/// " + name + "\n"
        if let target = targets.first {
            rtn += "/// " + target.name + "\n"
        }
        rtn += "///\n"
        rtn += "/// Created "
        if let uName = userName { rtn += "by \(uName) " }
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        rtn += "on \(format.string(from: Date()))\n"
        format.dateFormat = "yyyy"
        rtn += "///  Copyright © \(format.string(from: Date()))"
        if let uName = userName { rtn += " \(uName)" }
        rtn += ". All rights reserved.\n"
        rtn += "///\n"
        rtn += "\n"
        rtn += "#import <Foundation/Foundation.h>\n"
        rtn += "\n"
        rtn += "int main(int argc, const char * argv[]) {\n"
        rtn += "    @autoreleasepool {\n"
        rtn += "        // insert code here...\n"
        rtn += "        NSLog(@\"Hello, World!\");\n"
        rtn += "    }\n"
        rtn += "    return 0;\n"
        rtn += "}\n"
        return rtn.data(using: .utf8)!
    }
    
}
