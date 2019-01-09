//
//  CCEventObject.h
//  CCKit
//
// Copyright (c) 2015 CC ( https://github.com/gmaukh4517/CCKit )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
