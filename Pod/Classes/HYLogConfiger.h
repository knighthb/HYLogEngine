//
//  HYLogConfiger.h
//  Pods
//
//  Created by knight on 15/10/22.
//
//

#import <Foundation/Foundation.h>

@interface HYLogConfiger : NSObject
/** 日志路径 */
- (NSString *)logPath;

/** 上传日志 */
- (void)uplaodLog:(NSString *)logString;

@end
