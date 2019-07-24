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
    case directory(URL, Date?)
    /// A file on the file system
    case file(URL, Date?)
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - resource: The URL resource
    ///   - modDate: The modification date (Optional)
    public init(_ resource: (path: URL, isDirectory: Bool), _ modDate: Date? = nil) {
        if resource.isDirectory { self = .directory(resource.path, modDate) }
        else { self = .file(resource.path, modDate) }
    }
    
    /// Create a new resource object
    ///
    /// - Parameters:
    ///   - path: URL of the resource
    ///   - isDirectory: Indicator if its a directory or not (Default: false)
    ///   - modDate: The modification date (Optional)
    public init(path: URL,
                isDirectory: Bool = false,
                modDate: Date? = nil) {
        if isDirectory { self = .directory(path, modDate) }
        else { self = .file(path, modDate) }
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - string: The URL string
    ///   - relativeTo: The resource its relative to
    ///   - isDirectory: Indicator if its a directory or not (Default: false)
    ///   - modDate: The modification date (Optional)
    public init?(string: String,
                 relativeTo: XcodeFileSystemURLResource,
                 isDirectory: Bool = false,
                 modDate: Date? = nil) {
        guard let newURL = URL(string: string, relativeTo: relativeTo.realURL) else { return nil }
        if isDirectory {
            self = .directory(newURL, modDate)
        } else {
            self = .file(newURL, modDate)
        }
        
    }
    
    /// The actual URL of the resource
    public var realURL: URL {
        switch self {
            case .directory(let url, _) : return url
            case .file( let url, _): return url
        }
    }
    
    /*internal var provider: XcodeFileSystemProvider {
        switch self {
            case .directory(_, let provider, _) : return provider
            case .file(_, let provider, _): return provider
        }
    }*/
    
    /// The modification date of the resrouce if set
    public var modificationDate: Date? {
        switch self {
            case .directory(_, let date):
                return date
            case .file(_, let date):
                return date
        }
    }
    
    /// Indicator if this resource is a directory or not
    public var isDirectory: Bool {
        if case XcodeFileSystemURLResource.directory(_, _) = self { return true }
        else { return false }
    }
    
    /// Gets the relative path of the resoruce to another resource
    ///
    /// - Parameter url: The base path to make a relative path
    /// - Returns: Returns the new relative path
    internal func relative(to url: XcodeFileSystemURLResource) -> XcodeFileSystemURLResource {
        if self.isDirectory {
            return .directory(self.realURL.relative(to: url.realURL), self.modificationDate)
        } else {
            return .file(self.realURL.relative(to: url.realURL), self.modificationDate)
        }
    }
    
    /// Gets the relative path of the resoruce to another resource
    ///
    /// - Parameter url: The base path to make a relative path
    /// - Returns: Returns the new relative path
    internal func relative(to url: URL) -> URL {
        return self.realURL.relative(to: url)
    }
    
}

extension XcodeFileSystemURLResource: Equatable {
    public static func == (lhs: XcodeFileSystemURLResource, rhs: XcodeFileSystemURLResource) -> Bool {
        guard lhs.isFileURL == rhs.isFileURL else { return false }
        return lhs.realURL == rhs.realURL
    }
}
/*
 public extension XcodeFileSystemURLResource {
    func children() throws -> [XcodeFileSystemURLResource] {
        guard self.isDirectory else { return [] }
        return try self.provider.contentsOfDirectory(at: self)
    }
}
*/
// MARK: - URL accessors
extension XcodeFileSystemURLResource {
    /// Returns the absolute string for the URL.
    public var absoluteString: String { return self.realURL.absoluteString }
    /// Returns the absolute URL.
    ///
    /// If the URL is itself absolute, this will return self.
    public var absoluteURL: URL { return self.realURL.absoluteURL }
    /// Returns the base URL.
    ///
    /// If the URL is itself absolute, then this value is nil.
    public var baseURL: URL? { return self.realURL.baseURL }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the fragment component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var fragment: String? { return self.realURL.fragment }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the host component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var host: String? { return self.realURL.host }
    /// Returns the last path component of the URL, or an empty string if the path is an empty string.
    public var lastPathComponent: String { return self.realURL.lastPathComponent }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the path component of the URL; otherwise it returns an empty string.
    ///
    /// If the URL contains a parameter string, it is appended to the path with a `;`.
    /// - note: This function will resolve against the base `URL`.
    /// - returns: The path, or an empty string if the URL has an empty path.
    public var path: String { return self.realURL.path }
    /// Returns the path components of the URL, or an empty array if the path is an empty string.
    public var pathComponents: [String] { return self.realURL.pathComponents }
    /// Returns the path extension of the URL, or an empty string if the path is an empty string.
    public var pathExtension: String { return self.realURL.pathExtension }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the port component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var port: Int? { return self.realURL.port }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the query of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var query: String? { return self.realURL.query }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the relative path of the URL; otherwise it returns nil.
    ///
    /// This is the same as path if baseURL is nil.
    /// If the URL contains a parameter string, it is appended to the path with a `;`.
    ///
    /// - note: This function will resolve against the base `URL`.
    /// - returns: The relative path, or an empty string if the URL has an empty path.
    public var relativePath: String { return self.realURL.relativePath }
    /// The relative portion of a URL.
    ///
    /// If `baseURL` is nil, or if the receiver is itself absolute, this is the same as `absoluteString`.
    public var relativeString: String { return self.realURL.relativeString }
    /// Returns the scheme of the URL.
    public var scheme: String? { return self.realURL.scheme }
    /// Returns a `XcodeFileSystemURLResource` with any instances of ".." or "." removed from its path.
    public var standardized: XcodeFileSystemURLResource {
        switch self {
            case .directory(let url, let modDate):
                return .directory(url.standardized, modDate)
            case .file( let url, let modDate):
                return .file(url.standardized, modDate)
        }
    }
    /// Standardizes the path of a file URL.
    ///
    /// If the `isFileURL` is false, this method returns `self`.
    public var standardizedFileURL: XcodeFileSystemURLResource {
        switch self {
            case .directory(let url, let modDate):
                return .directory(url.standardizedFileURL, modDate)
            case .file( let url, let modDate):
                return .file(url.standardizedFileURL, modDate)
        }
    }
    
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the user component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var user: String? { return self.realURL.user }
    /// If the URL conforms to RFC 1808 (the most common form of URL), returns the password component of the URL; otherwise it returns nil.
    ///
    /// - note: This function will resolve against the base `URL`.
    public var password: String? { return self.realURL.password }
    
    
    /// Returns true if the scheme is `file:`.
    public var isFileURL: Bool { return self.realURL.isFileURL }
    /// Returns true if the URL path represents a directory.
    @available(OSX 10.11, *)
    public var hasDirectoryPath: Bool { return self.realURL.hasDirectoryPath }
    
    /// Resolves any symlinks in the path of a file XcodeFileSystemURLResource.
    ///
    /// If the `isFileURL` is false, this method returns `self`.
    public mutating func resolveSymlinksInPath() {
        switch self {
            case .directory(let url, let modDate):
                self = .directory(url.resolvingSymlinksInPath(), modDate)
            case .file( let url, let modDate):
                self = .file(url.resolvingSymlinksInPath(), modDate)
        }
    }
    
    
    /// Resolves any symlinks in the path of a file XcodeFileSystemURLResource.
    ///
    /// If the `isFileURL` is false, this method returns `self`.
    public func resolvingSymlinksInPath() -> XcodeFileSystemURLResource {
        switch self {
            case .directory(let url, let modDate):
                return .directory(url.resolvingSymlinksInPath(), modDate)
            case .file( let url, let modDate):
                return .file(url.resolvingSymlinksInPath(), modDate)
        }
    }
    
    /// Standardizes the path of a file XcodeFileSystemURLResource.
    ///
    /// If the `isFileURL` is false, this method does nothing.
    public mutating func standardize() {
        switch self {
            case .directory(let url, let modDate):
                self = .directory(url.standardized, modDate)
            case .file( let url, let modDate):
                self = .file(url.standardized, modDate)
        }
    }
    
    
    /// Appends a path component to the XcodeFileSystemURLResource.
    ///
    /// - parameter pathComponent: The path component to add.
    /// - parameter isDirectory: Use `true` if the resulting path is a directory.
    public mutating func appendPathComponent(_ pathComponent: String, isDirectory: Bool) {
        precondition(self.isDirectory, "appendPathComponent must be done on a directory")
        if isDirectory {
            self = .directory(self.realURL.appendingPathComponent(pathComponent, isDirectory: isDirectory),
                              nil)
        } else {
            self = .file(self.realURL.appendingPathComponent(pathComponent, isDirectory: isDirectory),
                         nil)
        }
    }
    
    /// Returns a URL constructed by appending the given path component to self.
    ///
    /// - parameter pathComponent: The path component to add.
    /// - parameter isDirectory: If `true`, then a trailing `/` is added to the resulting path.
    public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> XcodeFileSystemURLResource {
        precondition(self.isDirectory, "appendPathComponent must be done on a directory")
        if isDirectory {
            return .directory(self.realURL.appendingPathComponent(pathComponent, isDirectory: isDirectory).standardized,
                              nil)
        } else {
            return .file(self.realURL.appendingPathComponent(pathComponent, isDirectory: isDirectory).standardized,
                         nil)
        }
    }
    
    /// Deletes the last path component of the XcodeFileSystemURLResource
    ///
    /// This function may either remove a path component or append `/..`.
    ///
    /// If the URL has an empty path (e.g., `http://www.example.com`), then this function will do nothing.
    public mutating func deleteLastPathComponent() {
        self = .directory(self.realURL.deletingLastPathComponent(), nil)
    }
    
    /// Returns a XcodeFileSystemURLResource constructed by removing the last path component of self.
    ///
    /// This function may either remove a path component or append `/..`.
    ///
    /// If the URL has an empty path (e.g., `http://www.example.com`), then this function will do nothing.
    public func deletingLastPathComponent() -> XcodeFileSystemURLResource {
        return .directory(self.realURL.deletingLastPathComponent(), nil)
    }
}
