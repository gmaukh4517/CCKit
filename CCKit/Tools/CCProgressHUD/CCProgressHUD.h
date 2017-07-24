//
//  CCProgressHUD.h
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

#import <Foundation/Foundation.h>

@interface CCProgressHUD : NSObject

/**
 *  @author CC, 16-03-21
 *
 *  @brief 提示消息
 *
 *  @param detailsLabelText 消息内容
 */
+ (void)showMessages:(NSString *)detailsLabelText;

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  提示消息
 *
 *  @param LabelText        标题内容
 *  @param detailsLabelText 详细内容
 */
+ (void)showMessages:(NSString *)LabelText
   DetailsLabelText:(NSString *)detailsLabelText;

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 */
+ (void)showToastMessage:(NSString *)detailsLabelText;

/**
 提示消息
 
 @param icon 提示图标
 @param message 提示消息
 */
+ (void)showMessageWithIcon:(NSString *)icon
                    Message:(NSString *)message;


#pragma mark :. Show & hide

/**
 *  @author CC, 2016-01-08
 *
 *  @brief  预留导航栏位置
 *
 *  @param animated 动画
 */
+ (void)showWithCoveredNavigationBar:(BOOL)animated;

/**
 *  @author CC, 16-03-07
 *
 *  @brief 预留导航栏并显示提示信息
 *
 *  @param labeText 提示信息
 *  @param animated 动画
 */
+ (void)showWithCoveredNavigationBar:(NSString *)labeText
                            Animated:(BOOL)animated;

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  显弹窗
 *
 *  @param animated 动画
 */
+ (void)showAnimated:(BOOL)animated;
+ (void)showNavigationBar:(BOOL)animated;

/**
 显示弹窗
 
 @param title 提示消息
 */
+ (void)showWithTitle:(NSString *)title;

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 */
+ (void)hideAnimated:(BOOL)animated;

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 *  @param delay    时长
 */
+ (void)hideAnimated:(BOOL)animated
  afterDelay:(NSTimeInterval)delay;


@end
