//
//  XCSchemeTestAction.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-01.
//

import Foundation
#if swift(>=4.1)
    #if canImport(FoundationXML)
        import FoundationXML
    #endif
#endif

public class XCSchemeTestAction: XCSchemeObject {
    
    private enum CodingKeys: String, CodingKey {
        case buildConfiguration = "buildConfiguration"
        case selectedDebuggerIdentifier = "selectedDebuggerIdentifier"
        case selectedLauncherIdentifier = "selectedLauncherIdentifier"
        case shouldUseLaunchSchemeArgsEnv = "shouldUseLaunchSchemeArgsEnv"
        case testables = "Testables"
        case testableReference = "TestableReference"
        //case additionalOptions = "AdditionalOptions"
    }
    
    public class XCSchemeTestableReference: XCSchemeObject {
        
        private enum CodingKeys: String, CodingKey {
            case skipped = "skipped"
            case buildableReference = "BuildableReference"
            case additionalOptions = "AdditionalOptions"
        }
        
        internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.buildableReference.rawValue] }
        
        public var skipped: Bool {
            get {
                return self.getYESNOBoolValue(forAttribute: CodingKeys.skipped)
            }
            set {
                self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.skipped)
            }
        }
        
        public var buildableReference: XCSchemeBuildableReference
        // AdditionalOptions is unknown at this time, let the XCSchemeObject handle it
        //public var additionalOptions: AdditionalOptions
        
        public required init(from element: XMLElement) throws {
            
            guard let buildableReferenceElement = element.firstElement(forName: CodingKeys.buildableReference) else {
                throw XCSchemeError.elementNotFound(name: CodingKeys.buildableReference.rawValue, path: element.xPath)
            }
            self.buildableReference = try XCSchemeBuildableReference(from: buildableReferenceElement)
            try super.init(from: element)
        }
        
        public override func encode(to element: XMLElement) throws {
            try super.encode(to: element)
            let buildableReferenceElement = XMLTag(CodingKeys.buildableReference)
            element.addChild(buildableReferenceElement)
            try self.buildableReference.encode(to: buildableReferenceElement)
        }
        
    }
    
    public class XCSchemeTestables: XCSchemeCollection<XCSchemeTestableReference> {
        internal override class var XML_ELEMENT_NAME: String { return CodingKeys.testableReference.rawValue }
    }
    
    internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.testables.rawValue] }
    
    public var buildConfiguration: String {
        get {
            return self.attributes[CodingKeys.buildConfiguration] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildConfiguration] = newValue
        }
    }
    public var selectedDebuggerIdentifier: String {
        get {
            return self.attributes[CodingKeys.selectedDebuggerIdentifier] ?? ""
        }
        set {
            self.attributes[CodingKeys.selectedDebuggerIdentifier] = newValue
        }
    }
    public var selectedLauncherIdentifier: String {
        get {
            return self.attributes[CodingKeys.selectedLauncherIdentifier] ?? ""
        }
        set {
            self.attributes[CodingKeys.selectedLauncherIdentifier] = newValue
        }
    }
    public var shouldUseLaunchSchemeArgsEnv: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.shouldUseLaunchSchemeArgsEnv)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.shouldUseLaunchSchemeArgsEnv)
        }
    }
    
    public var testables: XCSchemeTestables
    
    
    public required init(from element: XMLElement) throws {
        
        guard let testablesElement = element.firstElement(forName: CodingKeys.testables) else {
            throw XCSchemeError.elementNotFound(name: CodingKeys.testables.rawValue, path: element.xPath)
        }
        
        self.testables = try XCSchemeTestables(from: testablesElement)
        
        try super.init(from: element)
    }
    
    public override func encode(to element: XMLElement) throws {
        try super.encode(to: element)
        let testablesElement = XMLTag(CodingKeys.testables)
        element.addChild(testablesElement)
        try self.testables.encode(to: testablesElement)
    }
    
}
