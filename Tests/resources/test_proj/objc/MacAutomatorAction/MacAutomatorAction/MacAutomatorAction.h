//
//  MacAutomatorAction.h
//  MacAutomatorAction
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface MacAutomatorAction : AMBundleAction

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
