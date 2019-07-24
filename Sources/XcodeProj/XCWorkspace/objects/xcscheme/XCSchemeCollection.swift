//
//  XCSchemeCollection.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-30.
//

import Foundation

public class XCSchemeCollection<Element>: XCSchemeObject, MutableCollection where Element: XCSchemeObject {
    
    internal class var XML_ELEMENT_NAME: String { fatalError("Must be implement in inherited classes") }
    
    internal override class var EXCLUDED_ELEMENTS: [String] { return [XML_ELEMENT_NAME] }
    
    internal var base: [Element] = []
    
    public var count: Int { return self.base.count }
    public var startIndex: Int { return self.base.startIndex }
    public var endIndex: Int { return self.base.endIndex }
    
    public override init() { super.init() }
    
    public required init(from element: XMLElement) throws {
        try super.init(from: element)
        
        //let children = element.elements(forName: XCSchemeCollection.XML_ELEMENT_NAME)
        let children = element.elements(forName: type(of: self).XML_ELEMENT_NAME)
        for child in children {
            base.append(try Element(from: child))
        }
    }
    
    public override func encode(to element: XMLElement) throws {
        try super.encode(to: element)
        
    }
    
    public subscript(index: Int) -> Element {
        get { return self.base[index] }
        set { self.base[index] = newValue}
    }
    
    public func index(after i: Int) -> Int {
        return self.base.index(after: i)
    }
    
}
