//
//  Encoder+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2021-10-03.
//

import Foundation
import AdvancedCodableHelpers

internal extension Encoder {
    /// Provides an easy way of encoding an array of objects like a dictionary using one of the object properties as the key.
    ///
    /// Note: Array order is not guarenteed.  This is dependant on how the the EncodingType handles Dictionaries
    ///
    ///     struct EncodingElement: Encodable {
    ///         let id: String
    ///         let variableA: Int
    ///         let variableB: Bool
    ///     }
    ///
    ///     let objects: [EncodingElement] = [...]
    ///
    ///     try encoder.dynamicElementEncoding(objects, to: encoder, elementKey: "id")
    ///
    ///     // This converts the encoded objects to (in JSON)
    ///     {
    ///         "{id}": { variableA: 3, variableB: false },
    ///         ...
    ///     }
    ///
    /// - Parameters:
    ///   - s: Sequence of Encodable elements to dynamically encode
    ///   - elementKey: The CodingKey within the Element to encode to
    func dynamicElementEncoding<S, R>(_ s: S,
                                   usingKey elementKey: R) throws where S: Sequence, S.Element: Encodable, R: RawRepresentable, R.RawValue == String {
        
        try self.dynamicElementEncoding(s, usingKey: elementKey.rawValue)
    }
}
