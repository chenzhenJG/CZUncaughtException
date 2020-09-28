//
//  UncaughtExceptionHandler.m
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import "CodeAddress.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString *const ZZSignalAddressKey = @"ZZSignalAddressKey";
NSString *const ZZSignalKey = @"ZZSignalKey";
NSString *const ZZExceptionAddresskey = @"ZZExceptionAddresskey";
@implementation ZZException
@end

@implementation UncaughtExceptionHandler
+ (void)uncaughtExceptionHandler:(BOOL)open {
    NSSetUncaughtExceptionHandler(open ? ZZ_HandleException : NULL);
    signal(SIGABRT, open ? ZZ_SignalHandler : SIG_DFL);
    signal(SIGILL, open ? ZZ_SignalHandler : SIG_DFL);
    signal(SIGSEGV, open ? ZZ_SignalHandler : SIG_DFL);
    signal(SIGFPE, open ? ZZ_SignalHandler : SIG_DFL);
    signal(SIGBUS, open ? ZZ_SignalHandler : SIG_DFL);
    signal(SIGPIPE, open ? ZZ_SignalHandler : SIG_DFL);
}

//崩溃异常
void ZZ_HandleException(NSException *exception) {
    //获取异常堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSString *callStackStr = [callStack componentsJoinedByString:@"\n"];
    NSString *crashAddress = getCrashAddress(callStack);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
    if (crashAddress) {
        [userInfo setObject:crashAddress forKey:@"crashAddress"];
    }
    [userInfo setObject:callStackStr forKey:ZZExceptionAddresskey];
    UncaughtExceptionHandler *zz_exception = [[UncaughtExceptionHandler alloc]init];
    [zz_exception performSelectorOnMainThread:@selector(handleException:) withObject:[NSException exceptionWithName:exception.name reason:exception.reason userInfo:userInfo] waitUntilDone:YES];
    
}

//Signal报错的处理
void ZZ_SignalHandler(int signal) {
    NSString *description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"SIGABRT!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"SIGILL!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"SIGSEGV!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"SIGFPE!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"SIGBUS!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"SIGPIPE!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal!\n"];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSString *crashAddress = getCrashAddress(callStack);
    NSString *callStackStr = [callStack componentsJoinedByString:@"\n"];
    if (crashAddress) {
        [userInfo setObject:crashAddress forKey:@"crashAddress"];
    }
    [userInfo setObject:callStackStr forKey:ZZSignalAddressKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:ZZSignalKey];
    UncaughtExceptionHandler *zz_Exception = [[UncaughtExceptionHandler alloc]init];
    [zz_Exception performSelectorOnMainThread:@selector(handleException:) withObject:[NSException exceptionWithName:@"SignalExceptionName" reason:description userInfo:userInfo] waitUntilDone:YES];
    kill(getpid(), signal);
}

#pragma mark - 综合处理异常函数 包含Signal类型和崩溃类型
- (void)handleException:(NSException *)exception {
    NSString *reason = exception.reason;
    NSString *name = exception.name;
    NSDictionary *userInfo = exception.userInfo;
    NSString *crashAddressValue = userInfo[@"crashAddress"];
    ZZException *exceptionModel = [[ZZException alloc]init];
    exceptionModel.exception_name = name;
    exceptionModel.reason = reason;
    if ([exception.userInfo objectForKey:ZZSignalAddressKey]) {
        exceptionModel.callStack = [userInfo objectForKey:ZZSignalAddressKey];
    }
    if ([exception.userInfo objectForKey:ZZExceptionAddresskey]) {
        exceptionModel.callStack = [userInfo objectForKey:ZZExceptionAddresskey];
    }
    if (crashAddressValue) {
        exceptionModel.crashAddress = crashAddressValue;
    }
//    NSLog(@"sdk start: %p end: %p", getSDKStartAddress(), getSDKEndAddress());
    long slide = getExecuteImageSlide();
//    NSLog(@"sdk start: %p end: %p", getSDKStartAddress() - slide, getSDKEndAddress() - slide);
    
    NSScanner *crash_scanner = [NSScanner scannerWithString:crashAddressValue];
    unsigned long long crash_longValue;
    [crash_scanner scanHexLongLong: &crash_longValue];
    
    long startAddress = (long)getSDKStartAddress() - slide;
    long crashAddress = crash_longValue - slide;
    long endAddress = (long)getSDKEndAddress() - slide;
    if (startAddress < crashAddress && crashAddress < endAddress) {
        NSLog(@"=====🥔=====在SDK中crash");
    }
    else {
        NSLog(@"=====🥔=====不在SDK中crash");
    }

    
    
}


+ (NSArray *)backtrace {
    //指针列表
    void *callstack[128];
    //调用系统堆栈表放到callstack里面
    int frames = backtrace(callstack,128);
    //将堆栈信息转化成字符串数组
    char **strs = backtrace_symbols(callstack, frames);
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}



#pragma mark - 获取crash target地址
NSString* getCrashAddress(NSArray *callStack) {
    for (NSString *stack in callStack) {
        if ([stack containsString:[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleExecutable"]]) {
            NSArray *valueList = [stack componentsSeparatedByString:@" "];
            for (NSString *value in valueList) {
                if ([value containsString:@"0x"]) {
                    return value;
                }
            }
        }
    }
    return @"";
}
@end
