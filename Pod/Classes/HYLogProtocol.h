//
//  HYLogProtocol.h
//  Bidding
//
//  Created by knight on 15/7/27.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HYLogProtocol <NSObject>
@required
/**
 *  做日志埋点
 */
- (void)trackLogWithEvenType:(id) type
                    userInfo:(NSDictionary *) userInfo;

@optional
- (void)logKeyFromClass:(Class) aClass
                context:(NSDictionary *)userInfo;
@end
