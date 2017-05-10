//
//  CCDebugTool.m
//  CCKit
//
// Copyright (c) 2015 CC ( https://github.com/gmaukh4517/CCKit )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CCDebugTool.h"
#import "CCDebugCrashViewController.h"
#import "CCDebugHttpProtocol.h"
#import "CCDebugHttpViewController.h"
#import "CCDebugLogViewController.h"
#import "CCMonitorViewController.h"
#import "Config.h"

#import "CCMonitorService.h"

@interface CCDebugWindow : UIWindow

@end

@implementation CCDebugWindow

- (void)becomeKeyWindow
{
    //uisheetview
    [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
}

@end


@interface CCDebugTool ()

@property (nonatomic, weak) UITabBarController *debugTabBar;
@property (nonatomic, strong) CCDebugWindow *debugWindow;

@property (nonatomic, strong) NSTimer *debugTimer;

@end

@implementation CCDebugTool

+ (instancetype)manager
{
    static CCDebugTool *tool;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[CCDebugTool alloc] init];
    });
    return tool;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.mainColor = cc_ColorRGB(245, 116, 91);
        self.maxCrashCount = 20;
        self.maxLogsCount = 50;
        self.debugWindow = [[CCDebugWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    }
    return self;
}

/**
 *  @author CC, 16-03-05
 *
 *  @brief 状态栏显示Debug按钮
 */
- (void)showOnStatusBar
{
    self.debugWindow.windowLevel = UIWindowLevelStatusBar + 1;
    self.debugWindow.hidden = NO;
    
    [CCMonitorService start:self.debugWindow];
    [CCMonitorService mainColor:self.mainColor];
    
    UIButton *debugButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [debugButton addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
    [self.debugWindow addSubview:debugButton];
}


/**
 *  @author CC, 16-03-05
 *
 *  @brief 启动Debug检测
 */
- (void)enableDebugMode
{
    [NSURLProtocol registerClass:[CCDebugHttpProtocol class]];
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf showOnStatusBar];
    });
}

- (void)showDebug
{
    if (!self.debugTabBar) {
        UITabBarController *debugTabBar = [[UITabBarController alloc] init];
        
        UINavigationController *debugHTTPNav = [self initializationNav:[CCDebugHttpViewController new] tabBarItemName:@"HTTP"];
        UINavigationController *debugCrashNav = [self initializationNav:[CCDebugCrashViewController new] tabBarItemName:@"Crash"];
        UINavigationController *debugLOGNav = [self initializationNav:[CCDebugLogViewController new] tabBarItemName:@"LOG"];
        UINavigationController *debugMonitorNav = [self initializationNav:[CCMonitorViewController new] tabBarItemName:@"Monitor"];
        
        debugTabBar.viewControllers = [NSArray arrayWithObjects:debugHTTPNav, debugCrashNav, debugLOGNav, debugMonitorNav, nil];
        self.debugTabBar = debugTabBar;
        
        UIViewController *rootViewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        [presentedViewController ?: rootViewController presentViewController:self.debugTabBar animated:YES completion:nil];
    } else {
        [self.debugTabBar dismissViewControllerAnimated:YES completion:nil];
        self.debugTabBar = nil;
    }
}

- (UINavigationController *)initializationNav:(UIViewController *)viewController tabBarItemName:(NSString *)tabBarItemName
{
    UINavigationController *debugNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    debugNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:tabBarItemName image:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [debugNav.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                          NSFontAttributeName : [UIFont systemFontOfSize:30] }
                                              forState:UIControlStateNormal];
    [debugNav.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : self.mainColor,
                                                          NSFontAttributeName : [UIFont systemFontOfSize:30] }
                                              forState:UIControlStateSelected];
    return debugNav;
}

@end
