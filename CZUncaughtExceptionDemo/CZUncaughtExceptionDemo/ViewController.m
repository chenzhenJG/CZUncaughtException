//
//  ViewController.m
//  CZUncaughtExceptionDemo
//
//  Created by chenzhen on 2020/9/28.
//  Copyright © 2020 chenzhen. All rights reserved.
//

#import "ViewController.h"
#import <UncaughtException/UncaughtException.h>


@interface ViewController ()

@end

@implementation ViewController
- (IBAction)mainAppCrash:(id)sender {
    NSDictionary *dic = @{};
    [dic setValue:nil forKey:@"value"];
}
- (IBAction)sdkCrash:(id)sender {
    [SDKCrashTest sdkCrash];
    //看终端日志打印
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


@end
