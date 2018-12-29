//
//  ViewDemoViewModel.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "ViewDemoViewModel.h"

@implementation ViewDemoViewModel

- (void)cc_viewManagerEvent:(NSString *)info withEvent:(NSDictionary *)eventDic
{
    if ([info isEqualToString:@"testClick"]) {
        NSLog(@"testClick ======= > %@", eventDic);
    }
}

- (void)cc_viewModelWithModelBlcok:(void (^)(id))modelBlock
{
    !modelBlock ?: modelBlock(@{ @"text" : [NSString stringWithFormat:@"假装我在网络请求 %i", arc4random() % 100] });
}

@end
