//
//  HomeViewController.m
//  CCKitDemo
//
//  Created by CC on 2018/7/5.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeViewManager.h"
#import "HomeViewModel.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (Class)cc_classOfViewManager
{
    return [HomeViewManager class];
}

- (Class)cc_classOfViewModel
{
    return [HomeViewModel class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initControl];
    [self initLoadData];
    [[CCKeyboardManager manager] registeredWithViewController:self];
}

- (void)initControl
{
    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;
}

- (void)initLoadData
{
    [self.cc_viewModel cc_viewModelWithGetDataSuccessHandler];
}

- (void)dealloc
{
    [[CCKeyboardManager manager] freed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
