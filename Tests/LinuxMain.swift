import XCTest
@testable import PBXProjTests
@testable import XcodeProjTests

XCTMain([
    
    testCase(PBXProjTests.allTests),
    testCase(XcodeProjTests.allTests),
])
