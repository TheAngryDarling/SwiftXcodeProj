//
//  XCSchemeProfileAction.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-02.
//

import Foundation

public class XCSchemeProfileAction: XCSchemeObject {
    private enum CodingKeys: String, CodingKey {
        case buildConfiguration
        case shouldUseLaunchSchemeArgsEnv
        case savedToolIdentifier
        case useCustomWorkingDirectory
        case debugDocumentVersioning
    }
    
    public var buildConfiguration: String {
        get {
            return self.attributes[CodingKeys.buildConfiguration] ?? ""
        }
        set {
            self.attributes[CodingKeys.buildConfiguration] = newValue
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
    public var savedToolIdentifier: String {
        get {
            return self.attributes[CodingKeys.savedToolIdentifier] ?? ""
        }
        set {
            self.attributes[CodingKeys.savedToolIdentifier] = newValue
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
    public var debugDocumentVersioning: Bool {
        get {
            return self.getYESNOBoolValue(forAttribute: CodingKeys.debugDocumentVersioning)
        }
        set {
            self.setYESNOBoolVal(newValue, forAttribute: CodingKeys.debugDocumentVersioning)
        }
    }
    
    public init(buildConfiguration: String,
                shouldUseLaunchSchemeArgsEnv: Bool,
                savedToolIdentifier: String,
                useCustomWorkingDirectory: Bool,
                debugDocumentVersioning: Bool) {
        super.init()
        
        self.buildConfiguration = buildConfiguration
        self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
        self.savedToolIdentifier = savedToolIdentifier
        self.useCustomWorkingDirectory = useCustomWorkingDirectory
        self.debugDocumentVersioning = debugDocumentVersioning
    }
    
    public required init(from element: XMLElement) throws {
        try super.init(from: element)
    }
    
}
