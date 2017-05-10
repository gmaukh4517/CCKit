//
//  CCPerformanceStatusBar.m
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCPerformanceStatusBar.h"
#import "UIView+Frame.h"

@implementation CCPerformanceStatusBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.layer.cornerRadius = 3;
    
    _fpsLabel = [[CCMonitorLabel alloc] initWithFrame:CGRectMake(5, 0, 45, 18)];
    _fpsLabel.font = [UIFont systemFontOfSize:10];
    _fpsLabel.textAlignment = NSTextAlignmentCenter;
    _fpsLabel.textColor = [UIColor whiteColor];
    _fpsLabel.text = @"FPS: d-";
    _fpsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_fpsLabel];
    
    _cpuLabel = [[CCMonitorLabel alloc] initWithFrame:CGRectMake(_fpsLabel.right, _fpsLabel.y, 65, 18)];
    _cpuLabel.font = [UIFont systemFontOfSize:10];
    _cpuLabel.textAlignment = NSTextAlignmentCenter;
    _cpuLabel.textColor = [UIColor whiteColor];
    _cpuLabel.text = @"CPU: -";
    _cpuLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_cpuLabel];
    
    _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cpuLabel.right + 5, _cpuLabel.y, 130, 18)];
    _networkLabel.font = [UIFont systemFontOfSize:10];
    _networkLabel.textColor = [UIColor whiteColor];
    _networkLabel.text = @"NetWork: -";
    _networkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_networkLabel];
}

@end
