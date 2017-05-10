//
//  CCPerformanceConfig.m
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCPerformanceConfig.h"

@implementation CCPerformanceConfig

+ (instancetype)defaultConfigForAttribtue:(CCPerformanceMonitorAttributes)attribute
{
    if (attribute == CCPerformanceMonitorMemory) {
        return [self configWithGood:150.0 warning:200.0 lessIsBetter:YES];
    }
    if (attribute == CCPerformanceMonitorFPS) {
        return [self configWithGood:55.0 warning:40.0 lessIsBetter:NO];
    }
    if (attribute == CCPerformanceMonitorCPU) {
        return [self configWithGood:70.0 warning:90.0 lessIsBetter:YES];
        ;
    }
    return nil;
}
+ (instancetype)configWithGood:(CGFloat)good warning:(CGFloat)warning lessIsBetter:(BOOL)lessIsBetter
{
    CCPerformanceConfig *config = [[CCPerformanceConfig alloc] init];
    config.lessIsBetter = lessIsBetter;
    config.goodThreshold = good;
    config.warningThreadhold = warning;
    return config;
}

@end
