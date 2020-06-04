//
//  CCViewControllerProtocolDelegate.h
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

#ifndef CCViewControllerProtocolDelegate_h
#define CCViewControllerProtocolDelegate_h

#import <UIKit/UIKit.h>

@protocol CCViewControllerProtocolDelegate <NSObject>
@optional

#pragma mark -
#pragma mark :. 类别管理器

/**
 *  @author CC, 16-03-14
 *
 *  @brief 所属类别视图模型
 */
- (Class)cc_classOfViewModel;

/**
 *  @author CC, 20-03-04
 *
 *  @brief 所属类别视图模型
 */
- (NSString *)cc_classNameViewModel;

/**
 *  @author CC, 16-03-14
 *
 *  @brief 所属类别视图管理器
 */
- (Class)cc_classOfViewManager;

/**
 *  @author CC, 20-03-04
 *
 *  @brief 所属类别视图管理器
 */
- (NSString *)cc_classNameViewManager;


#pragma mark -
#pragma mark :. 页面初始化函数

/**
 *  @author CC, 20-03-04
 *
 *  @brief  所属类别始化导航
 */
- (void)initNavigation;

/**
 *  @author CC, 20-03-04
 *
 *  @brief 所属类别初始换视图控件
 */
- (void)initControl;

/**
 *  @author CC, 20-03-04
 *
 *  @brief 所属类别初始化数据加载
 */
- (void)initLoadData;

@end


#endif /* CCViewControllerProtocolDelegate_h */
