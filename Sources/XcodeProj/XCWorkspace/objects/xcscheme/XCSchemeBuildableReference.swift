//
//  XCSchemeBuildableReference.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation

public class XCSchemeBuildableReference: XCSchemeObject  {
    
    private enum CodingKeys: String, CodingKey {
        case buildableIdentifier = "BuildableIdentifier"
        case blueprintIdentifier = "BlueprintIdentifier"
        case buildableName = "BuildableName"
        case blueprintName = "blueprintName"
        case referencedContainer = "ReferencedContainer"
    }
    
    public var buildableIdentifier: String {
        get {
            return self.attributes[CodingKeys.buildableIdentifier] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildableIdentifier] = newValue
        }
    }
    public var blueprintIdentifier: String {
        get {
            return self.attributes[CodingKeys.blueprintIdentifier] ?? ""
        }
        set {
            self.attributes[CodingKeys.blueprintIdentifier] = newValue
        }
    }
    public var buildableName: String{
        get {
            return self.attributes[CodingKeys.buildableName] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildableName] = newValue
        }
    }
    public var blueprintName: String {
        get {
            return self.attributes[CodingKeys.blueprintName] ?? ""
        }
        set {
            self.attributes[CodingKeys.blueprintName] = newValue
        }
    }
    public var referencedContainer: String {
        get {
            return self.attributes[CodingKeys.referencedContainer] ?? ""
        }
        set {
            self.attributes[CodingKeys.referencedContainer] = newValue
        }
    }
    
    
    
    public init(buildableIdentifier: String,
                blueprintIdentifier: String,
                buildableName: String,
                blueprintName: String,
                referencedContainer: String) {
        super.init()
        self.buildableIdentifier = buildableIdentifier
        self.blueprintIdentifier = blueprintIdentifier
        self.buildableName = buildableName
        self.blueprintName = blueprintName
        self.referencedContainer = referencedContainer
    }
    
    public required init(from element: XMLElement) throws {
        try super.init(from: element)
    }
}
