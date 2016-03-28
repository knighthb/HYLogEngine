//
//  HYLogEventTracker.h
//  Pods
//
//  Created by knight on 16/3/28.
//
//

#import <Foundation/Foundation.h>
#import "HYLogProtocol.h"
@interface HYLogEventTracker : NSObject<HYLogProtocol>
@property (nonatomic , copy) NSString * enventKey;

+ (instancetype)sharedInstance;

@end
