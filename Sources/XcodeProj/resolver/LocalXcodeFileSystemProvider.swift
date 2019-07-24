//
//  LocalXcodeFileSystemProvider.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-13.
//

import Foundation
#if os(macOS)
import Cocoa
#endif

fileprivate extension Array where Element == XcodeFileSystemProviderAction {
    func validateResourceConditions(_ precondtion: (XcodeFileSystemURLResource) throws -> Bool) rethrows -> XcodeFileSystemURLResource? {
        var rtn: XcodeFileSystemURLResource? = nil
        for a in self where (rtn == nil) {
            rtn = try a.validateResourceConditions(precondtion)
        }
        
        return rtn
    }
}

/// The class the provides access to the local files sytem for XcodeProjects
public class LocalXcodeFileSystemProvider: XcodeFileSystemProvider {
    
    public enum Errors: Error {
        case mustBeFileSystemURL(XcodeFileSystemURLResource)
    }
    
    
    public func actions(_ actions: [XcodeFileSystemProviderAction]) throws -> [XcodeFileSystemProviderActionResponse] {
        let failedResPreCondition = actions.validateResourceConditions({ return $0.isFileURL })
        guard failedResPreCondition == nil else {
            throw Errors.mustBeFileSystemURL(failedResPreCondition!)
        }
        
        var rtn: [XcodeFileSystemProviderActionResponse] = []
        
        for action in actions {
            switch action {
            case .noAction(for: let res):
                rtn.append(.void(for: res))
                
            case .actionWithCallBack(action: let act, handler: _):
                do {
                    let r = try self.action(act)
                    rtn.append(r)
                    action.invokeHandler(fs: self, response: r, error: nil)
                } catch {
                    action.invokeHandler(fs: self, response: nil, error: error)
                    throw error
                }
                
            case .actionWithFailoverAction(action: let act, failover: let fail):
                do {
                    let r = try self.action(act)
                    rtn.append(r)
                } catch {
                    _ = try? self.action(fail)
                    throw error
                }
                
            case .exists(item: let res):
                if FileManager.default.fileExists(atPath: res.path)  { rtn.append(.bool(true, for: res)) }
                else { rtn.append(.bool(false, for: res)) }
                
            case .notExists(item: let res):
                if FileManager.default.fileExists(atPath: res.path)  { rtn.append(.bool(false, for: res)) }
                else { rtn.append(.bool(true, for: res)) }
                
            case .dateAttribute(item: let res, attribute: let attrib):
                switch attrib {
                    case .creation:
                        let attr = try FileManager.default.attributesOfItem(atPath: res.realURL.path)
                        let dt = attr[FileAttributeKey.creationDate] as! Date
                        rtn.append(.date(dt, for: res))
                    case .lastModified:
                        let attr = try FileManager.default.attributesOfItem(atPath: res.realURL.path)
                        let dt = attr[FileAttributeKey.modificationDate] as! Date
                        rtn.append(.date(dt, for: res))
                }
                
            case .dateAttributeComparison(item: let res, attribute: let attrib, operator: let opr, value: let val):
                let dt = try self.date(attrib, for: res)
                switch opr {
                    case .greaterThan: rtn.append(.bool((dt > val), for: res))
                    case .greaterThanOrEquals: rtn.append(.bool((dt >= val), for: res))
                    case .equals: rtn.append(.bool((dt == val), for: res))
                    case .lessThanOrEquals: rtn.append(.bool((dt <= val), for: res))
                    case .lessThan: rtn.append(.bool((dt < val), for: res))
                
                }
                
            case .isDirectory(item: let res):
                var bool: Bool = false
                if !FileManager.default.fileExists(atPath: res.path, isDirectory: &bool) { rtn.append(.bool(false, for: res)) }
                else { rtn.append(.bool(bool, for: res)) }
                
            case .data(for: let res, readOptions: let options):
                 rtn.append(.data(try Data(contentsOf: res.realURL, options: options), for: res))
                
            case .write(data: let dta, to: let res, writeOptions: let options):
                try dta.write(to: res.realURL, options: options)
                rtn.append(.void(for: res))
                
            case .directoryContents(for: let res, ofType: let type, withRegExFilter: let regEx):
                if !res.isDirectory { rtn.append(.directoryContents([], for: res)) }
                else {
                    let children = try FileManager.default.contentsOfDirectory(atPath: res.path).map {
                        return res.realURL.appendingPathComponent($0)
                    }
                    
                    var namePattern: NSRegularExpression? = nil
                    if let regPattern = regEx {
                       namePattern = try NSRegularExpression(pattern: regPattern.pattern, options: regPattern.patternOptions)
                    }
                    var items: [XcodeFileSystemURLResource] = []
                    for u in children {
                        var isD: Bool = false
                        _ = FileManager.default.fileExists(atPath: u.path, isDirectory: &isD)
                        
                        var canAdd: Bool = true
                        if !((type == .any) || (isD && type == .folder) || (!isD && type == .file)) {
                            canAdd = false
                        }
                        if let reg = namePattern, canAdd {
                            if reg.firstMatch(in: u.lastPathComponent,
                                              options: regEx!.matchingOptions,
                                              range: NSMakeRange(0, NSString(string: u.lastPathComponent).length)) != nil {
                                canAdd = false
                            }
                        }
                        if canAdd {
                            let attr = try FileManager.default.attributesOfItem(atPath: u.path)
                            let dt = attr[FileAttributeKey.modificationDate] as! Date
                            
                            items.append(XcodeFileSystemURLResource(path: u, isDirectory: isD, modDate: dt))
                        }
                    }
                    rtn.append(.directoryContents(items, for: res))
                }
                
            case .directoryRemoveContents(from: let res, ofType: let type, withRegExFilter: let regEx):
                let children = try FileManager.default.contentsOfDirectory(atPath: res.path).map {
                    return res.realURL.appendingPathComponent($0)
                }
                
                var namePattern: NSRegularExpression? = nil
                if let regPattern = regEx {
                    namePattern = try NSRegularExpression(pattern: regPattern.pattern, options: regPattern.patternOptions)
                }
                
                for u in children {
                    var isD: Bool = false
                    _ = FileManager.default.fileExists(atPath: u.path, isDirectory: &isD)
                    
                    var canRemove: Bool = true
                    if !((type == .any) || (isD && type == .folder) || (!isD && type == .file)) {
                        canRemove = false
                    }
                    if let reg = namePattern, canRemove {
                        if reg.firstMatch(in: u.lastPathComponent,
                                          options: regEx!.matchingOptions,
                                          range: NSMakeRange(0, NSString(string: u.lastPathComponent).length)) != nil {
                            canRemove = false
                        }
                    }
                    if canRemove {
                        try FileManager.default.removeItem(at: u)
                    }
                }
                
                rtn.append(.void(for: res))
                
            case .directoryDataContents(from: let res, readOptions: let options, withRegExFilter: let regEx):
                let children = try FileManager.default.contentsOfDirectory(atPath: res.path).map {
                    return res.realURL.appendingPathComponent($0)
                }
                
                var namePattern: NSRegularExpression? = nil
                if let regPattern = regEx {
                    namePattern = try NSRegularExpression(pattern: regPattern.pattern, options: regPattern.patternOptions)
                }
                var items: [(resource: XcodeFileSystemURLResource, data: Data)] = []
                for u in children {
                    var isD: Bool = false
                    _ = FileManager.default.fileExists(atPath: u.lastPathComponent, isDirectory: &isD)
                    
                    guard !isD else { continue }
                    
                    var canLoad: Bool = true
                    
                    if let reg = namePattern, canLoad {
                        if reg.firstMatch(in: u.lastPathComponent,
                                          options: regEx!.matchingOptions,
                                          range: NSMakeRange(0, NSString(string: u.lastPathComponent).length)) != nil {
                            canLoad = false
                        }
                    }
                    if canLoad {
                        
                        let attr = try FileManager.default.attributesOfItem(atPath: u.path)
                        let dt = attr[FileAttributeKey.modificationDate] as! Date
                        
                        let dta = try Data(contentsOf: u, options: options)
                        
                        items.append((resource: XcodeFileSystemURLResource(path: u,
                                                                           isDirectory: false,
                                                                           modDate: dt),
                                      data: dta))
                    }
                    
                    
                    
                }
                
                rtn.append(.directoryDataContents(items, for: res))
                
            case .createDirectory(at: let res, withIntermediateDirectories: let intermediate):
                try FileManager.default.createDirectory(atPath: res.path, withIntermediateDirectories: intermediate)
                rtn.append(.void(for: res))
                
            case .copy(source: let resSource, destination: let resDestination):
                try FileManager.default.copyItem(at: resSource.realURL, to: resDestination.realURL)
                rtn.append(.void(for: resSource))
                
            case .remove(item: let res):
                try FileManager.default.removeItem(at: res.realURL)
                rtn.append(.void(for: res))
                
            case .actionWithDependencies(dependants: let dependancies, action: let subAction):
                var dependanciesPassed: Bool = true
                for dep in dependancies where dependanciesPassed {
                    let r = try self.action(dep)
                    if !r.succeeded {
                        dependanciesPassed = false
                        rtn.append(.failedDependancy(dep, for: action.url))
                    }
                }
                if dependanciesPassed {
                    let r = try self.action(subAction)
                    rtn.append(r)
                }
            //case .dependantConditions(dependants: [XcodeFileSystemProviderAction], actions: [XcodeFileSystemProviderAction]):
            }
        }
        
        return rtn
    }
    
    /*
    #if os(macOS)
    public let supportsRecycleBin: Bool = true
    #else
    public let supportsRecycleBin: Bool = false
    #endif
    */
    
    public static var newInstance: LocalXcodeFileSystemProvider { return LocalXcodeFileSystemProvider() }
    
    
    
    /*public func recycle(items urls: [URL], completionHandler handler: (([URL : URL], Error?) -> Void)?) throws {
        #if !os(macOS)
        fatalError("Unsupported method 'recycle' on current platform")
        
        #else
        NSWorkspace.shared.recycle(urls, completionHandler: handler)
        #endif
    }*/
    
}
