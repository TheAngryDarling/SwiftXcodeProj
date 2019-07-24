//
//  MyInstallerPane.m
//  MacInstallerPlugin
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import "MyInstallerPane.h"

@implementation MyInstallerPane

- (NSString *)title
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

@end
