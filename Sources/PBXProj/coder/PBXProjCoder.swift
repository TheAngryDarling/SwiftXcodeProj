//
//  PBXProjCoder.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-15.
//

import Foundation
import CodableHelpers
import CodeTimer
import SwiftClassCollections

/// Encoder for Xcode PBX Project File
public final class PBXProjEncoder: BasicClosedEncoder<PBXProj, Data> {
    
    /// String encoding type for this encoder
    public var encoding: String.Encoding = .utf8
    /// Tab representation
    public var tabs: String = " "
    
    public init() {
        super.init { e, v in
            let enc: PBXProjEncoder = e as! PBXProjEncoder
            
            guard let content = v as? [String: Any] else {
                throw EncodingError.invalidValue(v, EncodingError.Context(codingPath: [], debugDescription: "Top-level expected [String: Any] but found \(type(of: v))"))
            }
            //print(content)
            return try PBXProjSerialization.encode(content: content,
                                                        usingSingleIndentString: enc.tabs,
                                                        withEncoding: enc.encoding,
                                                        userInfo: enc.userInfo)
        }
    }
}

private struct Unboxer: BaseDecoderTypeUnboxing {
    public func unbox(_ value: Any, as type: Int.Type, atPath codingPath: [CodingKey]) throws -> Int? {
        if let s = value as? String, let iValue = Int(s) { return iValue }
        else { return nil }
        /*if var s = value as? String {
         if s.hasPrefix("\"") && s.hasSuffix("\"") {
         s.removeFirst()
         s.removeLast()
         }
         if let iValue = Int(s) { return iValue }
         else { return nil }
         } else { return nil }*/
    }
    
    public func unbox(_ value: Any, as type: UInt.Type, atPath codingPath: [CodingKey]) throws -> UInt? {
        if let s = value as? String, let iValue = UInt(s) { return iValue }
        else { return nil }
        /*if var s = value as? String {
         if s.hasPrefix("\"") && s.hasSuffix("\"") {
         s.removeFirst()
         s.removeLast()
         }
         if let iValue = UInt(s) { return iValue }
         else { return nil }
         } else { return nil }*/
    }
}

/// Decoder for Xcode PBX Project Files
public final class PBXProjDecoder: BasicClosedDecoder<PBXProj, Data> {
    
    /// String encoding type used with this decoder
    public var encoding: String.Encoding = .utf8
    /// Tab representation used with this decoder
    public var tabs: String = " "
    
    public init() {
        super.init(unboxer: Unboxer()) { e, d in
            let dec: PBXProjDecoder = e as! PBXProjDecoder
            let sT: (TimeInterval, (encoding: String.Encoding, singleIndent: String, content: [String: Any])) = try Timer.timeWithResults {
                return try PBXProjSerialization.decode(data: d, userInfo: dec.userInfo)
            }
            //debugPrint("PBXProj deserialization took \(sT.0) s")
            let rtn = sT.1
            //print(rtn)
            dec.encoding = rtn.encoding
            dec.tabs = rtn.singleIndent
            //print(PBXProjDecoder.printDict(rtn.content))
            return rtn.content
        }
    }
    
    
    
    private static func printDict(_ dict: [String: Any], _ level: Int = 0) -> String {
        guard dict.count > 0 else { return "{ }" }
        var tabs = "\t".repeated(level)
        var rtn: String = "{\n"
        let closingBrace = tabs + "}"
        tabs += "\t"
        for (k, v) in dict {
            rtn += tabs + k + ": "
            if let dV = v as? [String: Any] {
                rtn += printDict(dV, level + 1) + "\n"
            } else if let aV = v as? [Any] {
                 rtn += printDict(aV, level + 1) + "\n"
            } else {
                rtn += printDict(v, level + 1) + "\n"
            }
        }
        
        rtn += closingBrace
        return rtn
        
    }
    private static func printDict(_ ary: [Any], _ level: Int = 0) -> String {
        guard ary.count > 0 else { return "[ ]" }
        var tabs = "\t".repeated(level)
        var rtn: String = "[\n"
        let closingBrace = tabs + "]"
        tabs += "\t"
        for (i,v) in ary.enumerated() {
            if let dV = v as? [String: Any] {
                rtn += tabs + printDict(dV, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            } else if let aV = v as? [Any] {
                rtn += tabs + printDict(aV, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            } else {
                rtn += tabs + printDict(v, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            }
        }
        
        rtn += closingBrace
        return rtn
    }
    
    private static func printDict(_ val: Any, _ level: Int = 0) -> String {
        return "\(val) (\(type(of: val)))"
    }
    
}

/// This decoder should only be used in the PBXProj init(from: 
internal class PBXProjOpenDecoder: BasicOpenDecoder<Data> {
    /// String encoding type used with this decoder
    public var encoding: String.Encoding = .utf8
    /// Tab representation used with this decoder
    public var tabs: String = " "
    
    public init() {
        super.init(unboxer: Unboxer()) { e, d in
            let dec: PBXProjOpenDecoder = e as! PBXProjOpenDecoder
            let sT: (TimeInterval, (encoding: String.Encoding, singleIndent: String, content: [String: Any])) = try Timer.timeWithResults {
                return try PBXProjSerialization.decode(data: d, userInfo: dec.userInfo)
            }
            //debugPrint("PBXProj deserialization took \(sT.0) s")
            let rtn = sT.1
            //print(rtn)
            dec.encoding = rtn.encoding
            dec.tabs = rtn.singleIndent
            //print(PBXProjOpenDecoder.printDict(rtn.content))
            return rtn.content
        }
    }
    
    
    
    private static func printDict(_ dict: [String: Any], _ level: Int = 0) -> String {
        guard dict.count > 0 else { return "{ }" }
        var tabs = "\t".repeated(level)
        var rtn: String = "{\n"
        let closingBrace = tabs + "}"
        tabs += "\t"
        for (k, v) in dict {
            rtn += tabs + k + ": "
            if let dV = v as? [String: Any] {
                rtn += printDict(dV, level + 1) + "\n"
            } else if let aV = v as? [Any] {
                rtn += printDict(aV, level + 1) + "\n"
            } else {
                rtn += printDict(v, level + 1) + "\n"
            }
        }
        
        rtn += closingBrace
        return rtn
        
    }
    private static func printDict(_ ary: [Any], _ level: Int = 0) -> String {
        guard ary.count > 0 else { return "[ ]" }
        var tabs = "\t".repeated(level)
        var rtn: String = "[\n"
        let closingBrace = tabs + "]"
        tabs += "\t"
        for (i,v) in ary.enumerated() {
            if let dV = v as? [String: Any] {
                rtn += tabs + printDict(dV, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            } else if let aV = v as? [Any] {
                rtn += tabs + printDict(aV, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            } else {
                rtn += tabs + printDict(v, level + 1)
                if i < ary.count - 1 { rtn += "," }
                rtn += "\n"
            }
        }
        
        rtn += closingBrace
        return rtn
    }
    
    private static func printDict(_ val: Any, _ level: Int = 0) -> String {
        return "\(val) (\(type(of: val)))"
    }
}
