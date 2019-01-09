//
//  EventNoticeCenterViewController.m
//  CCKitDemo
//
//  Created by CC on 2019/1/8.
//  Copyright © 2019 CC. All rights reserved.
//

#import "EventNoticeCenterViewController.h"
#import "EventNoticeCenterViewManager.h"
#import "EventNoticeCenterViewModel.h"

@interface EventNoticeCenterViewController ()

@end

@implementation EventNoticeCenterViewController

- (Class)cc_classOfViewManager
{
    return [EventNoticeCenterViewManager class];
}

- (Class)cc_classOfViewModel
{
    return [EventNoticeCenterViewModel class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"CCEventNocite";
    [self initControl];
}

- (void)initControl
{
    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;
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
