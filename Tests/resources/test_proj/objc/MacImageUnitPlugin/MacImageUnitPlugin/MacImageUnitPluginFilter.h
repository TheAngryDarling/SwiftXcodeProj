//
//  MacImageUnitPluginFilter.h
//  MacImageUnitPlugin
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MacImageUnitPluginFilter : CIFilter {
    CIImage      *inputImage;
    CIVector     *inputCenter;
    NSNumber     *inputWidth;
    NSNumber     *inputAmount;
}

@end
