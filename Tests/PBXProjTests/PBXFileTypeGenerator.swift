//
//  PBXFileTypeGenerator.swift
//  PBXProjTests
//
//  Created by Tyler Anger on 2019-05-08.
//

import XCTest
import CustomCoders

fileprivate extension FileManager {
    func directoryExists(atPath path: String) -> Bool {
        var rtn: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &rtn) else { return false }
        #if _runtime(_ObjC) || swift(>=4.1)
        return rtn.boolValue
        #else
        return rtn
        #endif
    }
    func directoryExists(at url: URL) -> Bool {
        return directoryExists(atPath: url.path)
    }
}

class PBXFileTypeGenerator: XCTestCase {
    
    struct FileTypeDef: Decodable {
        enum CodingKeys: String, CodingKey {
            case identifier = "Identifier"
            case basedOn = "BasedOn"
            case extensions = "Extensions"
        }
        
        let identifier: String
        let basedOn: String
        let extensions: [String]
        
        
        let group: String
        let varIdentifier: String
        
        
        
        private static let IDENTIFIER_VAR_IDENTIFIER_OVERRIDES: [String: String] = [
            "sourcecode.swift": "source",
            //"sourcecode.c.c": "source",
            "sourcecode.cpp.h": "header",
            "sourcecode.c.objc": "source",
            "sourcecode.c.h": "header",
            "sourcecode.c": "source",
            "sourcecode.cpp.cpp": "cpp",
            "sourcecode.cpp": "source",
            "sourcecode.asm": "source",
            "sourcecode.c.c.preprocessed": "preprocessedSource",
            "sourcecode.c.objc.preprocessed": "preprocessedSource",
            "sourcecode.cpp.objcpp.preprocessed": "cppPreprocessedSource",
            "sourcecode.cpp.objcpp": "cppSource",
            "sourcecode.cpp.cpp.preprocessed": "preprocessedSource",
            "text": "plainText",
        ]
        
        private static let IDENTIFIER_GROUP_OVERRIDES: [String: String] = [
            "net.daringfireball.markdown": "text",
            "sourcecode.asm.llvm": "sourcecode.asm",
            "sourcecode.nasm": "sourcecode.asm",
            "sourcecode.swift": "sourcecode.swift",
            "sourcecode.c": "sourcecode.c",
            "sourcecode.c.objc": "sourcecode.objc",
            "sourcecode.asm": "sourcecode.asm",
            "sourcecode.applescript": "text.scripts",
            "sourcecode.javascript": "text.scripts",
            "sourcecode.cpp": "sourcecode.cpp",
            "text.plist.info": "text.plist",
            "text": "text",
        ]
        private static let BASED_ON_GROUP_OVERRIDES: [String: String] = [
            "wrapper.cfbundle": "wrapper",
            "wrapper.framework": "wrapper",
            "wrapper.pb-project": "wrapper",
            "wrapper.plug-in": "wrapper",
            "wrapper.xpc-service": "wrapper",
            "folder.abstractassetcatalog": "folder",
            "folder.assetcatalog": "folder",
            "archive.zip": "archive",
            "archive.rsrc": "archive",
            "archive.jar": "archive",
            "sourcecode.c": "sourcecode.c",
            "sourcecode.c.c": "sourcecode.c",
            "sourcecode.cpp.cpp": "sourcecode.cpp",
            "sourcecode.cpp.objcpp": "sourcecode.cpp",
            "sourcecode.c.objc": "sourcecode.objc",
            "text.script": "text.scripts",
        ]
        
        private static let VAR_KEY_WORDS: [String] = [ "static", "default"]
        
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.identifier = try container.decode(String.self, forKey: .identifier)
            self.basedOn = (try container.decodeIfPresent(String.self, forKey: .basedOn)) ?? ""
            self.extensions = (try container.decodeIfPresent([String].self, forKey: .extensions)) ?? []
            
            var bO = self.basedOn
            if let b = FileTypeDef.IDENTIFIER_GROUP_OVERRIDES[self.identifier] { bO = b }
            else if let b = FileTypeDef.BASED_ON_GROUP_OVERRIDES[bO] { bO = b }
            self.group = bO
            
            if let vI = FileTypeDef.IDENTIFIER_VAR_IDENTIFIER_OVERRIDES[self.identifier] { self.varIdentifier = vI }
            else {
                var varIdent = self.identifier
                if varIdent.hasPrefix(self.basedOn + ".") {
                    varIdent.removeFirst(self.basedOn.count + 1)
                } else if varIdent.hasPrefix(self.group + ".") {
                    varIdent.removeFirst(self.group.count + 1)
                }
                
                if !varIdent.isEmpty {
                
                    let str = varIdent.replacingOccurrences(of: "-", with: ".")
                    var components = str.split(separator: ".").map(String.init)
                    if components.count > 1 {
                        for i in 1..<components.count {
                            components[i] = components[i].capitalized
                        }
                    }
                    varIdent =  components.joined()
                }
                
                if FileTypeDef.VAR_KEY_WORDS.contains(varIdent) {
                    varIdent = "`\(varIdent)`"
                }
                
                self.varIdentifier = varIdent
            }
            
        }
        
    }
    
    
    class FileTypeGroup {
        let group: String
        var subGroups: [FileTypeGroup]
        var subItems: [FileTypeDef]
        
        
        var allSubItems: [FileTypeDef] {
            var rtn: [FileTypeDef] = self.subItems
            
            for g in self.subGroups {
                rtn.append(contentsOf: g.allSubItems)
            }
            
            return rtn.sorted(by: { return ($0.identifier < $1.identifier) })
        }
        
        var groupClassName: String {
            if group.isEmpty { return "Defined" }
            else if group == "sourcecode" { return "SourceCode" }
            else if group == "objc" { return "ObjectiveC" }
            else if group == "cpp" { return "CPP" }
            else if group == "asm" { return "Assembly" }
            else if group == "plist" { return "PropertyList" }
            else {
                let str = group.replacingOccurrences(of: "-", with: ".")
                var components = str.split(separator: ".").map(String.init)
                for i in 0..<components.count {
                    components[i] = components[i].capitalized
                }
                return components.joined()
            }
        }
        
        var count: Int {
            var rtn: Int = self.subItems.count
            for g in self.subGroups { rtn += g.count }
            return rtn
        }
        
        var itemCount: Int {
            var rtn: Int = self.subItems.count
            for g in self.subGroups { rtn += g.itemCount }
            return rtn
        }
        
        public init() {
            self.group = ""
            self.subGroups = []
            self.subItems = []
        }
        
        private init(_ group: String) {
            self.group = group
            self.subGroups = []
            self.subItems = []
        }
        
        public func add(_ type: FileTypeDef) {
            let groupPathComponents = type.group.split(separator: ".").map(String.init)
            self._add(groupPathComponents, type)
        }
        
        private func _add(_ pathComponents:[String], _ type: FileTypeDef) {
            var groupPathComponents = pathComponents
            if groupPathComponents.count == 0 {
                subItems.append(type)
            } else {
                var subGroup: FileTypeGroup! = subGroups.first(where: {$0.group == groupPathComponents[0] })
                if subGroup == nil {
                    let s = FileTypeGroup(groupPathComponents[0])
                    self.subGroups.append(s)
                    subGroup = s
                }
                
                groupPathComponents.removeFirst()
                subGroup._add(groupPathComponents, type)
                
            }
        }
        
        public func generateDefinedTypesSource(_ tabCount: Int, tab: String) -> String {
            var tbCnt = tabCount
            if self.group.isEmpty && tbCnt > 0 { tbCnt -= 1 }
            let tabs = String(repeating: tab, count: tbCnt)
            
            var rtn: String = ""
            
            if !self.group.isEmpty {
                rtn = tabs + "public struct \(self.groupClassName) { \n"
                rtn += tabs + tab + "private init() {} \n\n"
            }
            
            if self.group != "sourcecode" {
                for t in self.subItems.sorted(by: { return ($0.varIdentifier < $1.varIdentifier) }) {
                    rtn += tabs + tab + "public static let \(t.varIdentifier): PBXFileType = \"\(t.identifier)\" // parent: \(t.basedOn) \n"
                }
                if self.subItems.count > 0 && self.subGroups.count > 0 {
                    rtn += "\n"
                }
            }
            
            for g in self.subGroups.sorted(by: { return ($0.groupClassName < $1.groupClassName) }) {
                rtn += g.generateDefinedTypesSource(tbCnt + 1, tab: tab)
            }
            
            if self.group == "sourcecode" {
                let g = FileTypeGroup("various")
                g.subItems.append(contentsOf: self.subItems)
                rtn += g.generateDefinedTypesSource(tbCnt + 1, tab: tab)
            }
            
            if !self.group.isEmpty {
                rtn += tabs + "}\n"
            }
            
            return rtn
        }
    }
    
    static let packageRootPath: String = String(URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst())
    
    static let testPackageRootPath: String = packageRootPath + "/Tests"
    static let testPackagePath: String = String(URL(fileURLWithPath: #file).pathComponents.dropLast().joined(separator: "/").dropFirst())
    static let testPackageResourcePath: String = testPackageRootPath + "/resources"
    static let testPackageResourceTestProjectPath: String = testPackageResourcePath + "/test_proj"

    func testGenerateFileTypesCode() {
        
        
        do {
            
            
            let fileTypeDefinitionFolder = URL(fileURLWithPath: PBXProjTests.testPackageResourcePath + "/pbx_filetype_definitions", isDirectory: true)
            
            let children = try FileManager.default.contentsOfDirectory(atPath: fileTypeDefinitionFolder.path).map { return fileTypeDefinitionFolder.appendingPathComponent($0) }
            
            
            let definitions = FileTypeGroup()
            
            let decoder = PListDecoder()
            for c in children {
                
                if c.pathExtension == "xcspec" {
                    let d = try decoder.decode(FileTypeDef.self, from: try Data(contentsOf: c))
                    definitions.add(d)
                }
                
            }
            
            var sourceCode: String = """

            //
            //  PBXFileType.swift
            //  XCodeProj
            //
            //  Created by Tyler Anger on 2018-12-03.
            //

            import Foundation

            public protocol PBXFileTypeDetails {
                var identifier: String { get }
                var defaultExtension: String? { get }
                var allExtensions: [String] { get }
                var isCodeFile: Bool { get }
            }
            
            public struct PBXFileType {
                private let rawValue: String
                public init(_ rawValue: String) { self.rawValue = rawValue }\n\n

                private struct FileTypeDetails: PBXFileTypeDetails {
                    let identifier: String
                    let allExtensions: [String]
                    let isCodeFile: Bool

                    var defaultExtension: String? { return self.allExtensions.first }

                }

                private static var fileTypeDetails: [String: FileTypeDetails] = [

            """
            
            let allDefinitions = definitions.allSubItems
            
            for d in allDefinitions {
                
                sourceCode += "         \"\(d.identifier)\": FileTypeDetails(identifier: \"\(d.identifier)\", allExtensions: \(d.extensions), isCodeFile: \(d.identifier.hasPrefix("sourcecode"))),\n"
                
            }
            
            sourceCode += "     ]\n\n"
            
            sourceCode += """
                private struct FileDetailsOverrideMethod {
                    let id: String
                    let method: (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?
                    public init(_ method: @escaping (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?) {
                        self.id = UUID.init().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
                        self.method = method
                    }
                }
            
                private static var overrideFilelTypeDetailsFunc: [FileDetailsOverrideMethod] = []
            
                @discardableResult
                public static func registerOverrideFileTypeDetalisMethod(_ method: @escaping (_ identifier: String?, _ ext: String?)->PBXFileTypeDetails?) -> String {
                    let s = FileDetailsOverrideMethod(method)
                    overrideFilelTypeDetailsFunc.append(s)
                    return s.id
                }
            
                @discardableResult
                public static func unregisterOverrideFileTypeDetailsMethod(withId id: String) -> Bool {
                    if let idx = overrideFilelTypeDetailsFunc.firstIndex(where: { $0.id == id } ) {
                        overrideFilelTypeDetailsFunc.remove(at: idx)
                        return true
                    }
                    return false
                }
            
            
                private static func getfileTypeDetails(for identifier: String) -> PBXFileTypeDetails? {
                    for o in overrideFilelTypeDetailsFunc {
                        if let r = o.method(identifier, nil) { return r }
                    }
                    return getLocalFileTypeDetails(for: identifier)
                }
            
                public static func getLocalFileTypeDetails(for identifier: String) -> PBXFileTypeDetails? {
                     return PBXFileType.fileTypeDetails[identifier]
                }
            
                public static func fileType(forExt ext: String) -> PBXFileType? {
                    for o in overrideFilelTypeDetailsFunc {
                        if let r = o.method(nil, ext) { return PBXFileType(r.identifier) }
                    }
                    return localFileType(forExt: ext)
                }
            
                public static func localFileType(forExt ext: String) -> PBXFileType? {
                    for (k,v) in fileTypeDetails {
                        if v.allExtensions.contains(ext) { return PBXFileType(k) }
                    }
                    return nil
                }
            
                public var defaultExtension: String? {
                    return PBXFileType.getfileTypeDetails(for: self.rawValue)?.defaultExtension
                }
                public var allExtension: [String] {
                    return PBXFileType.getfileTypeDetails(for: self.rawValue)?.allExtensions ?? []
                }
                public var isCodeFile: Bool {
                    return PBXFileType.getfileTypeDetails(for: self.rawValue)?.isCodeFile ?? false
                }
            
            
            """
            
            if definitions.count > 0 {
                
                sourceCode += definitions.generateDefinedTypesSource(1, tab: "    ")
                
            }
            
            sourceCode += "}"
            
            
            sourceCode += """
            
            extension PBXFileType: CustomStringConvertible {
                public var description: String { return self.rawValue }
            }
            
            extension PBXFileType: Codable {
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(self.rawValue)
                }
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(String.self)
                    self.init(rawValue)
                }
            }
            
            extension PBXFileType: Equatable {
                public static func ==(lhs: PBXFileType, rhs: PBXFileType) -> Bool {
                    return lhs.rawValue == rhs.rawValue
                }
                public static func ==(lhs: PBXFileType, rhs: String) -> Bool {
                    return lhs.rawValue == rhs
                }
                public static func ==(lhs: String, rhs: PBXFileType) -> Bool {
                    return lhs == rhs.rawValue
                }
            }
            extension PBXFileType: ExpressibleByStringLiteral {
                public init(stringLiteral value: String) {
                    self.init(value)
                }
            }
            
            extension PBXFileType: Hashable {
                #if !swift(>=4.1)
                public var hashValue: Int { return self.rawValue.hashValue }
                #endif
            }
            """
            
            print(sourceCode)
            
            
        } catch {
            XCTFail("\(error)")
        }
        
        
    }

}
