//
//  HYLogEngine.m
//  Bidding
//
//  Created by knight on 15/6/29.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import "HYLogEngine.h"
#import "HYLogPool.h"
#import "HYLogBaseModel.h"
#import "HYLogConfiger.h"
#import <sys/param.h>
#import <sys/mount.h>
#define LOG_NUM 50//上传日志条数阈值
#define MAX_TIME_SECOND 3*60
#define BUFFER_SIZE 10//buffer最大的条数

#define WeakSelf(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define EMPTY_STRING @""
typedef NS_ENUM(NSInteger, HYUploadState) {
    EHYUploadSuccessed= 0,
    EHYUPloadFailed = 1
};
/**
 * 目前的做法：
 * 把日志放到buffer中，当buffer中满
 **/

@interface HYLogEngine ()
@property (nonatomic , weak) NSRunLoop * runloop;
@property (nonatomic , copy) NSString * filePath;
@property (nonatomic , strong) HYLogConfiger * configer;
@end

static NSMutableArray * _buffer = nil;
static NSString * fileName = @"log";
static NSTimer * _timer = nil;
static int writeTime = 0;
static NSTimeInterval timeInterval = 1;
static NSTimeInterval timePassed = 0;

@implementation HYLogEngine
+ (instancetype)sharedInstance {
    static  HYLogEngine * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYLogEngine alloc] init];
    });
    return instance;
}

- (void)registerEngineWithConfiger:(HYLogConfiger *)configer {
    _configer = configer;
    WeakSelf(weakself)
    self.filePath = [[self.configer logPath] stringByAppendingString:fileName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWriteToFileNotification:) name:kWriteLogToFileNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUnregisterLogEngineNotification:) name:kUnRegisterLogEngineNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveClearBufferNotification:) name:kClearBufferNotification object:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakself.runloop = [NSRunLoop currentRunLoop];
         _timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1] interval:timeInterval target:weakself selector:@selector(processOn) userInfo:nil repeats:YES];
        [weakself.runloop addTimer:_timer forMode:NSDefaultRunLoopMode];
        [weakself.runloop run];
    });
}

- (void)unRegisterEngine {
    [_timer invalidate];
    [self writeToDisk];
    [self uploadLog];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUnRegisterLogEngineNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWriteLogToFileNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kClearBufferNotification object:nil];
}

- (void)processOn {
    timePassed += timeInterval;
    [self parseLogModel];
    if ([self writeToFileStrategy]) {
        [self writeToDisk];
    }
    
    if ([self logStrategy]) {
        [self uploadLog];
    }
}

- (BOOL)parseLogModel {
    //NSLog(@"thread.. %@",        [NSThread currentThread]);

    //NSLog(@"解析日志model");
    if (!_buffer) {
        _buffer = [[NSMutableArray alloc] init];
    }
    if ([[HYLogPool sharedInstance] size] <= 0) {
        //NSLog(@"对象池没数据！");
        return NO;
    }
    HYLogBaseModel * model = [[HYLogPool sharedInstance] deQueue];
    NSDictionary * logDic ;
    if (![model isEqual:[NSNull null]]) {
        logDic = [model transef2Dic];
    }else {
         return NO;
    }
    
    //用jsonKit把logDic序列化成json串
    @synchronized(_buffer) {
        NSError * error = nil;
        NSData * data = [NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString * jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [_buffer addObject:jsonString];
    }
    return YES;
}

- (void)writeToDisk {
    if ([self writeToFileStrategy]) {
        @synchronized(_buffer) {
            
            writeTime++;
            NSString * content = [self ArrayToString:_buffer];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
                [self diskFullHandler];
                [content writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }else {
                [self appendToFile:_buffer];
            }
            //写入文件后立即清空buffer,迎接下一波日志的到来
            [_buffer removeAllObjects];
        }
    }
}

- (void)uploadLog {
    /**
     *  上传时机：
     *
     *  1.app启动时，先上传（wifi环境或者不考虑网络环境）单独写一个方法？
     *  2.到达上传策略的条件时上传 （无视网络环境）
     *  断点续传
     *  使用block，上传成功后删掉本地日志
     */
    NSString * content = [[NSString alloc] initWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    if (!content || [content isEqualToString:EMPTY_STRING]) return;
    NSLog(@"上传文件");
    writeTime = 0;
    timePassed = 0;
    [self.configer uplaodLog:content];
    
}

- (BOOL)writeToFileStrategy {
    if ([_buffer count] >= BUFFER_SIZE || timePassed >= MAX_TIME_SECOND) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)logStrategy {
    /**
     *  1.日志条数达到一定阈值
     *  2.到达上传的时间间隔
     *  3.当前网络环境是wifi的情况（暂时未实现）
     *  考虑用策略模式
     */
    if ( BUFFER_SIZE*writeTime >= LOG_NUM
        || timePassed >= MAX_TIME_SECOND )
        return YES;
    else
        return NO;
}

- (void)appendToFile:(NSArray *) array {
    if (!array) {
        return;
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    if (!handle) {
        return;
    }
    NSString * content = [self ArrayToString:array];
    [handle seekToEndOfFile];
    NSData * data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [self diskFullHandler];
    [handle writeData:data];
}

- (NSString *)ArrayToString:(NSArray *)array {
    NSString * content = @"";
    for (NSString * string in array) {
        content = [content stringByAppendingString:string];
        content = [content stringByAppendingString:@","];
    }
    return content;
}

#pragma mark - notification
//接受HYWriteLogToFileNotification的通知
- (void)didReceiveWriteToFileNotification:(NSNotification *)notification {
    NSParameterAssert(notification);
    [self writeToDisk];
    [self uploadLog];
}

- (void)didReceiveUnregisterLogEngineNotification:(NSNotification *)notification {
    NSParameterAssert(notification);
    [self writeToDisk];
    [self uploadLog];
    [self unRegisterEngine];
}

- (void)didReceiveClearBufferNotification:(NSNotification *)notification {
    NSParameterAssert(notification);
    NSString * content = EMPTY_STRING;
    [content writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)diskFullHandler {
    //磁盘满了之后先把现在已经有的上传上去
    CGFloat freeDiskSpace = [self diskLeftSpaceByMegaByte];
    if (freeDiskSpace < 10.0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDiskIsFullNotification object:nil];
        [self uploadLog];
    }
}
// tools
- (CGFloat)diskLeftSpaceByMegaByte {
    struct statfs buf;
    long long freeSpace = -1;
    if (statfs("/var", &buf)>=0) {
        freeSpace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return  freeSpace/(1024*1024.0);
}
@end
