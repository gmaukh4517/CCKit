//
//  CCSegmentMenuView.h
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

#import <UIKit/UIKit.h>

@protocol CCSegmentMenuViewDelegate <NSObject>

@optional
- (void)didScrollSelectedIndex:(NSInteger)index;

@end

@interface CCSegmentMenuView : UIScrollView

@property (nonatomic, weak) id<CCSegmentMenuViewDelegate> segmentDelegate;
/** 当前选中下标 **/
@property (nonatomic, assign) NSInteger currentIndex;
/** 默认显示颜色 **/
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, copy) UIFont *titleFont;
/** 选中后默认显示颜色 **/
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, copy) UIFont *titleSelectedFont;
/** 底部线偏移 **/
@property (nonatomic, assign) NSInteger lineOffsetY;
/** 底部线高度 **/
@property (nonatomic, assign) CGFloat lineHeight;
/** 底部线宽度 **/
@property (nonatomic, assign) CGFloat lineWidth;
/** 是否显示滑块 **/
@property (nonatomic, assign) BOOL isSlider;
/** 是否铺满 **/
@property (nonatomic, assign) BOOL isFullof;
/** 是否铺满加分割线 **/
@property (nonatomic, assign) BOOL isFullofLine;
/** 是否显示虚线 **/
@property (nonatomic, assign) BOOL isLine;
/** 是否使用动画 **/
@property (nonatomic, assign) BOOL animation;

@property (nonatomic, assign) BOOL shadow;

@property (nonatomic, assign) BOOL isTitleLength;

- (void)setItems:(NSArray *)arr;

- (void)showBadgePointOnItemIndex:(NSInteger)index;

- (void)hideBadgePointOnItemIndex:(NSInteger)index;

/** 开始滚动 **/
- (void)didBeginDraaWillBeginDragging:(CGPoint)offset;

/** 滚动过程 **/
- (void)didScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)didScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)didScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

