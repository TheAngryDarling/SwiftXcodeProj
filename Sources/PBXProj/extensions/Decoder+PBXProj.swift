//
//  Decoder+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2021-10-03.
//

import Foundation
import AdvancedCodableHelpers

internal extension Decoder {
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
    ///     let objects = try dynamicElementDecoding(from: decoder, usingKey: "id") {
    ///         return try EncodingElement(from: $0)
    ///     }
    ///
    /// - Parameters:
    ///   - elementKey: The coding key
    ///   - decodingFunc: Function used for decoding data into specific object type.  This helps when the array is a base type/protocol while the instances could be different inherited types
    /// - Returns: Returns an array of decoded objects
    func dynamicElementDecoding<Element, R>(usingKey elementKey: R,
                                            decodingFunc: (_ decoder: Decoder) throws -> Element) throws -> Array<Element> where R: RawRepresentable, R.RawValue == String {
        return try self.dynamicElementDecoding(usingKey: elementKey.rawValue, decodingFunc: decodingFunc)
     }
}
