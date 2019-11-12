//
//  CCEventNoticeCenter.h
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
#import "CCEvent.h"

typedef void (^CCEventSubscriberActionBlock)(CCEvent *info);

@interface CCEventNoticeCenter : NSObject

/**
 添加监听事件

 @param target 添加对象
 @param eventName 事件名
 @param action 回调
 */
+ (void)addTarget:(id)target eventName:(NSString *)eventName action:(CCEventSubscriberActionBlock)action;
+ (void)addTarget:(id)target eventName:(NSString *)eventName actionSEL:(SEL)action;

/**
 发送监听

 @param eventName 事件名
 @param object 发送参数
 */
+ (void)postEventName:(NSString *)eventName object:(id)object;
+ (void)postEventName:(NSString *)eventName object:(id)object afterDelay:(NSTimeInterval)delay;

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
