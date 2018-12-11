//
//  CCEventNoticeCenter.m
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCEventNoticeCenter.h"
#import "CCEventCenter.h"
#import "CCEvent.h"

@implementation CCEventNoticeCenter

+ (void)addTarget:(id)target EventName:(NSString *)eventName action:(CCEventSubscriberActionBlock)action
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

+ (void)removeTarget:(id)target
{
    [[CCEventCenter sharedInstance] unregistSubscribModelFromTarget:target];
}

+ (void)removeEvent:(NSString *)eventName
{
    [[CCEventCenter sharedInstance] removeEvent:eventName];
}

@end
