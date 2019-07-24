//
//  PListCoders.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-16.
//

import Foundation
import CodableHelpers


/// Property List Encoder.  Usefull on both Mac and Linux
internal class PListEncoder: BasicOpenEncoder<Data> {
    public var outputFormat: PropertyListSerialization.PropertyListFormat = .xml
    public init() {
        super.init { e, v in
            let enc: PListEncoder = e as! PListEncoder
            return try PropertyListSerialization.data(fromPropertyList: v,
                                                      format: enc.outputFormat,
                                                      options: 0)
        }
    }
}

/// Property List Decoder.  usefull on both Mac and Linux
internal class PListDecoder: BasicOpenDecoder<Data> {
    public var options: PropertyListSerialization.MutabilityOptions = []
    public var format: PropertyListSerialization.PropertyListFormat = .xml
    public init() {
        super.init { e, d in
            let dec: PListDecoder = e as! PListDecoder
            
            return try PropertyListSerialization.propertyList(from: d,
                                                              options: dec.options,
                                                              format: &dec.format)
        }
    }
}
