//
//  CCPerformanceConfig.h
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCPerformanceMonitorAttributes) {
    CCPerformanceMonitorFPS,
    CCPerformanceMonitorCPU,
    CCPerformanceMonitorNetWork,
    CCPerformanceMonitorMemory,
};

@interface CCPerformanceConfig : NSObject

@property (nonatomic, assign) CGFloat goodThreshold;

@property (nonatomic, assign) CGFloat warningThreadhold;

/**
 默认为NO。 所以，如果值大于goodThreshold，那么它是好的。就像FPS一样，越高越好。
 */
@property (nonatomic, assign) BOOL lessIsBetter;

+ (instancetype)defaultConfigForAttribtue:(CCPerformanceMonitorAttributes)attribute;

+ (instancetype)configWithGood:(CGFloat)good warning:(CGFloat)warning lessIsBetter:(BOOL)lessIsBetter;

@end
