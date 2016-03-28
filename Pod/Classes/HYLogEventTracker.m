//
//  HYLogEventTracker.m
//  Pods
//
//  Created by knight on 16/3/28.
//
//

#import "HYLogEventTracker.h"
#import "HYLogBaseModel.h"
#import "HYLogPool.h"

@implementation HYLogEventTracker

+ (instancetype)sharedInstance {
    static HYLogEventTracker * eventTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!eventTracker) {
            eventTracker = [[HYLogEventTracker alloc] init];
        }
    });
    return eventTracker;
}

- (void)trackLogWithEvenType:(id) type
                    userInfo:(NSDictionary *) userInfo {
    NSMutableDictionary * logDic = nil;
    if (userInfo) {
        logDic = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    }
    if (!logDic) logDic = [[NSMutableDictionary alloc] init];
    //TODO 填充logDic
    if (type) {
        [logDic setObject:type forKey:self.enventKey];
    }
    HYLogBaseModel * logModel = [[HYLogBaseModel alloc] init];
    logModel.logDic = logDic;
    [[HYLogPool sharedInstance] enQueue:logModel];
}

- (void)logKeyFromClass:(Class) aClass
                context:(NSDictionary *)userInfo {
    
}

@end
