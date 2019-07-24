//
//  XcodeProductsGroup.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-04-29.
//

import Foundation

/// The Xcode representation of a Products folder
public class XcodeProductsGroup: XcodeGroupResource {
    internal override var objectSortingOrder: Int { return 3 }
    public override func exists() throws -> Bool { return true }
}
