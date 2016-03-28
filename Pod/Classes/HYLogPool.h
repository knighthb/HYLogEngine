//
//  HYLogPool.h
//  Bidding
//
//  Created by knight on 15/6/29.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYQueue.h"
@class HYLogBaseModel;
extern NSInteger const kMAX_NUM;
extern NSInteger const kInitNum;

@interface HYLogPool : HYQueue
+ (instancetype)sharedInstance ;
/**
 *  入队列
 *
 *  @param aModel 入队的元素
 */
//- (void)enQueue:(HYLogBaseModel *) aModel ;

/**
 *  出队列
 *
 *  @return 返回队首的元素
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) HYLogBaseModel *deQueue ;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger size;
@end
