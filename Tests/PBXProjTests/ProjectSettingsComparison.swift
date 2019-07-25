//
//  ProjectSettingsComparison.swift
//  PBXProjTests
//
//  Created by Tyler Anger on 2019-06-24.
//

import XCTest
@testable import PBXProj
import CodableHelpers

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

fileprivate extension Dictionary where Key == String, Value == Any {
    
    func intersection(_ dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = Dictionary<Key, Value>()
        
        for (k,v) in self {
            guard let rV = dictionary[k] else {
                continue
            }
            if "\(v)" == "\(rV)" {
                rtn[k] = v
            }
        }
        
        return rtn
    }
    
    func symmetricDifference(_ dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = Dictionary<Key, Value>()
        
        for (k,v) in self {
            if dictionary[k] == nil { rtn[k] = v }
        }
        
        for (k,v) in dictionary {
            if self[k] == nil { rtn[k] = v }
        }
        
        return rtn
    }
    
    func removingValues(forKeys keys: Key...) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = self
        for key in keys {
            rtn.removeValue(forKey: key)
        }
        
        return rtn
    }
    
    func replacing(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = self
        if rtn.keys.contains(key) { rtn[key] = value }
        
        return rtn
    }
    
    func setting(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var rtn: Dictionary<Key, Value> = self
        rtn[key] = value
        return rtn
    }
}

public class ProjectSettingsComparison: XCTestCase {
    let XCODE_PROJECT_EXT: String = "xcodeproj"
    
    let PBX_PROJECT_FILE_NAME: String = "project.pbxproj"
    
    //fileprivate let packageTestRootPath = URL(fileURLWithPath: #file).deletingLastPathComponent().pathComponents.joined(separator: "/").dropFirst()
    static let packageRootPath: String = String(URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst())
    
    static let testPackageRootPath: String = packageRootPath + "/Tests"
    static let testPackagePath: String = String(URL(fileURLWithPath: #file).pathComponents.dropLast().joined(separator: "/").dropFirst())
    static let testPackageResourcePath: String = testPackageRootPath + "/resources"
    static let testPackageResourceTestProjectPath: String = testPackageResourcePath + "/test_proj"
    
    enum Projects {
        enum Swift: String {
            enum PM: String {
                case exe = "/swift/SwiftPMExe/SwiftPMExe.xcodeproj"
                case library = "/swift/SwiftPMLib/SwiftPMLib.xcodeproj"
                case sysMod = "/swift/SwiftPMSysMod/SwiftPMSysMod.xcodeproj"
            }
            
            enum Mac: String {
                case macCocoaApp = "/swift/MacCocoaApp/MacCocoaApp.xcodeproj"
                case macCocoaFramework = "/swift/MacCocoaFramework/MacCocoaFramework.xcodeproj"
                case macCommandLine = "/swift/MacCommandLine/MacCommandLine.xcodeproj"
                case macGame = "/swift/MacGame/MacGame.xcodeproj"
                case macSafariExtApp = "/swift/MacSafariExtApp/MacSafariExtApp.xcodeproj"
            }
            
            case crossplatformGame = "/swift/CrossplatformGame/CrossplatformGame.xcodeproj"
        }
        
        enum Other: String {
            /*enum Mac: String {
                
            }*/
            case emptyProj = "/other/EmptyProj/EmptyProj.xcodeproj"
            case crossPlatformInAppPurchaseContent = "/other/CrossPlatformInAppPurchaseContent/CrossPlatformInAppPurchaseContent.xcodeproj"
            case crossPlatformExternalBuild = "/other/CrossPlatformExternalBuild/CrossPlatformExternalBuild.xcodeproj"
        }
    }
    
    
    func settingsDetails(for xcodeProject: URL) throws -> (common: [String: Any], release: [String: Any], debug: [String: Any]) {
        let pbxFile = xcodeProject.appendingPathComponent(PBX_PROJECT_FILE_NAME)
        let proj = try PBXProj(fromURL: pbxFile)
        let configs = proj.project.buildConfigurationList.buildConfigurations
        let debugSettings: [String: Any] = configs["Debug"]?.completeBuildSettings ?? [:]
        let releaseSettings: [String: Any] = configs["Release"]?.completeBuildSettings ?? [:]
        
        //print("Debug:" + formatDictionaryDescription(debugSettings, indentCount: 1, indentOpening: false))
        //print("Release:" + formatDictionaryDescription(releaseSettings, indentCount: 1, indentOpening: false))
        
        let common: [String: Any] = releaseSettings.intersection(debugSettings)
        let release: [String: Any] = releaseSettings.symmetricDifference(common)
        let debug: [String: Any] = debugSettings.symmetricDifference(common)
        
        return (common: common.replacing("10.10", forKey: "MACOSX_DEPLOYMENT_TARGET"),
                release: release.replacing("10.10", forKey: "MACOSX_DEPLOYMENT_TARGET"),
                debug: debug.replacing("10.10", forKey: "MACOSX_DEPLOYMENT_TARGET"))
    }
    
    func settingsDetails<E>(for xcodeProject: E) throws -> (common: [String: Any], release: [String: Any], debug: [String: Any]) where E: RawRepresentable, E.RawValue == String {
        
        let url = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/" + xcodeProject.rawValue)
        return try settingsDetails(for: url)
    }
    
    enum SettingsField {
        case common
        case debug
        case release
    }
    
    enum SourceGroup: String {
        case swift
        case objc
        case other
        
        enum SwiftSubGroup: String {
            case all
            case pm = "SwiftPM"
            case mac = "Mac"
            case ios = "iOS"
            case tvos = "tvOS"
            case watchos = "watchOS"
            case ipados = "iPadOS"
            case other
            
            func filter(_ url: URL) -> Bool {
                if self == .all { return true }
                if self == .other {
                    let lowLastPath = url.lastPathComponent.lowercased()
                    return !(lowLastPath.hasPrefix(SwiftSubGroup.pm.rawValue.lowercased()) ||
                            lowLastPath.hasPrefix(SwiftSubGroup.mac.rawValue.lowercased()) ||
                            lowLastPath.hasPrefix(SwiftSubGroup.ios.rawValue.lowercased()) ||
                            lowLastPath.hasPrefix(SwiftSubGroup.tvos.rawValue.lowercased()) ||
                            lowLastPath.hasPrefix(SwiftSubGroup.watchos.rawValue.lowercased()) ||
                            lowLastPath.hasPrefix(SwiftSubGroup.ipados.rawValue.lowercased()))
                }
                return url.lastPathComponent.lowercased().hasPrefix(self.rawValue.lowercased())
            }
        }
        
        enum ObjCSubGroup: String {
            case all
            case mac = "Mac"
            case ios = "iOS"
            case tvos = "tvOS"
            case watchos = "watchOS"
            case ipados = "iPadOS"
            case other
            
            func filter(_ url: URL) -> Bool {
                if self == .all { return true }
                if self == .other {
                    let lowLastPath = url.lastPathComponent.lowercased()
                    return !(lowLastPath.hasPrefix(ObjCSubGroup.mac.rawValue.lowercased()) ||
                        lowLastPath.hasPrefix(ObjCSubGroup.ios.rawValue.lowercased()) ||
                        lowLastPath.hasPrefix(ObjCSubGroup.tvos.rawValue.lowercased()) ||
                        lowLastPath.hasPrefix(ObjCSubGroup.watchos.rawValue.lowercased()) ||
                        lowLastPath.hasPrefix(ObjCSubGroup.ipados.rawValue.lowercased()))
                }
                return url.lastPathComponent.lowercased().hasPrefix(self.rawValue.lowercased())
            }
        }
    }
    
    func getProjects(for group: SourceGroup, filter: (URL)->Bool = { _ in return true }) throws -> [URL] {
        var rtn: [URL] = []
        let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/" + group.rawValue)
        let children = try FileManager.default.contentsOfDirectory(atPath: projects.path).map { return projects.appendingPathComponent($0) }
        for c in children {
            guard FileManager.default.directoryExists(at: c) else { continue }
            let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
            
            for pC in projectChildren {
                guard pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) else { continue }
                guard filter(pC) else { continue }
                rtn.append(pC)
            }
        }
        return rtn.sorted(by: { return $0.absoluteString < $1.absoluteString })
    }
    
    func getSwiftProjects(for group: SourceGroup.SwiftSubGroup = .all, filter: (URL)->Bool = { _ in return true }) throws -> [URL] {
        return try getProjects(for: .swift) {
            return group.filter($0) && filter($0)
        }
    }
    
    func getObjCProjects(for group: SourceGroup.ObjCSubGroup = .all, filter: (URL)->Bool = { _ in return true }) throws -> [URL] {
        return try getProjects(for: .objc) {
            return group.filter($0) && filter($0)
        }
    }
    
    
    
    func getCommonSettings(for group: SourceGroup, field: SettingsField = .common, filter: (URL) -> Bool) throws -> [String: Any] {
        var rtn: [String: Any] = [:]
        var hasFirstSet: Bool = false
        
        let projects = try getProjects(for: group, filter: filter)
        for pC in projects {
            let details = try settingsDetails(for: pC)
            let workingSettings: [String: Any]
            switch field {
            case .common: workingSettings = details.common
            case .debug: workingSettings = details.debug
            case .release: workingSettings = details.release
            }
            if !hasFirstSet {
                hasFirstSet = true
                rtn = workingSettings
            }
            else { rtn = rtn.intersection(workingSettings) }
        }
        return rtn
    }
    
    func getAllCommonSettings(for group: SourceGroup, filter: (URL) -> Bool) throws -> (common: [String: Any], release: [String: Any], debug: [String: Any]) {
        var common: [String: Any] = [:]
        var release: [String: Any] = [:]
        var debug: [String: Any] = [:]
        var hasFirstSet: Bool = false
        
        let projects = try getProjects(for: group, filter: filter)
        for pC in projects {
            let details = try settingsDetails(for: pC)
            if !hasFirstSet {
                hasFirstSet = true
                common = details.common
                release = details.release
                debug = details.debug
                
            }
            else {
                common = common.intersection(details.common)
                release = release.intersection(details.release)
                debug = debug.intersection(details.debug)
                
                
            }
        }
        return (common: common, release: release, debug: debug)
    }
    
    
    func getCommonSwiftSettings(for group: SourceGroup.SwiftSubGroup = .all,
                                field: SettingsField = .common,
                                filter: (URL) -> Bool = { _ in return true }) throws -> [String: Any] {
        return try getCommonSettings(for: .swift, field: field) {
            return group.filter($0) && filter($0)
        }
    }
    
    func getAllCommonSwiftSettings(for group: SourceGroup.SwiftSubGroup = .all,
                                      filter: (URL) -> Bool = { _ in return true }) throws -> (common: [String: Any], release: [String: Any], debug: [String: Any]) {
        
        return try getAllCommonSettings(for: .swift) {
            return group.filter($0) && filter($0)
        }
    }
    
    func getCommonObjCSettings(for group: SourceGroup.ObjCSubGroup = .all,
                                   field: SettingsField = .common,
                                   filter: (URL) -> Bool = { _ in return true }) throws -> [String: Any] {
        return try getCommonSettings(for: .objc, field: field) {
            return group.filter($0) && filter($0)
        }
    }
    
    func getAllCommonObjCSettings(for group: SourceGroup.ObjCSubGroup = .all,
                                      filter: (URL) -> Bool = { _ in return true }) throws -> (common: [String: Any], release: [String: Any], debug: [String: Any]) {
        
        return try getAllCommonSettings(for: .objc) {
            return group.filter($0) && filter($0)
        }
    }
    
    
    func testGetCommonSwiftPMSettings() {
        do {
            let details = try getAllCommonSwiftSettings(for: .pm)
            print("\tCommon: " + details.common.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Debug: " + details.debug.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Release: " + details.release.leveledDescription(1, indentOpening: false, sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testGetSwiftPMSettingsDiff() {
        do {
            let common = try getAllCommonSwiftSettings(for: .pm)
            
            let projects: [Projects.Swift.PM] = [.exe, .library, .sysMod]
            for project in projects {
                let details = try settingsDetails(for: project)
                let commonDiff = details.common.symmetricDifference(common.common)
                let releaseDiff = details.release.symmetricDifference(common.release)
                let debugDiff = details.debug.symmetricDifference(common.debug)
                
                print(project.rawValue)
                print("\tCommon: " + commonDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                print("\tDebug: " + debugDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                print("\tRelease: " + releaseDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                
            }
            
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testGetCommonSwiftMacSettings() {
        do {
            let details = try getAllCommonSwiftSettings(for: .mac)
            print("\tCommon: " + details.common.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Debug: " + details.debug.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Release: " + details.release.leveledDescription(1, indentOpening: false, sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testGetSwiftMacSettingsDiff() {
        do {
            let common = try getAllCommonSwiftSettings(for: .mac)
            
            let projects: [Projects.Swift.Mac] = [.macCocoaApp, .macCocoaFramework, .macCommandLine, .macGame, . macSafariExtApp]
            for project in projects {
                let details = try settingsDetails(for: project)
                let commonDiff = details.common.symmetricDifference(common.common)
                let releaseDiff = details.release.symmetricDifference(common.release)
                let debugDiff = details.debug.symmetricDifference(common.debug)
                
                print(project.rawValue)
                print("\tCommon: " + commonDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                print("\tDebug: " + debugDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                print("\tRelease: " + releaseDiff.leveledDescription(1, indentOpening: false, sortKeys: true))
                
            }
            
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func buildSwiftSettingsStructs(_ section: SourceGroup.SwiftSubGroup, indentCount: Int = 0, showForEmptySections: Bool = false) throws -> String {
        let projects = try getSwiftProjects(for: section)
        
        guard projects.count > 0 else { return "" }
        
        let tabs = String(repeating: "\t", count: indentCount)
        var groupName = section.rawValue
        if section == .pm { groupName = "PackageManager" }
        
        var rtn: String = tabs + "public struct \(groupName) {\n"
        rtn += tabs + "\tprivate init() {}\n"
        let commonDetails = try getAllCommonSwiftSettings(for: section)
        rtn += tabs + "\tpublic static let BASE: [String: Any] = " + commonDetails.common.leveledDescription(indentCount + 1,
                                                                                                 indentOpening: false,
                                                                                                 sortKeys: true) + "\n\n"
        rtn += tabs + "\tprivate static let _RELEASE: [String: Any] = " + commonDetails.release.leveledDescription(indentCount + 1,
                                                                                                    indentOpening: false,
                                                                                                    sortKeys: true) + "\n\n"
        rtn += tabs + "\tprivate static let _DEBUG: [String: Any] = " + commonDetails.debug.leveledDescription(indentCount + 1,
                                                                                                  indentOpening: false,
                                                                                                  sortKeys: true) + "\n\n"
        
        rtn += tabs + "\tpublic static let RELEASE: [String: Any] = BASE.mergingKeepNew(_RELEASE)\n"
        rtn += tabs + "\tpublic static let DEBUG: [String: Any] = BASE.mergingKeepNew(_DEBUG)\n\n"
        
        
        for (i, project) in projects.enumerated() {
            var structName = project.lastPathComponent.replacingOccurrences(of: "." + XCODE_PROJECT_EXT, with: "")
            structName = structName.replacingOccurrences(of: section.rawValue, with: "")
            structName = structName.prefix(1).lowercased() + String(structName.dropFirst())
            
            
            rtn += tabs + "\tpublic struct \(structName) {\n "
            rtn += tabs + "\t\tprivate init() {}\n\n"
            
            let details = try settingsDetails(for: project)
            let commonDiff = details.common.symmetricDifference(commonDetails.common)
            let releaseDiff = details.release.symmetricDifference(commonDetails.release)
            let debugDiff = details.debug.symmetricDifference(commonDetails.debug)
            
            if commonDiff.count < 0 {
                rtn += tabs + "\t\tprivate static let _BASE: [String: Any] = " + commonDiff.leveledDescription(indentCount + 2,
                                                                                                             indentOpening: false,
                                                                                                             sortKeys: true) + "\n\n"
            }
            if releaseDiff.count > 0 {
                rtn += tabs + "\t\tprivate static let _RELEASE: [String: Any] = " + releaseDiff.leveledDescription(indentCount + 2,
                                                                                                                indentOpening: false,
                                                                                                                sortKeys: true) + "\n\n"
            }
            if debugDiff.count > 0 {
                rtn += tabs + "\t\tprivate static let _DEBUG: [String: Any] = " + debugDiff.leveledDescription(indentCount + 2,
                                                                                                              indentOpening: false,
                                                                                                              sortKeys: true) + "\n\n"
            }
            
            
            var code = "\(groupName).RELEASE"
            if commonDiff.count < 0 { code += ".mergingKeepNew(_BASE)" }
            if releaseDiff.count > 0 { code += ".mergingKeepNew(_RELEASE)" }
            rtn += tabs + "\t\tpublic static let RELEASE: [String: Any] = \(code)\n"
            
            code = "\(groupName).DEBUG"
            if commonDiff.count < 0 { code += ".mergingKeepNew(_BASE)" }
            if releaseDiff.count > 0 { code += ".mergingKeepNew(_DEBUG)" }
            rtn += tabs + "\t\tpublic static let DEBUG: [String: Any] = \(code)\n"
            
            rtn += tabs + "\t}\n"
            if i < projects.count - 1 { rtn += "\n" }
            
        }
        

        rtn += tabs + "}\n"
        return rtn
    }
    
    func buildSwiftSettings(indentCount: Int = 0) throws -> String {
        let tabs: String = String(repeating: "\t", count: indentCount)
        var rtn: String = tabs + "public struct swift {\n"
        rtn += tabs + "\tprivate init() { }\n\n"
        
        let  sections: [SourceGroup.SwiftSubGroup] = [.pm, .mac, .ios, .tvos, .watchos, .ipados]
        for section in sections {
            let sectionString = try buildSwiftSettingsStructs(section, indentCount: indentCount + 1)
            if !sectionString.isEmpty {
                rtn += sectionString + "\n"
            }
        }
        
        //rtn += try buildSwiftSettingsStructs(.mac, indentCount: 2) + "\n"
        
        rtn += tabs + "}"
        
        return rtn
    }
    
    func buildObjCSettingsStructs(_ section: SourceGroup.ObjCSubGroup, indentCount: Int = 0, showForEmptySections: Bool = false) throws -> String {
        let projects = try getObjCProjects(for: section)
        
        guard projects.count > 0 else { return "" }
        
        let tabs = String(repeating: "\t", count: indentCount)
        let groupName = section.rawValue
        //if section == .pm { groupName = "PackageManager" }
        
        var rtn: String = tabs + "public struct \(groupName) {\n"
        rtn += tabs + "\tprivate init() {}\n"
        let commonDetails = try getAllCommonObjCSettings(for: section)
        rtn += tabs + "\tpublic static let BASE: [String: Any] = " + commonDetails.common.leveledDescription(indentCount + 1,
                                                                                                 indentOpening: false,
                                                                                                 sortKeys: true) + "\n\n"
        rtn += tabs + "\tprivate static let _RELEASE: [String: Any] = " + commonDetails.release.leveledDescription(indentCount + 1,
                                                                                                      indentOpening: false,
                                                                                                      sortKeys: true) + "\n\n"
        rtn += tabs + "\tprivate static let _DEBUG: [String: Any] = " + commonDetails.debug.leveledDescription(indentCount + 1,
                                                                                                    indentOpening: false,
                                                                                                    sortKeys: true) + "\n\n"
        
        rtn += tabs + "\tpublic static let RELEASE: [String: Any] = BASE.mergingKeepNew(_RELEASE)\n"
        rtn += tabs + "\tpublic static let DEBUG: [String: Any] = BASE.mergingKeepNew(_DEBUG)\n\n"
        
        
        for (i, project) in projects.enumerated() {
            var structName = project.lastPathComponent.replacingOccurrences(of: "." + XCODE_PROJECT_EXT, with: "")
            structName = structName.replacingOccurrences(of: section.rawValue, with: "")
            structName = structName.prefix(1).lowercased() + String(structName.dropFirst())
            
            
            rtn += tabs + "\tpublic struct \(structName) {\n "
            rtn += tabs + "\t\tprivate init() {}\n\n"
            
            let details = try settingsDetails(for: project)
            let commonDiff = details.common.symmetricDifference(commonDetails.common)
            let releaseDiff = details.release.symmetricDifference(commonDetails.release)
            let debugDiff = details.debug.symmetricDifference(commonDetails.debug)
            
            if commonDiff.count < 0 {
                rtn += tabs + "\t\tprivate static let _BASE: [String: Any] = " + commonDiff.leveledDescription(indentCount + 2,
                                                                                                             indentOpening: false,
                                                                                                             sortKeys: true) + "\n\n"
            }
            if releaseDiff.count > 0 {
                rtn += tabs + "\t\tprivate static let _RELEASE: [String: Any] = " + releaseDiff.leveledDescription(indentCount + 2,
                                                                                                                indentOpening: false,
                                                                                                                sortKeys: true) + "\n\n"
            }
            if debugDiff.count > 0 {
                rtn += tabs + "\t\tprivate static let _DEBUG: [String: Any] = " + debugDiff.leveledDescription(indentCount + 2,
                                                                                                              indentOpening: false,
                                                                                                              sortKeys: true) + "\n\n"
            }
            
            
            var code = "\(groupName).RELEASE"
            if commonDiff.count < 0 { code += ".mergingKeepNew(_BASE)" }
            if releaseDiff.count > 0 { code += ".mergingKeepNew(_RELEASE)" }
            rtn += tabs + "\t\tpublic static let RELEASE: [String: Any] = \(code)\n"
            
            code = "\(groupName).DEBUG"
            if commonDiff.count < 0 { code += ".mergingKeepNew(_BASE)" }
            if releaseDiff.count > 0 { code += ".mergingKeepNew(_DEBUG)" }
            rtn += tabs + "\t\tpublic static let DEBUG: [String: Any] = \(code)\n"
            
            rtn += tabs + "\t}\n"
            if i < projects.count - 1 { rtn += "\n" }
            
        }
        
        
        rtn += tabs + "}\n"
        return rtn
    }
    
    func buildObjCSettings(indentCount: Int = 0) throws -> String {
        let tabs: String = String(repeating: "\t", count: indentCount)
        var rtn: String = tabs + "public struct objectiveC {\n"
        rtn += tabs + "\tprivate init() { }\n\n"
        
        let  sections: [SourceGroup.ObjCSubGroup] = [.mac, .ios, .tvos, .watchos, .ipados]
        for section in sections {
            let sectionString = try buildObjCSettingsStructs(section, indentCount: indentCount + 1)
            if !sectionString.isEmpty {
                rtn += sectionString + "\n"
            }
        }
        
        //rtn += try buildSwiftSettingsStructs(.mac, indentCount: 2) + "\n"
        
        rtn += tabs + "}"
        
        return rtn
    }
    
    func buildSettings() throws -> String {
        var rtn: String = "public struct XCodeProjectBuildConfigurationSettings {\n"
        rtn += "\tprivate init() { }\n\n"
        
        rtn += try buildSwiftSettings(indentCount: 1) + "\n\n"
        rtn += try buildObjCSettings(indentCount: 1) + "\n"
        
        rtn += "}"
        return rtn
    }
    
    func testBuildSwiftSettings() {
        do {
            
            print(try buildSwiftSettings())
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuildObjCSettings() {
        do {
            print(try buildObjCSettings())
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuildSettings() {
        do {
            print(try buildSettings())
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    
    func testGetCommonSwiftSettings() {
        do {
            let details = try getAllCommonSwiftSettings()
            print("\tCommon: " + details.common.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Debug: " + details.debug.leveledDescription(1, indentOpening: false, sortKeys: true))
            print("\tCommon Release: " + details.release.leveledDescription(1, indentOpening: false, sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    func testSettingsBetweenDebugRelease() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let children = try FileManager.default.contentsOfDirectory(atPath: projects.path).map { return projects.appendingPathComponent($0) }.sorted(by: { return $0.absoluteString < $1.absoluteString })
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    guard pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) else { continue }
                    
                    let details = try settingsDetails(for: pC)
                    print("Settings For \(pC.lastPathComponent): ")
                    print("\tCommon: " + details.common.leveledDescription(1, indentOpening: false, sortKeys: true))
                    print("\tDebug: " + details.debug.leveledDescription(1, indentOpening: false, sortKeys: true))
                    print("\tRelease: " + details.release.leveledDescription(1, indentOpening: false, sortKeys: true))
                    
                    break
                }
                break
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCompareBuildSettings() {
        do {
            let projectGroupFolders = [URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift"),
                                       URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/objc"),
                                       URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/other")]
            
            var projects: [URL] = []
            for pGroup in projectGroupFolders {
                let children = try FileManager.default.contentsOfDirectory(atPath: pGroup.path).map {
                    return pGroup.appendingPathComponent($0)
                }
                projects.append(contentsOf: children)
            }
            
            
            var configSettings: [String: [String]] = [:]
            var totalProjects: Int = 0
            for projectFolder in projects {
                guard FileManager.default.directoryExists(at: projectFolder) else { continue }
                let project = projectFolder.appendingPathComponent(projectFolder.lastPathComponent + "." + XCODE_PROJECT_EXT , isDirectory: true)
                guard FileManager.default.directoryExists(at: project) else { continue }
                totalProjects += 1
                let pbx = try PBXProj(fromURL: project.appendingPathComponent(PBX_PROJECT_FILE_NAME))
                let configs = pbx.project.buildConfigurationList
                for config in configs.buildConfigurations {
                    let configPathName = project.pathComponents[project.pathComponents.count - 3] + "/" + project.pathComponents[project.pathComponents.count - 2] + "/" + config.name
                    
                    let strSettings: String = config.completeBuildSettings.leveledDescription(sortKeys: true)
                    
                    var ary: [String] = configSettings[strSettings] ?? Array<String>()
                    ary.append(configPathName)
                    
                    configSettings[strSettings] = ary
                    
                }
                
            }
            
            print("Total Projects: \(totalProjects)")
            let filteredSettings = configSettings.filter({return $0.value.count > 1})
            print("Dictionary Count: \(filteredSettings.count)")
            
            for (_,v) in filteredSettings {
                print(v)
            }
            
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
    func checkCommonConfigSettings(for projects: URL,
                                   forConfigName configName: String? = nil,
                                   havingProjNamePrefix: String? = nil) throws -> [String: Any] {
        
        let children = try FileManager.default.contentsOfDirectory(atPath: projects.path).map { return projects.appendingPathComponent($0) }
        
        var hasPreSet: Bool = false
        var commonSettings: [String: Any] = [:]
        for c in children {
            guard FileManager.default.directoryExists(at: c) else { continue }
            let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
            
            for pC in projectChildren {
                //print(pC)
                if pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) {
                    if let prefix = havingProjNamePrefix, !pC.lastPathComponent.hasPrefix(prefix) {
                        continue
                    }
                    do {
                        let pbxFile = pC.appendingPathComponent(PBX_PROJECT_FILE_NAME)
                        
                        
                        let proj = try PBXProj(fromURL: pbxFile)
                        let configs = proj.project.buildConfigurationList.buildConfigurations
                        for config in configs {
                            guard configName == nil || config.name == configName! else {
                                continue
                            }
                            guard hasPreSet else {
                                commonSettings = config.completeBuildSettings
                                hasPreSet = true
                                continue
                            }
                            let completeBuildSettings = config.completeBuildSettings
                            for (k,v) in config.completeBuildSettings {
                                guard let oV = commonSettings[k] else {
                                    continue
                                }
                                if "\(v)" != "\(oV)" {
                                    commonSettings.removeValue(forKey: k)
                                }
                            }
                            
                            for key in commonSettings.keys {
                                if completeBuildSettings[key] == nil {
                                    commonSettings.removeValue(forKey: key)
                                }
                            }
                            
                        }
                        
                        
                    } catch {
                        XCTFail("Failed to load project at \(pC):\n\(error)")
                    }
                }
            }
        }
        
        if configName != nil {
            let allCommon = try checkCommonConfigSettings(for: projects)
            for key in allCommon.keys {
                commonSettings.removeValue(forKey: key)
            }
            //commonSettings = allCommon
        }
        
        return commonSettings
        
        /*var commonStrLine = "Common Settings For \(projects.lastPathComponent)"
         if let cfgName = configName { commonStrLine += " with config name '\(cfgName)':" }
         else { commonStrLine += ":" }
         print(commonStrLine)
         print(formatDictionaryDescription(commonSettings, indentCount: 0))*/
        
    }
    
    func testCommonConfigSettingsForSwift() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let commonSettings = try checkCommonConfigSettings(for: projects)
            
            print("Common Settings For \(projects.lastPathComponent): ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForSwiftPM() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let commonSettings = try checkCommonConfigSettings(for: projects, havingProjNamePrefix: "SwiftPM")
            
            print("Common Settings For \(projects.lastPathComponent): ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForSwiftRelease() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let commonSettings = try checkCommonConfigSettings(for: projects, forConfigName: "Release")
            
            print("Common Settings For \(projects.lastPathComponent) with config name 'Release': ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForSwiftDebug() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let commonSettings = try checkCommonConfigSettings(for: projects, forConfigName: "Debug")
            
            print("Common Settings For \(projects.lastPathComponent) with config name 'Debug': ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForObjectiveC() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/objc")
            let commonSettings = try checkCommonConfigSettings(for: projects)
            
            print("Common Settings For \(projects.lastPathComponent): ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForObjectiveCRelease() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/objc")
            let commonSettings = try checkCommonConfigSettings(for: projects, forConfigName: "Release")
            
            print("Common Settings For \(projects.lastPathComponent) with config name 'Release': ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCommonConfigSettingsForbjectiveCDebug() {
        do {
            let projects = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/objc")
            let commonSettings = try checkCommonConfigSettings(for: projects, forConfigName: "Debug")
            
            print("Common Settings For \(projects.lastPathComponent) with config name 'Debug': ")
            print(commonSettings.leveledDescription(sortKeys: true))
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
