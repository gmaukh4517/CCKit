//
//  CCEventEntity.m
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCEvent.h"

@implementation CCEvent

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%p> - userInfo: %@, extobj: %@", self, [self.userInfo description], [self.object description]];
}

@end
