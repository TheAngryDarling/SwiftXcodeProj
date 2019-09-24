//
//  XCSchemeLaunchAction.swift
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

public class XCSchemeLaunchAction: XCSchemeObject {
    
    
    
    public class XSchemeMacroExpansion: XCSchemeObject {
        private enum CodingKeys: String, CodingKey {
            case buildableReference = "BuildableReference"
        }
        
        internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.buildableReference.rawValue] }
        
        public var buildableReference: XCSchemeBuildableReference
        
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
    
    public class XCSchemeBuildableProductRunnable: XCSchemeObject {
        private enum CodingKeys: String, CodingKey {
            case runnableDebuggingMode
            case buildableReference = "BuildableReference"
        }
        
        internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.buildableReference.rawValue] }
        
        public var runnableDebuggingMode: Int {
            get {
                return try! self.getIntValue(forAttribute: CodingKeys.runnableDebuggingMode) ?? 0
            }
            set {
                self.setIntValue(newValue, forAttribute: CodingKeys.runnableDebuggingMode)
            }
        }
        
        public var buildableReference: XCSchemeBuildableReference
        
        public init(runnableDebuggingMode: Int = 0, buildableReference: XCSchemeBuildableReference) {
            self.buildableReference = buildableReference
            super.init()
            self.runnableDebuggingMode = runnableDebuggingMode
            
            
        }
        
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
    
    private enum CodingKeys: String, CodingKey {
        case buildConfiguration
        case selectedDebuggerIdentifier
        case selectedLauncherIdentifier
        case launchStyle
        case useCustomWorkingDirectory
        case ignoresPersistentStateOnLaunch
        case debugDocumentVersioning
        case debugServiceExtension
        case allowLocationSimulation
        case buildableProductRunnable = "BuildableProductRunnable"
        case macroExpansion = "MacroExpansion"
        //case buildableReference = "BuildableReference"
        case additionalOptions = "AdditionalOptions"
    }
    
    internal override class var EXCLUDED_ELEMENTS: [String] { return [CodingKeys.buildableProductRunnable.rawValue,
                                                                      CodingKeys.macroExpansion.rawValue] }
    
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
    public var launchStyle: Int {
        get {
            return try! self.getIntValue(forAttribute: CodingKeys.useCustomWorkingDirectory) ?? 0
        }
        set {
            self.setIntValue(newValue, forAttribute: CodingKeys.useCustomWorkingDirectory)
        }
    }
    public var useCustomWorkingDirectory: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.useCustomWorkingDirectory)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.useCustomWorkingDirectory)
        }
    }
    public var ignoresPersistentStateOnLaunch: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.ignoresPersistentStateOnLaunch)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.ignoresPersistentStateOnLaunch)
        }
    }
    public var debugDocumentVersioning: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.debugDocumentVersioning)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.debugDocumentVersioning)
        }
    }
    public var debugServiceExtension: String {
        get {
            return self.attributes[CodingKeys.debugServiceExtension] ?? ""
        }
        set {
            self.attributes[CodingKeys.debugServiceExtension] = newValue
        }
    }
    public var allowLocationSimulation: String {
        get {
            return self.attributes[CodingKeys.allowLocationSimulation] ?? ""
        }
        set {
            self.attributes[CodingKeys.allowLocationSimulation] = newValue
        }
    }
    
    
    public var macroExpansion: XSchemeMacroExpansion? = nil
    public var buildableProductRunnable: XCSchemeBuildableProductRunnable? = nil
    
    // AdditionalOptions is unknown at this time, let the XCSchemeObject handle it
    //public var additionalOptions: AdditionalOptions
    
    public required init(from element: XMLElement) throws {
        
        if let element = element.firstElement(forName: CodingKeys.macroExpansion) {
            self.macroExpansion = try XSchemeMacroExpansion(from: element)
        }
        if let element = element.firstElement(forName: CodingKeys.buildableProductRunnable) {
            self.buildableProductRunnable = try XCSchemeBuildableProductRunnable(from: element)
        }
        
        try super.init(from: element)
    }
    
    public override func encode(to element: XMLElement) throws {
        try super.encode(to: element)
        
        let actions: [(key: CodingKeys, action: XCSchemeObject?)] = [
            (CodingKeys.macroExpansion, self.macroExpansion),
            (CodingKeys.buildableProductRunnable, self.buildableProductRunnable),
        ]
        
        for a in actions {
            if let o = a.action {
                let actionElement = XMLTag(a.key)
                element.addChild(actionElement)
                try o.encode(to: actionElement)
            }
        }
    }
    
}
