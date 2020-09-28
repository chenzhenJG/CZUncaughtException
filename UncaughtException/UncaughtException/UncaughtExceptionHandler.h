//
//  UncaughtExceptionHandler.h
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZException : NSObject

@property (nonatomic,strong) NSString *exception_name;
@property (nonatomic,strong) NSString *reason;
@property (nonatomic,strong) NSString *callStack;
@property (nonatomic,strong) NSString *crashAddress;

@end

@interface UncaughtExceptionHandler : NSObject
+ (void)uncaughtExceptionHandler:(BOOL)open;
@end

NS_ASSUME_NONNULL_END
