//
//  ViewController.h
//  MacSafariExtApp
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak, nonatomic) IBOutlet NSTextField * appNameLabel;

- (IBAction)openSafariExtensionPreferences:(id)sender;

@end

