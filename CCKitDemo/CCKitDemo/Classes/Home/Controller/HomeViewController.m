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
    [self initNavigation];
    [self initControl];
    [self initLoadData];
    [self initManagerHandle];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)initNavigation
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"show" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
}

- (void)rightBarButtonClick:(UIBarButtonItem *)sender
{
    if ([self.cc_viewManager respondsToSelector:@selector(cc_viewManagerWithView:EventParams:)]) {
        [self.cc_viewManager cc_viewManagerWithView:@"message" EventParams:@{ @"show" : sender.title }];
    }
}

- (void)initControl
{
    // 将控制器的View传递给cc_viewManager 管理视图
    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];

    // cc_viewManager ----> info <-----  cc_viewModel 之间通过代理方式交互
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;

    //  cc_viewManager <-----> cc_viewModel  中介者传值
    CCMediator *mediator = [CCMediator mediatorWithViewModel:self.cc_viewModel ViewManager:self.cc_viewManager];

    self.cc_viewManager.cc_mediator = mediator;
    self.cc_viewModel.cc_mediator = mediator;

    self.cc_viewManager.cc_viewManagerInfos = @{ @"cc_ViewManager" : @"xx" };
    [self.cc_viewManager cc_notice];
    NSLog(@"viewManger------>viewModel==%@", self.cc_viewModel.cc_viewModelInfos);

    self.cc_viewModel.cc_viewModelInfos = @{ @"cc_viewModel" : @"oo" };
    [self.cc_viewModel cc_notice];

    NSLog(@"viewModel=====>viewManger==%@", self.cc_viewManager.cc_viewManagerInfos);
}

- (void)initManagerHandle
{
    // cc_viewManager ----> ViewController  之间通过block方式交互
    @weakify(self);
    [self.cc_viewManager didViewManagerInfosBlock:^(NSString *_Nonnull info, NSDictionary *_Nonnull params) {
        @strongify(self);
        if ([info isEqualToString:@"edit"]) {
            NSString *title = @"show";
            if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"show"])
                title = @"all";

            self.navigationItem.rightBarButtonItem.title = title;
        }
    }];
}

- (void)initLoadData
{
    [self.cc_viewModel cc_viewModelWithGetDataSuccessHandler];
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
