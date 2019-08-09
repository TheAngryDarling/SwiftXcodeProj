//
//  XcodeFileSystemURLResource.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-13.
//

import Foundation

/// The representation fo a file system object
///
/// - directory: A directory on the file system
/// - file: A file on the file system
public enum XcodeFileSystemURLResource {
    /// A directory on the file system
    case directory(path: String, modDate: Date?, basePath: String?)
    /// A file on the file system
    case file(path: String, modDate: Date?, basePath: String?)
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - resource: The resource path and directory indicator
    ///   - modDate: The modification date (Optional)
    public init(_ resource: (path: String, isDirectory: Bool), _ modDate: Date? = nil, base: XcodeFileSystemURLResource? = nil) {
        if resource.isDirectory { self = .directory(path: resource.path, modDate: modDate, basePath: base?.path) }
        else { self = .file(path: resource.path, modDate: modDate, basePath: base?.path) }
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: path of the resource
    ///   - isDirectory: Indicator if its a directory or not (Default: false)
    ///   - modDate: The modification date (Optional)
    ///   - base: The base for this path (Optional)
    public init(path: String,
                isDirectory: Bool = false,
                modDate: Date? = nil,
                base: XcodeFileSystemURLResource? = nil) {
        if isDirectory { self = .directory(path: path, modDate: modDate, basePath: base?.path) }
        else { self = .file(path: path, modDate: modDate, basePath: base?.path) }
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: Path of the directory
    ///   - modDate: The modification date (Optional)
    ///   - base: The base for this path (Optional)
    public init(directory path: String,
                modDate: Date? = nil,
                base: XcodeFileSystemURLResource? = nil) {
        self = .directory(path: path, modDate: modDate, basePath: base?.path)
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: Path of the directory
    ///   - modDate: The modification date (Optional)
    ///   - basePath: The base for this path (Optional)
    public init(directory path: String,
                modDate: Date? = nil,
                basePath: String?) {
        self = .directory(path: path, modDate: modDate, basePath: basePath)
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: Path of the file
    ///   - modDate: The modification date (Optional)
    ///   - base: The base for this path (Optional)
    public init(file path: String,
                modDate: Date? = nil,
                base: XcodeFileSystemURLResource? = nil) {
        self = .file(path: path, modDate: modDate, basePath: base?.path)
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: Path of the file
    ///   - modDate: The modification date (Optional)
    ///   - basePath: The base for this path (Optional)
    public init(file path: String,
                modDate: Date? = nil,
                basePath: String?) {
        self = .file(path: path, modDate: modDate, basePath: basePath)
    }
    
    /// The modification date of the resrouce if set
    public var modificationDate: Date? {
        switch self {
            case .directory(_, let date, _):
                return date
            case .file(_, let date, _):
                return date
        }
    }
    
    /// Indicator if this resource is a directory or not
    public var isDirectory: Bool {
        if case XcodeFileSystemURLResource.directory(_, _, _) = self { return true }
        else { return false }
    }
    
    /// Indicator if this resource is a file or not
    public var isFile: Bool {
        if case XcodeFileSystemURLResource.file(_, _, _) = self { return true }
        else { return false }
    }
    
    
    /// Gets the relative path of the resoruce to another resource
    ///
    /// - Parameter url: The base path to make a relative path
    /// - Returns: Returns the new relative path
    internal func relative(to url: XcodeFileSystemURLResource) -> XcodeFileSystemURLResource {
        if self.isDirectory {
            return .directory(path: self.path.relatvie(to: url.path), modDate: self.modificationDate, basePath: url.path)
        } else {
            return .file(path: self.path.relatvie(to: url.path), modDate: self.modificationDate, basePath: url.path)
        }
    }
    
    
    /*
    /// Gets the relative path of the resoruce to another resource
    ///
    /// - Parameter url: The base path to make a relative path
    /// - Returns: Returns the new relative path
    internal func relative(to url: URL) -> URL {
        return self.realURL.relative(to: url)
    }
    */
}

extension XcodeFileSystemURLResource: Equatable {
    public static func == (lhs: XcodeFileSystemURLResource, rhs: XcodeFileSystemURLResource) -> Bool {
        guard lhs.path == rhs.path else { return false }
        return true
    }
}

// MARK: - URL accessors
extension XcodeFileSystemURLResource {
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the relative path of the URL; otherwise it returns nil.
    ///
    /// This is the same as path if baseURL is nil.
    /// If the URL contains a parameter string, it is appended to the path with a `;`.
    ///
    /// - note: This function will resolve against the base `URL`.
    /// - returns: The relative path, or an empty string if the URL has an empty path.
    public var relativePath: String {
        switch self {
            case .directory(let rtn, _, _):
                return rtn
            case .file(let rtn, _, _):
                return rtn
        }
    }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path component of the URL; otherwise it returns an empty string.
    ///
    /// If the URL contains a parameter string, it is appended to the path with a `;`.
    /// - note: This function will resolve against the base `URL`.
    /// - returns: The path, or an empty string if the URL has an empty path.
    public var path: String {
        var rtn: String = self.relativePath
        if let base = self.basePath, !rtn.hasPrefix("/")  {
           rtn = self.relativePath.path(from: base)
        }
        if self.isDirectory && !rtn.hasSuffix("/") { rtn = rtn + "/" }
        return rtn
    }
    
   
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the host component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    //public var host: String? { return self.realURL.host }
    /// Returns the last path component of the URL, or an empty string if the path is an empty string.
    public var lastPathComponent: String { return NSString(string: self.path).lastPathComponent }
    
    
    public var basePath: String? {
        switch self {
            case .directory(_, _, let rtn):
                return rtn
            case .file(_, _, let rtn):
                return rtn
        }
    }
    /// Returns the path components of the URL, or an empty array if the path is an empty string.
    public var pathComponents: [String] { return  NSString(string: self.path).pathComponents }
    /// Returns the path extension of the URL, or an empty string if the path is an empty string.
    public var pathExtension: String { return  NSString(string: self.path).pathExtension }
    
    /// Appends a path component to the XcodeFileSystemURLResource.
    ///
    /// - parameter pathComponent: The path component to add.
    /// - parameter isDirectory: Use `true` if the resulting path is a directory.
    public mutating func appendPathComponent(_ pathComponent: String, isDirectory: Bool = false) {
        self = self.appendingPathComponent(pathComponent, isDirectory: isDirectory)
    }
    
    /// Returns a URL constructed by appending the given file component to self.
    ///
    /// - parameter fileComponent: The file component to add.
    public mutating func appendFileComponent(_ fileComponent: String) {
        return self.appendPathComponent(fileComponent, isDirectory: false)
    }
    
    /// Returns a URL constructed by appending the given directory component to self.
    ///
    /// - parameter dirComponent: The directory component to add.
    public mutating func appendDirComponent(_ dirComponent: String) {
        return self.appendPathComponent(dirComponent, isDirectory: true)
    }
    
    /// Returns a URL constructed by appending the given path component to self.
    ///
    /// - parameter pathComponent: The path component to add.
    /// - parameter isDirectory: If `true`, then a trailing `/` is added to the resulting path.
    public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool = false) -> XcodeFileSystemURLResource {
        precondition(self.isDirectory, "appendPathComponent must be done on a directory")
        if isDirectory {
            return .directory(path: NSString(string: self.path).appendingPathComponent(pathComponent),
                              modDate: nil,
                              basePath: self.basePath)
        } else {
            return .file(path: NSString(string: self.path).appendingPathComponent(pathComponent),
                         modDate: nil,
                         basePath: self.self.basePath)
        }
    }
    
    /// Returns a URL constructed by appending the given file component to self.
    ///
    /// - parameter fileComponent: The file component to add.
    public func appendingFileComponent(_ fileComponent: String) -> XcodeFileSystemURLResource {
        return self.appendingPathComponent(fileComponent, isDirectory: false)
    }
    
    /// Returns a URL constructed by appending the given directory component to self.
    ///
    /// - parameter dirComponent: The directory component to add.
    public func appendingDirComponent(_ dirComponent: String) -> XcodeFileSystemURLResource {
        return self.appendingPathComponent(dirComponent, isDirectory: true)
    }
    
    /// Deletes the last path component of the XcodeFileSystemURLResource
    ///
    /// This function may either remove a path component or append `/..`.
    ///
    /// If the URL has an empty path (e.g., `http://www.example.com`), then this function will do nothing.
    public mutating func deleteLastPathComponent() {
        self = self.deletingLastPathComponent()
    }
    
    /// Returns a XcodeFileSystemURLResource constructed by removing the last path component of self.
    ///
    /// This function may either remove a path component or append `/..`.
    ///
    /// If the URL has an empty path (e.g., `http://www.example.com`), then this function will do nothing.
    public func deletingLastPathComponent() -> XcodeFileSystemURLResource {
        return .directory(path: NSString(string: self.path).deletingLastPathComponent, modDate: nil, basePath: self.basePath)
    }
    
    internal var url: URL {
        return URL(fileURLWithPath: self.path)
    }
}
