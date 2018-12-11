//
//  CCEventNoticeCenter.h
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCEvent.h"

typedef void (^CCEventSubscriberActionBlock)(CCEvent *info);

@interface CCEventNoticeCenter : NSObject

/**
 添加监听事件

 @param target 添加对象
 @param eventName 事件名
 @param action 回调
 */
+ (void)addTarget:(id)target EventName:(NSString *)eventName action:(CCEventSubscriberActionBlock)action;
+ (void)addTarget:(id)target eventName:(NSString *)eventName actionSEL:(SEL)action;

/**
 发送监听

 @param eventName 事件名
 @param object 发送参数
 */
+ (void)postEventName:(NSString *)eventName object:(id)object;

/**
 删除监听对象

 @param target 删除对象
 */
+ (void)removeTarget:(id)target;

/**
 删除监听事件

 @param eventName 事件名
 */
+ (void)removeEvent:(NSString *)eventName;

@end
