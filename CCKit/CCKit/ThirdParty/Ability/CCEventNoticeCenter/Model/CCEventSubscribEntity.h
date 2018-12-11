//
//  CCEventSubscribEntity.h
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCEventNoticeCenter.h"

@interface CCEventSubscribEntity : NSObject

@property (nonatomic, assign) SEL actionSEL;
@property (nonatomic, copy) CCEventSubscriberActionBlock actionBlock;
@property (nonatomic, weak) id target;


- (void)actionWithEvent:(CCEvent *)event;

@end
