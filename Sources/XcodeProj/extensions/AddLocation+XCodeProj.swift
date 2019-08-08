//
//  AddLocation+XCodeProj.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-08-07.
//

import Foundation
import PBXProj

internal extension AddLocation where T: XcodeFileResource {
    var pbxLocation: AddLocation<PBXFileElement> {
        switch self {
            case .beginning: return AddLocation<PBXFileElement>.beginning
            case .end: return AddLocation<PBXFileElement>.end
            case .index(let idx): return AddLocation<PBXFileElement>.index(idx)
            case .before(let o): return AddLocation<PBXFileElement>.before(o.pbxFileResource)
            case .after(let o): return AddLocation<PBXFileElement>.after(o.pbxFileResource)
        }
    }
}
