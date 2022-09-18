//
//  XCScheme.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation
#if swift(>=4.1)
    #if canImport(FoundationXML)
        import FoundationXML
    #endif
#endif

public enum XCSchemeError: Error {
    case attributeNotFound(attribute: String, path: String?)
    case elementNotFound(name: String, path: String?)
    case valueNotFound(path: String)
    case invalidAttributeValue(value: String, expectedType: Any.Type, attribute: String)
}

public final class XCScheme: NSObject {
    
    public enum Errors: Error {
        case schemeDocumentMissingRootNode
    }
    
    private enum CodingKeys: String, CodingKey {
        case scheme = "Scheme"
        case version = "version"
        case lastUpgradeVersion = "LastUpgradeVersion"
        case buildAction = "BuildActionEntries"
        case testAction = "TestAction"
        case launchAction = "LaunchAction"
        case profileAction = "ProfileAction"
        case analyzeAction = "AnalyzeAction"
        case archiveAction = "ArchiveAction"
        
        public static let allAttributes: [CodingKeys] = [.version,
                                                         .lastUpgradeVersion]
        public static let allElements: [CodingKeys] = [.buildAction,
                                                       .testAction,
                                                       .launchAction,
                                                       .profileAction,
                                                       .analyzeAction,
                                                       .archiveAction]
        public static let allCases: [CodingKeys] = [.version,
                                                    .lastUpgradeVersion,
                                                    .buildAction,
                                                    .testAction,
                                                    .launchAction,
                                                    .profileAction,
                                                    .analyzeAction,
                                                    .archiveAction]
        
    }
    
    private static let DEFAULT_VERSION: Decimal = 1.3
    private static let DEFAULT_LAST_UPGRADE_VERSION: Decimal = 9999
    
    internal var hasInfoChanged: Bool = true
    
    public var buildAction: XCSchemeBuildAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    public var testAction: XCSchemeTestAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    public var launchAction: XCSchemeLaunchAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    public var profileAction: XCSchemeProfileAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    public var analyzeAction: XCSchemeAnalyzeAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    public var archiveAction: XCSchemeArchiveAction? = nil {
        didSet { self.hasInfoChanged = true }
    }
    
    public var attributes: [String: String] = [:] {
        didSet { self.hasInfoChanged = true }
    }
    public var elements: [String: [XCSchemeObject]] = [:] {
        didSet { self.hasInfoChanged = true }
    }
    
    private var hasAnyInfoChanged: Bool {
        get {
            
            if self.hasInfoChanged ||
            (self.buildAction != nil && self.buildAction!.hasInfoChanged) ||
            (self.testAction != nil && self.testAction!.hasInfoChanged) ||
            (self.launchAction != nil && self.launchAction!.hasInfoChanged) ||
            (self.profileAction != nil && self.profileAction!.hasInfoChanged) ||
            (self.analyzeAction != nil && self.analyzeAction!.hasInfoChanged) ||
            (self.archiveAction != nil && self.archiveAction!.hasInfoChanged) ||
                self.elements.values.flatMap({return $0}).contains(where: {$0.hasInfoChanged}) {
                return true
            } else {
                return false
            }
        }
        set {
            self.hasInfoChanged = newValue
            self.buildAction?.hasInfoChanged = newValue
            self.testAction?.hasInfoChanged = newValue
            self.launchAction?.hasInfoChanged = newValue
            self.profileAction?.hasInfoChanged = newValue
            self.analyzeAction?.hasInfoChanged = newValue
            self.archiveAction?.hasInfoChanged = newValue
            self.elements.values.flatMap({return $0}).forEach({$0.hasInfoChanged = newValue})
            
            
        }
    }
    
    public private(set) var version: Decimal {
        get {
            return try! self.getDecimalValue(forAttribute: CodingKeys.version,
                                             withDefaultValue: XCScheme.DEFAULT_VERSION)
        }
        set {
            self.setDecimalValue(newValue,
                                 forAttribute: CodingKeys.version)
        }
    }
    public private(set) var lastUpgradeVersion: Decimal {
        get {
            return try! self.getDecimalValue(forAttribute: CodingKeys.lastUpgradeVersion,
                                             withDefaultValue: XCScheme.DEFAULT_LAST_UPGRADE_VERSION)
        }
        set {
            self.setDecimalValue(newValue,
                                 forAttribute: CodingKeys.lastUpgradeVersion)
        }
    }
    
    public override init() {
        super.init()
        self.version = XCScheme.DEFAULT_VERSION
        self.lastUpgradeVersion = XCScheme.DEFAULT_LAST_UPGRADE_VERSION
        self.hasAnyInfoChanged = true
    }
    
    public init(fromData data: Data) throws {
        let xmlDocument = try XMLDocument(data: data, options: [])
        guard let element = xmlDocument.rootElement() else {
            throw Errors.schemeDocumentMissingRootNode
        }
       
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.buildAction) {
            self.buildAction = try XCSchemeBuildAction(from: aE)
        }
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.testAction) {
            self.testAction = try XCSchemeTestAction(from: aE)
        }
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.launchAction) {
            self.launchAction = try XCSchemeLaunchAction(from: aE)
        }
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.profileAction) {
            self.profileAction = try XCSchemeProfileAction(from: aE)
        }
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.analyzeAction) {
            self.analyzeAction = try XCSchemeAnalyzeAction(from: aE)
        }
        if let aE: XMLElement = element.firstElement(forName: CodingKeys.archiveAction) {
            self.archiveAction = try XCSchemeArchiveAction(from: aE)
        }
        
        
        for attrib in (element.attributes ?? []) {
            guard attrib.kind == .attribute else { continue }
            guard let attribKey = attrib.name, XCScheme.CodingKeys.allAttributes.contains(attribKey) else {
                continue
            }
            if let strVal = attrib.stringValue {
                self.attributes[attribKey] = strVal
            }
        }
        
        if let children = element.children, children.count > 0 {
            for child in children {
                guard child.kind == .element, let childElement = child as? XMLElement else { continue }
                guard let childElementName = childElement.name else { continue }
                guard XCScheme.CodingKeys.allElements.contains(childElementName) else { continue }
                
                let childObject = try XCSchemeObject(from: childElement)
                var ary: [XCSchemeObject] = self.elements[childElementName] ?? []
                ary.append(childObject)
                self.elements[childElementName] = ary
            }
        }
        super.init()
    }
    
    public convenience init(fromURL url: XcodeFileSystemURLResource, usingFSProvider provider: XcodeFileSystemProvider) throws {
        let data = try provider.data(from: url)
        try self.init(fromData: data)
        
    }
    
    
    public func saveAction(to url: XcodeFileSystemURLResource, overrideChangeCheck: Bool = false) throws -> XcodeFileSystemProviderAction? {
        guard self.hasAnyInfoChanged || overrideChangeCheck else { return nil }
        
        let element = XMLTag(CodingKeys.scheme)
        let xmlDocment = XMLDocument(rootElement: element)
        
        XMLAddAttributes(to: element, attributes: self.attributes)
        
        let actions: [(key: CodingKeys, action: XCSchemeObject?)] = [
            (CodingKeys.buildAction, self.buildAction),
            (CodingKeys.testAction, self.testAction),
            (CodingKeys.launchAction, self.launchAction),
            (CodingKeys.profileAction, self.profileAction),
            (CodingKeys.analyzeAction, self.analyzeAction),
            (CodingKeys.archiveAction, self.archiveAction),
        ]
        
        for a in actions {
            if let o = a.action {
                let actionElement = XMLTag(a.key)
                element.addChild(actionElement)
                try o.encode(to: actionElement)
            }
        }
        
        for (k,v) in self.elements {
            for e in v {
                let c = XMLTag(k, compact: (e.elements.count == 0))
                try e.encode(to: c)
                element.addChild(c)
            }
        }
        
        
        let dta = xmlDocment.xmlData(options: [.nodePrettyPrint, .nodePreserveEmptyElements, .nodeUseDoubleQuotes])
        
        return XcodeFileSystemProviderAction.writeData(dta, to: url, writeOptions: .atomic) {
            (_: XcodeFileSystemProvider, _: XcodeFileSystemProviderAction, _: XcodeFileSystemProviderActionResponse?, err: Error?) -> Void in
            if err == nil {
                self.hasAnyInfoChanged = false
            }
        }
    }
    
    public func save(to url: XcodeFileSystemURLResource,
                     usingFSProvider provider: XcodeFileSystemProvider,
                     overrideChangeCheck: Bool = false) throws {
        
        if let action = try self.saveAction(to: url, overrideChangeCheck: overrideChangeCheck) {
            try provider.action(action)
        }

        
    }
    
    
    private func getDecimalValue(forAttribute name: String) throws -> Decimal? {
        guard let strValue = self.attributes[name] else { return nil }
        guard let rtn = Decimal(string: strValue) else {
            throw XCSchemeError.invalidAttributeValue(value: strValue, expectedType: Decimal.self, attribute: name)
        }
        return rtn
    }
    
    private func getDecimalValue<E>(forAttribute name: E) throws -> Decimal? where E: RawRepresentable, E.RawValue == String {
        return try getDecimalValue(forAttribute: name.rawValue)
    }
    
    private func getDecimalValue(forAttribute name: String,
                                  withDefaultValue defVal: @autoclosure () -> Decimal) throws -> Decimal {
        return try getDecimalValue(forAttribute: name) ?? defVal()
    }
    
    private func getDecimalValue<E>(forAttribute name: E,
                                     withDefaultValue defVal: @autoclosure () -> Decimal) throws -> Decimal where E: RawRepresentable, E.RawValue == String {
        return try getDecimalValue(forAttribute: name.rawValue,
                                   withDefaultValue: defVal())
    }
    
    private func setDecimalValue(_ value: Decimal, forAttribute name: String) {
        var strValue = "\(value)"
        
        if strValue.hasSuffix(".0") { strValue.removeLast(2)}

        self.attributes[name] = strValue
    }
    
    private func setDecimalValue<E>(_ value: Decimal, forAttribute name: E) where E: RawRepresentable, E.RawValue == String {
        setDecimalValue(value, forAttribute: name.rawValue)
    }
    
}
