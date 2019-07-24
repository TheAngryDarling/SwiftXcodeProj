//
//  XML.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-22.
//

// Revised from https://gist.github.com/brentdax/caaaa134c500e00efd36

import Foundation


// MARK: - Object Initialization
internal func XMLAttribute(_ name: String, stringValue value: String) -> XMLNode {
    return XMLNode.attribute(withName: name, stringValue: value) as! XMLNode
}

internal func XMLAddAttributes(to element: XMLElement, attributes: [XMLNode]) {
    for attrib in attributes {
        guard attrib.kind == .attribute else {
            fatalError("node kind missmatch.  Expected \(XMLNode.Kind.attribute) but found \(attrib.kind) in \(attrib)")
        }
        element.addAttribute(attrib)
    }
}

internal func XMLAddAttributes(to element: XMLElement, attributes: XMLNode...) {
    XMLAddAttributes(to: element, attributes: attributes)
}

internal func XMLAddAttributes(to element: XMLElement, attributes: (String, String)...) {
    var attribs: [XMLNode] = []
    for attr in attributes {
        attribs.append(XMLAttribute(attr.0, stringValue: attr.1))
    }
    XMLAddAttributes(to: element, attributes: attribs)
}

internal func XMLAddAttributes(to element: XMLElement, attributes:  [String: String]) {
    var attribs: [XMLNode] = []
    for attr in attributes {
        attribs.append(XMLAttribute(attr.key, stringValue: attr.value))
    }
     XMLAddAttributes(to: element, attributes: attribs)
}


// ---------------------------------------------------------------------------------




internal func XMLTag(_ name: String, compact: Bool = false, attributes: [XMLNode] = []) -> XMLElement {
    let rtn: XMLElement = XMLElement(kind: .element, options: compact ? .nodeCompactEmptyElement : XMLNode.Options())
    
    
    for attrib in attributes {
        guard attrib.kind == .attribute else {
            fatalError("node kind missmatch.  Expected \(XMLNode.Kind.attribute) but found \(attrib.kind) in \(attrib)")
        }
        rtn.addAttribute(attrib)
    }
    
    return rtn
}

/*internal func XMLTag(_ name: String, compact: Bool = false, attributes: XMLNode...) -> XMLElement {
    return XMLTag(name, compact: compact, attributes: attributes)
}

internal func XMLTag(_ name: String, compact: Bool = false, attributes: (String, String)...) -> XMLElement {
    var attribs: [XMLNode] = []
    for attr in attributes {
        attribs.append(XMLAttribute(attr.0, stringValue: attr.1))
    }
    return XMLTag(name, compact: compact, attributes: attribs)
}*/

internal func XMLTag(_ name: String, compact: Bool = false, attributes: [String: String]) -> XMLElement {
    let rtn = XMLTag(name, compact: compact)
    rtn.setAttributesWith(attributes)
    return rtn
}

internal func XMLTag(_ name: String, compact: Bool = false, attributes: [(String, String)]) -> XMLElement {
    return XMLTag(name, compact: compact, attributes: Dictionary<String, String>(uniqueKeysWithValues: attributes))
}

internal func XMLTag(_ name: String, compact: Bool = false, attribute: (String, String)) -> XMLElement {
    return XMLTag(name, compact: compact, attributes: [attribute])
}




internal func XMLTag<E>(_ name: E,
                        compact: Bool = false,
                        attributes: [XMLNode] = []) -> XMLElement where E: RawRepresentable, E.RawValue == String {
    return XMLTag(name.rawValue, compact: compact, attributes: attributes)
}

internal func XMLTag<E>(_ name: E,
                        compact: Bool = false,
                        attributes: [String: String]) -> XMLElement where E: RawRepresentable, E.RawValue == String {
    return XMLTag(name.rawValue, compact: compact, attributes: attributes)
}
internal func XMLTag<E>(_ name: E,
                        compact: Bool = false,
                        attributes: [(String, String)]) -> XMLElement where E: RawRepresentable, E.RawValue == String {
    return XMLTag(name.rawValue, compact: compact, attributes: attributes)
}
internal func XMLTag<E>(_ name: E,
                        compact: Bool = false,
                        attribute: (String, String)) -> XMLElement where E: RawRepresentable, E.RawValue == String {
    return XMLTag(name.rawValue, compact: compact, attribute: attribute)
}




internal func XMLTag<E, E2>(_ name: E,
                        compact: Bool = false,
                        attributes: [E2: String]) -> XMLElement where E: RawRepresentable, E.RawValue == String, E2: RawRepresentable, E2.RawValue == String {
    var attribs: [String: String] = [:]
    for (k,v) in attributes { attribs[k.rawValue] = v }
    return XMLTag(name.rawValue, compact: compact, attributes: attribs)
}

internal func XMLTag<E, E2>(_ name: E,
                        compact: Bool = false,
                        attributes: [(E2, String)]) -> XMLElement where E: RawRepresentable, E.RawValue == String, E2: RawRepresentable, E2.RawValue == String {
    let attribs = attributes.map({ return ($0.0.rawValue, $0.1) })
    return XMLTag(name.rawValue, compact: compact, attributes: attribs)
}
internal func XMLTag<E, E2>(_ name: E,
                        compact: Bool = false,
                        attribute: (E2, String)) -> XMLElement where E: RawRepresentable, E.RawValue == String, E2: RawRepresentable, E2.RawValue == String {
    return XMLTag(name.rawValue, compact: compact, attribute: (attribute.0.rawValue, attribute.1))
}
