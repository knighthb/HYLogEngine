//
//  HYLogPool.m
//  Bidding
//
//  Created by knight on 15/6/29.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import "HYLogPool.h"

NSInteger const kInitNum = 100;//暂时写100个到时候再说
NSInteger const kMAX_NUM = 5*kInitNum;
@interface HYLogPool (){
    NSInteger  _increacement;
    NSInteger  _startIndex;
    NSInteger  _endIndex;
    NSInteger  _currentLength;
    NSInteger  _queueLength;
}
@end

@implementation HYLogPool

@dynamic deQueue, size;

+ (instancetype)sharedInstance {
    static HYLogPool * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[HYLogPool alloc] init];
        }
    });
    return instance;
}

- (void)enQueue:(HYLogBaseModel *)aModel {
    [super enQueue:aModel];
}
@end
