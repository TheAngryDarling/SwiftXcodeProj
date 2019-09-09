//
//  SafariExtensionViewController.swift
//  MacSafariExtApp Extension
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
