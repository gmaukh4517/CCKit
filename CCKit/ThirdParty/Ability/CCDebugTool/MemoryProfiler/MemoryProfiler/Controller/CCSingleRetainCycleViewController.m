//
//  CCSingleRetainCycleViewController.m
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
        Cell.textLabel.font = [UIFont systemFontOfSize:13];
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
