//
//  XCUserDataList.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-15.
//

import Foundation

/// Stores all the user data
public final class XCUserDataList: NSObject {
    
    public enum Error: Swift.Error {
        //case urlNotFileBased(URL)
        case userDataListFolderMissing(URL)
    }
    
    fileprivate var users: [XCUserData] = []
    
    /// The number of elements in the collection.
    public var count: Int { return self.users.count }
    /// Accesses the element at the specified position.
    public subscript(index: Int) -> XCUserData {
        get { return self.users[index] }
        set { self.users[index] = newValue }
    }
    
    public override var debugDescription: String {
        var rtn: String = "XCUserDataList["
        for (i, user) in self.users.enumerated() {
            if i > 0 { rtn += ", " }
            rtn += user.debugDescription
        }
        rtn += "]"
        return rtn
    }
    
    /// Create a new empty instance of a User Data List
    public override init() {
        super.init()
    }
    /// Create a new instance of a User Data List from file
    ///
    /// - Parameters:
    ///   - url: The url to the user dat alist
    ///   - provider: The file system provider to use
    public init(fromURL url: XcodeFileSystemURLResource,
                usingFSProvider provider: XcodeFileSystemProvider) throws {
        
       
        if try provider.itemExists(at: url) {
            
            let children = try provider.contentsOfDirectory(at: url)
            for child in children {
                if child.lastPathComponent.lowercased().hasSuffix(XCUserData.USER_DATA_PACKAGE_EXT) {
                    users.append(try XCUserData(from: child, usingFSProvider: provider))
                }
            }
        }
        super.init()
        
    }
    
    /// Adds a new element at the end of the array.
    ///
    /// Use this method to append a single element to the end of a mutable array.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(100)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 100]"
    ///
    /// Because arrays increase their allocated capacity using an exponential
    /// strategy, appending a single element to an array is an O(1) operation
    /// when averaged over many calls to the `append(_:)` method. When an array
    /// has additional capacity and is not sharing its storage with another
    /// instance, appending an element is O(1). When an array needs to
    /// reallocate storage before appending or its storage is shared with
    /// another copy, appending is O(*n*), where *n* is the length of the array.
    ///
    /// - Parameter newElement: The element to append to the array.
    ///
    /// - Complexity: O(1) on average, over many calls to `append(_:)` on the
    ///   same array.
    public func append(_ user: XCUserData) {
        self.users.append(user)
    }
    
    /// Get all save actions that are needed
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    /// - Returns: Returns an array of all save actions that are required
    public func saveActions(to url: XcodeFileSystemURLResource,
                            overrideChangeCheck: Bool = false) throws -> [XcodeFileSystemProviderAction] {
        var rtn: [XcodeFileSystemProviderAction] = []
        for user in users {
            rtn.append(contentsOf: try user.saveActions(to: url.appendingDirComponent(user.user + "." + XCUserData.USER_DATA_PACKAGE_EXT),
                                                        overrideChangeCheck: overrideChangeCheck))
        }
        return rtn
    }
    
    /// Save thisobject to the file system
    ///
    /// - Parameters:
    ///   - url: The location where to save to
    ///   - provider: the file system provider to use
    ///   - overrideChangeCheck: Indicator if should override any value change checks (Default: false)
    public func save(to url: XcodeFileSystemURLResource,
                     usingFSProvider provider: XcodeFileSystemProvider,
                     overrideChangeCheck: Bool = false) throws {
        for user in users {
            try user.save(to: url.appendingDirComponent(user.user + "." + XCUserData.USER_DATA_PACKAGE_EXT),
                          usingFSProvider: provider,
                          overrideChangeCheck: overrideChangeCheck)
        }
    }
    
}

extension XCUserDataList: Sequence {
    public func makeIterator() -> Array<XCUserData>.Iterator {
        return self.users.makeIterator()
    }
}
