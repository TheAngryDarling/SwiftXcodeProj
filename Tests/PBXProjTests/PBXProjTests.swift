import XCTest
@testable import PBXProj




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


class PBXProjTests: XCTestCase {
    
    let XCODE_PROJECT_EXT: String = "xcodeproj"
    
    let PBX_PROJECT_FILE_NAME: String = "project.pbxproj"
    
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
    
    /*func testPrintAllCodableFiles() {
        let fileTypeKeys = PBXFileType.fileTypeDetails.keys
        for fileTypeIdent in fileTypeKeys {
            if let details = PBXFileType.fileTypeDetails[fileTypeIdent],
                details.isCodeFile && details.allExtensions.count > 0 {
                print(fileTypeIdent)
            }
            
        }
    }*/
    func loadProject(_ url: URL) throws {
        if isXcodeTesting { print("Loading: \(url.path)") }
        let tr: (TimeInterval, PBXProj) = try Timer.timeWithResults {
            return try PBXProj(fromURL: url)
        }
        if isXcodeTesting { print("Loaded project (\(url.lastPathComponent)) in \(tr.0) s") }
        if isXcodeTesting { debugPrint(tr.1) }
        let tr2: (TimeInterval, [PBXObject]) = Timer.timeWithResults {
            return tr.1.danglingObjects()
        }
        if isXcodeTesting { print("Finding dangling objets took: \(tr2.0) s") }
        if isXcodeTesting { print(tr2.1) }
    }
    
    func testLocalSwiftProject() {
        do {
            let swiftProjectsURL = URL(fileURLWithPath: PBXProjTests.packageRootPath)
            let children = try FileManager.default.contentsOfDirectory(atPath: swiftProjectsURL.path).map { return swiftProjectsURL.appendingPathComponent($0) }
            
            
            for pC in children {
                
                //print(pC)
            if pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) {
                    do {
                        let pbxFile = pC.appendingPathComponent(PBX_PROJECT_FILE_NAME)
                        try loadProject(pbxFile)
                        /*print("Loading: \(pbxFile.path)")
                        
                        let proj = try PBXProj(fromURL: pbxFile)
                        print(proj)*/
                    } catch {
                        XCTFail("Failed to load project at \(pC):\n\(error)")
                    }
                }
                
            }
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func testSwiftProjects() {
        do {
            let testProjectsURL = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/swift")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) {
                        do {
                            let pbxFile = pC.appendingPathComponent(PBX_PROJECT_FILE_NAME)
                            try loadProject(pbxFile)
                        } catch {
                            XCTFail("Failed to load project at \(pC):\n\(error)")
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
            let testProjectsURL = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/objc")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) {
                        do {
                            let pbxFile = pC.appendingPathComponent(PBX_PROJECT_FILE_NAME)
                            try loadProject(pbxFile)
                        } catch {
                            XCTFail("Failed to load project at \(pC):\n\(error)")
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
            let testProjectsURL = URL(fileURLWithPath: PBXProjTests.testPackageResourceTestProjectPath + "/other")
            let children = try FileManager.default.contentsOfDirectory(atPath: testProjectsURL.path).map { return testProjectsURL.appendingPathComponent($0) }
            
            for c in children {
                guard FileManager.default.directoryExists(at: c) else { continue }
                let projectChildren = try FileManager.default.contentsOfDirectory(atPath: c.path).map { return c.appendingPathComponent($0) }
                
                for pC in projectChildren {
                    //print(pC)
                    if pC.lastPathComponent.lowercased().hasSuffix(XCODE_PROJECT_EXT) {
                        do {
                            let pbxFile = pC.appendingPathComponent(PBX_PROJECT_FILE_NAME)
                            try loadProject(pbxFile)
                        } catch {
                            XCTFail("Failed to load project at \(pC):\n\(error)")
                        }
                    }
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testEmpty() { }
    
    static var allTests = [
        ("testEmpty", testEmpty),
        ("testLocalSwiftProject", testLocalSwiftProject),
        ("testSwiftProjects", testSwiftProjects),
        ("testObjectiveCProjects", testObjectiveCProjects),
        ("testOtherProjects", testOtherProjects),
    ]
}
