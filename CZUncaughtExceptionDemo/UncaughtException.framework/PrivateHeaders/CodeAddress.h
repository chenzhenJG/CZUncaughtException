//
//  CodeAddress.h
//  UncaughtException
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#ifndef CodeAddress_h
#define CodeAddress_h

#if __cplusplus
extern "C" {
#endif
    
    extern void * getSDKStartAddress(void);
    extern void * getSDKEndAddress(void);
    extern long getExecuteImageSlide(void);
    
#if __cplusplus
}
#endif

#endif /* CodeAddress_h */
