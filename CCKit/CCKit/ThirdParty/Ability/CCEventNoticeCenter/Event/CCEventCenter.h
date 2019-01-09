//
//  CCEventCenter.h
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
