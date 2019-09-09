//
//  CodableHelpers+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2019-07-12.
//

import Foundation
import AdvancedCodableHelpers

internal extension CodableHelpers.sequences {
    /// Provides an easy way of decoding dictionaries of objects like an array using the key as one of the object property values.
    ///
    /// Note: Array order is not guarenteed.  This is dependant on how the the DecodingType handles Dictionaries
    ///
    ///     struct EncodingElement: Decodable {
    ///         let id: String
    ///         let variableA: Int
    ///         let variableB: Bool
    ///     }
    ///
    ///     // JSON data that is in the decoder
    ///     {
    ///         "{id}": { variableA: 3, variableB: false },
    ///         ...
    ///     }
    ///
    ///     let objects = try dynamicElementDecoding(from: decoder, usingKey: CodingKey.key) {
    ///         return try EncodingElement(from: $0)
    ///     }
    ///
    /// - Parameters:
    ///   - decoder: The decoder to decode the objects from
    ///   - elementKey: The coding key
    ///   - decodingFunc: Function used for decoding data into specific object type.  This helps when the array is a base type/protocol while the instances could be different inherited types
    /// - Returns: Returns an array of decoded objects
    static func dynamicElementDecoding<Element, R>(from decoder: Decoder,
                                                   usingKey elementKey: R,
                                                   decodingFunc: (_ decoder: Decoder) throws -> Element) throws -> Array<Element> where R: RawRepresentable, R.RawValue == String {
        
        return try dynamicElementDecoding(from: decoder,
                                          usingKey: elementKey.rawValue,
                                          decodingFunc: decodingFunc)
    }
    
    
    // Provides an easy way of encoding an array of objects like a dictionary using one of the object properties as the key.
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
    ///     try CodableHelpers.sequences.dynamicElementEncoding(objects, to: encoder, elementKey: CodingKey.key)
    ///
    ///     // This converts the encoded objects to (in JSON)
    ///     {
    ///         "{id}": { variableA: 3, variableB: false },
    ///         ...
    ///     }
    ///
    /// - Parameters:
    ///   - s: Sequence of Encodable elements to dynamically encode
    ///   - encoder: The encoder to encode the objects to
    ///   - elementKey: The CodingKey within the Element to encode to
    static func dynamicElementEncoding<S, R>(_ s: S,
                                             to encoder: Encoder,
                                             usingKey elementKey: R) throws where S: Sequence, S.Element: Encodable, R: RawRepresentable, R.RawValue == String {
        
        return try dynamicElementEncoding(s, to: encoder, usingKey: elementKey.rawValue)
    }
}
