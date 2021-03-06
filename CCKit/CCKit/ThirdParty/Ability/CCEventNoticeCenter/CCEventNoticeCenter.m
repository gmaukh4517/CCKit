//
//  CCEventNoticeCenter.m
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

#import "CCEventNoticeCenter.h"
#import "CCEventCenter.h"
#import "CCEvent.h"

@implementation CCEventNoticeCenter

+ (void)addTarget:(id)target eventName:(NSString *)eventName action:(CCEventSubscriberActionBlock)action
{
    [[CCEventCenter sharedInstance] registSubscribModel:target markEvent:eventName action:action actionSEL:nil];
}

+ (void)addTarget:(id)target eventName:(NSString *)eventName actionSEL:(SEL)action
{
    [[CCEventCenter sharedInstance] registSubscribModel:target markEvent:eventName action:nil actionSEL:action];
}

+ (void)postEventName:(NSString *)eventName object:(id)object
{
    CCEvent *event = nil;
    if (object) {
        event = [CCEvent new];
        if ([object isKindOfClass:[NSDictionary class]])
            event.userInfo = object;
        else
            event.object = object;
    }

    [[CCEventCenter sharedInstance] postEvent:eventName delivery:event];
}

+ (void)postEventName:(NSString *)eventName object:(id)object afterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CCEventNoticeCenter postEventName:eventName object:eventName];
    });
}

+ (void)removeTarget:(id)target
{
    [[CCEventCenter sharedInstance] unregistSubscribModelFromTarget:target];
}

+ (void)removeEvent:(NSString *)eventName
{
    [[CCEventCenter sharedInstance] removeEvent:eventName];
}

@end
