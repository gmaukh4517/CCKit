//
//  CCSegmentView.h
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

#import <UIKit/UIKit.h>

@class CCSegmentMenuView, CCSegmentView;

@protocol CCSegmentViewDelegate <NSObject>

/**
 显示View数量
 
 @param segmentView segmentView
 @return 数量
 */
- (NSInteger)numberOfSectionsInsSgmentView:(CCSegmentView *)segmentView;

/**
 创建显示View
 
 @param segmentView segmentView
 @param index 下标位置
 @return View
 */
- (UIView *)segmentView:(CCSegmentView *)segmentView cellForRowAtIndex:(NSInteger)index;

@optional

/**
 多重Cell获取标识符
 
 @param segmentView segmentView
 @param index 下标位置
 @return cell 标识符
 */
- (NSString *)segmentView:(CCSegmentView *)segmentView cellMultipleIdentifier:(NSInteger)index;

/**
 创建Cell 底部显示View
 
 @param segmentView segmentView
 @param index 下标位置
 @return View
 */
- (UIView *)segmentView:(CCSegmentView *)segmentView cellForFooterAtIndex:(NSInteger)index;

/**
 显示加载数据
 
 @param segmentView segmentView
 @param view 当前View
 @param index 下标位置
 */
- (void)segmentView:(CCSegmentView *)segmentView willDisplayView:(UIView *)view forRowAtIndex:(NSInteger)index;

/**
 选中实现
 
 @param index 下标位置
 */
- (void)didSegmentMenuSelectedIndex:(UIView *)view forRowAtIndex:(NSInteger)index;

/**
 当前显示View
 
 @param view View
 */
- (void)didShowSegmentVie:(UIView *)view;

/**
 加载当前索引附近视图
 
 @param index 当前缩影
 */
- (void)loadViewNearIndex:(NSInteger)index;

@end

@interface CCSegmentView : UIView

@property (nonatomic, readonly, strong) CCSegmentMenuView *segmentMenuView;

@property (nonatomic, assign) NSInteger segmentViewCount;

@property (nonatomic, assign) BOOL scrollEnabled;

/**
 是否复用 默认开启
 */
@property (nonatomic, assign) BOOL isMultiplexing;

@property (nonatomic, weak) id<CCSegmentViewDelegate> delegate;

- (void)reloadData;

@end
