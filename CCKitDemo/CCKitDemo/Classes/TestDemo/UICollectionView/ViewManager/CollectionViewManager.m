


//
//  CollectionViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/12/28.
//  Copyright © 2018 CC. All rights reserved.
//

#import "CollectionViewManager.h"

@interface CollectionViewManager ()

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL isLoad;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation CollectionViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    CGFloat height = 64;
    if (device_iPhoneXAbove) {
        height = 100;
    }

    self.dataArray = [NSMutableArray array];

    self.collectionView.frame = CGRectMake(0, 0, superView.width, superView.height - height);
    [superView addSubview:self.collectionView];
    [self tableViewHandle];
}

- (void)tableViewHandle
{
    [self.collectionView.cc_collectionViewHelper registerNibs:@[ @"CollectionViewCell" ]];
    self.collectionView.cc_collectionViewHelper.reusableDelegate = self;
    self.collectionView.cc_collectionViewHelper.cellDelegate = self;

    @weakify(self);
    [self.collectionView.cc_collectionViewHelper didScrollViewDidScroll:^(UIScrollView *scrollView) {
        @strongify(self);
        [self navigationColor:scrollView.contentOffset.y];
    }];

    [self.collectionView.cc_collectionViewHelper didSelectItemAtIndexPath:^(UICollectionView *collectionView, NSIndexPath *cIndexPath, id cModel) {
        [collectionView deselectItemAtIndexPath:cIndexPath animated:YES];
    }];


    [self.collectionView.cc_collectionViewHelper didCellItemMargin:^UIEdgeInsets(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger cSection, id cModel) {
        UIEdgeInsets insets = UIEdgeInsetsMake(10, 15, 0, 15);
        if (isiPad)
            insets = UIEdgeInsetsMake(10, 22, 0, 22);
        return insets;
    }];

    [self.collectionView.cc_collectionViewHelper didSizeForItemAtIndexPath:^CGSize(UICollectionView *collectionView, UICollectionViewLayout *layout, NSIndexPath *cIndexPath, id cModel) {
        float itemWidth = (collectionView.width - 45) / 2;
        CGSize size = CGSizeMake(itemWidth, winsize.width * 0.40625);
        if (isiPad) {
            itemWidth = (collectionView.width - 66) / 2;
            CGFloat height = itemWidth / 16 * 9;
            size = CGSizeMake(itemWidth, height + 70);
        }
        return size;
    }];

    [self.collectionView addHeaderWithCallback:^{
        @strongify(self);
        self.currentIndex = 0;
        [self loadData];
        if (self.isLoad) {
            self.isLoad = NO;
            [self addFooter];
        }
    }];

    [self addFooter];
}

- (void)addFooter
{
    self.isLoad = NO;
    @weakify(self);
    [self.collectionView addFooterWithCallback:^{
        @strongify(self);
        if (!self.isLoad) {
            self.currentIndex++;
            [self loadData];
        }
    }];
}

- (void)loadData
{
    if ([self.viewManagerDelegate respondsToSelector:@selector(cc_viewManagerEvent:withEvent:)]) {
        [self.viewManagerDelegate cc_viewManagerEvent:@"loadData" withEvent:@{ @"index" : @(self.currentIndex) }];
    }
}

- (void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos
{
    if ([infos.allKeys containsObject:@"model"]) {
        [self.collectionView EndRefreshing];
        NSString *message = [infos objectForKey:@"message"];
        if (message.length > 0) {
            [CCProgressHUD showMessages:message];
            return;
        }

        if (self.currentIndex == 0)
            [self.dataArray removeAllObjects];

        [self.dataArray addObjectsFromArray:[infos objectForKey:@"model"]];
        cc_dispatch_after(0.3, ^{
            [self.collectionView.cc_collectionViewHelper cc_resetDataAry:self.dataArray];
        });
    }
}

- (void)navigationColor:(CGFloat)offsetY
{
    self.cc_viewManagerInfos = @{ @"offsetY" : @(offsetY) };
    CGFloat y = device_iPhoneX ? 88 : 64;
    NSInteger navbarChangePoint = -y;

    if (offsetY > navbarChangePoint) {
        CGFloat alpha = MIN(1, 1 - ((navbarChangePoint + y - offsetY) / y));
        [self.collectionView.navigationController.navigationBar setNeedsNavigationBackground:alpha];
        UIStatusBarStyle style = UIStatusBarStyleLightContent;
        UIColor *color = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        BOOL isShadow = YES;
        if (alpha == 1) {
            style = UIStatusBarStyleDefault;
            color = [UIColor colorFromHexCode:@"1C86EE"];
            isShadow = NO;
        }

        [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
        [self.collectionView.navigationController.navigationBar setShadowImage:[UIImage new]];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        [self.collectionView.navigationController.navigationBar setNeedsNavigationBackground:0];
        self.collectionView.navigationController.navigationBar.layer.shadowColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.alwaysBounceVertical = YES;
        _collectionView = collectionView;
    }
    return _collectionView;
}

@end
