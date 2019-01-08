//
//  DataBaseViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "DataBaseViewManager.h"

@interface DataBaseViewManager ()

@property (nonatomic, strong) UITableView *dataBaseTableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isLoadData;

@end

@implementation DataBaseViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    _currentIndex = 1;
    _dataArray = [NSMutableArray array];
    superView.backgroundColor = [UIColor colorFromHexCode:@"f3f5f7"];
    [self tableViewHandle];

    CGFloat height = 64;
    if (device_iPhoneXAbove) {
        height = 100;
    }

    self.dataBaseTableView.frame = CGRectMake(0, 0, superView.width, superView.height - height);
    [superView addSubview:self.dataBaseTableView];
}

- (void)tableViewHandle
{
    self.dataBaseTableView.cc_tableViewHelper.paddedSeparator = YES;
    self.dataBaseTableView.cc_tableViewHelper.isAntiHurry = YES;
    [self.dataBaseTableView.cc_tableViewHelper registerNibs:@[ @"DataBaseTableViewCell" ]];

    @weakify(self);
    [self.dataBaseTableView.cc_tableViewHelper didEditActions:^NSArray<UITableViewRowAction *> *_Nonnull(UITableView *_Nonnull tableView, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel) {
        NSMutableArray *array = [NSMutableArray array];

        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                                title:@"删除"
                                                                                image:[UIImage new]
                                                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                                  @strongify(self);
                                                                                  [self deleteHandleCell:cIndexPath];
                                                                              }];
        deleteAction.backgroundColor = [UIColor redColor];
        [array addObject:deleteAction];

        return array;
    }];

    [self.dataBaseTableView.cc_tableViewHelper didSelect:^(UITableView *tableView, NSIndexPath *_Nonnull cIndexPath, id _Nonnull cModel) {
        [tableView deselectRowAtIndexPath:cIndexPath animated:YES];
    }];

    [self.dataBaseTableView addFooterWithCallback:^{
        @strongify(self);
        self.isLoadData = YES;
        if ([self.viewManagerDelegate respondsToSelector:@selector(cc_viewManagerEvent:withEvent:)]) {
            [self.viewManagerDelegate cc_viewManagerEvent:@"Refresh" withEvent:@{ @"index" : @(self.currentIndex + 1) }];
        }
    }];
}

- (void)cc_viewManagerWithView:(NSString *)info EventParams:(NSDictionary *)params
{
    if ([info isEqualToString:@"add"]) {
        if ([self.viewManagerDelegate respondsToSelector:@selector(cc_viewManagerEvent:withEvent:)]) {
            [self.viewManagerDelegate cc_viewManagerEvent:@"add" withEvent:@{ @"index" : @(self.currentIndex++) }];
        }
    }
}

- (void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos
{
    if ([infos.allKeys containsObject:@"model"]) {
        [self.dataBaseTableView EndRefreshing];
        NSArray *arr = [infos objectForKey:@"model"];
        if (self.currentIndex == 0)
            [self.dataArray removeAllObjects];

        if (self.isLoadData && arr.count)
            self.currentIndex++;

        self.isLoadData = NO;

        [self.dataArray addObjectsFromArray:arr];
        [self.dataBaseTableView.cc_tableViewHelper cc_resetDataAry:self.dataArray];
    }
}

#pragma mark -
#pragma mark :. handel

- (void)deleteHandleCell:(NSIndexPath *)indexPath
{
    TableViewCellEntity *entity = [self.dataArray objectAtIndex:indexPath.row];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.dataBaseTableView.cc_tableViewHelper cc_deleteDataAtIndex:indexPath];

    if ([self.viewManagerDelegate respondsToSelector:@selector(cc_viewManagerEvent:withEvent:)]) {
        [self.viewManagerDelegate cc_viewManagerEvent:@"delete" withEvent:@{ @"id" : @(entity.cellType) }];
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (UITableView *)dataBaseTableView
{
    if (!_dataBaseTableView) {
        _dataBaseTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_dataBaseTableView extraCellLineHidden];
    }
    return _dataBaseTableView;
}


@end
