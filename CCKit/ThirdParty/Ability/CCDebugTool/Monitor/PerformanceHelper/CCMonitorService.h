//
//  CCMonitorService.h
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCMonitorService : NSObject

+ (void)start:(UIWindow *)monitorWindow;

+ (void)stop;

+ (void)mainColor:(UIColor *)color;

@end
