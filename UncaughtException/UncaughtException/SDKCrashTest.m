//
//  SDKCrashTest.m
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#import "SDKCrashTest.h"

@implementation SDKCrashTest
+ (void)sdkCrash {
    NSArray * arr = @[@"1"];
    [arr objectAtIndex:2];
}
@end
