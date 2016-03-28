//
//  HYLogBaseModel.h
//  Bidding
//
//  Created by knight on 15/6/29.
//  Copyright (c) 2015年 bj.58.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYLogBaseModel : NSObject

@property (nonatomic , strong) NSDictionary * logDic;
/**
 *  将logModel转化成字典
 *  按照MVVM模式这个应该放到VM里，暂时先放这
 *
 *  @return 转化后的字典
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *transef2Dic;
@end
