//
//  XcodeDependenciesGroup.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-05-06.
//

import Foundation



/// A group object that represents the Dependancies folder within the project
public class XcodeDependenciesGroup: XcodeGroupResource {
    internal override var objectSortingOrder: Int { return 2 }
    public override func exists() throws -> Bool { return true }
}
