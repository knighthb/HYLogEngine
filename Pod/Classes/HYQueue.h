//
//  HYQueue.h
//  Bidding
//
//  Created by knight on 15/7/13.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HYQueueProtocol <NSObject>
@optional
/**
 *  clear方法中调用的,如果子类有其余的操作要在clear中做，
 *  子类则要重写该方法
 */
- (void)customClear;

@end

@interface HYQueue : NSObject <HYQueueProtocol>{
   
}

@property (nonatomic,strong) NSMutableArray * array;

/**
 *  入队列
 *
 *  @param aModel 入队的元素
 */
- (void)enQueue:(id) aModel ;

/**
 *  出队列
 *
 *  @return 返回队首的元素
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id deQueue ;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger size;
@end