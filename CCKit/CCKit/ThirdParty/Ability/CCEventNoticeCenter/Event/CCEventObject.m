//
//  CCEventObject.m
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCEventObject.h"
#import "CCEventSubscribEntity.h"
#import "CCEvent.h"

@interface CCEventObject ()

@property (nonatomic, strong) NSMapTable *mapDefault;
@property (nonatomic, strong) dispatch_semaphore_t actionSemaphore;

@end

@implementation CCEventObject

- (BOOL)hasContainedSubscribModelForKey:(id)target
{
    if (!target) return NO;
    if ([self.mapDefault objectForKey:target]) return YES;
    return NO;
}

- (void)registSubscribModel:(CCEventSubscribEntity *)subscrib forKey:(id)target
{
    if (!subscrib) return;
    if (!target) return;
    [self addSubscribModel:subscrib forKey:target toMap:self.mapDefault];
}

- (void)postEventWithDeliveryData:(CCEvent *)info
{
    [self actionMap:self.mapDefault deliveryData:info];
}

- (BOOL)deleteEntryForTarget:(id)target
{
    if (!target) return NO;
    [self deleteEntryForTarget:target in:self.mapDefault];
    BOOL isEmpty = [self isEmptyMap];
    return isEmpty;
}

- (BOOL)isEmptyMap
{
    return self.mapDefault.keyEnumerator.allObjects.count <= 0;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionSemaphore = dispatch_semaphore_create(4);
        [self nestConcurrent2SerialQueue];
    }
    return self;
}
#pragma mark ======  delegate  ======
#pragma mark ======  event  ======

#pragma mark ======  private  ======
- (void)nestConcurrent2SerialQueue
{
    dispatch_set_target_queue(event_subscriber_dispatcher_concurrentQueue(), event_subscriber_dispatcher_serialQueue());
}
- (void)actionMap:(NSMapTable *)map deliveryData:(id)info
{
    dispatch_async(event_subscriber_dispatcher_concurrentQueue(), ^{
        NSArray *tmps = [[NSArray alloc] initWithArray:map.objectEnumerator.allObjects];
        __weak __typeof(self) weakSelf = self;
        [tmps enumerateObjectsUsingBlock:^(CCEventSubscribEntity *_Nonnull subscriber, NSUInteger idx, BOOL *_Nonnull stop) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            dispatch_semaphore_wait(strongSelf.actionSemaphore, DISPATCH_TIME_FOREVER);
            [subscriber actionWithEvent:info];
            dispatch_semaphore_signal(strongSelf.actionSemaphore);
        }];
    });
}
- (void)deleteEntryForTarget:(id)target in:(NSMapTable *)map
{
    [map removeObjectForKey:target];
}
- (void)addSubscribModel:(CCEventSubscribEntity *)subscrib forKey:(id)target toMap:(NSMapTable *)map
{
    [map setObject:subscrib forKey:target];
}

#pragma mark ======  c  ======
static dispatch_queue_t event_subscriber_dispatcher_serialQueue()
{
    static dispatch_queue_t cc_event_subscriber_dispatcher_serialQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cc_event_subscriber_dispatcher_serialQueue = dispatch_queue_create("COM.CC_EVENT.SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);

        dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_set_target_queue(cc_event_subscriber_dispatcher_serialQueue, referQueue);

    });
    return cc_event_subscriber_dispatcher_serialQueue;
}
static dispatch_queue_t event_subscriber_dispatcher_concurrentQueue()
{
    static dispatch_queue_t cc_event_subscriber_dispatcher_concurrentQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cc_event_subscriber_dispatcher_concurrentQueue = dispatch_queue_create("COM.CC_EVENT.CONCURRENT_QUEUE", DISPATCH_QUEUE_CONCURRENT);

        dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_set_target_queue(cc_event_subscriber_dispatcher_concurrentQueue, referQueue);
    });
    return cc_event_subscriber_dispatcher_concurrentQueue;
}

- (NSMapTable *)mapDefault
{
    if (!_mapDefault) {
        _mapDefault = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _mapDefault;
}

@end
