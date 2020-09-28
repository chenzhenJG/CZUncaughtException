//
//  CodeAddressEnd.m
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#import "CodeAddress.h"

extern void * getSDKEndAddress(void) {
    return &getSDKEndAddress;
}
