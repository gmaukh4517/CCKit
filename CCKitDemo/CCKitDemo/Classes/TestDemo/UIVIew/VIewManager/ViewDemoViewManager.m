//
//  ViewDemoViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "ViewDemoViewManager.h"
#import "ViewDemo.h"

@interface ViewDemoViewManager ()

@property (nonatomic, weak) ViewDemo *viewDemo;

@end

@implementation ViewDemoViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    self.viewDemo = (ViewDemo *)[superView viewWithTag:123];
    self.viewDemo.viewDelegate = self;
}

- (void)cc_viewEvent:(__kindof UIView *)view withEvents:(NSDictionary *)events
{
    if ([events.allKeys containsObject:@"jump"]) {
        [view.viewController pushNewViewControllerWithBack:[NSClassFromString(@"TestHandleViewController") new]];
    }
}

- (ViewEventsBlock)cc_viewManagerWithViewEventBlockOfInfos:(NSDictionary *)infos
{
    @weakify(self);
    return ^(NSString *info, NSDictionary *eventDic) {
        @strongify(self);
        if ([self.viewManagerDelegate respondsToSelector:@selector(cc_viewManagerEvent:withEvent:)]) {
            [self.viewManagerDelegate cc_viewManagerEvent:info withEvent:eventDic];
        }
    };
}

#pragma mark -
#pragma mark :. getter/setter


@end
