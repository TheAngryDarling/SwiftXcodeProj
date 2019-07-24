//
//  SafariExtensionViewController.m
//  MacSafariExtApp Extension
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import "SafariExtensionViewController.h"

@interface SafariExtensionViewController ()

@end

@implementation SafariExtensionViewController

+ (SafariExtensionViewController *)sharedController {
    static SafariExtensionViewController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[SafariExtensionViewController alloc] init];
        sharedController.preferredContentSize = NSMakeSize(320, 240);
    });
    return sharedController;
}

@end
