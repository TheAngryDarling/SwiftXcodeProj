//
//  XcodeFileSystemProvider.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-05.
//

import Foundation


public typealias XcodeFSProviderActionCompleteHandler = (XcodeFileSystemProvider, XcodeFileSystemProviderAction, XcodeFileSystemProviderActionResponse?, Error?) -> Void

/// A File System Action
///
/// - noAction: A non action action.  Nothing happens with this action
/// - exists: Checks to see if an object exists
/// - notExists: Checks to see if an object does not exist
/// - dateAttribute: Get a specific date attribute
/// - dateAttributeComparison: Compare a date attribute
/// - isDirectory: Checks to see if an object is a directory
/// - data: Get the data for the file
/// - write: Write that data of a file
/// - directoryContents?: Get the contents of a directory
/// - directoryRemoveContents?: Remove items from within a directory
/// - directoryDataContents?: Get the data content from within the directory
/// - createDirectory: Create a new directory
/// - copy: Copy a resource
/// - remove: Remove a resource
/// - actionWithDependancies: An action that requires other action to succeed before it can be executed
/// - actionWithCallBack: An action that has a callback after its been completed
/// - actionWithFailoverAction: An action that if fails will execute a secondary action
public indirect enum XcodeFileSystemProviderAction {
    
    /// Operation when comparing attributes
    public enum Operator {
        case greaterThan
        case greaterThanOrEquals
        case equals
        case lessThanOrEquals
        case lessThan
    }
    
    /// The date attribute to work with
    public enum DateAttribute {
        case creation
        case lastModified
    }
    
    /// The type of objects when collecting items from a directory
    public enum DirectoryContentType {
        case any
        case folder
        case file
    }
    
    ///  A non action action.  Nothing happens with this action
    case noAction(for: XcodeFileSystemURLResource)
    /// Checks to see if an object exists
    case exists(item: XcodeFileSystemURLResource)
    /// Checks to see if an object does not exist
    case notExists(item: XcodeFileSystemURLResource)
    ///  Get a specific date attribute
    case dateAttribute(item: XcodeFileSystemURLResource, attribute: DateAttribute)
    /// Compare a date attribute
    case dateAttributeComparison(item: XcodeFileSystemURLResource, attribute: DateAttribute, operator: Operator, value: Date)
    /// Checks to see if an object is a directory
    case isDirectory(item: XcodeFileSystemURLResource)
    /// Get the data for the file
    case data(for: XcodeFileSystemURLResource, readOptions: Data.ReadingOptions)
    /// Write that data of a file
    case write(data: Data, to: XcodeFileSystemURLResource, writeOptions: Data.WritingOptions)
    /// Get the contents of a directory
    case directoryContents(for: XcodeFileSystemURLResource, ofType: DirectoryContentType, withRegExFilter: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?)
    /// Remove items from within a directory
    case directoryRemoveContents(from: XcodeFileSystemURLResource, ofType: DirectoryContentType, withRegExFilter: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?)
    /// Get the data content from within the directory
    case directoryDataContents(from: XcodeFileSystemURLResource, readOptions: Data.ReadingOptions, withRegExFilter: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?)
    /// Create a new directory
    case createDirectory(at: XcodeFileSystemURLResource, withIntermediateDirectories: Bool)
    /// Copy a resource
    case copy(source: XcodeFileSystemURLResource, destination: XcodeFileSystemURLResource)
    /// Remove a resource
    case remove(item: XcodeFileSystemURLResource)
    /// An action that requires other action to succeed before it can be executed
    case actionWithDependencies(dependants: [XcodeFileSystemProviderAction], action: XcodeFileSystemProviderAction)
    /// An action that has a callback after its been completed
    case actionWithCallBack(action: XcodeFileSystemProviderAction, handler: XcodeFSProviderActionCompleteHandler)
    /// An action that if fails will execute a secondary action
    case actionWithFailoverAction(action: XcodeFileSystemProviderAction, failover: XcodeFileSystemProviderAction)
    
    
    /// The resource this action is acting on
    internal var url: XcodeFileSystemURLResource {
        switch self {
            case .noAction(for: let url): return url
            case .exists(item: let url): return url
            case .notExists(item: let url): return url
            case .dateAttribute(item: let url, _): return url
            case .dateAttributeComparison(item: let url, _, _, _): return url
            case .isDirectory(item: let url): return url
            case .data(for: let url, _): return url
            case .write(_, to: let url, _): return url
            case .directoryContents(for: let url, _, _): return url
            case .directoryRemoveContents(from: let url, _, _): return url
            case .directoryDataContents(from: let url, _, _): return url
            case .createDirectory(at: let url, withIntermediateDirectories: _): return url
            case .copy(source: let url, destination: _): return url
            case .remove(item: let url): return url
            case .actionWithDependencies(dependants: _, action: let action): return action.url
            
            case .actionWithCallBack(action: let action, handler: _): return action.url
            case .actionWithFailoverAction(action: let action, failover: _): return action.url
        }
    }
    
    /// The method for calling any callback from this action
    ///
    /// - Parameters:
    ///   - fs: The filesystem provider
    ///   - response: The action that was executed
    ///   - error: Any error that occured while executing the action
    public func invokeHandler(fs: XcodeFileSystemProvider, response: XcodeFileSystemProviderActionResponse?, error: Error?) {
        guard case let XcodeFileSystemProviderAction.actionWithCallBack(action: act, handler: handler) = self else { return }
        handler(fs, act, response, error)
    }
    
    /// Creates an action with dependancy that gets the data of a file if it exists
    ///
    /// - Parameters:
    ///   - resource: The file to get the data for
    ///   - readOptions: The reading options
    /// - Returns: Returns an action that represents the retrieval of data for a resource
    public static func dataIfExists(for resource: XcodeFileSystemURLResource, readOptions: Data.ReadingOptions = []) -> XcodeFileSystemProviderAction {
        return XcodeFileSystemProviderAction.data(for: resource, readOptions: readOptions).withDependencies(.exists(item: resource))
    }
    
    /// Creates an action with dependancy that removes a file system object only if it exists
    ///
    /// - Parameter item: The resource to remove
    /// - Returns: Returns an action that represents the removal of a resource
    public static func removeIfExists(item: XcodeFileSystemURLResource) -> XcodeFileSystemProviderAction {
        return XcodeFileSystemProviderAction.remove(item: item).withDependencies(.exists(item: item))
    }
    
    /// Creates a write action that then has a callback when its finished
    ///
    /// - Parameters:
    ///   - data: The data to write to a file
    ///   - to: The location to write the data
    ///   - writeOptions: The write options
    ///   - callback: The call back to execute when the action is completed
    /// - Returns: Returns the action with callback
    public static func writeData(_ data: Data,
                             to: XcodeFileSystemURLResource,
                             writeOptions: Data.WritingOptions = [],
                             callback: @escaping XcodeFSProviderActionCompleteHandler) -> XcodeFileSystemProviderAction {
        return XcodeFileSystemProviderAction.write(data: data,
                                                   to: to,
                                                   writeOptions: writeOptions).withCallback(callback: callback)
    }
    
   /// Creates a new action that takes the current action and wraps it around with a callback action
   ///
   /// - Parameter callback: The callback to execute when an action has completed
   /// - Returns: Returns a new action that is wrapped with a callback action
   public func withCallback(callback: @escaping XcodeFSProviderActionCompleteHandler) -> XcodeFileSystemProviderAction {
        return .actionWithCallBack(action: self, handler: callback)
    }
    
   /// Creates a new action that takes the current action and wraps it around with a failover action
   ///
   /// - Parameter failover: The failover action to execute if the current action fails
   /// - Returns: Returns a new action that is warapped with a failover action
   public func withFailover(failover: XcodeFileSystemProviderAction) -> XcodeFileSystemProviderAction {
        return .actionWithFailoverAction(action: self, failover: failover)
    }
    /// Creates a new action that takes the current action and wraps it with dependencies
    ///
    /// - Parameter dependencies: The dependancies to require on this action
    /// - Returns: Returns a new action that is wrapped wtih a dependencies action
    public func withDependencies(_ dependencies: [XcodeFileSystemProviderAction]) -> XcodeFileSystemProviderAction {
        return .actionWithDependencies(dependants: dependencies, action: self)
    }
    /// Creates a new action that takes the current action and wraps it with dependencies
    ///
    /// - Parameter dependencies: The dependancies to require on this action
    /// - Returns: Returns a new action that is wrapped wtih a dependencies action
    public func withDependencies(_ dependencies: XcodeFileSystemProviderAction...) -> XcodeFileSystemProviderAction {
        return .actionWithDependencies(dependants: dependencies, action: self)
    }
    
    /// A function to help validate the resources on an action
    ///
    /// - Parameter precondition: The validation method
    /// - Returns: Returns a resource that fails the validateion
    func validateResourceConditions(_ precondition: (XcodeFileSystemURLResource) throws -> Bool)  rethrows -> XcodeFileSystemURLResource? {
        switch self {
        case .noAction(for: let res):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .exists(item: let res):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .notExists(item: let res):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .dateAttribute(item: let res, _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .dateAttributeComparison(item: let res, _, _, _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .isDirectory(item: let res):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .data(for: let res, readOptions: _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .write(_, to: let res, writeOptions: _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .directoryContents(for: let res, _, _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .directoryRemoveContents(from: let res, _, _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .directoryDataContents(from: let res, _, _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .createDirectory(at: let res, withIntermediateDirectories: _):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .copy(source: let resA, destination: let resB):
            if !(try precondition(resA)) { return resA }
            else if !(try precondition(resB)) { return resB }
            else { return nil }
        case .remove(item: let res):
            if !(try precondition(res)) { return res }
            else { return nil }
        case .actionWithDependencies(dependants: let dependancies, action: let action):
            var rtn: XcodeFileSystemURLResource? = nil
            for d in dependancies where (rtn == nil) {
                
                rtn = try d.validateResourceConditions(precondition)
            }
            
            /*for a in actions where (rtn == nil) {
                rtn = try a.validateResourceConditions(precondition)
            }*/
            rtn = try action.validateResourceConditions(precondition)
            
            
            return rtn
        case .actionWithCallBack(action: let action, handler: _):
            return try action.validateResourceConditions(precondition)
        case .actionWithFailoverAction(action: let action, failover: let failover):
            if let r = try action.validateResourceConditions(precondition) {
                return r
            } else if let r = try failover.validateResourceConditions(precondition) {
                return r
            } else {
                return nil
            }
        }
    }
}

/// A File System Action Response
///
/// - void: Void response
/// - bool: A Bool response value
/// - data: A Date respopnse value
/// - resourceData: A resourece data response value
/// - date: A date response value
/// - directoryContents: Resource list values
/// - directoryDataContents]: Resoureces and data list values
/// - failedDependancy: Failed dependancy response
public enum XcodeFileSystemProviderActionResponse {
    
    /// Void response
    case void(for: XcodeFileSystemURLResource)
    /// A Bool response value
    case bool(Bool, for: XcodeFileSystemURLResource)
    /// A Date respopnse value
    case data(Data, for: XcodeFileSystemURLResource)
    /// A resourece data response value
    case resourceData(Data, modDate: Date, for: XcodeFileSystemURLResource)
    /// A date response value
    case date(Date, for: XcodeFileSystemURLResource)
    /// Resource list values
    case directoryContents([XcodeFileSystemURLResource], for: XcodeFileSystemURLResource)
    /// Resoureces and data list values
    case directoryDataContents([(resource: XcodeFileSystemURLResource, data: Data)], for: XcodeFileSystemURLResource)
    /// Failed dependancy response
    case failedDependancy(XcodeFileSystemProviderAction, for: XcodeFileSystemURLResource)
    
     /// The resource this response is for
    internal var url: XcodeFileSystemURLResource {
        switch self {
            case .void(for: let url): return url
            case .bool(_, for: let url): return url
            case .data(_, for: let url): return url
            case .resourceData(_, _, for: let url): return url
            case .date(_, for: let url): return url
            case .directoryContents(_, for: let url): return url
            case .directoryDataContents(_, for: let url): return url
            case .failedDependancy(_, for: let url): return url
            //case .exists(_, for: let url): return url
            //case .notExists(_, for: let url): return url
        }
    }
    
    /// If this is Bool response, it returns a the value of it, otherwise it will return true
    internal var boolResults: Bool {
        guard case let .bool(b, for: _) = self else { return true }
        return b
    }
    
    /// Returns if the action was successful or not.
    ///
    /// If this is a Bool response, the bool value is returned
    /// If this is failedDependancy response, the value is false
    /// Otherwise the value is true
    internal var succeeded: Bool {
        switch self {
            case .bool(let b, for: _): return b
            case .failedDependancy(_, for: _): return false
            default: return true
        }
    }
    
    /// Returns if the current response is a failed dependency response
    internal var isFailedDependancy: Bool {
        guard case .failedDependancy(_, for: _) = self else { return false }
        return true
    }
    
}

public enum XcodeFileSystemProviderErrors: Error {
    case missingResults
    case invalidResults
}

public protocol XcodeFileSystemProvider {
    
    /// Execute the provided actions on the the given file system
    ///
    /// - Parameter actions: The array of actions to execute
    /// - Returns: An array of action responses one for each action
    @discardableResult
    func actions( _ actions: [XcodeFileSystemProviderAction]) throws -> [XcodeFileSystemProviderActionResponse]
    
    /// Execute the provided actions on the the given file system
    ///
    /// - Parameter actions: The array of actions to execute
    /// - Returns: An array of action responses one ffor each action
    @discardableResult
    func actions( actions: XcodeFileSystemProviderAction...) throws -> [XcodeFileSystemProviderActionResponse]
    
    /// Execute the provided action on the the given file system
    ///
    /// - Parameter action: The action to execute
    /// - Returns: The action response from the execution of the action
    @discardableResult
    func action( _ action: XcodeFileSystemProviderAction) throws -> XcodeFileSystemProviderActionResponse
    
    
    /// A method for reading the data from a file on the file system
    ///
    /// - Parameters:
    ///   - url: The url of the file to read
    ///   - options: The read options
    /// - Returns: The data from the file
    func data(from url: XcodeFileSystemURLResource,
              withOptions options: Data.ReadingOptions) throws -> Data
    /// A method for reading the data from a file on the file system if modified after a specific date
    ///
    /// - Parameters:
    ///   - url: The url of the file to read
    ///   - options: The read options
    ///   - ifModifiedAfter: The modification date to check against
    /// - Returns: The data from the file if it was modified after the given date
    func data(from url: XcodeFileSystemURLResource,
              withOptions options: Data.ReadingOptions, ifModifiedAfter: Date) throws -> Data?
    
    /// A method for reading the data from a file on the file system if it exists
    ///
    /// - Parameters:
    ///   - url: The url of the file to read
    ///   - options: The read options
    /// - Returns: The data from the file if it existsed
    func dataIfExists(from url: XcodeFileSystemURLResource,
                      withOptions options: Data.ReadingOptions) throws -> Data?
    
    /// Write the given data to a specific file location
    ///
    /// - Parameters:
    ///   - data: The data to write
    ///   - url: The location to write it to
    ///   - options: The write options
    func write(_ data: Data,
               to url: XcodeFileSystemURLResource,
               withOptions options: Data.WritingOptions) throws
    
    
    /// Get the child elements of a given folder
    ///
    /// - Parameters:
    ///   - url: The url of the folder to read the contents from
    ///   - ofType: The type of elements to return
    ///   - regex: Any regular expression to help filter the elements (Optional)
    /// - Returns: Returns an array of child elements
    func contentsOfDirectory(at url: XcodeFileSystemURLResource,
                             ofType: XcodeFileSystemProviderAction.DirectoryContentType,
                             withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?) throws -> [XcodeFileSystemURLResource]
    /// Get the child elements of a given folder and incldue data for the files
    ///
    /// - Parameters:
    ///   - url: The url of the folder to read the contents from
    ///   - ofType: The type of elements to return
    ///   - regex: Any regular expression to help filter the elements (Optional)
    /// - Returns: Returns an array of child elements
    func contentsAndDataOfDirectory(at url: XcodeFileSystemURLResource,
                                    readOptions options: Data.ReadingOptions,
                                    withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?) throws -> [(resource: XcodeFileSystemURLResource, data: Data)]
    /// Check to see if a file system object exists or not
    ///
    /// - Parameter url: The url to the file system object
    /// - Returns: Returns true if the object exists or false if it does not
    func itemExists(at url: XcodeFileSystemURLResource) throws -> Bool
    /// Returns the last modified date of the file system object
    ///
    /// - Parameter url: The url to the file system object
    /// - Returns: Returns the last modification date of the file system object
    func lastModificationDate(for url: XcodeFileSystemURLResource) throws -> Date
    /// Returns the creation date of the file system object
    ///
    /// - Parameter url: The url to the file system object
    /// - Returns: Returns the creation date of the file system object
    func creationDate(for url: XcodeFileSystemURLResource) throws -> Date
    /// Create a new directory on the file system
    ///
    /// - Parameters:
    ///   - url: The url of where to create the directory
    ///   - intermediateDirectories: If true, this method creates any non-existent parent directories as part of creating the directory in path. If false, this method fails if any of the intermediate parent directories does not exist. This method also fails if any of the intermediate path elements corresponds to a file and not a directory.
    func createDirectory(at url: XcodeFileSystemURLResource,
                         withIntermediateDirectories intermediateDirectories: Bool) throws
    
    /// Copy the specific file system object from source location to destination location
    ///
    /// - Parameters:
    ///   - source: The location of the object to copy
    ///   - destination: The location of where to copy the object to
    func copy(_ source: XcodeFileSystemURLResource,
              to destination: XcodeFileSystemURLResource) throws
    
    /// Remove the specific object
    ///
    /// This may throw an exception if the file does not exists and you try to delete it
    /// - Parameter url: The url of the object to remove
    func remove(item url: XcodeFileSystemURLResource) throws
    /// remove the specific object if it exists
    ///
    /// - Parameter url: The url of the object to remove
    func removeIfExists(item url: XcodeFileSystemURLResource) throws
    
    
    
    //var supportsRecycleBin: Bool { get }
    //func recycle(item url: XcodeFileSystemURLResource, completionHandler handler: (([URL : URL], Error?) -> Void)?) throws
    //func recycle(items urls: [XcodeFileSystemURLResource], completionHandler handler: (([URL : URL], Error?) -> Void)?) throws
    
    
    
}

public extension XcodeFileSystemProvider {
    
    /// Read data from file
    ///
    /// - Parameters:
    ///   - url: The address of the file to read
    ///   - options: The reading options
    /// - Returns: Returns the data content of the file
    func data(from url: XcodeFileSystemURLResource,
              withOptions options: Data.ReadingOptions) throws -> Data {
        let r = try self.action(.data(for: url, readOptions: options))
        guard case let XcodeFileSystemProviderActionResponse.data(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
        
    }
    
    /// Read data from file if modified after a given date
    ///
    /// - Parameters:
    ///   - url: The address of the file to read
    ///   - options: The reading options
    ///   - ifModifiedAfter: The date to compare to
    /// - Returns: Returns the data content of the file only if the modification date is after the given date, otherwise returns nil
    func data(from url: XcodeFileSystemURLResource,
              withOptions options: Data.ReadingOptions,
              ifModifiedAfter: Date) throws -> Data? {
        let r = try self.action(.actionWithDependencies(dependants: [.dateAttributeComparison(item: url,
                                                                                              attribute: .lastModified,
                                                                                              operator: .greaterThan,
                                                                                              value: ifModifiedAfter)],
                                                        action: .data(for: url, readOptions: options)))
        if case let XcodeFileSystemProviderActionResponse.data(dta, for: _) = r {
            return dta
        } else if case XcodeFileSystemProviderActionResponse.failedDependancy(_, for: _) = r {
            return nil
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    /// Read data from file if the file exists
    ///
    /// - Parameters:
    ///   - url: The address of the file to read
    ///   - options: The reading options
    /// - Returns: Returns the data content of the file only if the file exists, otherwise returns nil
    func dataIfExists(from url: XcodeFileSystemURLResource,
                      withOptions options: Data.ReadingOptions) throws -> Data? {
        let r = try self.action(.actionWithDependencies(dependants: [.exists(item: url)],
                                                        action: .data(for: url, readOptions: options)))
        if case let XcodeFileSystemProviderActionResponse.data(dta, for: _) = r {
            return dta
        } else if case XcodeFileSystemProviderActionResponse.failedDependancy(_, for: _) = r {
            return nil
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    /// Write data to a given address
    ///
    /// - Parameters:
    ///   - data: The data to write
    ///   - url: The address of the file to write to
    ///   - options: The write options
    func write(_ data: Data,
                      to url: XcodeFileSystemURLResource,
                      withOptions options: Data.WritingOptions) throws {
        
        let action: XcodeFileSystemProviderAction = .write(data: data, to: url, writeOptions: options)
        
        let r = try self.action(action)
        
        
        guard case XcodeFileSystemProviderActionResponse.void(for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
   
    
    /// Get the content of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - ofType: The type of objects to get (any, files, folders)
    ///   - regex: A pattern match to filter the list
    /// - Returns: Returns an array of resources within the folder
    func contentsOfDirectory(at url: XcodeFileSystemURLResource,
                             ofType: XcodeFileSystemProviderAction.DirectoryContentType,
                             withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?) throws -> [XcodeFileSystemURLResource] {
        guard url.isDirectory else { return [] }
        
        let r = try self.action(.directoryContents(for: url, ofType: ofType, withRegExFilter: regex))
        
        guard case let XcodeFileSystemProviderActionResponse.directoryContents(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    /// Get the content of a given directory
    ///
    /// - Parameter url: The address of the directory to look at
    /// - Returns: Returns an array of resources within the folder
    func contentsOfDirectory(at url: XcodeFileSystemURLResource)throws -> [XcodeFileSystemURLResource] {
        return try self.contentsOfDirectory(at: url, ofType: .any, withRegExFilter: nil)
    }
    
    /// Get the content of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - ofType: The type of objects to get (all, files, folders)
    /// - Returns: Returns an array of resources within the folder
    func contentsOfDirectory(at url: XcodeFileSystemURLResource,
                             ofType: XcodeFileSystemProviderAction.DirectoryContentType)throws -> [XcodeFileSystemURLResource] {
        return try self.contentsOfDirectory(at: url, ofType: ofType, withRegExFilter: nil)
    }
    
    /// Get the content of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - regex: A pattern match to filter the list
    /// - Returns: Returns an array of resources within the folder
    func contentsOfDirectory(at url: XcodeFileSystemURLResource,
                             withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)) throws -> [XcodeFileSystemURLResource] {
        return try self.contentsOfDirectory(at: url, ofType: .any, withRegExFilter: regex)
    }
    
    /// Get file contents and data of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - options: The read options to use
    ///   - regex: A pattern match to filter the list
    /// - Returns: Returns an array of file resources and their corresponding data
    func contentsAndDataOfDirectory(at url: XcodeFileSystemURLResource,
                                    readOptions options: Data.ReadingOptions,
                                    withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)?) throws -> [(resource: XcodeFileSystemURLResource, data: Data)] {
        guard url.isDirectory else { return [] }
        
        let r = try self.action(.directoryDataContents(from: url,
                                                       readOptions: options, withRegExFilter: regex))
        guard case let XcodeFileSystemProviderActionResponse.directoryDataContents(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
        
    }
    
    /// Get file contents and data of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    /// - Returns: Returns an array of file resources and their corresponding data
    func contentsAndDataOfDirectory(at url: XcodeFileSystemURLResource) throws -> [(resource: XcodeFileSystemURLResource, data: Data)] {
        return try self.contentsAndDataOfDirectory(at: url, readOptions: [], withRegExFilter: nil)
    }
    
    /// Get file contents and data of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - options: The read options to use
    /// - Returns: Returns an array of file resources and their corresponding data
    func contentsAndDataOfDirectory(at url: XcodeFileSystemURLResource,
                                    readOptions options: Data.ReadingOptions) throws -> [(resource: XcodeFileSystemURLResource, data: Data)] {
        return try self.contentsAndDataOfDirectory(at: url, readOptions: options, withRegExFilter: nil)
    }
    
    /// Get file contents and data of a given directory
    ///
    /// - Parameters:
    ///   - url: The address of the directory to look at
    ///   - regex: A pattern match to filter the list
    /// - Returns: Returns an array of file resources and their corresponding data
    func contentsAndDataOfDirectory(at url: XcodeFileSystemURLResource,
                                    withRegExFilter regex: (pattern: String, patternOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions)) throws -> [(resource: XcodeFileSystemURLResource, data: Data)] {
        return try self.contentsAndDataOfDirectory(at: url, readOptions: [], withRegExFilter: regex)
    }
    
    /// Checks to see if an item exists on the file system
    ///
    /// - Parameter url: Address to the resource to check for
    /// - Returns: Returns true if the object exists, otherwise false
    func itemExists(at url: XcodeFileSystemURLResource) throws -> Bool {
        let r = try self.action(.exists(item: url))
        guard case let XcodeFileSystemProviderActionResponse.bool(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    /// Get the creation date for a given resource
    ///
    /// - Parameter url: Address to the resource to check
    /// - Returns: The creation date of the resource
    func creationDate(for url: XcodeFileSystemURLResource) throws -> Date {
        let r = try self.action(.dateAttribute(item: url, attribute: .creation))
        guard case let XcodeFileSystemProviderActionResponse.date(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    
    /// Get the last modification date for a given resource
    ///
    /// - Parameter url: Address to the resource to check
    /// - Returns: The last modification date of the resource
    func lastModificationDate(for url: XcodeFileSystemURLResource) throws -> Date {
        let r = try self.action(.dateAttribute(item: url, attribute: .lastModified))
        guard case let XcodeFileSystemProviderActionResponse.date(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    /// Create a directory
    ///
    /// - Parameters:
    ///   - url: Address to the directory to cratea
    ///   - intermediateDirectories: If true, this method creates any non-existent parent directories as part of creating the directory in url. If false, this method fails if any of the intermediate parent directories does not exist.
    func createDirectory(at url: XcodeFileSystemURLResource,
                                withIntermediateDirectories intermediateDirectories: Bool) throws {
        let action: XcodeFileSystemProviderAction = .createDirectory(at: url, withIntermediateDirectories: intermediateDirectories)
        
        let r = try self.action(action)
        guard case XcodeFileSystemProviderActionResponse.void(for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    /// Copy a resource from one location to another
    ///
    /// - Parameters:
    ///   - source: The resource to copy
    ///   - destination: The destination location
    func copy(_ source: XcodeFileSystemURLResource,
              to destination: XcodeFileSystemURLResource) throws {
        
        let action: XcodeFileSystemProviderAction = .copy(source: source, destination: destination)
        
        let r = try self.action(action)
        
        
        guard case XcodeFileSystemProviderActionResponse.void(for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    /// Remove a given resource
    ///
    /// - Parameter url: The resource to remove
    func remove(item url: XcodeFileSystemURLResource) throws {
        
        let action: XcodeFileSystemProviderAction = .remove(item: url)
        
        let r = try self.action(action)
        
        guard case XcodeFileSystemProviderActionResponse.void(for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    /// Remove a given resource if it exists
    ///
    /// - Parameter url: The resource to remove
    func removeIfExists(item url: XcodeFileSystemURLResource) throws {
        let a: XcodeFileSystemProviderAction = .remove(item: url)
        let d: XcodeFileSystemProviderAction = .exists(item: url)
        let complex: XcodeFileSystemProviderAction = .actionWithDependencies(dependants: [d], action: a)
        let r = try self.action(complex)
        
        
        if case XcodeFileSystemProviderActionResponse.failedDependancy(_, for: _) = r {
            // do nothing, we're ok if it doesn't exists
        } else if case XcodeFileSystemProviderActionResponse.void(for: _) = r {
            // do nothing, everything went fine
        } else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
    }
    
    
}

public extension XcodeFileSystemProvider {
    
    
    @discardableResult
    func action( _ action: XcodeFileSystemProviderAction) throws -> XcodeFileSystemProviderActionResponse {
        let rA = try self.actions([action])
        guard let r = rA.first else {
            throw XcodeFileSystemProviderErrors.missingResults
        }
        return r
    }
    
    @discardableResult
    func actions( actions: XcodeFileSystemProviderAction...) throws -> [XcodeFileSystemProviderActionResponse] {
        return try self.actions(actions)
    }
    
    
    /// Check to see if the given resource is a directory
    ///
    /// - Parameter url: The url of the resource to check
    /// - Returns: Returns true if the resource is a directory, otherwise false
    func isDirectory(at url: XcodeFileSystemURLResource) throws -> Bool {
        let r = try self.action(.isDirectory(item: url))
        guard case let XcodeFileSystemProviderActionResponse.bool(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    /// Checks to see if the given resources does not exists
    ///
    /// - Parameter url: The url of the resource to check
    /// - Returns: Returns true if the resource does not exists, otherwise true
    func itemNotExists(at url: XcodeFileSystemURLResource) throws -> Bool {
        let r = try self.action(.notExists(item: url))
        guard case let XcodeFileSystemProviderActionResponse.bool(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        
        return results
    }
    
    /// Gets the specified date attribute for a given resource
    ///
    /// - Parameters:
    ///   - attribute: The attribute type to get
    ///   - url: The url of the resoruce to read from
    /// - Returns: Returns the date attribute for the resource
    func date(_ attribute: XcodeFileSystemProviderAction.DateAttribute, for url: XcodeFileSystemURLResource) throws -> Date {
        let r = try self.action(.dateAttribute(item: url, attribute: attribute))
        guard case let XcodeFileSystemProviderActionResponse.date(results, for: _) = r else {
            throw XcodeFileSystemProviderErrors.invalidResults
        }
        return results
    }
    
}

extension XcodeFileSystemProvider {
    /// A method for reading the data from a file on the file system
    ///
    /// - Parameters:
    ///   - url: The url of the file to read
    /// - Returns: The data from the file
    public func data(from url: XcodeFileSystemURLResource) throws -> Data {
        return try self.data(from: url, withOptions: [])
    }
    
    /// A method for reading the data from a file on the file system if it exists
    ///
    /// - Parameters:
    ///   - url: The url of the file to read
    /// - Returns: The data from the file if it existsed
    public func dataIfExists(from url: XcodeFileSystemURLResource) throws -> Data? {
        return try self.dataIfExists(from: url, withOptions: [])
    }
    
    /// Write the given data to a specific file location
    ///
    /// - Parameters:
    ///   - data: The data to write
    ///   - url: The location to write it to
    public func write(_ data: Data, to url: XcodeFileSystemURLResource) throws {
        try self.write(data, to: url, withOptions: [])
    }
    
    /// Create a new directory on the file system
    ///
    /// - Parameters:
    ///   - url: The url of where to create the directory
    public func createDirectory(at url: XcodeFileSystemURLResource) throws {
        try self.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
