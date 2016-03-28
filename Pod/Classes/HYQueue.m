//
//  HYQueue.m
//  Bidding
//
//  Created by knight on 15/7/13.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import "HYQueue.h"

@implementation HYQueue
- (instancetype)init {
    if (self = [super init]) {
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - HYQueue Interface
- (void)enQueue:(id) aModel {
    @synchronized(self){
        [self.array addObject:aModel];
    }
}

- (id)deQueue {
    id model = nil;
    @synchronized(self){
        if ([self size]<=0) {
            return nil;
        }
        model = self.array[0];
        [self.array removeObjectAtIndex:0];
    }
    return model;
}

- (NSInteger)size {
    return [self.array count];
}

- (void)clear {
    [self.array removeAllObjects];
    [self customClear];
}

#pragma mark - HYQueueProtocol
- (void)customClear {
    return;
}

@end
