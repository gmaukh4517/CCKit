//
//  CCPopupView.m
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

#import "CCPopupView.h"
#import "UIView+CCHierarchy.h"

#define kCCDuration 0.3
#define kSemiModalModalViewTag 10003
#define kSemiModalScreenshotTag 10002
#import <objc/runtime.h>

@implementation CCPopupView

/** 添加视图对象 **/
+ (UIWindow *)parentTarget
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)]) {
        UIWindow *window = [app.delegate window];
        if (!window)
            window = [app keyWindow];
        return window;
    } else
        return [app keyWindow];
}

/**
 *  @brief  弹出视图
 *
 *  @param view 视图
 */
+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
{
    [self showInView:view
        backgroundView:nil
               atPoint:point];
}

+ (void)showInView:(UIView *)view
     withIsPackage:(BOOL)isPackage
{
    [self showInView:view
             superView:nil
        backgroundView:nil
               atPoint:CGPointZero
             popupType:CCPopupTypeBottom
             animation:YES
         withIsPackage:NO
            completion:nil];
}

/**
 *  @brief  弹出视图
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 */
+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
{
    [self showInView:view
        backgroundView:backgroundView
               atPoint:point
           completeion:nil];
}

/**
 *  @brief  弹出视图
 *
 *  @param view           视图
 *  @param backgroundView 背景视图
 *  @param completeion    完成回调
 */
+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
       completeion:(void (^)(void))completeion
{
    [self showInView:view
             superView:nil
        backgroundView:backgroundView
               atPoint:point
             popupType:CCPopupTypeBottom
             animation:YES
         withIsPackage:YES
            completion:completeion];
}

/**
 弹出试图方式

 @param view 视图
 @param type 弹出位置
 */
+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
{
    [self showInView:view
        backgroundView:nil
               atPoint:point
             PopupType:type];
}

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
         PopupType:(CCPopupType)type
{
    [self showInView:view
             superView:superView
        backgroundView:nil
               atPoint:point
             popupType:type
             animation:YES
         withIsPackage:YES
            completion:nil];
}

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
         PopupType:(CCPopupType)type
        completion:(void (^)(void))completion
{
    [self showInView:view
             superView:superView
        backgroundView:nil
               atPoint:point
             popupType:type
             animation:YES
         withIsPackage:YES
            completion:completion];
}

+ (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
        completion:(void (^)(void))completion
{
    [self showInView:view
             superView:nil
        backgroundView:nil
               atPoint:point
             popupType:type
             animation:YES
         withIsPackage:YES
            completion:completion];
}

+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
{
    [self showInView:view
        backgroundView:backgroundView
               atPoint:point
             PopupType:type
           completeion:nil];
}

+ (void)showInView:(UIView *)view
    backgroundView:(UIView *)backgroundView
           atPoint:(CGPoint)point
         PopupType:(CCPopupType)type
       completeion:(void (^)(void))completion
{
    [self showInView:view
             superView:nil
        backgroundView:backgroundView
               atPoint:point
             popupType:type
             animation:YES
         withIsPackage:YES
            completion:completion];
}

/**
 弹出试图

 @param view 显示试图
 @param superView 显示父类视图
 @param backgroundView 背景视图
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
        completion:(void (^)(void))completion
{
    UIView *targetView = superView;
    if (!targetView)
        targetView = [self parentTarget];

    if (![targetView.subviews containsObject:view]) {
        CGFloat semiViewHeight = view.frame.size.height;
        CGRect vf = targetView.bounds;

        CGRect semiViewFrame;
        CGRect overlayFrame;
        switch (type) {
            case CCPopupTypeTop: {
                semiViewFrame = CGRectMake(point.x, point.y, view.frame.size.width - point.x, semiViewHeight);
                overlayFrame = CGRectMake(point.x, semiViewHeight, vf.size.width - point.x, vf.size.height - semiViewHeight - point.y);
                view.frame = CGRectOffset(semiViewFrame, point.x, -(semiViewHeight + point.y));
            } break;
            case CCPopupTypeLeft: {
                semiViewFrame = CGRectMake(point.x, point.y, view.frame.size.width - point.x, vf.size.height - point.y);
                overlayFrame = CGRectMake(view.frame.size.width + point.x, point.y, vf.size.width - view.frame.size.width - point.x, vf.size.height - point.y);
                view.frame = CGRectOffset(semiViewFrame, -(view.frame.size.width + point.x), point.y);
            } break;
            case CCPopupTypeBottom: {
                semiViewFrame = CGRectMake(point.x, vf.size.height - semiViewHeight - point.y, vf.size.width - point.x, semiViewHeight);
                overlayFrame = CGRectMake(point.x, point.y, vf.size.width - point.x, vf.size.height - semiViewHeight - point.y);
                view.frame = CGRectOffset(semiViewFrame, point.x, +(semiViewHeight + point.y));
            } break;
            case CCPopupTypeRight: {
                semiViewFrame = CGRectMake(vf.size.width - view.frame.size.width - point.x, point.y, view.frame.size.width - point.x, vf.size.height - point.y);
                overlayFrame = CGRectMake(point.x, point.y, vf.size.width - view.frame.size.width - point.x, vf.size.height - point.y);
                view.frame = CGRectOffset(semiViewFrame, vf.size.width - point.x, point.y);
            } break;
            default:
                break;
        }

        UIView *overlay = [[UIView alloc] init];
        overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        if (backgroundView)
            overlay = backgroundView;

        overlay.frame = CGRectMake(point.x, point.y, targetView.frame.size.width - point.x, targetView.frame.size.height - point.y);

        overlay.userInteractionEnabled = YES;
        overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlay.tag = kSemiModalScreenshotTag;
        overlay.alpha = 0;
        [targetView addSubview:overlay];

        if (isPackage) {
            UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [dismissButton addTarget:self action:@selector(dismissButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            dismissButton.backgroundColor = [UIColor clearColor];
            dismissButton.selected = animation;
            dismissButton.tag = type;
            dismissButton.frame = overlayFrame;
            [overlay addSubview:dismissButton];

            if (completion)
                objc_setAssociatedObject(dismissButton, @"dismissButtonBlock", completion, OBJC_ASSOCIATION_RETAIN);
        }

        view.tag = kSemiModalModalViewTag;
        [targetView addSubview:view];
        if (type != CCPopupTypeBottom) {
            if ([targetView isKindOfClass:[UIWindow class]])
                ((UIWindow *)targetView).windowLevel = UIWindowLevelAlert;
            else
                [targetView bringSubviewToFront:view];
        }

        [UIView animateWithDuration:kCCDuration
                         animations:^{
                             view.frame = semiViewFrame;
                             overlay.alpha = 1;
                         }];

        if (CCPopupTypeBottom) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(globalKeyboardHide:)];
            tapGestureRecognizer.cancelsTouchesInView = NO;
            [view addGestureRecognizer:tapGestureRecognizer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        }
    }
}

+ (void)dismissButtonClick:(UIButton *)sender
{
    void (^dismissButtonBlock)(void) = objc_getAssociatedObject(sender, @"dismissButtonBlock");
    if (dismissButtonBlock) {
        [self hideAnimation:sender.selected completeion:dismissButtonBlock];
    } else {
        [self hideAnimation:sender.selected];
    }
}

+ (void)globalKeyboardHide:(UITapGestureRecognizer *)tap
{
    NSArray *textFields = [tap.view deepResponderViews];
    for (UIView *view in textFields) {
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            [textField resignFirstResponder];
        }
    }
    [tap.view endEditing:YES];
}

#pragma mark -
#pragma mark :. UIKeyboad Notification methods
+ (void)keyboardWillShow:(NSNotification *)aNotification
{
    CGRect kbFrame = [[aNotification userInfo][ UIKeyboardFrameEndUserInfoKey ] CGRectValue];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGRect intersectRect = CGRectIntersection(kbFrame, screenSize);

    UIWindow *target = [self parentTarget];
    UIView *modal = [target viewWithTag:kSemiModalModalViewTag];
    [UIView animateWithDuration:kCCDuration
                     animations:^{
                         CGRect frame = modal.frame;
                         frame.origin.y -= intersectRect.size.height;
                         modal.frame = frame;
                     }];
}

+ (void)keyboardWillHide:(NSNotification *)aNotification
{
    UIWindow *target = [self parentTarget];
    UIView *modal = [target viewWithTag:kSemiModalModalViewTag];
    [UIView animateWithDuration:kCCDuration
                     animations:^{
                         CGRect frame = modal.frame;
                         frame.origin.y = target.frame.size.height - modal.frame.size.height;
                         modal.frame = frame;
                     }];
}

/** 隐藏 **/
+ (void)hideAnimation
{
    [self hideAnimation:YES
            completeion:nil];
}

+ (void)hideAnimation:(BOOL)animation
{
    [self hideAnimation:animation
            completeion:nil];
}

/**
 *  @brief  隐藏
 *
 *  @param completeion 完成回调
 */
+ (void)hideAnimation:(BOOL)animation
          completeion:(void (^)(void))completion
{
    UIWindow *target = [self parentTarget];
    UIView *modal = [target viewWithTag:kSemiModalModalViewTag];
    UIView *overlay = [target viewWithTag:kSemiModalScreenshotTag];
    if (animation) {
        [UIView animateWithDuration:kCCDuration
            animations:^{
                [self animationPosition];
                overlay.alpha -= 0.9;
            }
            completion:^(BOOL finished) {
                [overlay removeFromSuperview];
                [modal removeFromSuperview];
                if (completion) {
                    dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        completion();
                    });
                }
            }];
    } else {
        [self animationPosition];
        [overlay removeFromSuperview];
        [modal removeFromSuperview];

        if (completion) {
            dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }
}

+ (void)animationPosition
{
    UIWindow *target = [self parentTarget];
    UIView *modal = [target viewWithTag:kSemiModalModalViewTag];
    CCPopupType type = [[target viewWithTag:kSemiModalScreenshotTag].subviews firstObject].tag;
    target.windowLevel = UIWindowLevelNormal;
    CGRect frame = modal.frame;
    switch (type) {
        case CCPopupTypeTop:
            frame.origin.y = -frame.size.height;
            break;
        case CCPopupTypeLeft:
            frame.origin.x -= frame.size.width;
            break;
        case CCPopupTypeBottom:
            frame.origin.y = target.frame.size.height;
            break;
        case CCPopupTypeRight:
            frame.origin.x = target.frame.size.width;
            break;
        default:
            break;
    }
    modal.frame = frame;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [modal removeGestureRecognizer:modal.gestureRecognizers.lastObject];
}

@end
