//
//  XCSchemeArchiveAction.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-02.
//

import Foundation

public class XCSchemeArchiveAction: XCSchemeObject {
    private enum CodingKeys: String, CodingKey {
        case buildConfiguration
        case revealArchiveInOrganizer
    }
    
    public var buildConfiguration: String {
        get {
            return self.attributes[CodingKeys.buildConfiguration] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildConfiguration] = newValue
        }
    }
    
    public var revealArchiveInOrganizer: Bool  {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.revealArchiveInOrganizer)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.revealArchiveInOrganizer)
        }
    }
}
