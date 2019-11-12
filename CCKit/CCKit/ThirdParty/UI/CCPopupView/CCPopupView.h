//
//  CCPopupView.h
//  CCKit
//
// Copyright (c) 2015 CC
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

typedef NS_ENUM(NSInteger, CCPopupType) {
    /// 左边弹出
    CCPopupTypeLeft = 0,
    /// 顶部弹出
    CCPopupTypeTop = 1,
    /// 底部弹出
    CCPopupTypeBottom = 2,
    /// 右边弹出
    CCPopupTypeRight = 3,
};

@interface CCPopupView : NSObject

/**
 *  @brief  弹出视图 (CCPopupTypeBottom)
 *
 *  @param view 视图
 */
+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point;
+ (void)showInView:(UIView *)view
     withIsPackage:(BOOL)isPackage;

/**
 *  @brief  弹出视图 (CCPopupTypeBottom)
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 */
+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point;

/**
 *  @brief  弹出视图 (CCPopupTypeBottom)
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 *  @param completeion    完成回调
 */
+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
       completeion:(void (^)(void))completeion;

/**
 弹出试图方式

 @param view 视图
 @param type 弹出位置
 */
+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type;

/**
 弹出试图方式

 @param view 视图
 @param superView 显示view层级
 @param point 偏移位置
 @param type 弹出位置
 */
+ (void)showInView:(UIView *)view
         superView:(UIView *)superView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type;

+ (void)showInView:(UIView *)view
         superView:(UIView *)superView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
        completion:(void (^)(void))completion;

+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
        completion:(void (^)(void))completion;

+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type;

+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
       completeion:(void (^)(void))completion;


/**
 弹出试图

 @param view 显示视图
  @param superView 显示父类视图
 @param backgroundView 背景试图
 @param point 偏移位置
 @param type 弹出类型
 @param animation 是否动画
 @param isPackage 点击背景是否消失
 @param completion 弹出回调
 */
+ (void)showInView:(UIView *)view
         superView:(UIView *)superView
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
         popupType:(CCPopupType)type
         animation:(BOOL)animation
     withIsPackage:(BOOL)isPackage
        completion:(void (^)(void))completion;

/** 隐藏 **/
+ (void)hideAnimation;

+ (void)hideAnimation:(BOOL)animation;

/**
 *  @brief  隐藏
 *
 *  @param completeion 完成回调
 */
+ (void)hideAnimation:(BOOL)animation
          completeion:(void (^)(void))completeion;

@end
