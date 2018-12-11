//
//  CCEventCenter.h
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCEventNoticeCenter.h"

@class CCEvent;

@interface CCEventCenter : NSObject

+ (instancetype)sharedInstance;

/**
 注册订阅者事件（单一）

 @param target target
 @param eventName 事件名称
 @param action target对应订阅者的行为
 @param actionSEL target对应订阅者的行为
 */
- (void)registSubscribModel:(id)target markEvent:(NSString *)eventName action:(CCEventSubscriberActionBlock)action actionSEL:(SEL)actionSEL;

/**
 触发事件

 @param eventName 事件名称
 @param info 传输的数据
 */
- (void)postEvent:(NSString *)eventName delivery:(CCEvent *)info;
/**
 解注册Target对应的订阅者：
 若解除后事件无相关订阅者，则移除该Event对象

 @param target target
 */
- (void)unregistSubscribModelFromTarget:(id)target;
/**
 移除事件

 @param eventName 事件名称
 */
- (void)removeEvent:(NSString *)eventName;

@end
