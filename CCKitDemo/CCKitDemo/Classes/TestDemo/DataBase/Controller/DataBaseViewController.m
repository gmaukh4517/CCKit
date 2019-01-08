//
//  DataBaseViewController.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "DataBaseViewController.h"
#import "DataBaseViewManager.h"
#import "DataBaseViewModel.h"

@interface DataBaseViewController ()

@end

@implementation DataBaseViewController

- (Class)cc_classOfViewManager
{
    return [DataBaseViewManager class];
}

- (Class)cc_classOfViewModel
{
    return [DataBaseViewModel class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"DataBase";
    [self initNavigation];
    [self initControl];
    [self initLoadData];
}

- (void)initNavigation
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
}

- (void)rightBarButtonClick:(UIBarButtonItem *)sender
{
    if ([self.cc_viewManager respondsToSelector:@selector(cc_viewManagerWithView:EventParams:)]) {
        [self.cc_viewManager cc_viewManagerWithView:@"add" EventParams:@{}];
    }
}

- (void)initControl
{
    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;
}

- (void)initLoadData
{
    [self.cc_viewModel cc_viewModelWithGetData:@{ @"index" : @0 }];
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
