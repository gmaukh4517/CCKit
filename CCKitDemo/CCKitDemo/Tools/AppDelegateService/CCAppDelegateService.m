//
//  CCAppDelegateService.m
//  CCKitDemo
//
//  Created by CC on 2018/4/8.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCAppDelegateService.h"
#import "MainTabBarViewController.h"

@implementation CCAppDelegateService

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setUpNavigationBarAppearance:appThemeColor];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [MainTabBarViewController new];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)setUpNavigationBarAppearance:(UIColor *)color
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:color];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        UIImage *backButtonImage = [UIImage imageNamed:@"nav_back"];
        [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    } else {
        [[UINavigationBar appearance] setTintColor:color];
    }

    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];

    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

@end
