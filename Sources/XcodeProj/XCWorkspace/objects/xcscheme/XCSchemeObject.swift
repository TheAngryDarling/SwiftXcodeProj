//
//  XCSchemeObject.swift
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

public class XCSchemeObject: NSObject {
    
    internal class var EXCLUDED_ATTRIBUTES: [String] { return [] }
    internal class var EXCLUDED_ELEMENTS: [String] { return [] }
    
    internal var hasInfoChanged: Bool = true
    
    public var attributes: [String: String] = [:] {
        didSet { self.hasInfoChanged = true }
    }
    
    public var elements: [String: [XCSchemeObject]] = [:] {
        didSet { self.hasInfoChanged = true }
    }
    
    
    public override init() {
        super.init()
    }
    public required init(from element: XMLElement) throws {
        self.hasInfoChanged = false
        
        for attrib in (element.attributes ?? []) {
            guard attrib.kind == .attribute else { continue }
            guard let attribKey = attrib.name, !type(of: self).EXCLUDED_ATTRIBUTES.contains(attribKey) else {
                continue
            }
            if let strVal = attrib.stringValue {
                self.attributes[attribKey] = strVal
            }
        }
        super.init()
        if let children = element.children, children.count > 0 {
            for child in children {
                guard child.kind == .element, let childElement = child as? XMLElement else { continue }
                guard let childElementName = childElement.name else { continue }
                guard !type(of: self).EXCLUDED_ELEMENTS.contains(childElementName) else { continue }
                
                let childObject = try XCSchemeObject(from: childElement)
                var ary: [XCSchemeObject] = self.elements[childElementName] ?? []
                ary.append(childObject)
                self.elements[childElementName] = ary
            }
        }
    }
    
    public func encode(to element: XMLElement) throws {
        XMLAddAttributes(to: element, attributes: self.attributes)
        for (k,v) in self.elements {
            for e in v {
                let c = XMLTag(k, compact: (e.elements.count == 0))
                try e.encode(to: c)
                element.addChild(c)
            }
        }
    }
    
    internal func getYESNOBoolValue(forAttribute name: String,
                                    withDefaultValue defVal: @autoclosure () -> Bool = { return false }()) -> Bool {
        guard let v = self.attributes[name], v.uppercased() == "YES" else {
            return defVal()
        }
        return true
    }
    internal func getYESNOBoolValue<E>(forAttribute name: E,
                                       withDefaultValue defVal: @autoclosure () -> Bool = { return false }()) -> Bool where E: RawRepresentable, E.RawValue == String {
        return getYESNOBoolValue(forAttribute: name.rawValue, withDefaultValue: defVal)
    }
    
    internal func setYESNOBoolVal(_ value: Bool, forAttribute name: String) {
        self.attributes[name] = (value ? "YES" : "NO")
    }
    
    internal func setYESNOBoolVal<E>(_ value: Bool, forAttribute name: E) where E: RawRepresentable, E.RawValue == String {
        setYESNOBoolVal(value, forAttribute: name.rawValue)
    }
    
    internal func getDecimalValue(forAttribute name: String) throws -> Decimal? {
        guard let strValue = self.attributes[name] else { return nil }
        guard let rtn = Decimal(string: strValue) else {
            throw XCSchemeError.invalidAttributeValue(value: strValue, expectedType: Decimal.self, attribute: name)
        }
        return rtn
    }
    
    internal func getDecimalValue<E>(forAttribute name: E) throws -> Decimal? where E: RawRepresentable, E.RawValue == String {
        return try getDecimalValue(forAttribute: name.rawValue)
    }
    
    internal func getDecimalValue(forAttribute name: String,
                                  withDefaultValue defVal: @autoclosure () -> Decimal) throws -> Decimal {
        return try getDecimalValue(forAttribute: name) ?? defVal()
    }
    
    internal func getDecimalValue<E>(forAttribute name: E,
                                     withDefaultValue defVal: @autoclosure () -> Decimal) throws -> Decimal where E: RawRepresentable, E.RawValue == String {
        return try getDecimalValue(forAttribute: name.rawValue, withDefaultValue: defVal)
    }
    
    internal func setDecimalValue(_ value: Decimal, forAttribute name: String) {
        var strValue = "\(value)"
        // Remove any trailing 0 after decimal point
        while strValue.contains(".") && strValue.hasSuffix("0") {
            strValue.removeLast()
        }
        // If last character IS the decimal point, lets remove it to only show whole number
        if strValue.hasSuffix(".") { strValue.removeLast() }
        self.attributes[name] = strValue
    }
    
    internal func setDecimalValue<E>(_ value: Decimal, forAttribute name: E) where E: RawRepresentable, E.RawValue == String {
        setDecimalValue(value, forAttribute: name.rawValue)
    }
    
    
    
    
    internal func getIntValue(forAttribute name: String) throws -> Int? {
        guard let strValue = self.attributes[name] else { return nil }
        guard let rtn = Int(strValue) else {
            throw XCSchemeError.invalidAttributeValue(value: strValue, expectedType: Int.self, attribute: name)
        }
        return rtn
    }
    
    internal func getIntValue<E>(forAttribute name: E) throws -> Int? where E: RawRepresentable, E.RawValue == String {
        return try getIntValue(forAttribute: name.rawValue)
    }
    
    internal func getIntValue(forAttribute name: String,
                                  withDefaultValue defVal: @autoclosure () -> Int) throws -> Int {
        return try getIntValue(forAttribute: name) ?? defVal()
    }
    
    internal func getIntValue<E>(forAttribute name: E,
                                     withDefaultValue defVal: @autoclosure () -> Int) throws -> Int where E: RawRepresentable, E.RawValue == String {
        return try getIntValue(forAttribute: name.rawValue, withDefaultValue: defVal)
    }
    
    internal func setIntValue(_ value: Int, forAttribute name: String) {
        self.attributes[name] = "\(value)"
    }
    
    internal func setIntValue<E>(_ value: Int, forAttribute name: E) where E: RawRepresentable, E.RawValue == String {
        setIntValue(value, forAttribute: name.rawValue)
    }
    
}
