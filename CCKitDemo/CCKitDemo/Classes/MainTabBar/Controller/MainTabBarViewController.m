//
//  MainTabBarViewController.m
//  CCKitDemo
//
//  Created by CC on 2018/4/8.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "HomeViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self initTabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTabBar
{
    [self addChildViewController:[HomeViewController new] title:@"首页" imageNamed:@"tabbar_home_no" selectedImage:@"tabbar_home_yes"];
    [self addChildViewController:[UIViewController new] title:@"我的" imageNamed:@"tabbar_me_no" selectedImage:@"tabbar_me_yes"];

    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:20],
                                                         NSForegroundColorAttributeName : appThemeColor }
                                             forState:UIControlStateSelected];
    self.tabBar.translucent = NO;
}

- (void)addChildViewController:(UIViewController *)vc
                         title:(NSString *)title
                    imageNamed:(NSString *)imageNamed
                 selectedImage:(NSString *)selectedImage
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.title = title;
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [[UIImage imageNamed:imageNamed] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self addChildViewController:nav];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
