//
//  XCSchemeBuildActionEntry.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation

public class XCSchemeBuildActionEntry: XCSchemeObject {
    
    
    private enum CodingKeys: String, CodingKey {
        case buildForTesting = "buildForTesting"
        case buildForRunning = "buildForRunning"
        case buildForProfiling = "buildForProfiling"
        case buildForArchiving = "buildForArchiving"
        case buildForAnalyzing = "buildForAnalyzing"
        case buildableReference = "BuildActionEntry"
    }
    
    //fileprivate static let XML_TAG_NAME: String = "BuildActionEntry"
    
    internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.buildableReference.rawValue] }
    
    
    
    public var buildForTesting: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildForTesting)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildForTesting)
        }
    }
    public var buildForRunning: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildForRunning)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildForRunning)
        }
    }
    public var buildForProfiling: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildForProfiling)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildForProfiling)
        }
    }
    public var buildForArchiving: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildForArchiving)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildForArchiving)
        }
    }
    public var buildForAnalyzing: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildForAnalyzing)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildForAnalyzing)
        }
    }
    
    public var buildableReference: XCSchemeBuildableReference
    
    public init(buildForTesting: Bool = true,
                buildForRunning: Bool = true,
                buildForProfiling: Bool = true,
                buildForArchiving: Bool = true,
                buildForAnalyzing: Bool = true,
                buildableReference: XCSchemeBuildableReference) {
        
        self.buildableReference = buildableReference
        
        super.init()
        
        self.buildForTesting = buildForTesting
        self.buildForRunning = buildForRunning
        self.buildForProfiling = buildForProfiling
        self.buildForArchiving = buildForArchiving
        self.buildForAnalyzing = buildForAnalyzing
    }
    
    
    public required init(from element: XMLElement) throws {
        
        guard let reference = element.firstElement(forName: CodingKeys.buildableReference) else {
            throw XCSchemeError.elementNotFound(name: CodingKeys.buildableReference.rawValue, path: element.xPath)
        }
        self.buildableReference = try XCSchemeBuildableReference(from: reference)
        
        try super.init(from: element)
    }
    
    public override func encode(to element: XMLElement) throws {
        try super.encode(to: element)
        let e = XMLTag(CodingKeys.buildableReference)
        try self.buildableReference.encode(to: e)
        element.addChild(e)
    }
    
}
