//
//  CCEventCenter.m
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCEventCenter.h"
#import "CCEventSubscribEntity.h"
#import "CCEvent.h"
#import "CCEventObject.h"

@interface CCEventCenter ()

@property (nonatomic, strong) NSMutableDictionary *events;

@end

@implementation CCEventCenter

+ (instancetype)sharedInstance
{
    static CCEventCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registSubscribModel:(id)target markEvent:(NSString *)eventName action:(CCEventSubscriberActionBlock)action actionSEL:(SEL)actionSEL
{
    if (!target) return;
    if (!eventName) return;
    if (!action && !actionSEL) return;

    dispatch_async(event_bus_dispatcher_serialQueue(), ^{
        CCEventObject *event = self.events[ eventName ];
        if (!event) {
            event = [[CCEventObject alloc] init];
            event.eventName = eventName;
            self.events[ eventName ] = event;
        } else {
            if ([event hasContainedSubscribModelForKey:target]) {
                NSString *msg = [NSString stringWithFormat:@"!multiple_registration!\nName:%@\nTarget:%@", eventName, target];
                NSLog(@"%@", msg);
                return;
            }
        }
        CCEventSubscribEntity *subscribModel = [[CCEventSubscribEntity alloc] init];
        subscribModel.actionBlock = action;
        subscribModel.actionSEL = actionSEL;
        subscribModel.target = target;
        [event registSubscribModel:subscribModel forKey:target];
    });
}

- (void)postEvent:(NSString *)eventName delivery:(CCEvent *)info
{
    if (!eventName) return;

    dispatch_async(event_bus_dispatcher_serialQueue(), ^{
        CCEventObject *event = self.events[ eventName ];
        if (!event) {
            NSLog(@"!post_to_no_exist_event!\nName:%@", eventName);
            return;
        }

        if ([event isEmptyMap]) {
            [self removeEvent:eventName];
            NSLog(@"!post_to_no_exist_event!\nName:%@", eventName);
            return;
        }
        [event postEventWithDeliveryData:info];
    });
}
- (void)unregistSubscribModelFromTarget:(id)target
{
    if (!target) {
        return;
    }

    dispatch_async(event_bus_dispatcher_serialQueue(), ^{
        NSMutableArray *deleteEventNames = [NSMutableArray array];
        [self.events enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CCEventObject *event = obj;
            NSString *eventName = key;
            BOOL hasNoSubscribers = [event deleteEntryForTarget:target];
            if (hasNoSubscribers) {
                [deleteEventNames addObject:eventName];
            }
        }];
        [self.events removeObjectsForKeys:deleteEventNames];
    });
}
- (void)removeEvent:(NSString *)eventName
{
    if (!eventName) {
        return;
    }
    dispatch_async(event_bus_dispatcher_serialQueue(), ^{
        [self.events removeObjectForKey:eventName];
    });
}

static dispatch_queue_t event_bus_dispatcher_serialQueue()
{
    static dispatch_queue_t cc_event_bus_dispatcher_serialQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cc_event_bus_dispatcher_serialQueue = dispatch_queue_create("COM.CC_EVENT.SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);

        dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_set_target_queue(cc_event_bus_dispatcher_serialQueue, referQueue);

    });
    return cc_event_bus_dispatcher_serialQueue;
}

- (NSMutableDictionary *)events
{
    if (!_events) {
        _events = [[NSMutableDictionary alloc] init];
    }
    return _events;
}

@end
