//
//  PBXProjSerialization.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-10-28.
//

import Foundation
import CoreFoundation
import StringIANACharacterSetEncoding
import Nillable
import CodeTimer

/// The Serialization and Deseriazation of PBXProj files
public final class PBXProjSerialization {
    
    enum ObjectType {
        case comment
        case complex
        case array
        case value
    }
    
    enum Error: Swift.Error {
        case unableToDetermineFileEncoding
        case unableToFindFileEncodingFrom(String)
        case unableToDecodeProjectDataWithEncoding(String.Encoding)
        case unableToFindBeginningOfRootObject
        //case invalidStartOfComplexObject(Character)
        case missingEndingSemicolonOnComplexObject(line: Int, column: Int)
        case unableToParseObjectName(line: Int, column: Int)
        case unableToParseObjectValue(line: Int, column: Int)
        case unableToEncodeProjectUsing(String.Encoding)
        //case invalidObjectType(Any)
        case unableToIdentifyEncoding(String)
        
        case unableToGetIANACharacterEncodingFor(String.Encoding)
        
        case missingClosingOfObject(objectType: ObjectType, closingSequence: String, atIndex: String.Index, startingAtLocation: (line: Int, column: Int))
        case invalidStartOfObject(objectType: ObjectType, expecting: String, found: String, atIndex: String.Index, atLocation: (line: Int, column: Int))
    }
    
    /// Some values read in look like Floats but arn't, We needt to keep the trailing 0's so we must force them to be read as string
    /*private static let FORCE_STRING_ENCODING_END_PATHS: [String] = ["/objects/[^/]+/buildSettings/SWIFT_VERSION$",
                                                                    "/objects/[^/]+/buildSettings/[^/]+_DEPLOYMENT_TARGET$"]*/
    /// Some values read in look like Floats but arn't, We needt to keep the trailing 0's so we must force them to be read as string
    /// Any build setting simple values will now be read as strings
    private static let FORCE_STRING_ENCODING_END_PATHS: [String] = ["/objects/[^/]+/buildSettings/.+",
                                                                    "/object/[^/]+/attributes/.+",
                                                                    "/objects/[^/]/defaultConfigurationIsVisible"]
    
    /// Characters to escape and their replacement within strings
    private static let esacpedCharacters: [(raw: String, escaped: String)] = [
        ("\\", "\\\\"),
        ("\t", "\\t"),
        ("\n", "\\n"),
        ("\r", "\\r"),
        ("\"", "\\\"")
    ]
    
    /// Exclusing characters when mapping object ID's
    private static let KEY_REGEX_CHARACTERS: String = ";\\*\\{\\}\\n\\t"
    
    private init() { }
    
    private static func isForcedStringType(atPath path: [String],
                                           havingObjectVersion objectVersion: Int,
                                           havingArchiveVersion archiveVersion: Int) -> Bool {
        let strPath: String = "/" + path.joined(separator: "/")
        for pattern in FORCE_STRING_ENCODING_END_PATHS {
            if strPath.match(pattern) { return true }
        }
        return false
    }
    
    /// Checks to see of a given string has characters that require escaping
    ///
    /// - Parameter string: The string to check and see if it has escaping characters
    /// - Returns: Returns true if the string contains any characters that require escaping otherwise false
    private static func stringHasRequiredEscapingCharacters(_ string: String) -> Bool {
        let requiredEscapingFor: [String] = ["@","$","(",")"," ","\t","\n","<",">","=","-","+", "::"]
        for r in requiredEscapingFor {
            if string.contains(r) { return true }
        }
        return false
    }
    
    /// Decode the contente of a given PBX Project File
    ///
    /// - Parameters:
    ///   - data: The PBX Project File data
    ///   - userInfo: Any user info
    /// - Returns: Returns a tuple of the string encoding, single tab, and content dictionary for this data
    public static func decode(data: Data, userInfo: [CodingUserInfoKey: Any]) throws -> (encoding: String.Encoding, singleIndent: String, content: [String: Any]) {
        var idx: Int = 0
        let newLineCode: UInt8 = 0x0A
        let charReturnCode: UInt8 = 0x0D
        
        while data[idx] != newLineCode { idx += 1 }
        if data[idx - 1] == charReturnCode { idx -= 1 }
        
        let encodingData = data[0..<idx]
        guard let encodingString = String(data: encodingData, encoding: .utf8) else {
            throw Error.unableToDetermineFileEncoding
        }
        
        let regEx = try! NSRegularExpression(pattern: "^// \\!\\$\\*(.+)\\*\\$\\!$")
        guard let firstMatch = regEx.firstMatch(in: encodingString, range: encodingString.completeNSRange) else {
            throw Error.unableToFindFileEncodingFrom(encodingString)
        }
        
       
        let encodingStringValue = String(encodingString[Range(firstMatch.range(at: 1), in: encodingString)!])
        guard let encoding = String.Encoding(IANACharSetName: encodingStringValue) else {
            throw Error.unableToIdentifyEncoding(encodingStringValue)
        }
        
        //guard let projStr = String(data: data, encoding: encoding) else {
        // Only convert from second line on using specific encoding type
        guard let projStr = String(data: data[idx..<data.count], encoding: encoding) else {
            throw Error.unableToDecodeProjectDataWithEncoding(encoding)
        }
        
        guard let beginningOfRootObject = projStr.range(of: "{") else {
            throw Error.unableToFindBeginningOfRootObject
        }
        
        var indents: String = ""
        
        let regExIndents = try! NSRegularExpression(pattern: "^(\\s+)\\w", options: .anchorsMatchLines)
        if let firstMatchIndents = regExIndents.firstMatch(in: projStr, range: encodingString.completeNSRange)  {
            indents = String(projStr[Range(firstMatchIndents.range(at: 1), in: projStr)!])
        }
        
        
        
        func propIntValue(for prop: String, in string: String) -> Int {
            var rtn: Int = -1
            
            if let r = string.range(of: prop) {
                var endIdx = r.upperBound
                //Find end if property
                while string[endIdx] != ";" { endIdx = string.index(after: endIdx) }
                let propStr = String(string[r.lowerBound..<endIdx])
                let components = propStr.split(separator: "=").map(String.init)
                var value = components[1]
                
                while value.hasPrefix(" ") { value.removeFirst() }
                while value.hasSuffix(" ") { value.removeLast() }
                
                if value.hasPrefix("\"") && value.hasSuffix("\"") {
                    value.removeFirst()
                    value.removeLast()
                }
                
                if let r = Int(value) {
                    rtn = r
                }
 
            }
            
            
            return rtn
        }
        
        let objectVersion: Int = propIntValue(for: "objectVersion", in: projStr)
        let archiveVersion: Int = propIntValue(for: "archiveVersion", in: projStr)
        
        
        
        
        let fileObjects = try decodeComplexObject(from: projStr,
                                                  startingAt: beginningOfRootObject.lowerBound,
                                                  atPath: [],
                                                  inData: [:],
                                                  isRootObject: true,
                                                  havingObjectVersion: objectVersion,
                                                  havingArchiveVersion: archiveVersion,
                                                  userInfo: userInfo).content
        
        return (encoding: encoding, singleIndent: indents, content: fileObjects)
        
    }
    
    /// Determins the Line and Column of the given index within a string
    ///
    /// - Parameters:
    ///   - string: The string to look into
    ///   - index: The position within the string to calculate for
    /// - Returns: Returns a tuple containing the line number and column number of the given index
    private static func getLineCharPos(from string: String,
                                       atIndex index: String.Index) -> (line: Int, column: Int) {
        let lines = string.countOccurrences(of: "\n", inRange: string.startIndex..<index)
        var beginningOfLineIndex: String.Index = string.startIndex
        if let r = string.range(of: "\n", options: .backwards, range: string.startIndex..<index) {
            beginningOfLineIndex = r.lowerBound
        }
        
        let column = string.distance(from: beginningOfLineIndex, to: index)
        
        return (line: (lines + 1), column: column)
        
    }
    
    /// Finds the next available index outside a comment (/*....*/) section
    ///
    /// - Parameters:
    ///   - string: The working string (Should start with /*)
    ///   - index: The current index within the string
    ///   - path: The current path with the decoding sequence (Must like CodingKey)
    /// - Returns: Returns the next available index after the current comment section
    private static func decodePastComment(from string: String,
                                          startingAt index: String.Index,
                                          atPath path: [String]) throws -> String.Index {
        var workingIndex: String.Index = index
        workingIndex = string.index(workingIndex, offsetBy: 2) // Move after beginning of comment
        if string.range(of: "*/", range: workingIndex..<string.endIndex) == nil {
            throw Error.missingClosingOfObject(objectType: .comment,
                                               closingSequence: "*/",
                                               atIndex: index,
                                               startingAtLocation: getLineCharPos(from: string, atIndex: index))
        }
        
        while !(string[workingIndex] == "*" && string[string.index(after: workingIndex)] == "/") &&
             workingIndex < string.endIndex {
            if string[workingIndex] == "/" && string[string.index(after: workingIndex)] == "*" {
                workingIndex = try decodePastComment(from: string, startingAt: workingIndex, atPath: path)
                // Must recheck for closing comment because prevouse check would have picked up inner comments
                if string.range(of: "*/", range: workingIndex..<string.endIndex) == nil {
                    throw Error.missingClosingOfObject(objectType: .comment,
                                                       closingSequence: "*/",
                                                       atIndex: index,
                                                       startingAtLocation: getLineCharPos(from: string, atIndex: index))
                }
            } else {
                workingIndex = string.index(after: workingIndex)
            }
        }
        return string.index(workingIndex, offsetBy: 2) // Move after ending of comment
    }
    
    /// Stores the given value within the complate data dictionary
    ///
    /// - Parameters:
    ///   - value: The value to store
    ///   - data: The complete data dictionary (From root of the coding process)
    ///   - path: The path within the data dictionary to store the value
    /// - Returns: Returns a new copy of the data dictionary with the value added
    private static func adding(_ value: Any,
                               to data: [String: Any],
                               atPath path: [String]) -> [String: Any] {
        func _adding(_ value: Any, to data: [String: Any], atPath path: [String]) -> [String: Any] {
            guard path.count > 0 else { return data }
            
            var rtn: [String: Any] = data
            
            if path.count == 1 {
                rtn[path[0]] = value
            } else {
                if path.count == 2 && path[1].hasPrefix("[") && path[1].hasSuffix("]")  {
                    if !rtn.keys.contains(path[0]) { rtn[path[0]] = Array<Any>() }
                    if var ary = rtn[path[0]] as? [Any] {
                        ary.append(value)
                        rtn[path[0]] = ary
                    }
                } else if let subDta = rtn[path[0]] as? [String: Any] {
                    rtn[path[0]] = _adding(value, to: subDta, atPath: path.removingFirst())
                }
            }
            
            return rtn
        }
        return _adding(value, to: data, atPath: path)
    }
    
    /// Decode a complex object from within the string
    ///
    /// - Parameters:
    ///   - string: The string representing the PBX Project file
    ///   - index: The starting index of the object
    ///   - path: The current path of the object
    ///   - data: The complete dictonary of the decoded data so far
    ///   - acceptableEndingSequences: An array containing the possible ending sequences for this object type (Default: ;)
    ///   - isRootObject: Indicator of this is a root object.  Root objects have no ending sequence characters (Default: false)
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info
    /// - Returns: Returns a tuple containind a dictionary of the given complex object, and the string index just after the object in the file
    private static func decodeComplexObject(from string: String,
                                            startingAt index: String.Index,
                                            atPath path: [String],
                                            inData data: [String: Any],
                                            acceptableEndingSequences: [String] = [";"],
                                            isRootObject: Bool = false,
                                            havingObjectVersion objectVersion: Int,
                                            havingArchiveVersion archiveVersion: Int,
                                            userInfo: [CodingUserInfoKey: Any]) throws -> (content: [String: Any], endingAt: String.Index) {
        
        
        guard string[index] == "{" else {
            throw Error.invalidStartOfObject(objectType: .complex,
                                             expecting: "}",
                                             found: String(string[index]),
                                             atIndex: index,
                                             atLocation: getLineCharPos(from: string, atIndex: index))
        }
        
        
        var rtn: [String: Any] = [:]
        
        let endingObject: Character = "}"
        var workingIndex: String.Index = string.index(after: index)
        
        //let _ = try Timer.time {
        
            while string[workingIndex] != endingObject {
                //let innerString = String(string.suffix(from: workingIndex))
                let workingIndexChar = string[workingIndex]
                if workingIndexChar == " " ||
                    workingIndexChar == "\t" ||
                    workingIndexChar == "\r" ||
                    workingIndexChar == "\n" {
                    //Ignore white space characters
                    workingIndex = string.index(after: workingIndex)
                } else if workingIndexChar == "/" && string[string.index(after: workingIndex)] == "*" {
                    // Skip comment lines
                    workingIndex = try decodePastComment(from: string, startingAt: workingIndex, atPath: path)
                    /*guard let r = string.range(of: "* /", range: workingIndex..<string.endIndex) else {
                        fatalError()
                    }
                    workingIndex = r.upperBound*/
                } else {
                    
                    let objectNameRegex = try! NSRegularExpression(pattern: "([^\(KEY_REGEX_CHARACTERS)]+) (/\\*([^\(KEY_REGEX_CHARACTERS)]+)\\*/\\s)?= (.{1})")
                    var range = workingIndex..<string.endIndex
                    
                    #if !_runtime(_ObjC)
                    var eol = string.index(after: workingIndex)
                    while eol != string.endIndex && string[eol] != "\n" { eol = string.index(after: eol) }
                    range = workingIndex..<eol
                    #endif
                    //let range = workingIndex..<(string.index(workingIndex, offsetBy: 256, limitedBy: string.endIndex) ?? string.endIndex )
                    
                    guard let firstMatch = objectNameRegex.firstMatch(in: string, range: NSRange(range, in: string)) else {
                        let location = getLineCharPos(from: string, atIndex: range.lowerBound)
                        throw Error.unableToParseObjectName(line: location.line, column: location.column)
                    }
                    
                    var objectName = String(string[Range(firstMatch.range(at: 1), in: string)!])
                    
                   //print("Decoding Object '\(path.reduce("", { return $0 + "/" + $1 }))/\(objectName)'")
                    
                    let objectTypeRange = Range(firstMatch.range(at: 4), in: string)!
                    let objectType = String(string[objectTypeRange])
                    
                    
                    
                    if objectType == "{" {
                        
                        if objectName.hasPrefix("\"") && objectName.hasSuffix("\"") {
                            objectName.removeFirst()
                            objectName.removeLast()
                        }
                        
                        let innerObjects = try decodeComplexObject(from: string,
                                                                   startingAt: objectTypeRange.lowerBound,
                                                                   atPath: path.appending(objectName),
                                                                   inData: adding(rtn, to: data, atPath: path),
                                                                   havingObjectVersion: objectVersion,
                                                                   havingArchiveVersion: archiveVersion,
                                                                   userInfo: userInfo)
                        rtn[objectName] = innerObjects.content
                        workingIndex = innerObjects.endingAt
                    } else if objectType == "(" {
                        let innerObjects = try decodeObjectList(from: string,
                                                                startingAt: objectTypeRange.lowerBound,
                                                                atPath: path.appending(objectName),
                                                                inData: adding(rtn, to: data, atPath: path),
                                                                havingObjectVersion: objectVersion,
                                                                havingArchiveVersion: archiveVersion,
                                                                userInfo: userInfo)
                        rtn[objectName] = innerObjects.content
                        workingIndex = innerObjects.endingAt
                    } else {
                        let childObjectDetails = try decodeObjectValue(from: string,
                                                                       startingAt: objectTypeRange.lowerBound,
                                                                       atPath: path.appending(objectName),
                                                                       inData: adding(rtn, to: data, atPath: path),
                                                                       acceptableEndingSequences: [";"],
                                                                       havingObjectVersion: objectVersion,
                                                                       havingArchiveVersion: archiveVersion,
                                                                       userInfo: userInfo)
                        rtn[objectName] = childObjectDetails.content
                        workingIndex = childObjectDetails.endingAt
                        //
                        //workingIndex = string.index(after: workingIndex)
                    }
                    
                }
            }
            // Move after closing brace }
            workingIndex = string.index(after: workingIndex)
            if !isRootObject {
                //let innerString = String(string.suffix(from: workingIndex))
                guard acceptableEndingSequences.contains(String(string[workingIndex])) else {
                    let location = getLineCharPos(from: string, atIndex: workingIndex)
                    //let strRest = String(string.suffix(from: workingIndex))
                    throw Error.missingEndingSemicolonOnComplexObject(line: location.line, column: location.column)
                }
                workingIndex = string.index(after: workingIndex)
                
            }
        //}
        
        //debugPrint("decodeComplexObject(/\(path.joined(separator: "/"))) Took \(duration)s")
        
        return (content: rtn, endingAt: workingIndex)
        
    }
    
    /// Decode an array of items from within the string
    ///
    /// - Parameters:
    ///   - string: The string representing the PBX Project file
    ///   - index: The starting index of the object
    ///   - path: The current path of the object
    ///   - data: The complete dictonary of the decoded data so far
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info
    /// - Returns: Returns a tuple containing an array of the given objects, and the string index just after the array in the file
    private static func decodeObjectList(from string: String,
                                         startingAt index: String.Index,
                                         atPath path: [String],
                                         inData data: [String: Any],
                                         havingObjectVersion objectVersion: Int,
                                         havingArchiveVersion archiveVersion: Int,
                                         userInfo: [CodingUserInfoKey: Any])  throws ->(content: [Any], endingAt: String.Index) {
        guard string[index] == "(" else {
            throw Error.invalidStartOfObject(objectType: .array,
                                             expecting: "(",
                                             found: String(string[index]),
                                             atIndex: index,
                                             atLocation: getLineCharPos(from: string, atIndex: index))
        }
        
        var rtn: [Any] = []
        
        let endingObject: Character = ")"
        var workingIndex: String.Index = string.index(after: index)
        
        //let _ = try Timer.time {
            //var innerRange = String(string[workingIndex..<string.endIndex])
            while string[workingIndex] != endingObject {
              //  innerRange = String(string[workingIndex..<string.endIndex])
                if string[workingIndex] == " " ||
                    string[workingIndex] == "," ||
                    string[workingIndex] == "\t" ||
                    string[workingIndex] == "\r" ||
                    string[workingIndex] == "\n" {
                    //Ignore white space characters
                    workingIndex = string.index(after: workingIndex)
                } else {
                    let firstChar = string[workingIndex]
                    if firstChar == "{" {
                        let childObjectDetails = try decodeComplexObject(from: string,
                                                                         startingAt: workingIndex,
                                                                         atPath: path.appending("[\(rtn.count)]"),
                                                                         inData: adding(rtn, to: data, atPath: path),
                                                                         acceptableEndingSequences: [","],
                                                                         havingObjectVersion: objectVersion,
                                                                         havingArchiveVersion: archiveVersion,
                                                                         userInfo: userInfo)
                        rtn.append(childObjectDetails.content)
                        workingIndex = childObjectDetails.endingAt
                        
                    } else if firstChar == "(" {
                        let childObjectDetails = try decodeObjectList(from: string,
                                                                      startingAt: workingIndex,
                                                                      atPath: path.appending("[\(rtn.count)]"),
                                                                      inData: adding(rtn, to: data, atPath: path),
                                                                      havingObjectVersion: objectVersion,
                                                                      havingArchiveVersion: archiveVersion,
                                                                      userInfo: userInfo)
                        
                        rtn.append(childObjectDetails.content)
                        workingIndex = childObjectDetails.endingAt
                        
                    } else {
                        let childObjectDetails = try decodeObjectValue(from: string,
                                                                       startingAt: workingIndex,
                                                                       atPath: path.appending("[\(rtn.count)]"),
                                                                       inData: adding(rtn, to: data, atPath: path),
                                                                       acceptableEndingSequences: ["\\,","\n"],
                                                                       specialExcludeCharacters: ",",
                                                                       havingObjectVersion: objectVersion,
                                                                       havingArchiveVersion: archiveVersion,
                                                                       userInfo: userInfo)
                        rtn.append(childObjectDetails.content)
                        workingIndex = childObjectDetails.endingAt
                    }
                    
                    
                }
            }
            //Move to after end of object )
            workingIndex = string.index(after: workingIndex)
            
            guard string[workingIndex] == ";" else {
                //let innerString = String(string.suffix(from: workingIndex))
                let location = getLineCharPos(from: string, atIndex: workingIndex)
                throw Error.missingEndingSemicolonOnComplexObject(line: location.line, column: location.column)
            }
            workingIndex = string.index(after: workingIndex)
        
        //}
        
        //debugPrint("decodeObjectList(/\(path.joined(separator: "/"))) Took \(duration)s")
        
        return (content: rtn, endingAt: workingIndex)
        
        
    }
    
    /// Decode an object from within the string
    ///
    /// - Parameters:
    ///   - string: The string representing the PBX Project file
    ///   - index: The starting index of the object
    ///   - path: The current path of the object
    ///   - data: The complete dictonary of the decoded data so far
    ///   - acceptableEndingSequences: An array containing the possible ending sequences for this object type
    ///   - specialExcludeCharacters: Characters to exclude when trying to find object pattern
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info
    /// - Returns: Returns a tuple containing the content of the given object, and the string index just after the object in the file
    private static func decodeObjectValue(from string: String,
                                          startingAt index: String.Index,
                                          atPath path: [String],
                                          inData data: [String: Any],
                                          acceptableEndingSequences: [String],
                                          specialExcludeCharacters: String = "",
                                          havingObjectVersion objectVersion: Int,
                                          havingArchiveVersion archiveVersion: Int,
                                          userInfo: [CodingUserInfoKey: Any])  throws -> (content: Any, endingAt: String.Index) {
        
        var endingSequeneces: String = ""
        for e in acceptableEndingSequences {
            if endingSequeneces != "" { endingSequeneces += "|" }
            endingSequeneces += e
        }
        
        var wholeRange = index..<string.endIndex
        var objectValue: String = ""
        
        var workingIndex = index
        // Move past any preceeding spaces
        while string[workingIndex] == " " { workingIndex = string.index(after: workingIndex) }
        
        if string[workingIndex] == "\"" {
            // Move past opening quote
            workingIndex = string.index(after: workingIndex)
            // Loop until we find the proper non-escaping closing quote
            while workingIndex < string.endIndex &&
                (string[workingIndex] != "\"" || (string[workingIndex] == "\"" && string[string.index(before: workingIndex)] == "\\")) {
                    workingIndex = string.index(after: workingIndex)
            }
            // Ensure we are at the ending quote
            guard string[workingIndex] == "\"" else {
                let location = getLineCharPos(from: string, atIndex: index)
                throw Error.unableToParseObjectValue(line: location.line, column: location.column)
            }
            // Look for the ending character of the value (eg ; or ,)
            while workingIndex < string.endIndex && !endingSequeneces.contains(string[workingIndex]) {
                 workingIndex = string.index(after: workingIndex)
            }
            // Ensure we are at the ending character
            guard endingSequeneces.contains(string[workingIndex]) else {
                let location = getLineCharPos(from: string, atIndex: index)
                throw Error.unableToParseObjectValue(line: location.line, column: location.column)
            }
            
            objectValue = String(string[index..<workingIndex]).replacingOccurrences(of: "\\s+/\\*.*\\*/", with: "", options: .regularExpression)
            // Move just past the ending character
            wholeRange = index..<string.index(after: workingIndex)
        } else {
            // Loop until we we find the ending character
            while workingIndex < string.endIndex && !endingSequeneces.contains(string[workingIndex]) {
                workingIndex = string.index(after: workingIndex)
            }
            // Ensure we find the ending character
            guard endingSequeneces.contains(string[workingIndex]) else {
                let location = getLineCharPos(from: string, atIndex: index)
                throw Error.unableToParseObjectValue(line: location.line, column: location.column)
            }
            
            objectValue = String(string[index..<workingIndex]).replacingOccurrences(of: "\\s+/\\*.*\\*/", with: "", options: .regularExpression)
            // Move just past the ending character
            wholeRange = index..<string.index(after: workingIndex)
            
        }
        
        
        // Will have to process objectValue here for real types
        
        if (objectValue.hasPrefix("\"") && objectValue.hasSuffix("\"")) ||
            isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) {
            
            var wasQuoted: Bool = false
            if (objectValue.hasPrefix("\"") && objectValue.hasSuffix("\"")) {
                wasQuoted = true
                objectValue.removeFirst()
                objectValue.removeLast()
            }
            // Strings that aren't already enclosed in quotes
            if wasQuoted && PBXProj.isPBXEncodinStringEscaping(objectValue,
                                                          //hasKeyIndicators: stringHasRequiredEscapingCharacters(string),
                                                          hasKeyIndicators: stringHasRequiredEscapingCharacters(objectValue),
                                                          atPath: path,
                                                          inData: adding(string, to: data, atPath: path),
                                                          havingObjectVersion: objectVersion,
                                                          havingArchiveVersion: archiveVersion,
                                                          userInfo: userInfo) {
                var workingString = objectValue
                //workingString.removeFirst() // Remove beginning quote
                //workingString.removeLast() // Remove ending quote
               
                for e in esacpedCharacters.reversed() {
                    workingString = workingString.replacingOccurrences(of: e.escaped, with: e.raw)
                }
                objectValue = workingString
            }
            
            return (content: objectValue, endingAt: wholeRange.upperBound)
            
            
        } else {
            if objectValue.lowercased() == "true" { return (content: NSNumber(value: true), endingAt: wholeRange.upperBound) }
            else if objectValue.lowercased() == "false" { return (content: NSNumber(value: false), endingAt: wholeRange.upperBound) }
            else if objectValue.lowercased() == "null" { return (content: NSNull(), endingAt: wholeRange.upperBound) }
            else if objectValue.lowercased() == "nil" { return (content: NSNull(), endingAt: wholeRange.upperBound) }
            else if objectValue.match("^(|\\+)\\d+(\\.\\d+)?[eE](|\\+\\-)\\d+?$") {
                var workingValues = objectValue.lowercased().split(separator: "e").map(String.init)
                
                var digitCount: Int = workingValues[1].count
                if workingValues[0].hasPrefix("-") || workingValues[0].hasPrefix("+") { digitCount -= 1 }
                
                //var exponentCount: Int = workingValues[1].count
                //if workingValues[1].hasPrefix("-") || workingValues[1].hasPrefix("+") { exponentCount -= 1 }
                
                let exponent: Int = Int(workingValues[1]) ?? 0
                
                if digitCount > 17 && exponent >= -128 && exponent <= 127,
                    let decimal = Decimal(string: objectValue), decimal.isFinite {
                    return (content: NSDecimalNumber(decimal: decimal), endingAt: wholeRange.upperBound)
                } else if let doubleValue = Double(objectValue) {
                    return (content: NSNumber(value: doubleValue), endingAt: wholeRange.upperBound)
                } else {
                    return (content: objectValue, endingAt: wholeRange.upperBound)
                }
                
                
            } else if objectValue.match("^(|\\+|\\-)\\d+(\\.\\d+)?$") {
                
                let isNegative: Bool = objectValue.hasPrefix("-")
                let isInteger: Bool = !(objectValue.contains(".") || objectValue.contains("x"))
                var digitCount: Int = objectValue.count
                if objectValue.hasPrefix("-") || objectValue.hasPrefix("+") { digitCount -= 1 }
                
                if isInteger && isNegative && digitCount <= 19, let val = Int(objectValue) {
                    //return (content: val, endingAt: wholeRange.upperBound)
                    return (content: NSNumber(value: val), endingAt: wholeRange.upperBound)
                } else if isInteger && !isNegative && digitCount <= 20, let val = UInt(objectValue) {
                    //return (content: val, endingAt: wholeRange.upperBound)
                    return (content: NSNumber(value: val), endingAt: wholeRange.upperBound)
                } else if let val = Double(objectValue) {
                    return (content: NSNumber(value: val), endingAt: wholeRange.upperBound)
                } else {
                    return (content: objectValue, endingAt: wholeRange.upperBound)
                }
                
                
            }
            else
            {
                return (content: objectValue, endingAt: wholeRange.upperBound)
                
            }
        }
        
        //return (content: objectValue, endingAt: wholeRange.upperBound)
    }
    
    
    /// Encodes the contents into a PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - indents: The representation of a single indent/tab
    ///   - encoding: The type of string encoding to use
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns the data representing a PBX Project file
    public static func encode(content: [String: Any],
                              usingSingleIndentString indents: String,
                              withEncoding encoding: String.Encoding,
                              havingObjectVersion objectVersion: Int,
                              havingArchiveVersion archiveVersion: Int,
                              userInfo: [CodingUserInfoKey: Any]) throws -> Data {
        
        guard let encodName = encoding.noDashIANACharSetName else {
            throw Error.unableToGetIANACharacterEncodingFor(encoding)
        }
        var stringData: String = "// !$*\(encodName.uppercased())*$!\n"
        stringData += "{\n"
        stringData += try encodeObject(content: content,
                                       rootContent: content,
                                      usingSingleIndentString: indents,
                                      currentLevel: 1,
                                      atPath: [],
                                      havingObjectVersion: objectVersion,
                                      havingArchiveVersion: archiveVersion,
                                      userInfo: userInfo)
        stringData += "\n}"
        
        guard let dta = stringData.data(using: encoding) else {
            throw Error.unableToEncodeProjectUsing(encoding)
        }
        return dta
        
    }
    
    /// Returns the content keys in the order they should be encoded in
    ///
    /// - Parameters:
    ///   - content: The complex objet content
    ///   - data:  The complete data being encoded
    ///   - path: The current coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns the complex object keys in encoding order
    private static func getComplexObjectOrder(forContent content: [String: Any],
                                              inData data: [String: Any],
                                              atPath path: [String],
                                              havingObjectVersion objectVersion: Int,
                                              havingArchiveVersion archiveVersion: Int,
                                              userInfo: [CodingUserInfoKey: Any]) -> [String] {
       
        return PBXProj.getPBXEncodingOrderKeys(content,
                                               inData: data,
                                               atPath: path,
                                               havingObjectVersion: objectVersion,
                                               havingArchiveVersion: archiveVersion )
       
        /*if path == [] {
            return PBXProj.orderKeys(content, atPath: path)
        } else if path == ["objects"] {
            return PBXObjects.orderKeys(content, atPath: path)
        } else if path.count == 2 && path[0] == "objects", let isa = content[PBXObject.ISA_CODING_KEY] as? String  {
            return PBXObjectType.init(isa).objectContainerType.orderKeys(content, atPath: path)
        } else {
            var rtn: [String] = []
            rtn.append(contentsOf: content.keys)
            return rtn
        }*/
        
    }
   
    /// Returns any comments for the given value
    ///
    /// - Parameters:
    ///   - value: The value to get comments for
    ///   - path: The current coding path
    ///   - data: The complete encoded data
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns a comment if one exists, otherwise nil
    internal static func getComments(forValue value: String,
                                    atPath path: [String],
                                    inData data: [String: Any],
                                    havingObjectVersion objectVersion: Int,
                                    havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) -> String? {
        return PBXProj.getPBXEncodingComments(forValue: value,
                                              atPath: path,
                                              inData: data,
                                              havingObjectVersion: objectVersion,
                                              havingArchiveVersion: archiveVersion,
                                              userInfo: userInfo)
    }
    
    /// Determins of the current complex object should be multi-line or single line
    ///
    /// - Parameters:
    ///   - content: The complex object dictionary
    ///   - path: The current coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns true if this complex object should be multi-lined otherwise false
    private static func isMultiLineComplexObject(_ content: [String: Any],
                                                 atPath path: [String],
                                                 havingObjectVersion objectVersion: Int,
                                                 havingArchiveVersion archiveVersion: Int,
                                                 userInfo: [CodingUserInfoKey: Any]) -> Bool {
       
        if let isa = content[PBXObject.ObjectCodingKeys.type] as? String {
            // For PBXObject, lets check the object type for indications if it is a multi line object or not
            return PBXObjectType.init(isa).objectContainerType.isPBXEncodingMultiLineObject(content,
                                                                                            atPath: path,
                                                                                            havingObjectVersion: objectVersion,
                                                                                            havingArchiveVersion: archiveVersion,
                                                                                            userInfo: userInfo)
        } else {
            // Any other type of complex object is by default a multi line object.  That includs empty objects
            return true
        }
    
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject(content: [String: Any],
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        //let objects: [String: Any] = (rootContent["objects"] as? [String: Any]) ?? [:]
        let currentIndents = indents.repeated(currentLevel)
        var rtn: String = ""
        var prevObjectSection: String? = nil
        
        let objectOrder = getComplexObjectOrder(forContent: content,
                                                inData: rootContent,
                                                atPath: path,
                                                havingObjectVersion: objectVersion,
                                                havingArchiveVersion: archiveVersion,
                                                userInfo: userInfo)
        
        let oneObjectPerLine: Bool = isMultiLineComplexObject(content, atPath: path,
                                                              havingObjectVersion: objectVersion,
                                                              havingArchiveVersion: archiveVersion,
                                                              userInfo: userInfo)
        
        for key in objectOrder {
            let val = content[key]!
            //print("\(key) - \(type(of: val))")
            if rtn != "" && oneObjectPerLine { rtn += "\n" }
            
            var line: String = ""
            if oneObjectPerLine { line += currentIndents }
            line += key
            if let v = val as? [String: Any] {
                
                if path == ["objects"], let isa = v["isa"] as? String, isa != prevObjectSection {
                    if let sectionEnding = prevObjectSection {
                        rtn += "/* End \(sectionEnding) section */\n"
                    }
                    rtn += "\n/* Begin \(isa) section */\n"
                    prevObjectSection = isa
                }
                
                // Add key comment if one exists
                /*if let keyComments = getComments(forValue: key, inObject: v, lookingInObjectList: objects, atPath: path.appending(key)) {
                    line += " /* \(keyComments) */"
                }*/
                if let keyComments = getComments(forValue: key,
                                                 atPath: path.appending(key),
                                                 inData: rootContent,
                                                 havingObjectVersion: objectVersion,
                                                 havingArchiveVersion: archiveVersion,
                                                 userInfo: userInfo) {
                    line += " /* \(keyComments) */"
                }
               
                line += " = {"
                let isInnerMultiLine = isMultiLineComplexObject(v,
                                                                atPath: path.appending(key),
                                                                havingObjectVersion: objectVersion,
                                                                havingArchiveVersion: archiveVersion,
                                                                userInfo: userInfo)
                if isInnerMultiLine && v.count > 0 { line += "\n" }
                else { line += " " }
                line += try encodeObject(content: v,
                                         rootContent: rootContent,
                                         usingSingleIndentString: indents,
                                         currentLevel: currentLevel + 1,
                                         atPath: path.appending(key),
                                         havingObjectVersion: objectVersion,
                                         havingArchiveVersion: archiveVersion,
                                         userInfo: userInfo)
                if isInnerMultiLine { line += currentIndents }
                line += "};"
                //if !oneObjectPerLine { line += "\n" }
                
                
            } else if let v = val as? [Any] {
                line += " = (\n"
                line += try encodeObject(content: v,
                                     rootContent: rootContent,
                                     usingSingleIndentString: indents,
                                     currentLevel: currentLevel + 1,
                                     atPath: path.appending(key),
                                     havingObjectVersion: objectVersion,
                                     havingArchiveVersion: archiveVersion,
                                     userInfo: userInfo)
                line += currentIndents + ");"
            } else {
                line +=  " = " + (try encodeObject(content: val,
                                              rootContent: rootContent,
                                              usingSingleIndentString: indents,
                                              currentLevel: currentLevel + 1 ,
                                              atPath: path.appending(key),
                                              havingObjectVersion: objectVersion,
                                              havingArchiveVersion: archiveVersion,
                                              userInfo: userInfo))
                if let s = val as? String {
                    /*if let valueComments = getComments(forValue: s,inObject: content, lookingInObjectList: objects, atPath: path.appending(key)) {
                        line += " /* \(valueComments) */"
                    }*/
                    if let valueComments = getComments(forValue: s,
                                                       atPath: path.appending(key),
                                                       inData: rootContent,
                                                       havingObjectVersion: objectVersion,
                                                       havingArchiveVersion: archiveVersion,
                                                       userInfo: userInfo) {
                        line += " /* \(valueComments) */"
                    }
                }
                line += ";"
                if !oneObjectPerLine { line += " " }
                //else { line += "\n" }
            }
            
            rtn += line
        
        }
        if oneObjectPerLine { rtn += "\n" }
        if let sectionEnding = prevObjectSection {
            rtn += "/* End \(sectionEnding) section */\n"
        }
        
        return rtn
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject(content: [Any],
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        let currentIndents = indents.repeated(currentLevel)
        var rtn: String = ""
        
        for (i, value) in content.enumerated() {
            rtn += currentIndents + (try encodeObject(content: value,
                                                 rootContent: rootContent,
                                                 usingSingleIndentString: indents,
                                                 currentLevel: currentLevel + 1,
                                                 atPath: path.appending("[\(i)]"),
                                                 havingObjectVersion: objectVersion,
                                                 havingArchiveVersion: archiveVersion,
                                                 userInfo: userInfo))
            if let s = value as? String {
                /*let objects: [String: Any] = (rootContent["objects"] as? [String: Any]) ?? [:]
                if let valueComments = getComments(forValue: s, lookingInObjectList: objects, atPath: path.appending("[\(i)]")) {
                    rtn += " /* \(valueComments) */"
                }*/
                if let valueComments = getComments(forValue: s,
                                                   atPath: path.appending("[\(i)]"),
                                                   inData: rootContent,
                                                   havingObjectVersion: objectVersion,
                                                   havingArchiveVersion: archiveVersion,
                                                   userInfo: userInfo) {
                    rtn += " /* \(valueComments) */"
                }
            }
            if i < content.count - 1 { rtn += "," }
            rtn += "\n"
        }
        return rtn
        
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject(content: Any,
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        if let v = content as? [String: Any] {
            return try encodeObject(content: v,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel + 1,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? [Any] {
            return try encodeObject(content: v,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel + 1,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Int {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Int64 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Int32 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Int16 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Int8 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? UInt {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? UInt64 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? UInt32 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? UInt16 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? UInt8 {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Float {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Double {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? Decimal {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? NSDecimalNumber {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if isNil(content) {
            return "null"
        } else if let v = content as? NSNumber {
            guard isForcedStringType(atPath: path, havingObjectVersion: objectVersion, havingArchiveVersion: archiveVersion) else {
                return v.description
            }
            return try encodeObject(content: v.description,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? String {
            return try encodeObject(content: v,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else if let v = content as? NSString {
            let s = v.substring(from: 0)
            return try encodeObject(content: s,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: ["NSDebugDescription" : "Invalid object cannot be serialized"])
        }
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject(content: NSNumber,
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        if CFNumberIsFloatType(content.cfObject) {
            return try encodeObject(content: content.doubleValue,
                                    rootContent: rootContent,
                                    usingSingleIndentString: indents,
                                    currentLevel: currentLevel,
                                    atPath: path,
                                    havingObjectVersion: objectVersion,
                                    havingArchiveVersion: archiveVersion,
                                    userInfo: userInfo)
        } else {
            switch content.cfTypeID {
            case CFBooleanGetTypeID():
                return content.boolValue.description
            default:
                return content.stringValue
            }
        }
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject<T: FloatingPoint & LosslessStringConvertible>(content: T,
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        guard content.isFinite else {
            throw NSError(domain: NSCocoaErrorDomain,
                          code: CocoaError.propertyListReadCorrupt.rawValue,
                          userInfo: ["NSDebugDescription" : "Invalid number value (\(content)) in XcodeProj write"])
        }
        var str = content.description
        if str.hasSuffix(".0") {
            str.removeLast(2)
        }
        return str
        
    }
    
    /// Encodes an object into a string for witting to the PBX Project file
    ///
    /// - Parameters:
    ///   - content: The content to encode
    ///   - rootContent: The complete data being encoded
    ///   - indents: The representation of a single indent/tab
    ///   - currentLevel: The current level within the encoding process (0 means root, then the value increases on each level)
    ///   - path: The coding path
    ///   - objectVersion: The object version of the pbx file
    ///   - archiveVersion: The archive version of the pbx file
    ///   - userInfo: Any user info passed along
    /// - Returns: Returns an encoded string representing the content
    private static func encodeObject(content: String,
                                     rootContent: [String: Any],
                                     usingSingleIndentString indents: String,
                                     currentLevel: Int,
                                     atPath path: [String],
                                     havingObjectVersion objectVersion: Int,
                                     havingArchiveVersion archiveVersion: Int,
                                     userInfo: [CodingUserInfoKey: Any]) throws -> String {
        var rtn: String = content
        
        if !(content.hasPrefix("\"") &&
            content.hasSuffix("\"")) &&
            (objectVersion >= 46 || PBXProj.isPBXEncodinStringEscaping(rtn,
                                                                       hasKeyIndicators: stringHasRequiredEscapingCharacters(rtn),
                                                                       atPath: path,
                                                                       inData: rootContent,
                                                                       havingObjectVersion: objectVersion,
                                                                       havingArchiveVersion: archiveVersion,
                                                                       userInfo: userInfo)) {
            rtn = "\""
            // Taken from https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/JSONSerialization.swift
            var workingString = content
            for e in esacpedCharacters {
                workingString = workingString.replacingOccurrences(of: e.raw, with: e.escaped)
            }
            rtn += workingString
            
            rtn += "\""
        }
        // Empty Strings need to be quoted
        if rtn.isEmpty { rtn = "\"\"" }
        return rtn
        
        
    }
    
    
}
