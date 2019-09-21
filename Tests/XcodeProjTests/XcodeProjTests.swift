import XCTest
import CodeTimer
@testable import XcodeProj
import SwiftPatches

#if os(Linux)
import SwiftGlibc
#else
import Darwin
#endif

extension FileManager {
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

extension XcodeProjectBuilders.UserDetails {
    /// This builds and returns a user details object out of environment variables
    ///
    /// User Name: REAL_USER
    /// Display Name: REAL_DISPLAY_NAME
    public static var envUserDetails: XcodeProjectBuilders.UserDetails {
        guard let userName = ProcessInfo.processInfo.environment["REAL_USER"] else {
            fatalError("Unable to get real user from Docker Enviromental variable 'REAL_USER'")
        }
        let rDN = ProcessInfo.processInfo.environment["REAL_DISPLAY_NAME"]
        let displayName: String = rDN ?? userName
        if rDN == nil {
            debugPrint("WARNING: Unable to find Docker Enviromental variable 'REAL_DISPLAY_NAME'.  Failing back to user name for display name")
        }
        
        
        
        return XcodeProjectBuilders.UserDetails.populated(userName: userName, displayName: displayName)
    }
    
    public static var testUserDetails: XcodeProjectBuilders.UserDetails {
        if ProcessInfo.processInfo.environment["REAL_USER_NAME"]  != nil { return envUserDetails }
        else { return XcodeProjectBuilders.UserDetails() }
    }
        
    
}

class XcodeProjTests: XCTestCase {
    
    //fileprivate let packageTestRootPath = URL(fileURLWithPath: #file).deletingLastPathComponent().pathComponents.joined(separator: "/").dropFirst()
    static let packageRootPath: String = String(URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst())
    
    static let testPackageRootPath: String = packageRootPath + "/Tests"
    static let testPackagePath: String = String(URL(fileURLWithPath: #file).pathComponents.dropLast().joined(separator: "/").dropFirst())
    static let testPackageResourcePath: String = testPackageRootPath + "/resources"
    static let testPackageResourceTestProjectPath: String = testPackageResourcePath + "/test_proj"
    
    var isXcodeTesting: Bool {
        return (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil)
    }
    
    @discardableResult
    func loadProject(_ url: URL) throws -> XcodeProject {
        if isXcodeTesting { print("Loading: \(url.lastPathComponent)") }
        let tr: (TimeInterval, XcodeProject) = try Timer.timeWithResults {
            return try XcodeProject(fromURL: url)
        }
        tr.1.resources.sort()
        if isXcodeTesting { print("Loaded project (\(url.lastPathComponent)) in \(tr.0) s") }
        if isXcodeTesting { debugPrint(tr.1) }
        
        // Test out path function
        testResourcePathFunction(for: tr.1, in: tr.1.resources)
        
        let tUserList: (TimeInterval, XCUserDataList) = try Timer.timeWithResults {
            try tr.1.userdataList()
        }
        if isXcodeTesting { print("Loaded User Data List in \(tUserList.0) s") }
        if isXcodeTesting { debugPrint(tUserList.1) }
        
        let tSharedData: (TimeInterval, XCSharedData) = try Timer.timeWithResults {
            try tr.1.sharedData()
        }
        if isXcodeTesting { print("Loaded Shared Data List in \(tSharedData.0) s") }
        if isXcodeTesting { debugPrint(tSharedData.1) }
       return tr.1
    }
    
    func testResourcePathFunction(for project: XcodeProject, in group: XcodeGroup) {
        
        let childGroups: [XcodeGroup] = group.filter({ return $0 is XcodeGroup }).map({ return $0 as! XcodeGroup })
        for childGroup in childGroups {
            let foundParent = childGroup.group(atPath: "..")
            XCTAssertEqual(foundParent, group)
            let foundRoot = childGroup.group(atPath: "/")
            XCTAssertEqual(foundRoot, project.resources)
            let foundCurrent = childGroup.group(atPath: ".")
            XCTAssertEqual(foundCurrent, childGroup)
        }
        
        for childGroup in childGroups {
            testResourcePathFunction(for: project, in: childGroup)
        }
    }
    
    func testLocalSwiftProject() {
        
        do {
            let projectsURL = URL(fileURLWithPath: XcodeProjTests.packageRootPath)
            guard FileManager.default.fileExists(atPath: projectsURL.path) else {
                print("WARNING: No local xCode project available")
                return
            }
            let children = try FileManager.default.contentsOfDirectory(atPath: projectsURL.path).map {
                return projectsURL.appendingPathComponent($0)
            }.sorted(by: { return $0.absoluteString < $1.absoluteString })
            
            //print(children)
            for pC in children {
                
                //print(pC)
                if pC.lastPathComponent.lowercased().hasSuffix(XcodeProject.XCODE_PROJECT_EXT) {
                    do {
                        try loadProject(pC)
                    } catch {
                        XCTFail("Failed to load project at \(pC.lastPathComponent):\n\(error)")
                    }
                }
                
            }
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func testSwiftProjects() {
        do {
            let testProjectsURL = URL(fileURLWithPath: XcodeProjTests.testPackageResourceTestProjectPath + "/swift")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }.sorted(by: { return $0.absoluteString < $1.absoluteString })
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XcodeProject.XCODE_PROJECT_EXT) {
                        do {
                            try loadProject(pC)
                        } catch {
                            XCTFail("Failed to load project at \(pC.lastPathComponent):\n\(error)")
                        }
                    }
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    
    }
    
    
    func testObjectiveCProjects() {
        do {
            let testProjectsURL = URL(fileURLWithPath: XcodeProjTests.testPackageResourceTestProjectPath + "/objc")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }.sorted(by: { return $0.absoluteString < $1.absoluteString })
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XcodeProject.XCODE_PROJECT_EXT) {
                        do {
                            try loadProject(pC)
                        } catch {
                            XCTFail("Failed to load project at \(pC.lastPathComponent):\n\(error)")
                        }
                    }
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testOtherProjects() {
        do {
            let testProjectsURL = URL(fileURLWithPath: XcodeProjTests.testPackageResourceTestProjectPath + "/other")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }.sorted(by: { return $0.absoluteString < $1.absoluteString })
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XcodeProject.XCODE_PROJECT_EXT) {
                        do {
                            try loadProject(pC)
                        } catch {
                            XCTFail("Failed to load project at \(pC.lastPathComponent):\n\(error)")
                        }
                    }
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    
    func testFileNameRegExPatternExclusing() {
        do {
            let workingPath: String = XcodeProjTests.packageRootPath + "/Sources/XcodeProj/resources/"
            
            let workingURL: URL = URL(fileURLWithPath: workingPath, isDirectory: true)
            
            let children = try FileManager.default.contentsOfDirectory(atPath: workingURL.path).map {
                return workingURL.appendingPathComponent($0)
            }
            
            let regExEscapeCharacters: [String] = ["[", "]", "\\", "^", "$", ".", "|", "?", "*", "+", "(", ")", "{", "}"]
            var pattern: String = "^"
            
            print("All Files: ")
            for (i, child) in children.enumerated() {
                print("\t\(child.lastPathComponent)")
                // we're going to skip the first and last file
                guard i > 0 && i < (children.count-1) else { continue }
                
                var fileName = child.lastPathComponent
                for esc in regExEscapeCharacters {
                    fileName = fileName.replacingOccurrences(of: esc, with: "\\" + esc)
                }
                
                pattern += "(?!\(fileName)$)"
                
            }
            
            pattern += ".+\\.swift$"
            
            print("\nPattern: '\(pattern)'\n")
            
            let regPattern: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions) = (pattern: pattern, patternOptions: NSRegularExpression.Options.caseInsensitive, matchingOptions: [])
            
            
            let namePattern = try NSRegularExpression(pattern: regPattern.pattern, options: regPattern.patternOptions)
            
            print("Matched Files:")
            for child in children {
                if namePattern.firstMatch(in: child.lastPathComponent,
                                  options: regPattern.matchingOptions,
                                  range: NSMakeRange(0, NSString(string: child.lastPathComponent).length)) != nil {
                    print("\t\(child.lastPathComponent)")
                }
            }
            
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCreateSwiftCommandLineApp() {
        let workingDir: URL = URL(fileURLWithPath: NSString(string: "~/").expandingTildeInPath,
                                 isDirectory: true)
        let workingProjectName: String = "TestSwiftCommandLine"
        do {
            
            let proj = try XcodeProjectBuilders.Swift.CommandLine.create(workingProjectName,
                                                                          in: workingDir,
                                                                          havingUserDetails: .testUserDetails)
            
            print(proj)
        } catch {
            XCTFail("\(error)")
            try? FileManager.default.removeItem(at: workingDir.appendingPathComponent(workingProjectName, isDirectory: true))
        }
    }
    
    func testCreateObjCCommandLineApp() {
        let workingDir: URL = URL(fileURLWithPath: NSString(string: "~/").expandingTildeInPath,
                                  isDirectory: true)
        let workingProjectName: String = "TestObjCCommandLine"
        do {
            
            let proj = try XcodeProjectBuilders.ObjectiveC.CommandLine.create(workingProjectName,
                                                                         in: workingDir,
                                                                         havingUserDetails: .testUserDetails)
            
            print(proj)
        } catch {
            XCTFail("\(error)")
            try? FileManager.default.removeItem(at: workingDir.appendingPathComponent(workingProjectName, isDirectory: true))
        }
    }
    
    func testCreateOtherEmptyProject() {
        let workingDir: URL = URL(fileURLWithPath: NSString(string: "~/").expandingTildeInPath,
                                  isDirectory: true)
        let workingProjectName: String = "TestOtherEmptyProject"
        do {
            
            let proj = try XcodeProjectBuilders.CrossPlatform.Empty.create(workingProjectName,
                                                                              in: workingDir,
                                                                              havingUserDetails: .testUserDetails)
            
            print(proj)
        } catch {
            XCTFail("\(error)")
            try? FileManager.default.removeItem(at: workingDir.appendingPathComponent(workingProjectName, isDirectory: true))
        }
    }

    func testEmpty() { }
    
    static var allTests = [
        ("testEmpty", testEmpty),
        ("testLocalSwiftProject",testLocalSwiftProject),
        ("testSwiftProjects", testSwiftProjects),
        ("testObjectiveCProjects", testObjectiveCProjects),
        ("testOtherProjects", testOtherProjects),
        //("testCreateSwiftCommandLineApp", testCreateSwiftCommandLineApp),
        //("testCreateObjCCommandLineApp", testCreateObjCCommandLineApp),
        //("testCreateOtherEmptyProject", testCreateOtherEmptyProject)
    ]
}
