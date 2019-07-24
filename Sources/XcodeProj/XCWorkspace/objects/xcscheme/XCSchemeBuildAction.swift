//
//  XCSchemeBuildAction.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation

public class XCSchemeBuildAction: XCSchemeObject {
    
    private enum CodingKeys: String, CodingKey {
        case parallelizeBuildables = "parallelizeBuildables"
        case buildImplicitDependencies = "buildImplicitDependencies"
        case entries = "BuildActionEntries"
        case entry = "BuildActionEntry"
    }
    
    public class XCSchemeBuildActionEntries: XCSchemeCollection<XCSchemeBuildActionEntry> {
        internal override class var XML_ELEMENT_NAME: String { return CodingKeys.entry.rawValue }
    }
    
    internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.entries.rawValue] }
    
    public var parallelizeBuildables: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.parallelizeBuildables)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.parallelizeBuildables)
        }
    }
    
    public var buildImplicitDependencies: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.buildImplicitDependencies)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.buildImplicitDependencies)
        }
    }
    
    public private(set) var entries: XCSchemeBuildActionEntries
    
    /*public override init() {
        self.entries = XCSchemeBuildActionEntries()
        super.init()
        self.parallelizeBuildables = true
        self.buildImplicitDependencies = true
    }*/
    
    public required init(from element: XMLElement) throws {
        
        
        guard let entrys = element.firstElement(forName: CodingKeys.entries) else {
            throw XCSchemeError.elementNotFound(name: CodingKeys.entries.rawValue, path: element.xPath)
        }
        self.entries = try XCSchemeBuildActionEntries(from: entrys)
        
        
        try super.init(from: element)
        
    }
    
    public override func encode(to element: XMLElement) throws {
        try super.encode(to: element)
        let entrys = XMLTag(CodingKeys.entries)
        element.addChild(entrys)
        try self.entries.encode(to: entrys)
    }
    
}
