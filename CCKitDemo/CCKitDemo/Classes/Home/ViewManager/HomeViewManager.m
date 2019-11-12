//
//  HomeViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/7/5.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "HomeViewManager.h"
#import "CollectionViewController.h"

@interface HomeViewManager ()

@property (nonatomic, strong) UITableView *homeTableView;

@end

@implementation HomeViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    superView.backgroundColor = [UIColor colorFromHexCode:@"f3f5f7"];
    [self tableViewHandle];

    CGFloat height = device_iPhoneX ? 80 : 50;

    self.homeTableView.frame = CGRectMake(0, 0, superView.width, superView.height - height);
    [superView addSubview:self.homeTableView];
}

- (void)tableViewHandle
{
    self.homeTableView.cc_tableViewHelper.paddedSeparator = YES;
    self.homeTableView.cc_autoSizingCell = YES;
    self.homeTableView.cc_tableViewHelper.isAntiHurry = YES;
    self.homeTableView.cc_tableViewHelper.titleHeaderHeight = 30;
    [self.homeTableView.cc_tableViewHelper registerNibs:@[ @"HomeTableViewCell" ]];

    //    @weakify(self);
    [self.homeTableView.cc_tableViewHelper headerView:^UIView *_Nonnull(UITableView *_Nonnull tableView, NSInteger section, id _Nonnull cModel) {
        static NSString *headIdentifier = @"TZCourseDetailsDownloadHeaderViewIdentifier";
        UITableViewHeaderFooterView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headIdentifier];
        if (!headView) {
            headView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headIdentifier];

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.width - 20, 20)];
            titleLabel.tag = 123;
            [headView addSubview:titleLabel];
        }
        UILabel *titleLabel = (UILabel *)[headView viewWithTag:123];
        titleLabel.text = [NSString stringWithFormat:@"Header %zi", section];

        return headView;
    }];

    //    @weakify(self);
    [self.homeTableView.cc_tableViewHelper didSelect:^(UITableView *tableView, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel) {
        [tableView deselectRowAtIndexPath:cIndexPath animated:YES];
        TableViewCellEntity *entity = cModel;
        if (entity.cellType == 1) {
            !self.viewManagerInfosBlock ?: self.viewManagerInfosBlock(@"edit", @{ @"edit" : @"" });
        } else if (entity.cellType == 2) {
            [tableView.viewController pushNewViewControllerWithBack:[CollectionViewController new]];
        } else {
            if (entity.cellData)
                [tableView.viewController pushNewViewControllerWithBack:[NSClassFromString(entity.cellData) new]];
        }
    }];
}

- (void)cc_viewManagerWithView:(NSString *)info EventParams:(NSDictionary *)params
{
    if ([info isEqualToString:@"message"]) {
        [CCProgressHUD showMessages:[params objectForKey:@"show"]];
    }
}

- (void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos
{
    if ([infos.allKeys containsObject:@"model"]) {
        NSString *message = [infos objectForKey:@"message"];
        if (message.length > 0) {
            [CCProgressHUD showMessages:message];
            return;
        }
        [self.homeTableView.cc_tableViewHelper cc_reloadGroupDataAry:[infos objectForKey:@"model"]];
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (UITableView *)homeTableView
{
    if (!_homeTableView) {
        _homeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_homeTableView extraCellLineHidden];
    }
    return _homeTableView;
}

@end
