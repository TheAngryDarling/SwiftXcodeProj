//
//  XcodeProjectBuilders.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-06-13.
//

import CoreFoundation
import Foundation
import PBXProj
import VersionKit
import SwiftPatches

#if os(Linux)
import SwiftGlibc
#else
import Darwin
#endif

fileprivate extension Version.SingleVersion {

    /// Default Xcode version
    static var defaultXcodeSupport: Version.SingleVersion { return XcodeProjectBuilders.DEFAUILT_XCODE_SUPPORT }
    /// Default mac deployment version
    static var defaultMacDeploymentTarget: Version.SingleVersion { return XcodeProjectBuilders.DEFAUILT_MAC_DEPLOYMENT_TARGET }
    /// Default swift verson
    static var defaultSwiftVersion: Version.SingleVersion { return XcodeProjectBuilders.DEFAULT_SWIFT_VERSION }
}
public struct XcodeProjectBuilders {
    private init() { }
    
    public enum Errors: Error {
        public enum DeploymentTarget {
            case mac
            case iOS
            case tvOS
            case watchOS
            case iPadOS
        }
        case noDefaultsFound
        case missingDeploymentTargetVersion(for: DeploymentTarget)
        case missingSwiftVersion
    }
    
    /// Default Settings for PBX Project File
    public struct DefaultDetails {
        public let archiveVersion: Int
        public let objectVersion: Int
        public let compatibleXcode: NamedVersion.BasicVersion
        public let swiftVersion: NamedVersion.BasicVersion!
        public let macDeploymentTarget: NamedVersion.BasicVersion!
        public let iOSDeploymentTarget: NamedVersion.BasicVersion!
        public let tvOSDeploymentTarget: NamedVersion.BasicVersion!
        public let watchOSDeploymentTarget: NamedVersion.BasicVersion!
        public let iPadOSDeploymentTarget: NamedVersion.BasicVersion!
        
        public init(archiveVersion: Int = 1,
                    objectVersion: Int,
                    compatibleXcode: NamedVersion.BasicVersion,
                    swiftVersion: NamedVersion.BasicVersion? = nil,
                    macDeploymentTarget: NamedVersion.BasicVersion? = nil,
                    iOSDeploymentTarget: NamedVersion.BasicVersion? = nil,
                    tvOSDeploymentTarget: NamedVersion.BasicVersion? = nil,
                    watchOSDeploymentTarget: NamedVersion.BasicVersion? = nil,
                    iPadOSDeploymentTarget: NamedVersion.BasicVersion? = nil) {
            self.archiveVersion = archiveVersion
            self.objectVersion = objectVersion
            self.compatibleXcode = compatibleXcode
            self.swiftVersion = swiftVersion
            self.macDeploymentTarget = macDeploymentTarget
            self.iOSDeploymentTarget = iOSDeploymentTarget
            self.tvOSDeploymentTarget = tvOSDeploymentTarget
            self.watchOSDeploymentTarget = watchOSDeploymentTarget
            self.iPadOSDeploymentTarget = iPadOSDeploymentTarget
        }
    }
    
    /// Requirements used to find the most compatible version of Build / Deployment details
    public enum DefaultDetailsChoice {
        case objectVersion(Int)
        case compatibleXcode(Version.SingleVersion)
        case swiftVersion(Version.SingleVersion)
        case macDeploymentTarget(Version.SingleVersion)
        case iOSDeploymentTarget(Version.SingleVersion)
        case tvOSDeploymentTarget(Version.SingleVersion)
        case watchOSDeploymentTarget(Version.SingleVersion)
        case iPadOSDeploymentTarget(Version.SingleVersion)
        case compound([DefaultDetailsChoice])
        
        public init(_ objectVersion: Int) { self = .objectVersion(objectVersion) }
        public init(compatibleXcode version: Version.SingleVersion) { self = .compatibleXcode(version) }
        public init(swiftVersion version: Version.SingleVersion) { self = .swiftVersion(version) }
        public init(macDeploymentTarget version: Version.SingleVersion) { self = .macDeploymentTarget(version) }
        public init(iOSDeploymentTarget version: Version.SingleVersion) { self = .iOSDeploymentTarget(version) }
        public init(tvOSDeploymentTarget version: Version.SingleVersion) { self = .tvOSDeploymentTarget(version) }
        public init(watchOSDeploymentTarget version: Version.SingleVersion) { self = .watchOSDeploymentTarget(version) }
        public init(iPadOSDeploymentTarget version: Version.SingleVersion) { self = .iPadOSDeploymentTarget(version) }
        public init(_ compound: DefaultDetailsChoice...) { self = .compound(compound) }
        public init(_ compound: [DefaultDetailsChoice]) { self = .compound(compound) }
        
        
        /// Find the most compatiable Default Build Details for the given choices
        public func mostCompatible() -> DefaultDetails! {
            return self.mostCompatible(from: XcodeProjectBuilders.getObjectVersionDefaultDetails())
        }
        /// Find the most compatiable Default Build Details for the given choices within the list of Default Build Details
        fileprivate func mostCompatible(from details: [DefaultDetails]) -> DefaultDetails! {
            switch self {
                case .objectVersion(let version):
                    return details.first(where: { return $0.objectVersion >= version })
                case .compatibleXcode(let version):
                    return details.first(where: { return $0.compatibleXcode.version ~= version || $0.compatibleXcode.version >= version })
                case .swiftVersion(let version):
                    return details.first(where: { return $0.swiftVersion != nil && ($0.swiftVersion.version ~= version || $0.swiftVersion.version >= version) })
                case .macDeploymentTarget(let version):
                    return details.first(where: { return $0.macDeploymentTarget != nil && ($0.macDeploymentTarget.version ~= version || $0.macDeploymentTarget.version >= version) })
                case .iOSDeploymentTarget(let version):
                    return details.first(where: { return $0.iOSDeploymentTarget != nil && ($0.iOSDeploymentTarget.version ~= version || $0.iOSDeploymentTarget.version >= version) })
                case .tvOSDeploymentTarget(let version):
                    return details.first(where: { return $0.tvOSDeploymentTarget != nil && ($0.tvOSDeploymentTarget.version ~= version || $0.tvOSDeploymentTarget.version >= version) })
                case .watchOSDeploymentTarget(let version):
                    return details.first(where: { return $0.watchOSDeploymentTarget != nil && ($0.watchOSDeploymentTarget.version ~= version || $0.watchOSDeploymentTarget.version >= version) })
                case .iPadOSDeploymentTarget(let version):
                    return details.first(where: { return $0.iPadOSDeploymentTarget != nil && ($0.iPadOSDeploymentTarget.version ~= version || $0.iPadOSDeploymentTarget.version >= version) })
                case .compound(let choices):
                    var results: [DefaultDetails] = []
                    for choice in choices {
                        if let c = choice.mostCompatible(from: details) {
                            results.append(c)
                        }
                    }
                    results = results.sorted(by: objectVersionDetailsSorter)
                    return results.last
            }
        }
        
        /// Test to see if the given choice contains the provided choice reglardless of any choice parameters
        /// - Parameter option: The choice/option to check for
        public func has(_ option: DefaultDetailsChoice) -> Bool {
            switch (self, option) {
                case (.objectVersion(_), .objectVersion(_)): return true
                case (.compatibleXcode(_), .compatibleXcode(_)): return true
                case (.swiftVersion(_), .swiftVersion(_)): return true
                case (.macDeploymentTarget(_), .macDeploymentTarget(_)): return true
                case (.iOSDeploymentTarget(_), .iOSDeploymentTarget(_)): return true
                case (.tvOSDeploymentTarget(_), .tvOSDeploymentTarget(_)): return true
                case (.watchOSDeploymentTarget(_), .watchOSDeploymentTarget(_)): return true
                case (.iPadOSDeploymentTarget(_), .iPadOSDeploymentTarget(_)): return true
                case (.compound(let lhs), .compound(let rhs)):
                    for choice in rhs {
                        if !lhs.has(choice) { return false }
                    }
                    return true
                case (.compound(let lhs), _): return lhs.has(option)
                default: return false
            }
           
        }
        
        
        /// Remove any choices/options provided
        /// - Parameter option: any options to remove
        /// - Returns: Returns true of anything was removed, otherwise false
        @discardableResult
        public mutating func remove(_ option: DefaultDetailsChoice) -> Bool {
            var rtn: Bool = false
            switch (self, option) {
                case (.compound(var lhs), .compound(let rhs)):
                    /// Remove any items in lhs that exist in rhs
                    var idx: Int = 0
                    while idx < lhs.count {
                        if rhs.has(lhs[idx]) {
                            lhs.remove(at: idx)
                            rtn = true
                        } else {
                            idx += 1
                        }
                    }
                    if lhs.count == 1 { self = lhs.first! }
                    else { self = .compound(lhs) }
                case (.compound(var lhs), _):
                    /// Remove any items in lhs that exist in rhs
                    var idx: Int = 0
                    while idx < lhs.count {
                        if [option].has(lhs[idx]) {
                            lhs.remove(at: idx)
                            rtn = true
                        } else {
                            idx += 1
                        }
                    }
                    if lhs.count == 1 { self = lhs.first! }
                    else { self = .compound(lhs) }
                case (_, .compound(let rhs)):
                    if rhs.has(self) {
                        rtn = true
                        self = .compound([])
                    }
                default: rtn = false
            }
            return rtn
        }
        
        /// Add the provided choice/option to the given choice
        /// - Parameter option: The choice/option to add
        public mutating func add(_ option: DefaultDetailsChoice) {
            switch (self, option) {
                case (.compound(let lhs), .compound(let rhs)):
                    let ary = lhs.removing(rhs).appending(contentsOf: rhs)
                    if ary.count == 1 { self = ary.first! }
                    else { self = .compound(ary) }
                case (.compound(let lhs), _):
                    let ary = lhs.removing(option).appending(option)
                    if ary.count == 1 { self = ary.first! }
                    else { self = .compound(ary) }
                case (_, .compound(let rhs)):
                    let ary = [self].removing(rhs).appending(contentsOf: rhs)
                    if ary.count == 1 { self = ary.first! }
                    else { self = .compound(ary) }
                default:
                    let ary = [self].removing(option).appending(option)
                    if ary.count == 1 { self = ary.first! }
                    else { self = .compound(ary) }
            }
        }
        
    }
    
    /// Stores user details
    ///
    /// - none: No user details
    /// - populated: The current user details
    public enum UserDetails {
        /// Indicator weather to check the environmental variables for the user name and full user name when using the default constructor
        /// This would help when temporarialy working in VM environments like Docker.
        ///
        /// Then environmental variables are REAL_USER_NAME and REAL_DISPLAY_NAME
        ///
        public static var supportEnvUserName: Bool = false
        case none
        case populated(userName: String, displayName: String)
        
        /// Indicates if there are no user details
        public var isEmpty: Bool {
            guard case UserDetails.none = self else { return false }
            return true
        }
        /// The user name if available
        public var userName: String! {
            guard case UserDetails.populated(userName: let rtn, displayName: _) = self else { return nil }
            return rtn
        }
        
        /// The display name if available
        public var displayName: String! {
            guard case UserDetails.populated(userName: _, displayName: let rtn) = self else { return nil }
            return rtn
        }
        
        /// Tries to load the current uesr's details.
        ///
        /// If not a desktop OS, this will set it to .none.
        /// If UserDetails.supportEnvUserName is true, will look for REAL_USER_NAME and REAL_DISPLAY_NAME in the environmental variables, otherwise
        /// this will get NSUserName and NSFullUserName
        /// When swift < 4.1, this calls getpwnam to get the display name instead of NSFullUserName
        public init() {
            #if (os(macOS) || os(Linux) || os(Windows))
                if  let userName = ProcessInfo.processInfo.environment["REAL_USER_NAME"],
                    let displayName = ProcessInfo.processInfo.environment["REAL_DISPLAY_NAME"], UserDetails.supportEnvUserName {
                    self = .populated(userName: userName, displayName: displayName)
                } else {
                    self = .populated(userName: NSUserName(), displayName: NSFullUserName())
                }
            
            #else
                self = .none
            #endif
            
        }
        public init(userName: String, displayName: String) { self = .populated(userName: userName, displayName: displayName) }
        
        
        
    }
    
    /// Pre-defined details
    private static let INTERNAL_OBJECT_VERSION_DEFAULT_DETAILS: [DefaultDetails] = [
        DefaultDetails(objectVersion: 46, compatibleXcode: "Xcode 2.3"),
         DefaultDetails(objectVersion: 46, compatibleXcode: "Xcode 2.4"),
         DefaultDetails(objectVersion: 46, compatibleXcode: "Xcode 2.4.1"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 3.0",
                        macDeploymentTarget: "macOS 10.3",
                        iOSDeploymentTarget: "iOS 2"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 3.1",
                         macDeploymentTarget: "macOS 10.3",
                         iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.1.1",
                        macDeploymentTarget: "macOS 10.3",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.1.2",
                        macDeploymentTarget: "macOS 10.3",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.1.3",
                        macDeploymentTarget: "macOS 10.3",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.1.4",
                        macDeploymentTarget: "macOS 10.3",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.1",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 2"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.2",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.3",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.4",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.5",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 3.2.6",
                        macDeploymentTarget: "macOS 10.4",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 4",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 4.0.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
        DefaultDetails(objectVersion: 46,
                       compatibleXcode: "Xcode 4.0.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 4"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 5"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.2.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.3",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.3.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.3.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.3.3",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.4",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.4.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 3"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.5",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.5.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.5.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.6",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6.1"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.6.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6.1"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.6.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6.1"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 4.6.3",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 6.1"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 5",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 7"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 5.0.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 7"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 5.0.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 7"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 5.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 7"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 5.1.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 7"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.0.1",
                        swiftVersion: "Swift 1.0",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.1",
                        swiftVersion: "Swift 1.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.1.1",
                        swiftVersion: "Swift 1.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.2",
                        swiftVersion: "Swift 1.1",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.3",
                        swiftVersion: "Swift 1.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.3.1",
                        swiftVersion: "Swift 1.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.3.2",
                        swiftVersion: "Swift 1.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 46,
                        compatibleXcode: "Xcode 6.4",
                        swiftVersion: "Swift 1.2",
                        macDeploymentTarget: "macOS 10.6",
                        iOSDeploymentTarget: "iOS 8"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7",
                         swiftVersion: "Swift 2.0",
                         macDeploymentTarget: "macOS 10.11",
                         iOSDeploymentTarget: "iOS 9",
                         tvOSDeploymentTarget: nil,
                         watchOSDeploymentTarget: "watchOS 2"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.0.1",
                         swiftVersion: "Swift 2.0",
                         macDeploymentTarget: "macOS 10.11",
                         iOSDeploymentTarget: "iOS 9",
                         tvOSDeploymentTarget: nil,
                         watchOSDeploymentTarget: "watchOS 2"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.1",
                         swiftVersion: "Swift 2.1",
                         macDeploymentTarget: "macOS 10.11",
                         iOSDeploymentTarget: "iOS 9.1",
                         tvOSDeploymentTarget: "tvOS 9",
                         watchOSDeploymentTarget: "watchOS 2"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.1.1",
                         swiftVersion: "Swift 2.1",
                         macDeploymentTarget: "macOS 10.11",
                         iOSDeploymentTarget: "iOS 9.1",
                         tvOSDeploymentTarget: "tvOS 9",
                         watchOSDeploymentTarget: "watchOS 2"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.2",
                         swiftVersion: "Swift 2.1.1",
                         macDeploymentTarget: "macOS 10.11.2",
                         iOSDeploymentTarget: "iOS 9.2",
                         tvOSDeploymentTarget: "tvOS 9.2",
                         watchOSDeploymentTarget: "watchOS 2.1"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.2.1",
                         swiftVersion: "Swift 2.1.1",
                         macDeploymentTarget: "macOS 10.11.2",
                         iOSDeploymentTarget: "iOS 9.2",
                         tvOSDeploymentTarget: "tvOS 9.2",
                         watchOSDeploymentTarget: "watchOS 2.1"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.3",
                         swiftVersion: "Swift 2.2",
                         macDeploymentTarget: "macOS 10.11.4",
                         iOSDeploymentTarget: "iOS 9.3",
                         tvOSDeploymentTarget: "tvOS 9.2",
                         watchOSDeploymentTarget: "watchOS 2.2"),
         DefaultDetails(objectVersion: 47,
                        compatibleXcode: "Xcode 7.3.1",
                         swiftVersion: "Swift 2.2",
                         macDeploymentTarget: "macOS 10.11.4",
                         iOSDeploymentTarget: "iOS 9.3",
                         tvOSDeploymentTarget: "tvOS 9.2",
                         watchOSDeploymentTarget: "watchOS 2.2"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8",
                         swiftVersion: "Swift 3.0",
                         macDeploymentTarget: "macOS 10.12",
                         iOSDeploymentTarget: "iOS 10",
                         tvOSDeploymentTarget: "tvOS 10",
                         watchOSDeploymentTarget: "watchOS 3"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.1",
                         swiftVersion: "Swift 3.0.1",
                         macDeploymentTarget: "macOS 10.12.1",
                         iOSDeploymentTarget: "iOS 10.1",
                         tvOSDeploymentTarget: "tvOS 10",
                         watchOSDeploymentTarget: "watchOS 3.1"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.2",
                         swiftVersion: "Swift 3.0.2",
                         macDeploymentTarget: "macOS 10.12.2",
                         iOSDeploymentTarget: "iOS 10.2",
                         tvOSDeploymentTarget: "tvOS 10.1",
                         watchOSDeploymentTarget: "watchOS 3.1"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.2.1",
                         swiftVersion: "Swift 3.0.2",
                         macDeploymentTarget: "macOS 10.12.2",
                         iOSDeploymentTarget: "iOS 10.2",
                         tvOSDeploymentTarget: "tvOS 10.1",
                         watchOSDeploymentTarget: "watchOS 3.1"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.3",
                         swiftVersion: "Swift 3.1",
                         macDeploymentTarget: "macOS 10.12.4",
                         iOSDeploymentTarget: "iOS 10.3",
                         tvOSDeploymentTarget: "tvOS 10.2",
                         watchOSDeploymentTarget: "watchOS 3.2"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.3.1",
                         swiftVersion: "Swift 3.1",
                         macDeploymentTarget: "macOS 10.12.4",
                         iOSDeploymentTarget: "iOS 10.3",
                         tvOSDeploymentTarget: "tvOS 10.2",
                         watchOSDeploymentTarget: "watchOS 3.2"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.3.2",
                         swiftVersion: "Swift 3.1",
                         macDeploymentTarget: "macOS 10.12.4",
                         iOSDeploymentTarget: "iOS 10.3",
                         tvOSDeploymentTarget: "tvOS 10.2",
                         watchOSDeploymentTarget: "watchOS 3.2"),
         DefaultDetails(objectVersion: 48,
                        compatibleXcode: "Xcode 8.3.3",
                         swiftVersion: "Swift 3.1",
                         macDeploymentTarget: "macOS 10.12.4",
                         iOSDeploymentTarget: "iOS 10.3.1",
                         tvOSDeploymentTarget: "tvOS 10.2",
                         watchOSDeploymentTarget: "watchOS 3.2"),
         DefaultDetails(objectVersion: 49,
                        compatibleXcode: "Xcode 9",
                         swiftVersion: "Swift 4.0",
                         macDeploymentTarget: "macOS 10.13",
                         iOSDeploymentTarget: "iOS 11",
                         tvOSDeploymentTarget: "tvOS 11",
                         watchOSDeploymentTarget: "watchOS 4"),
         DefaultDetails(objectVersion: 49,
                        compatibleXcode: "Xcode 9.0.1",
                         swiftVersion: "Swift 4.0",
                         macDeploymentTarget: "macOS 10.13",
                         iOSDeploymentTarget: "iOS 11",
                         tvOSDeploymentTarget: "tvOS 11",
                         watchOSDeploymentTarget: "watchOS 4"),
         DefaultDetails(objectVersion: 49,
                        compatibleXcode: "Xcode 9.1",
                         swiftVersion: "Swift 4.0.2",
                         macDeploymentTarget: "macOS 10.13.1",
                         iOSDeploymentTarget: "iOS 11.1",
                         tvOSDeploymentTarget: "tvOS 11.1",
                         watchOSDeploymentTarget: "watchOS 4.1"),
         DefaultDetails(objectVersion: 49,
                        compatibleXcode: "Xcode 9.2",
                         swiftVersion: "Swift 4.0.3",
                         macDeploymentTarget: "macOS 10.13.2",
                         iOSDeploymentTarget: "iOS 11.2",
                         tvOSDeploymentTarget: "tvOS 11.2",
                         watchOSDeploymentTarget: "watchOS 4.2"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 9.3",
                         swiftVersion: "Swift 4.1",
                         macDeploymentTarget: "macOS 10.13.4",
                         iOSDeploymentTarget: "iOS 11.3",
                         tvOSDeploymentTarget: "tvOS 11.3",
                         watchOSDeploymentTarget: "watchOS 4.3"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 9.3.1",
                         swiftVersion: "Swift 4.1",
                         macDeploymentTarget: "macOS 10.13.4",
                         iOSDeploymentTarget: "iOS 11.3",
                         tvOSDeploymentTarget: "tvOS 11.3",
                         watchOSDeploymentTarget: "watchOS 4.3"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 9.4",
                         swiftVersion: "Swift 4.1.2",
                         macDeploymentTarget: "macOS 10.13.4",
                         iOSDeploymentTarget: "iOS 11.4",
                         tvOSDeploymentTarget: "tvOS 11.4",
                         watchOSDeploymentTarget: "watchOS 4.3"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 9.4.1",
                         swiftVersion: "Swift 4.1.2",
                         macDeploymentTarget: "macOS 10.13.4",
                         iOSDeploymentTarget: "iOS 11.4",
                         tvOSDeploymentTarget: "tvOS 11.4",
                         watchOSDeploymentTarget: "watchOS 4.3"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 10",
                         swiftVersion: "Swift 4.2",
                         macDeploymentTarget: "macOS 10.14",
                         iOSDeploymentTarget: "iOS 12",
                         tvOSDeploymentTarget: "tvOS 12",
                         watchOSDeploymentTarget: "watchOS 5"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 10.1",
                         swiftVersion: "Swift 4.2.1",
                         macDeploymentTarget: "macOS 10.14.1",
                         iOSDeploymentTarget: "iOS 12.1",
                         tvOSDeploymentTarget: "tvOS 12.1",
                         watchOSDeploymentTarget: "watchOS 5.1"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 10.2",
                         swiftVersion: "Swift 5.0",
                         macDeploymentTarget: "macOS 10.14.4",
                         iOSDeploymentTarget: "iOS 12.2",
                         tvOSDeploymentTarget: "tvOS 12.2",
                         watchOSDeploymentTarget: "watchOS 5.2"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 10.2.1",
                         swiftVersion: "Swift 5.0.1",
                         macDeploymentTarget: "macOS 10.14.4",
                         iOSDeploymentTarget: "iOS 12.2",
                         tvOSDeploymentTarget: "tvOS 12.2",
                         watchOSDeploymentTarget: "watchOS 5.2"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 10.3",
                         swiftVersion: "Swift 5.0.1",
                         macDeploymentTarget: "macOS 10.14.4",
                         iOSDeploymentTarget: "iOS 12.2",
                         tvOSDeploymentTarget: "tvOS 12.2",
                         watchOSDeploymentTarget: "watchOS 5.2"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 11",
                         swiftVersion: "Swift 5.1",
                         macDeploymentTarget: "macOS 10.15",
                         iOSDeploymentTarget: "iOS 13",
                         tvOSDeploymentTarget: "tvOS 13",
                         watchOSDeploymentTarget: "watchOS 6"),
         DefaultDetails(objectVersion: 50,
                        compatibleXcode: "Xcode 11.1",
                         swiftVersion: "Swift 5.1",
                         macDeploymentTarget: "macOS 10.15",
                         iOSDeploymentTarget: "iOS 13.1",
                         tvOSDeploymentTarget: "tvOS 13",
                         watchOSDeploymentTarget: "watchOS 6"),
    ]
    
    /// Registered details
    private static var REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS: [DefaultDetails] = []
    
    /// Sort function, sorted xcode compatible version, then by object version
    private static func objectVersionDetailsSorter( _ lhs: DefaultDetails,
                                                    _ rhs: DefaultDetails) -> Bool {
        // Sort by compatableXcode
        if lhs.compatibleXcode < rhs.compatibleXcode { return true }
        else if lhs.compatibleXcode > rhs.compatibleXcode { return false }
        // Sort by objectVersion second
        if lhs.objectVersion < rhs.objectVersion { return true }
        else if lhs.objectVersion > rhs.objectVersion { return false }
        return false
    }
    
    
    /// Register a default details object
    public static func registerObjectVersionDetails(_ details: DefaultDetails) {
        guard !REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS.contains(where: { return $0.compatibleXcode == details.compatibleXcode }) else {
            fatalError("ObjectVersionDefaultDetails with compatableXcode \(details.compatibleXcode) already registered")
        }
        REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS.append(details)
        REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS.sort(by: objectVersionDetailsSorter)
    }
    
    /// Unregister a registered defaults details object based on its compatibleXcode
    @discardableResult
    public static func unregisterObjectVersionDetails(for compatibleXcode: NamedVersion.BasicVersion) -> Bool {
        if let idx = REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS.firstIndex(where:  { return $0.compatibleXcode == compatibleXcode }) {
            REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS.remove(at: idx)
        }
        return false
    }
    
    /// Get all Pre-defined and registered default details
    public static func getObjectVersionDefaultDetails() -> [DefaultDetails] {
        var rtn: [DefaultDetails] = INTERNAL_OBJECT_VERSION_DEFAULT_DETAILS
        
        for rO in REGISTERED_OBJECT_VERSION_DEFAULT_DETAILS {
            if let idx = rtn.firstIndex(where:  { return $0.compatibleXcode == rO.compatibleXcode }) {
                rtn.remove(at: idx)
                rtn.insert(rO, at: idx)
            } else {
                rtn.append(rO)
            }
            
        }
        
        rtn.sort(by: objectVersionDetailsSorter)
        return rtn
    }
    
    /// Default PBX File Archive version
    public static let DEFAULT_PBX_ARCHIVE_VERSION: Int = 1
    /// Default PBX File Object version
    public static let DEFAULT_PBX_OBJECT_VERSION: Int = 46
    /// Default Xcode version
    public static let DEFAUILT_XCODE_SUPPORT: Version.SingleVersion = "3.2"
    /// Default mac deployment version
    public static let DEFAUILT_MAC_DEPLOYMENT_TARGET: Version.SingleVersion = "10.10"
    /// Default swift verson
    public static let DEFAULT_SWIFT_VERSION: Version.SingleVersion = "4.0"
    
    /// Swift Project Generators
    public struct Swift {
        private init() { }
        
        /// Command Line Project Generator
        public struct CommandLine {
            private init() { }
            
            /// Create new Swift Command Line project
            public static func create(_ name: String,
                                      in folder: XcodeFileSystemURLResource,
                                      using provider: XcodeFileSystemProvider,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compound([.macDeploymentTarget(DEFAUILT_MAC_DEPLOYMENT_TARGET),
                                                                                                     .swiftVersion(DEFAULT_SWIFT_VERSION)]),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                
                var defaultOptions = defaultOptions
                
                if !defaultOptions.has(.swiftVersion(.defaultSwiftVersion)) { defaultOptions.add(.swiftVersion(.defaultSwiftVersion)) }
                if !defaultOptions.has(.macDeploymentTarget(.defaultMacDeploymentTarget)) { defaultOptions.add(.macDeploymentTarget(.defaultMacDeploymentTarget)) }
                
                guard let defaults = defaultOptions.mostCompatible(from: getObjectVersionDefaultDetails()) else {
                    throw Errors.noDefaultsFound
                }
                guard let deploymentTarget = defaults.macDeploymentTarget?.version.description else {
                    throw Errors.missingDeploymentTargetVersion(for: .mac)
                }
                guard let swiftVersion = defaults.swiftVersion?.version.description else {
                    throw Errors.missingSwiftVersion
                }
                
                
                let workspace: XCWorkspace? = nil
                let sharedData: XCSharedData = XCSharedData()
                var userdataList: XCUserDataList? = nil
                
                if !userDetails.isEmpty {
                    userdataList = XCUserDataList()
                    let userData: XCUserData = XCUserData(forUser: userDetails.userName)
                    userdataList!.append(userData)
                }
                
                
                let projectFolder = folder.appendingDirComponent(name)
                
                let rtn = try XcodeProject(fromURL: projectFolder,
                                           usingFSProvider: provider,
                                           workspace: workspace,
                                           sharedData: sharedData,
                                           userdataList: userdataList,
                                           pbxArchiveVersion: defaults.archiveVersion,
                                           pbxObjectVersion: defaults.objectVersion,
                                           buildSettings: XcodeProject.ProjectBuildConfigurationOptions(
                                                debug: XcodeProjectBuildConfigurationSettings.swift.Mac.commandLine.DEBUG.setting(deploymentTarget, forKey: "MACOSX_DEPLOYMENT_TARGET"),
                                                release: XcodeProjectBuildConfigurationSettings.swift.Mac.commandLine.RELEASE.setting(deploymentTarget, forKey: "MACOSX_DEPLOYMENT_TARGET")
                                           ),
                                           xCodeCompatibilityVersion: defaults.compatibleXcode.description,
                                           hasScannedForEncodings: 0,
                                           projectDirPath: "",
                                           projectRoot: "")
                
                
                
                
                
                
                let targetSettings:  [String: Any] = [
                    "CODE_SIGN_STYLE": "Automatic",
                    "PRODUCT_NAME":  "\"$(TARGET_NAME)\"",
                    "SWIFT_VERSION": swiftVersion
                ]
                
                let target = try rtn.createNativeTarget(withTargetName: name,
                                                    buildConfigurationList: .init(common: targetSettings),
                                                    productType: PBXProductType.commandLineTool,
                                                    productFileReferenceNaming: .generated,
                                                    targetReferenceNaming: .target,
                                                    createProxy: false,
                                                    havingInfo: [:])
                
            
                // Create sources folder before target so it will show up before Products folder
                let sourcesFolder = try rtn.resources.createSourceGroup(withName: "Sources", savePBXFile: false)
                let targetFolder = try sourcesFolder.createGroup(withName: name)
                
                let mainFileName: String = "main.swift"
                
                let dta = XcodeDefaultFileContent.getContentFor(fileType: XcodeFileType.SourceCode.Swift.main,
                                                                withName: mainFileName,
                                                                forUser: userDetails.displayName,
                                                                havingMembership: target,
                                                                inProject: rtn)
                
                let sourceFile = try targetFolder.createFile(ofType: PBXFileType.SourceCode.Swift.source,
                                                             withName: mainFileName,
                                                             withInitialData: dta,
                                                             havingMembership: target)
                
                
                let sourcesBuildPhase = target.sourcesBuildPhase()
                sourcesBuildPhase.createBuildFile(for: sourceFile)
                /// Ensures we create the framework build phase
                target.frameworkBuildPhase()
                try target.createCopyFilesBuildPhase(dstPath: "/usr/share/man/man1/", dstSubfolderSpec: .absolutePath)
                
                
                try rtn.save()
                
                return rtn
            }
            
            /// Create new Swift Command Line project
            public static func create(_ name: String,
                                      in folder: String,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compound([.macDeploymentTarget(DEFAUILT_MAC_DEPLOYMENT_TARGET),
                                                                                                     .swiftVersion(DEFAULT_SWIFT_VERSION)]),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: XcodeFileSystemURLResource(directory: folder),
                                  using: LocalXcodeFileSystemProvider.default,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
            
            /// Create new Swift Command Line project
            public static func create(_ name: String,
                                      in folder: URL,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: folder.path,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
 
        }
    }
    
    /// Objective C Project Generators
    public struct ObjectiveC {
        private init() { }
        
        /// Command Line Project Generator
        public struct CommandLine {
            private init() { }
            
            /// Create new Objective C Command Line project
            public static func create(_ name: String,
                                      in folder: XcodeFileSystemURLResource,
                                      using provider: XcodeFileSystemProvider,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .macDeploymentTarget(DEFAUILT_MAC_DEPLOYMENT_TARGET),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                
                guard let defaults = defaultOptions.mostCompatible(from: getObjectVersionDefaultDetails()) else {
                    throw Errors.noDefaultsFound
                }
                
                guard let deploymentTarget = defaults.macDeploymentTarget?.version.description else {
                    throw Errors.missingDeploymentTargetVersion(for: .mac)
                }
                
                
                let workspace: XCWorkspace? = nil
                let sharedData: XCSharedData = XCSharedData()
                var userdataList: XCUserDataList? = nil
                
                if !userDetails.isEmpty {
                    userdataList = XCUserDataList()
                    let userData: XCUserData = XCUserData(forUser: userDetails.userName)
                    userdataList!.append(userData)
                }
                
                
                let projectFolder = folder.appendingDirComponent(name)
                
                let rtn = try XcodeProject(fromURL: projectFolder,
                                           usingFSProvider: provider,
                                           workspace: workspace,
                                           sharedData: sharedData,
                                           userdataList: userdataList,
                                           pbxArchiveVersion: defaults.archiveVersion,
                                           pbxObjectVersion: defaults.objectVersion,
                                           buildSettings: XcodeProject.ProjectBuildConfigurationOptions(
                                            debug: XcodeProjectBuildConfigurationSettings.objectiveC.Mac.commandLine.DEBUG.setting(deploymentTarget, forKey: "MACOSX_DEPLOYMENT_TARGET"),
                                            release: XcodeProjectBuildConfigurationSettings.objectiveC.Mac.commandLine.RELEASE.setting(deploymentTarget, forKey: "MACOSX_DEPLOYMENT_TARGET")
                                            ),
                                           xCodeCompatibilityVersion: defaults.compatibleXcode.description,
                                           hasScannedForEncodings: 0,
                                           projectDirPath: "",
                                           projectRoot: "")
                
                
                
                
                
                
                let targetSettings:  [String: Any] = [
                    "CODE_SIGN_STYLE": "Automatic",
                    "PRODUCT_NAME":  "\"$(TARGET_NAME)\"",
                    ]
                
                let target = try rtn.createNativeTarget(withTargetName: name,
                                                        buildConfigurationList: .init(common: targetSettings),
                                                        productType: PBXProductType.commandLineTool,
                                                        productFileReferenceNaming: .generated,
                                                        targetReferenceNaming: .target,
                                                        createProxy: false,
                                                        havingInfo: [:])
                
                
                // Create sources folder before target so it will show up before Products folder
                let sourcesFolder = try rtn.resources.createSourceGroup(withName: name, savePBXFile: false)
                
                let mainFileName: String = "main.m"
                
                let dta = XcodeDefaultFileContent.getContentFor(fileType: XcodeFileType.SourceCode.ObjectiveC.main,
                                                                withName: mainFileName,
                                                                forUser: userDetails.displayName,
                                                                havingMembership: target,
                                                                inProject: rtn)
                
                let sourceFile = try sourcesFolder.createFile(ofType: PBXFileType.SourceCode.ObjectiveC.source,
                                                              withName: mainFileName,
                                                              withInitialData: dta,
                                                              havingMembership: target)
                
                let sourcesBuildPhase = target.sourcesBuildPhase()
                sourcesBuildPhase.createBuildFile(for: sourceFile)
                /// Ensures we create the framework build phase
                target.frameworkBuildPhase()
                try target.createCopyFilesBuildPhase(dstPath: "/usr/share/man/man1/", dstSubfolderSpec: .absolutePath)
                
                
                try rtn.save()
                
                return rtn
            }
            
            /// Create new Objective C Command Line project
            public static func create(_ name: String,
                                      in folder: String,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: XcodeFileSystemURLResource(directory: folder),
                                  using: LocalXcodeFileSystemProvider.default,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
            
            /// Create new Objective C Command Line project
            public static func create(_ name: String,
                                      in folder: URL,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: folder.path,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
            
        }
    }
    /// Other Project Generators
    public struct CrossPlatform {
        private init() { }
        /// Empty Project Generator
        public struct Empty {
            private init() { }
            
            /// Create new empty project
            public static func create(_ name: String,
                                      in folder: XcodeFileSystemURLResource,
                                      using provider: XcodeFileSystemProvider,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                
                guard let defaults = defaultOptions.mostCompatible(from: getObjectVersionDefaultDetails()) else {
                    throw Errors.noDefaultsFound
                }
                
                
                let workspace: XCWorkspace? = nil
                let sharedData: XCSharedData = XCSharedData()
                var userdataList: XCUserDataList? = nil
                
                if !userDetails.isEmpty {
                    userdataList = XCUserDataList()
                    let userData: XCUserData = XCUserData(forUser: userDetails.userName)
                    userdataList!.append(userData)
                }
                
                
                let projectFolder = folder.appendingDirComponent(name)
                
                let rtn = try XcodeProject(fromURL: projectFolder,
                                           usingFSProvider: provider,
                                           workspace: workspace,
                                           sharedData: sharedData,
                                           userdataList: userdataList,
                                           pbxArchiveVersion: defaults.archiveVersion,
                                           pbxObjectVersion: defaults.objectVersion,
                                           buildSettings: XcodeProject.ProjectBuildConfigurationOptions(),
                                           xCodeCompatibilityVersion: defaults.compatibleXcode.description,
                                           hasScannedForEncodings: 0,
                                           projectDirPath: nil,
                                           projectRoot: nil)
                
                
                try rtn.save()
                
                return rtn
            }
            
            /// Create new empty project
            public static func create(_ name: String,
                                      in folder: String,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: XcodeFileSystemURLResource(directory: folder),
                                  using: LocalXcodeFileSystemProvider.default,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
            
            /// Create new empty project
            public static func create(_ name: String,
                                      in folder: URL,
                                      withDefaults defaultOptions: DefaultDetailsChoice = .compatibleXcode(DEFAUILT_XCODE_SUPPORT),
                                      havingUserDetails userDetails: UserDetails = UserDetails()) throws -> XcodeProject {
                return try create(name,
                                  in: folder.path,
                                  withDefaults: defaultOptions,
                                  havingUserDetails: userDetails)
            }
        }
    }
}
