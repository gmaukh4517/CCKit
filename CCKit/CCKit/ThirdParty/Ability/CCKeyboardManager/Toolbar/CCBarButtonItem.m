//
//  CCBarButtonItem.m
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import "CCBarButtonItem.h"

@implementation CCBarButtonItem

+ (void)initialize
{
    [super initialize];

    CCBarButtonItem *appearanceProxy = [self appearance];

    NSArray<NSNumber *> *states = @[ @(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled), @(UIControlStateSelected), @(UIControlStateApplication), @(UIControlStateReserved) ];

    for (NSNumber *state in states) {
        UIControlState controlState = [state unsignedIntegerValue];

        [appearanceProxy setBackgroundImage:nil forState:controlState barMetrics:UIBarMetricsDefault];
        [appearanceProxy setBackgroundImage:nil forState:controlState style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
        [appearanceProxy setBackgroundImage:nil forState:controlState style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
        [appearanceProxy setBackButtonBackgroundImage:nil forState:controlState barMetrics:UIBarMetricsDefault];
    }

    [appearanceProxy setTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [appearanceProxy setBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    [appearanceProxy setBackButtonBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    //titleTextAttributes tweak is to overcome an issue comes with iOS11 where appearanceProxy set for NSForegroundColorAttributeName and bar button texts start appearing in appearance proxy color
    NSMutableDictionary *textAttributes = [[self titleTextAttributesForState:UIControlStateNormal] mutableCopy] ?: [NSMutableDictionary new];
    textAttributes[ NSForegroundColorAttributeName ] = tintColor;
    [self setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(nullable id)target action:(nullable SEL)action
{
    if (self = [super initWithBarButtonSystemItem:systemItem target:target action:action])
        _isSystemItem = YES;
    return self;
}


- (void)setTarget:(nullable id)target action:(nullable SEL)action
{
    NSInvocation *invocation = nil;

    if (target && action) {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }

    self.invocation = invocation;
}

- (void)dealloc
{
    self.target = nil;
    self.invocation.target = nil;
    self.invocation = nil;
}

@end
