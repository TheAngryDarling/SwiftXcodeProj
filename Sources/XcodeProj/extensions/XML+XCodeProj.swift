//
//  XML+XcodeProj.swift
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

extension XMLElement {
    
    /// Find the first element with the given name
    ///
    /// - Parameter name: The name of the element to find
    /// - Returns: The found element or nil if not found
    internal func firstElement(forName name: String) -> XMLElement? {
        return self.elements(forName: name).first
    }
    /// Find the first element with the given name
    ///
    /// - Parameter name: The name of the element to find
    /// - Returns: The found element or nil if not found
    internal func firstElement<E>(forName name: E) -> XMLElement? where E: RawRepresentable, E.RawValue == String {
        return self.firstElement(forName: name.rawValue)
    }
    
}
