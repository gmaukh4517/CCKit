//
//  CCMonitorLabel.h
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCPerformanceLabelState) {
    CCPerformanceStateGood,    //性能状态良好
    CCPerformanceStateWarning, //性能状态警告
    CCPerformanceStateBad,     //性能状态不良
};


@interface CCMonitorLabel : UILabel

@property (nonatomic, assign) CCPerformanceLabelState state;

- (void)setTextColor:(UIColor *)textColor forState:(CCPerformanceLabelState)state;

- (UIColor *)textColorForState:(CCPerformanceLabelState)state;


@end
