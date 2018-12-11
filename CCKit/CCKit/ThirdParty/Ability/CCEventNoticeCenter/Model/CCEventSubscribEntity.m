//
//  CCEventSubscribEntity.m
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCEventSubscribEntity.h"
#import "CCEvent.h"

@implementation CCEventSubscribEntity

- (void)actionWithEvent:(CCEvent *)event
{
    !self.actionBlock ?: self.actionBlock(event);
    if ([self.target respondsToSelector:self.actionSEL]) {
        IMP imp = [self.target methodForSelector:self.actionSEL];
        void (*func)(id, SEL, CCEvent *) = (void *)imp;
        func(self.target, self.actionSEL, event);
    }
}

@end
