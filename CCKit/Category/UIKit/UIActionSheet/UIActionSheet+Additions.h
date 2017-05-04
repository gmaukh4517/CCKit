//
//  UIActionSheet+Additions.h
//  CCKit
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
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

@interface UIActionSheet (Additions) <UIAlertViewDelegate, UIActionSheetDelegate>

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  扩展属性
 *
 *  @since 1.0
 */
@property(nonatomic, strong) UIView *sheetBackgroundView;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  设置视图
 *
 *  @param views 试图
 */
- (id)initWithContentView:(UIView *)views;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  隐藏视图
 *
 *  @param index 下标
 */
- (void)hide:(NSInteger)index;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block返回结果
 *
 *  @param actionSheet 当前对象
 *  @param buttonIndex 选中下标
 */
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex;


/**
 Block返回结果
 
 @param completionHandler block
 */
- (void)config:(void (^)(NSInteger buttonIndex))completionHandler;

/**
 Block返回结果
 
 @param view 显示父类视图
 @param completionHandler block
 */
- (void)showInView:(UIView *)view
withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;


/**
 Block 返回结果
 
 @param view 显示父类视图
 @param completionHandler block
 */
- (void)showFromToolbar:(UIToolbar *)view
  withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;


/**
 Block 返回结果
 
 @param view 显示父类视图
 @param completionHandler block
 */
- (void)showFromTabBar:(UITabBar *)view
 withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;


/**
 block显示试图
 
 @param rect 显示位置
 @param view 显示父类视图
 @param animated 是否动画
 @param completionHandler block
 */
- (void)showFromRect:(CGRect)rect
              inView:(UIView *)view
            animated:(BOOL)animated
withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;


/**
 block 显示视图

 @param item time
 @param animated 是否动画
 @param completionHandler block
 */
- (void)showFromBarButtonItem:(UIBarButtonItem *)item
                     animated:(BOOL)animated
        withCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

@end
