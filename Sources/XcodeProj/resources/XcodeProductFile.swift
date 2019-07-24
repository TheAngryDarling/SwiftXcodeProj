//
//  XcodeProductFile.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-29.
//

import Foundation

/// The Xcode representation of a Product File located in the Products folder
public class XcodeProductFile: XcodeFileResource {
    
    override var objectSortingOrder: Int { return XcodeFile.OBJECT_SORT_ORDER }
    public override func exists() throws -> Bool {
        // Since we can't determine this at the moment, we'll just say it exists
        return true
    }
}
