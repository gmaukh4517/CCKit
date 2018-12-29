//
//  ViewDemoViewController.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "ViewDemoViewController.h"
#import "ViewDemoViewManager.h"
#import "ViewDemoViewModel.h"

#import "ViewDemo.h"

@interface ViewDemoViewController ()

@property (nonatomic, weak) ViewDemo *viewDemo;

@end

@implementation ViewDemoViewController

- (Class)cc_classOfViewManager
{
    return [ViewDemoViewManager class];
}

- (Class)cc_classOfViewModel
{
    return [ViewDemoViewModel class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Event";
    [self initControl];
}

- (void)initControl
{
    [self.view addSubview:self.viewDemo];

    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;

    self.viewDemo.viewEventsBlock = [self.cc_viewManager cc_viewManagerWithViewEventBlockOfInfos:@{ @"view" : self.viewDemo }];

    UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - 150) / 2, self.viewDemo.bottom + 50, 150, 50)];
    viewButton.backgroundColor = [UIColor RandomColor];
    viewButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [viewButton setTitle:@"点击加载/改变数据"];
    [viewButton addTarget:self action:@selector(viewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewButton];
}


- (void)viewButtonClick:(UIButton *)sender
{
    [self.viewDemo cc_configureViewWithViewModel:self.cc_viewModel];
}

#pragma mark -
#pragma mark :. getter/setter

- (ViewDemo *)viewDemo
{
    if (!_viewDemo) {
        ViewDemo *viewDome = [[ViewDemo alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
        viewDome.tag = 123;
        [self.view addSubview:_viewDemo = viewDome];
    }
    return _viewDemo;
}

@end
