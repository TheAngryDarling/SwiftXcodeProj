//
//  NSNumber+PBXProj.swift
//  PBXProj
//
//  Created by Tyler Anger on 2018-11-14.
//

import Foundation
import CoreFoundation


extension NSNumber {
    /// Returns the CFTypeID of this NSNumber
    internal var cfTypeID: CFTypeID {
        return CFNumberGetTypeID()
    }
    
    /// The CFNumber representation of this NSNumber
    ///
    /// This is a bit cast from one to the other
    internal var cfObject: CFNumber {
        return unsafeBitCast(self, to: CFNumber.self)
    }
}
