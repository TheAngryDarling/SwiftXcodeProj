//
//  PBXProductType.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-26.
//

import Foundation

/// Structure defining the PBX Product Type
public struct PBXProductType {
    internal let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let none: PBXProductType = ""
    public static let application: PBXProductType = "com.apple.product-type.application"
    public static let framework: PBXProductType = "com.apple.product-type.framework"
    public static let dynamicLibrary: PBXProductType = "com.apple.product-type.library.dynamic"
    public static let staticLibrary: PBXProductType = "com.apple.product-type.library.static"
    public static let bundle: PBXProductType = "com.apple.product-type.bundle"
    public static let unitTestBundle: PBXProductType = "com.apple.product-type.bundle.unit-test"
    public static let uiTestBundle: PBXProductType = "com.apple.product-type.bundle.ui-testing"
    public static let appExtension: PBXProductType = "com.apple.product-type.app-extension"
    public static let commandLineTool: PBXProductType = "com.apple.product-type.tool"
    public static let watchApp: PBXProductType = "com.apple.product-type.application.watchapp"
    public static let watch2App: PBXProductType = "com.apple.product-type.application.watchapp2"
    public static let watchExtension: PBXProductType = "com.apple.product-type.watchkit-extension"
    public static let watch2Extension: PBXProductType = "com.apple.product-type.watchkit2-extension"
    public static let tvExtension: PBXProductType = "com.apple.product-type.tv-app-extension"
    public static let messagesApplication: PBXProductType = "com.apple.product-type.application.messages"
    public static let messagesExtension: PBXProductType = "com.apple.product-type.app-extension.messages"
    public static let stickerPack: PBXProductType = "com.apple.product-type.app-extension.messages-sticker-pack"
    public static let xpcService: PBXProductType = "com.apple.product-type.xpc-service"
    public static let ocUnitTestBundle: PBXProductType = "com.apple.product-type.bundle.ocunit-test"
    public static let xcodeExtension: PBXProductType = "com.apple.product-type.xcode-extension"
    
    
    
    /// Returns the file extension for the given product type.
    public var fileExtension: String? {
        switch self {
        case .application, .watchApp, .watch2App, .messagesApplication:
            return "app"
        case .framework:
            return "framework"
        case .dynamicLibrary:
            return "dylib"
        case .staticLibrary:
            return "a"
        case .bundle:
            return "bundle"
        case .unitTestBundle, .uiTestBundle:
            return "xctest"
        case .appExtension, .tvExtension, .watchExtension, .watch2Extension, .messagesExtension, .stickerPack, .xcodeExtension:
            return "appex"
        case .commandLineTool:
            return nil
        case .xpcService:
            return "xpc"
        case .ocUnitTestBundle:
            return "octest"
        default:
            return nil
        }
    }
    
    /// Reuturns the file type of the given product type if one exists
    public var fileType: PBXFileType? {
        switch self {
        case .commandLineTool:
            return PBXFileType.Compiled.MachO.executable
        case .application, .watchApp, .watch2App, .messagesApplication:
            return PBXFileType.Wrapper.application
        case .framework, .dynamicLibrary, .staticLibrary, .bundle:
            return PBXFileType.Wrapper.framework
        case .unitTestBundle, .uiTestBundle:
            return PBXFileType.file
        case .xpcService:
            return PBXFileType.Wrapper.xpcService
        default:
            return nil
        }
    }
}

extension PBXProductType: CustomStringConvertible {
    public var description: String { return self.rawValue }
}

extension PBXProductType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue)
    }
}

extension PBXProductType: Equatable {
    public static func ==(lhs: PBXProductType, rhs: PBXProductType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: PBXProductType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: String, rhs: PBXProductType) -> Bool {
        return lhs == rhs.rawValue
    }
}
extension PBXProductType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
extension PBXProductType: Hashable {
    #if !swift(>=4.1)
    public var hashValue: Int { return self.rawValue.hashValue }
    #endif
}
