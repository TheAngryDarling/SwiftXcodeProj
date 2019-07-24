//
//  MacImageUnitPluginPlugInLoader.h
//  MacImageUnitPlugin
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import <QuartzCore/CoreImage.h>

@interface MacImageUnitPluginPlugInLoader : NSObject <CIPlugInRegistration>

- (BOOL)load:(void *)host;

@end
