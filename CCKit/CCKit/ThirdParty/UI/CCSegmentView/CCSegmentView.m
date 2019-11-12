//
//  CCSegmentView.m
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
//opyright © 2019 CC. All rights reserved.
//

#import "CCSegmentView.h"
#import "CCSegmentMenuView.h"

#import "CCSegmentContentScrollView.h"

#import "UIView+Frame.h"
#import "UIView+Method.h"
#import "UIScrollView+CCAdd.h"
#import "CCConfig.h"
#import "UIColor+CCAdd.h"

#define kSegmentViewTagOffset 1000
#define kSegmentViewFooterTagOffset 2000
#define kSegmentViewIndex(view) ([view tag] - kSegmentViewTagOffset)
#define kSegmentViewFooterIndex(view) ([view tag] - kSegmentViewTagOffset)

#define CCAssert(condition, format, ...)                                                       \
    do {                                                                                       \
        _Pragma("clang diagnostic push")                                                       \
            _Pragma("clang diagnostic ignored \"-Wformat-extra-args\"") if ((condition) == NO) \
                NSLog(format, ##__VA_ARGS__);                                                  \
        _Pragma("clang diagnostic pop")                                                        \
    } while (0);

@interface CCSegmentView () <CCSegmentMenuViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) CCSegmentMenuView *segmentView;

@property (nonatomic, strong) CCSegmentContentScrollView *contentScrollView;

@property (nonatomic, strong) NSMutableSet *visibleTableViews;
@property (nonatomic, strong) NSMutableSet *reusableTableViews;

@property (nonatomic, strong) NSMutableSet *visibleFooterViews;
@property (nonatomic, strong) NSMutableSet *reusableFooterViews;

@property (nonatomic, strong) NSMutableArray *tableViews;

@property (nonatomic, weak) UIView *currentView;

@property (nonatomic, assign) NSInteger showIndex;

// top 1 left 2 bottom 3  right 4;
@property (nonatomic, assign) NSInteger direction;

@end


@implementation CCSegmentView

- (instancetype)init
{
    if (self = [super init]) {
        [self initControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    if (_segmentView)
        return;

    self.isMultiplexing = YES;
    self.visibleTableViews = [NSMutableSet set];
    self.reusableTableViews = [NSMutableSet set];

    self.visibleFooterViews = [NSMutableSet set];
    self.reusableFooterViews = [NSMutableSet set];

    self.tableViews = [NSMutableArray array];
    self.showIndex = -1;

    CCSegmentMenuView *segmentView = [[CCSegmentMenuView alloc] initWithFrame:CGRectMake(0, 0, winsize.width, 40)];
    segmentView.lineWidth = 15;
    segmentView.lineHeight = 3;
    segmentView.animation = YES;
    segmentView.isFullof = YES;
    segmentView.titleColor = [UIColor colorFromHexCode:@"A1A1A3"];
    segmentView.titleSelectedColor = [UIColor colorFromHexCode:@"303943"];
    segmentView.segmentDelegate = self;
    [self addSubview:_segmentView = segmentView];
    [self bringSubviewToFront:segmentView];
    _segmentMenuView = segmentView;

    [self addSubview:self.contentScrollView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat y = self.contentScrollView.y;
    self.segmentMenuView.width = self.width;
    self.contentScrollView.y = self.segmentMenuView.bottom;
    self.contentScrollView.size = CGSizeMake(self.width, self.height - self.contentScrollView.y);
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.width * self.segmentViewCount, self.contentScrollView.height - 10);

    [self.contentScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.height = self.contentScrollView.height;
        obj.width = self.contentScrollView.width;
    }];

    if (y == 0) {
        [self.contentScrollView scrollToHorizontalPageIndex:self.segmentMenuView.currentIndex animated:NO];
        [self showTables];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    _segmentMenuView.scrollEnabled = scrollEnabled;
    self.contentScrollView.scrollEnabled = scrollEnabled;
}

- (void)reloadData
{
    if (self.isMultiplexing) {
        [self.visibleTableViews removeAllObjects];
        [self.reusableTableViews removeAllObjects];

        [self.visibleFooterViews removeAllObjects];
        [self.reusableFooterViews removeAllObjects];
    } else {
        [self.contentScrollView removeAllSubviews];
        [self.tableViews removeAllObjects];
    }
    self.segmentViewCount = 0;
    self.showIndex = -1;
    [self showTables];
}

- (void)setSegmentViewCount:(NSInteger)segmentViewCount
{
    _segmentViewCount = segmentViewCount;
    self.contentScrollView.contentSizeWidth = self.contentScrollView.width * _segmentViewCount;
}

#pragma mark -
#pragma mark :. UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            UIScrollView *oScrollView = (UIScrollView *)obj;
            oScrollView.scrollEnabled = NO;
        }
    }];

    [self.segmentView didBeginDraaWillBeginDragging:scrollView.contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
    // top 1 left 2 bottom 3  right 4;
    if (translatedPoint.x < 0)
        self.direction = 4;
    if (translatedPoint.x > 0)
        self.direction = 2;

    if (translatedPoint.y < 0)
        self.direction = 3;
    if (translatedPoint.y > 0)
        self.direction = 1;

    [self.segmentView didScrollViewDidScroll:scrollView];
    [self showTables];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.segmentView didScrollViewDidEndDecelerating:scrollView];

    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.segmentView didScrollViewDidEndDragging:scrollView willDecelerate:decelerate];

    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView
{
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            UIScrollView *oScrollView = (UIScrollView *)obj;
            oScrollView.scrollEnabled = YES;
        }
    }];
}

#pragma mark -
#pragma mark :. CCSegmentViewDelegate

- (void)didScrollSelectedIndex:(NSInteger)index
{
    if (self.contentScrollView.contentOffsetX != index * self.contentScrollView.width) {
        BOOL animated = YES;
        if (index > self.contentScrollView.currentPage && index - self.contentScrollView.currentPage > 1) {
            animated = NO;
        } else if (self.contentScrollView.currentPage > index && self.contentScrollView.currentPage - index > 1) {
            animated = NO;
        }

        if (index <= self.segmentViewCount - 1)
            [self.contentScrollView scrollToHorizontalPageIndex:index animated:animated];

        if ([self.delegate respondsToSelector:@selector(loadViewNearIndex:)]) {
            [self.delegate loadViewNearIndex:index];
        }
    }
}

#pragma mark -
#pragma mark :. handler

// 显示View
- (void)showTables
{
    if (!self.segmentViewCount) {
        if ([self.delegate respondsToSelector:@selector(numberOfSectionsInsSgmentView:)])
            self.segmentViewCount = [self.delegate numberOfSectionsInsSgmentView:self];

        if (self.segmentViewCount == 0) {
            self.segmentViewCount = 1;
        }
    }

    if (self.segmentViewCount == 1) {
        [self showTabeViewAtIndex:0];
        return;
    }

    CGRect visibleBounds = self.contentScrollView.bounds;
    int firstIndex = (int)floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastIndex = (int)floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= self.segmentViewCount) firstIndex = (int)self.segmentViewCount - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= self.segmentViewCount) lastIndex = (int)self.segmentViewCount - 1;

    if (self.isMultiplexing) {
        //回收不再显示的TableView
        NSInteger viewIndex;
        for (UIView *view in _visibleTableViews) {
            viewIndex = kSegmentViewIndex(view);
            if (viewIndex < firstIndex || viewIndex > lastIndex) {
                [_reusableTableViews addObject:view];
                [view removeFromSuperview];
            }
        }

        for (UIView *view in _visibleFooterViews) {
            viewIndex = kSegmentViewFooterIndex(view);
            if (viewIndex < firstIndex || viewIndex > lastIndex) {
                [_visibleFooterViews addObject:view];
                [view removeFromSuperview];
            }
        }

        [_visibleTableViews minusSet:_reusableTableViews];
        [_visibleFooterViews minusSet:_reusableFooterViews];
        while (_reusableTableViews.count > 2)
            [_reusableTableViews removeObject:[_reusableTableViews anyObject]];

        while (_reusableFooterViews.count > 2)
            [_reusableFooterViews removeObject:[_reusableFooterViews anyObject]];

        for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
            if (![self isShowingTableViewAtIndex:index])
                [self showTabeViewAtIndex:index];
        }
    } else {
        NSInteger index = lastIndex;
        if (self.direction == 2)
            index = firstIndex;
        [self showTabeViewAtIndex:index];
    }
}

#pragma mark 显示一个图片view
- (void)showTabeViewAtIndex:(NSUInteger)index
{
    if (!self.isMultiplexing) {
        if (self.showIndex == index)
            return;
        self.showIndex = index;
    }

    UIView *view, *footerView;
    if (self.isMultiplexing) {
        view = [self dequeueReusableTableView];
        footerView = [self dequeueReusableFooterView];
    } else if ([self isShowingTableViewAtIndex:index]) {
        view = [self dequeueReusableTableView:index];
    }

    if (!view) { // 添加新的图片view
        if ([self.delegate respondsToSelector:@selector(segmentView:cellForRowAtIndex:)])
            view = [self.delegate segmentView:self cellForRowAtIndex:index];

        if ([self.delegate respondsToSelector:@selector(segmentView:cellForFooterAtIndex:)])
            footerView = [self.delegate segmentView:self cellForFooterAtIndex:index];

        CCAssert(view, @"view is nil index ⤭ %zi ⤪", index);
    }
    // 调整当期页的frame
    CGRect bounds = _contentScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.origin.x = bounds.size.width * index;
    if (footerView) {
        photoViewFrame.size.height -= footerView.height;
        footerView.y = photoViewFrame.origin.y + photoViewFrame.size.height;
        if (footerView.width < bounds.size.width)
            footerView.width = bounds.size.width;
        footerView.tag = kSegmentViewFooterTagOffset + index;
    }
    view.frame = photoViewFrame;
    view.tag = kSegmentViewTagOffset + index;

    if (self.isMultiplexing) {
        [_visibleTableViews addObject:view];
        if (footerView)
            [_visibleFooterViews addObject:footerView];
    } else {
        if (![self.tableViews containsObject:view])
            [self.tableViews addObject:view];
    }
    [_contentScrollView addSubview:view];
    if (footerView)
        [_contentScrollView addSubview:footerView];
    _currentView = view;
    [self loadTableViewNearIndex:index];
}

- (void)loadTableViewNearIndex:(NSInteger)index
{
    UIView *view;
    if (self.isMultiplexing) {
        view = [_visibleTableViews anyObject];
        if (_visibleTableViews.count > 1)
            view = [self dequeueReusableTableView];
    } else if ([self isShowingTableViewAtIndex:index]) {
        view = [self dequeueReusableTableView:index];
    }

    if (!view)
        view = self.currentView;

    if ([self.delegate respondsToSelector:@selector(segmentView:willDisplayView:forRowAtIndex:)])
        [self.delegate segmentView:self willDisplayView:view forRowAtIndex:index];

    if ([self.delegate respondsToSelector:@selector(didSegmentMenuSelectedIndex:forRowAtIndex:)])
        [self.delegate didSegmentMenuSelectedIndex:view forRowAtIndex:index];

    if ([self.delegate respondsToSelector:@selector(loadViewNearIndex:)]) {
        [self.delegate loadViewNearIndex:index];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingTableViewAtIndex:(NSUInteger)index
{
    id tableViews = _visibleTableViews;
    if (!self.isMultiplexing)
        tableViews = self.tableViews;

    for (UIView *view in tableViews) {
        if (kSegmentViewIndex(view) == index)
            return YES;
    }
    return NO;
}

- (UIView *)dequeueReusableTableView
{
    UIView *tableView = [_reusableTableViews anyObject];
    if (tableView) {
        [_reusableTableViews removeObject:tableView];
    }
    return tableView;
}

- (UIView *)dequeueReusableFooterView
{
    UIView *footerView = [_reusableFooterViews anyObject];
    if (footerView) {
        [_reusableFooterViews removeObject:footerView];
    }
    return footerView;
}

- (UIView *)dequeueReusableTableView:(NSInteger)index
{
    UIView *view;
    for (UIView *itemView in self.tableViews) {
        if (kSegmentViewIndex(itemView) == index)
            view = itemView;
    }
    return view;
}

#pragma mark -
#pragma mark :. getter/setter

- (CCSegmentContentScrollView *)contentScrollView
{
    if (!_contentScrollView) {
        CCSegmentContentScrollView *contentScrollView = [CCSegmentContentScrollView new];
        contentScrollView.backgroundColor = [UIColor whiteColor];
        contentScrollView.directionalLockEnabled = YES;
        contentScrollView.bounces = NO;
        contentScrollView.delegate = self;
        contentScrollView.pagingEnabled = YES;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView = contentScrollView;
    }
    return _contentScrollView;
}

@end
