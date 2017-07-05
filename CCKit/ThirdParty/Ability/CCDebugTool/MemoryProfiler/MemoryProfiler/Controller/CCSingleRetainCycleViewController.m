//
//  CCSingleRetainCycleViewController.m
//  CCKit
//
//  Created by CC on 2017/7/5.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCSingleRetainCycleViewController.h"
#import "CCTableViewHelper.h"
#import "UITableView+CCAdd.h"
#import "FBObjectiveCGraphElement.h"

@interface CCSingleRetainCycleViewController ()

@property (nonatomic, strong) UITableView *singleTableView;

@end

@implementation CCSingleRetainCycleViewController

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
    self.title = @"Single";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControl
{
    [self.view addSubview:self.singleTableView];
    [self tableViewHandle];
}

- (void)initLoadData
{
    [self.singleTableView.cc_tableViewHelper cc_resetDataAry:self.singleCycle];
}

- (void)tableViewHandle
{
    self.singleTableView.cc_tableViewHelper.cc_CellXIB = @[ @NO ];
    [self.singleTableView.cc_tableViewHelper registerNibs:@[ @"UITableViewCell" ]];
    
    [self.singleTableView.cc_tableViewHelper numberOfRowsInSection:^NSInteger(UITableView *_Nonnull tableView, NSInteger section, id _Nonnull cModel) {
        return [cModel count];
    }];
    
    [self.singleTableView.cc_tableViewHelper didSelect:^(UITableView *tableView, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel) {
        [tableView deselectRowAtIndexPath:cIndexPath animated:YES];
    }];
    
    [self.singleTableView.cc_tableViewHelper cellWillDisplay:^(UITableViewCell *_Nonnull Cell, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel, BOOL IsCelldisplay) {
        Cell.textLabel.text = [cModel description];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark :. getter/setter

- (UITableView *)singleTableView
{
    if (!_singleTableView) {
        _singleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [UIColor clearColor];
        [_singleTableView setTableFooterView:v];
    }
    return _singleTableView;
}

@end
