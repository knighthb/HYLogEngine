//
//  HYLogEngine.h
//  Bidding
//
//  Created by knight on 15/6/29.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

/**
 *  description:
 *  0.引擎是典型的生产者消费者模式，生产者是业务方的事件，事件产生的埋点加入到日志池
 *  消费者是一个有定时器驱动的runloop，定时从日志池消费日志。
 *  1.客户端（业务方，以下简称客户端）在使用时需要调用registerEngine来注册日志引擎
 *  2.还提供了两个消息：
 *      #define kUnRegisterLogEngineNotification @"HYWriteLogToFileNotification"
 *      #define kWriteLogToFileNotification @"HYWriteLogToFileNotification"
 *  3.客户端在需要立即将缓存写入磁盘并上传日志时发送kWriteLogToFileNotification消息，一般不用发，由runloop处理
 *  4.客户端在需要退出日志引擎时需要发送kUnRegisterLogEngineNotification消息，一般在appDelegate退出程序的回调里发送
 *  发送该消息时会将当前缓存里的日志立即写入磁盘并上传，同时会去移除观察者
 *  5.可以直接调用unRegisterEngine方法
 */
 

#import <Foundation/Foundation.h>

#define kUnRegisterLogEngineNotification @"HYUnRegisterLogEngineNotification"

#define kWriteLogToFileNotification @"HYWriteLogToFileNotification"

#define kClearBufferNotification @"HYClearBufferNotification"

//磁盘小于一定阈值的时候会发送通知
#define kDiskIsFullNotification @"HYDiskIsFullNotification"
@class HYLogConfiger;
@interface HYLogEngine : NSObject

+ (instancetype)sharedInstance;
/**
 *  注册日志引擎
 */
- (void)registerEngineWithConfiger:(HYLogConfiger *)configer ;

/**
 *  卸载日志引擎
 */
- (void)unRegisterEngine;
@end
