//
//  CCPerformanceStatusBar.h
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCMonitorLabel.h"
#import <UIKit/UIKit.h>

@interface CCPerformanceStatusBar : UIView

@property (nonatomic, strong) CCMonitorLabel *fpsLabel;
@property (nonatomic, strong) CCMonitorLabel *cpuLabel;
@property (nonatomic, strong) UILabel *networkLabel;

@end
