//
//  HYAppDelegate.m
//  HYLogEngine
//
//  Created by knight on 03/28/2016.
//  Copyright (c) 2016 knight. All rights reserved.
//

#import "HYAppDelegate.h"
#import "HYLogEngineHeader.h"
#import "HYDemoConfiger.h"
@implementation HYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[HYLogEngine sharedInstance] registerEngineWithConfiger:[[HYDemoConfiger alloc] init] ];
    [HYLogEventTracker sharedInstance].enventKey = @"co";
    [[HYLogEventTracker sharedInstance] trackLogWithEvenType:@(1) userInfo:@{@"cityId":@"1",@"cateId":@"1"}];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //进入后台时把logengine里的buffer写进文件保存
    [[NSNotificationCenter defaultCenter] postNotificationName:kWriteLogToFileNotification object:nil userInfo:nil];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //内存警告时把logengine里的buffer写进文件保存
    [[NSNotificationCenter defaultCenter] postNotificationName:kWriteLogToFileNotification object:nil userInfo:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    //退出时先把logegine卸载，卸载时会把logengine里的buffer写进文件上传
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnRegisterLogEngineNotification object:nil userInfo:nil];
}

@end
