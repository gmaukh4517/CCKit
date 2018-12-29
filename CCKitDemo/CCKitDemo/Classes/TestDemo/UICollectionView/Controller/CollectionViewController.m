//
//  CollectionViewController.m
//  CCKitDemo
//
//  Created by CC on 2018/12/28.
//  Copyright © 2018 CC. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewManager.h"
#import "CollectionViewModel.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

- (Class)cc_classOfViewManager
{
    return [CollectionViewManager class];
}

- (Class)cc_classOfViewModel
{
    return [CollectionViewModel class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"UICollectionView";
    [self initControl];
    [self initLoadData];
}

- (void)initControl
{
    // 将控制器的View传递给cc_viewManager 管理视图
    [self.cc_viewManager cc_viewManagerWithSuperView:self.view];

    // cc_viewManager ----> info <-----  cc_viewModel 之间通过代理方式交互
    self.cc_viewManager.viewManagerDelegate = self.cc_viewModel;
    self.cc_viewModel.viewModelDelegate = self.cc_viewManager;
}

- (void)initLoadData
{
    [self.cc_viewModel cc_viewModelWithData:@{ @"index" : @0 }];
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
