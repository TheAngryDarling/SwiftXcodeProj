//
//  XCSchemeAnalyzeAction.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-02.
//

import Foundation


public class XCSchemeAnalyzeAction: XCSchemeObject {
    private enum CodingKeys: String, CodingKey {
        case buildConfiguration
    }
    
    public var buildConfiguration: String {
        get {
            return self.attributes[CodingKeys.buildConfiguration] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildConfiguration] = newValue
        }
    }
}
