//
//  CCEventObject.h
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCEvent, CCEventSubscribEntity;

@interface CCEventObject : NSObject

@property (nonatomic, copy) NSString *eventName;

/**
 Event 中是否包含`target-subscribModel`条目

 @param target key
 @return 包含：YES
 */
- (BOOL)hasContainedSubscribModelForKey:(id)target;

/**
 注册订阅者：
 将订阅者条目`target-subscriber`添加至对应的优先级队列中

 @param subscrib 订阅者条目
 @param target key
 */
- (void)registSubscribModel:(CCEventSubscribEntity *)subscrib forKey:(id)target;
/**
 触发具体事件，执行其队列中的订阅者行为

 @param info 传输数据
 */
- (void)postEventWithDeliveryData:(CCEvent *)info;
/**
 删除事件中Target对应的一条订阅者记录

 @param target key
 @return 删除target对应记录后，各队列是否全为空
 */
- (BOOL)deleteEntryForTarget:(id)target;
/**
 各优先级对应的队列是否全为空

 @return 若全为空，返回YES；反之则否。
 */
- (BOOL)isEmptyMap;

@end
