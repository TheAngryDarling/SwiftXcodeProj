//
//  XcodeGroupResource.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-17.
//

import Foundation
import PBXProj

/// A base class for all group objects
public class XcodeGroupResource: XcodeFileResource {
    
    /// The PBX Group object
    internal var pbxGroup: PBXGroup {
        get { return self.pbxFileResource as! PBXGroup }
        //set { self.pbxFileResource = newValue }
    }
    
    internal override var objectSortingOrder: Int { return 1 }
    
    /*public var files: [XcodeFile] {
        var rtn: [XcodeFile] = []
        for c in self.group.children {
            if let f = c as? PBXFileReference {
                rtn.append(XcodeFile(self.project, f))
            }
        }
        return rtn
    }
    
    public var groups: [XcodeGroup] {
        var rtn: [XcodeGroup] = []
        for c in self.group.children {
            if let g = c as? PBXGroup {
                rtn.append(XcodeGroup(self.project, g))
            }
        }
        return rtn
    }*/
    
    /// An array of the child resources of this group
    public internal(set) lazy var children: [XcodeFileResource] = {
        var rtn:  [XcodeFileResource] = []
        for c in self.pbxGroup.children {
            let child = XcodeGroup.xCodeResourceFor(c, inProject: project, havingParent: self)
            rtn.append(child)
        }
        return rtn
    }()
    
    /// Create a new Folder File Reference
    ///
    /// - Parameters:
    ///   - project: The Xcode project this resource is for
    ///   - group: The PBX Group for this resource
    ///   - parent: The parent Xcode group (Optional)
    internal init(_ project: XcodeProject, _ group: PBXGroup, havingParent parent: XcodeGroupResource? = nil) {
        //self.children = []
        super.init(project, group, havingParent: parent)
        
        /*for c in self.pbxGroup.children {
            let child = XcodeGroup.xCodeResourceFor(c, inProject: project, havingParent: self)
            self.children.append(child)
        }*/
    }
    
    
    public override func leveledDescription(_ level: Int, indent: String, indentOpening: Bool, sortKeys: Bool) -> String {
        var rtn: String = super.leveledDescription(level, indent: indent, indentOpening: indentOpening, sortKeys: sortKeys)
        
        for c in self.children {
            rtn += "\n" + c.leveledDescription(level + 1, indent: indent, indentOpening: true, sortKeys: sortKeys )
        }
        
        return rtn
    }
    
    
    /// Create the specific file element type for the PBX File Resource
    ///
    /// - Parameters:
    ///   - pbxResource: The PBX File resource
    ///   - project: The current Xcode Project
    ///   - parent: The parent Xcode group (Optional)
    /// - Returns: Returns the Xcode File Resource for this PBX File object
    private static func xCodeResourceFor(_ pbxResource: PBXFileElement,
                                         inProject project: XcodeProject,
                                         havingParent parent: XcodeGroupResource? = nil) -> XcodeFileResource {
        if let f = pbxResource as? PBXFileReference, let st = f.sourceTree, st == .buildProductsDir {
            return XcodeProductFile(project, f, havingParent: parent)
        } else if let f = pbxResource as? PBXFileReference, let ft = f.lastKnownFileType, ft == PBXFileType.folder {
            return XcodeFolderReference(project, f, havingParent: parent)
        } else if let f = pbxResource as? PBXFileReference {
            return XcodeFile(project, f, havingParent: parent)
        } else if let g = pbxResource as? PBXGroup, let st = g.sourceTree, st == .buildProductsDir {
            return XcodeProductsGroup(project, g, havingParent: parent)
        } else if let g = pbxResource as? PBXGroup, let st = g.sourceTree, st == .group, g.name == "Dependencies", parent?.name == "" {
            return XcodeDependenciesGroup(project, g, havingParent: parent)
        } else if let g = pbxResource as? PBXGroup {
            return XcodeGroup(project, g, havingParent: parent)
        } else {
            // Possible Error
            fatalError("Unknown file type for \(type(of: pbxResource)) with ID: \(pbxResource.id)")
        }
    }
    
    /// Sorts the collection in place, using the given predicate as the
    /// comparison between elements.
    ///
    /// When you want to sort a collection of elements that doesn't conform to
    /// the `Comparable` protocol, pass a closure to this method that returns
    /// `true` when the first element passed should be ordered before the
    /// second.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// The sorting algorithm is not stable. A nonstable sort may change the
    /// relative order of elements for which `areInIncreasingOrder` does not
    /// establish an order.
    ///
    /// In the following example, the closure provides an ordering for an array
    /// of a custom enumeration that describes an HTTP response. The predicate
    /// orders errors before successes and sorts the error responses by their
    /// error code.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     var responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
    ///     responses.sort {
    ///         switch ($0, $1) {
    ///         // Order errors by code
    ///         case let (.error(aCode), .error(bCode)):
    ///             return aCode < bCode
    ///
    ///         // All successes are equivalent, so none is before any other
    ///         case (.ok, .ok): return false
    ///
    ///         // Order errors before successes
    ///         case (.error, .ok): return true
    ///         case (.ok, .error): return false
    ///         }
    ///     }
    ///     print(responses)
    ///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
    ///
    /// Alternatively, use this method to sort a collection of elements that do
    /// conform to `Comparable` when you want the sort to be descending instead
    /// of ascending. Pass the greater-than operator (`>`) operator as the
    /// predicate.
    ///
    ///     var students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     students.sort(by: >)
    ///     print(students)
    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`. If `areInIncreasingOrder` throws an error during
    ///   the sort, the elements may be in a different order, but none will be
    ///   lost.
    public func sort(by areInIncreasingOrder: (XcodeFileResource, XcodeFileResource) throws -> Bool) rethrows {
        try self.children.sort(by: areInIncreasingOrder)
        self.pbxGroup.childrenReferences = self.children.map({ return $0.pbxFileResource.id })
        for r in self.children {
            if let g = r as? XcodeGroupResource {
                try g.sort(by: areInIncreasingOrder)
            }
        }
    }
    
    /// Sort the group and sub groups by the following:  Groups first, files second, and between same types, sort by name case insensative
    public func sort() {
        func srtFnc(_ lhs: XcodeFileResource, _ rhs: XcodeFileResource) -> Bool {
            let lhsOrder = lhs.objectSortingOrder
            let rhsOrder = rhs.objectSortingOrder
            if lhsOrder < rhsOrder { return true }
            else if lhsOrder > rhsOrder { return false }
            else { return lhs.name.lowercased() < rhs.name.lowercased() }
        }
        
        self.sort(by: srtFnc)
    }

}

extension XcodeGroupResource: Collection {
    
    
    public var startIndex: Int { return self.children.startIndex }
    public var endIndex: Int { return self.children.endIndex }
    public var count: Int { return self.children.count }
    
    public subscript(index: Int) -> XcodeFileResource {
        return self.children[index]
    }
    
    public func index(after i: Int) -> Int {
        return self.children.index(after: i)
    }
    
}
