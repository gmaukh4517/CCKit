//
//  CCMonitorLabel.m
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCMonitorLabel.h"

@interface CCMonitorLabel ()

@property (nonatomic, strong) NSMutableDictionary *configCache;

@end

@implementation CCMonitorLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    [self setTextColor:[UIColor colorWithRed:244.0 / 255.0 green:66.0 / 255.0 blue:66.0 / 255.0 alpha:1.0] forState:CCPerformanceStateBad];
    [self setTextColor:[UIColor orangeColor] forState:CCPerformanceStateWarning];
    [self setTextColor:[UIColor colorWithRed:66.0 / 255.0 green:244.0 / 255.0 blue:89.0 / 255.0 alpha:1.0] forState:CCPerformanceStateGood];
    self.state = CCPerformanceStateGood;
}

- (NSMutableDictionary *)configCache
{
    if (_configCache == nil) {
        _configCache = [[NSMutableDictionary alloc] init];
    }
    return _configCache;
}
- (void)setTextColor:(UIColor *)textColor forState:(CCPerformanceLabelState)state
{
    if (textColor) {
        [self.configCache setObject:textColor forKey:@(state)];
    } else {
        [self.configCache removeObjectForKey:@(state)];
    }
}

- (UIColor *)textColorForState:(CCPerformanceLabelState)state
{
    return [self.configCache objectForKey:@(state)];
}

- (void)setState:(CCPerformanceLabelState)state
{
    _state = state;
    UIColor *color = [self textColorForState:state];
    self.textColor = color;
}


@end
