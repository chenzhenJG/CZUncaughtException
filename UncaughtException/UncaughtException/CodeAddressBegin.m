//
//  CodeAddressBegin.m
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//
#import "CodeAddress.h"
#import <mach-o/dyld.h>

extern void * getSDKStartAddress(void) {
    return &getSDKStartAddress;
}



extern long getExecuteImageSlide(void) {
    long slide = -1;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return slide;
}
