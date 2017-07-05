//
//  CCRetainCyclePresenter.m
//  CCKit
//
//  Created by CC on 2017/7/5.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCRetainCyclePresenter.h"
#import "CCSingleRetainCycleViewController.h"
#import "CCTableViewHelper.h"
#import "Config.h"
#import "FBObjectiveCGraphElement.h"
#import "UITableView+CCAdd.h"

@interface CCRetainCyclePresenter ()

@property (nonatomic, strong) UITableView *cycleTableView;

@end

@implementation CCRetainCyclePresenter

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigation];
    [self initControl];
    [self initLoadData];
}

- (void)initNavigation
{
    self.title = @"Cycle";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)initControl
{
    [self.view addSubview:self.cycleTableView];
    [self tableViewHandle];
}

- (void)initLoadData
{
    [self.cycleTableView.cc_tableViewHelper cc_resetDataAry:self.retainCycles];
}

- (void)tableViewHandle
{
    self.cycleTableView.cc_tableViewHelper.cc_CellXIB = @[ @NO ];
    [self.cycleTableView.cc_tableViewHelper registerNibs:@[ @"UITableViewCell" ]];
    
    [self.cycleTableView.cc_tableViewHelper numberOfRowsInSection:^NSInteger(UITableView *_Nonnull tableView, NSInteger section, id _Nonnull cModel) {
        return [cModel count];
    }];
    
    @weakify(self);
    [self.cycleTableView.cc_tableViewHelper didSelect:^(UITableView *tableView, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel) {
        [tableView deselectRowAtIndexPath:cIndexPath animated:YES];
        @strongify(self);
        CCSingleRetainCycleViewController *viewController = [[CCSingleRetainCycleViewController alloc] init];
        viewController.singleCycle = cModel;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    
    [self.cycleTableView.cc_tableViewHelper cellWillDisplay:^(UITableViewCell *_Nonnull Cell, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel, BOOL IsCelldisplay) {
        Cell.textLabel.numberOfLines = 0;
        Cell.textLabel.font = [UIFont systemFontOfSize:13];
        Cell.textLabel.text = [cModel[0] classNameOrNull];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark :. getter/setter

- (UITableView *)cycleTableView
{
    if (!_cycleTableView) {
        _cycleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [UIColor clearColor];
        [_cycleTableView setTableFooterView:v];
    }
    return _cycleTableView;
}


@end
