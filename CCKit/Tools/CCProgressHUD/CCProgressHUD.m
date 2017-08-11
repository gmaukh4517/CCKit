//
//  CCProgressHUD.m
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

#import "CCProgressHUD.h"
#import "MBProgressHUD.h"
#import "CCMacros.h"

@implementation CCProgressHUD

/**
 *  @brief  初始化弹出对象
 */
+ (MBProgressHUD *)initialization
{
    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = (MBProgressHUD *)[windowView viewWithTag:999999];
    if (!hud)
        hud = [self initHUD:windowView];
    
    return hud;
}

+ (MBProgressHUD *)initHUD:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithRed:33 / 255.0 green:33 / 255.0 blue:33 / 255.0 alpha:0.5];
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    hud.backgroundView.color = [UIColor clearColor];
    hud.contentColor = [UIColor whiteColor];
    hud.tag = 999999;
    return hud;
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view
{
    MBProgressHUD *hud;
    if (view) {
        hud = [self initHUD:view];
    } else
        hud = [self initialization];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)superView belowView:(UIView *)view
{
    MBProgressHUD *hud;
    if (view) {
        hud = [self initHUD:view];
    } else
        hud = [self initialization];
    hud.mode = MBProgressHUDModeText;
    [superView bringSubviewToFront:view];
}

+ (void)show:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initialization];
    hud.label.text = nil;
    hud.detailsLabel.text = detailsLabelText;
    [hud showAnimated:YES];
}

/**
 *  @brief 提示消息
 *
 *  @param detailsLabelText 消息内容
 */
+ (void)showMessages:(NSString *)detailsLabelText
{
    [self showMessages:nil DetailsLabelText:detailsLabelText];
}

/**
 *  @brief  提示消息
 *
 *  @param LabelText        标题内容
 *  @param detailsLabelText 详细内容
 */
+ (void)showMessages:(NSString *)LabelText
    DetailsLabelText:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initialization];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = LabelText;
    hud.detailsLabel.text = detailsLabelText;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2];
}

/**
 提示消息
 
 @param icon 提示图标
 @param message 提示消息
 */
+ (void)showMessageWithIcon:(UIImage *)iconImage
                    Message:(NSString *)message
{
    MBProgressHUD *hud = [self initialization];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.detailsLabel.text = message;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2];
}

/**
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 */
+ (void)showToastMessage:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initialization];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = nil;
    hud.detailsLabel.text = detailsLabelText;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2];
}

+ (void)showProgress:(NSString *)message view:(UIView *)view
{
    MBProgressHUD *hud;
    if (view) {
        hud = [self initHUD:view];
    } else
        hud = [self initialization];
    
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = message;
}

+ (void)setProgress:(float)progress view:(UIView *)view
{
    MBProgressHUD *hud;
    if (view) {
        hud = [MBProgressHUD HUDForView:view];
    } else {
        UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
        hud = (MBProgressHUD *)[windowView viewWithTag:999999];
    }
    
    hud.progress = progress;
}

#pragma mark :. Show & hide
/**
 *  @brief  预留导航栏位置
 *
 *  @param animated 动画
 */
+ (void)showWithCoveredNavigationBar:(BOOL)animated
{
    [self showWithCoveredNavigationBar:nil
                              Animated:animated];
}

/**
 *  @brief 预留导航栏并显示提示信息
 *
 *  @param labeText 提示信息
 *  @param animated 动画
 */
+ (void)showWithCoveredNavigationBar:(NSString *)labeText
                            Animated:(BOOL)animated
{
    MBProgressHUD *hud = [self initialization];
    hud.detailsLabel.text = labeText;
    hud.coveredNavigationBar = YES;
    [hud showAnimated:YES];
}

/**
 *  @brief  显弹窗
 *
 *  @param animated 动画
 */
+ (void)showAnimated:(BOOL)animated
{
    cc_dispatch_async_on_main_queue(^{
        [[self initialization] showAnimated:animated];
    });
}

+ (void)showNavigationBar:(BOOL)animated
{
    MBProgressHUD *hud = [self initialization];
    hud.coveredNavigationBar = NO;
    [hud showAnimated:animated];
}

/**
 显示弹窗
 
 @param title 提示消息
 */
+ (void)showWithTitle:(NSString *)title
{
    MBProgressHUD *hud = [self initialization];
    hud.label.text = title;
    [hud showAnimated:YES];
}

/**
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 */
+ (void)hideAnimated:(BOOL)animated
{
    [[self initialization] hideAnimated:animated];
}

+ (void)hideView:(UIView *)view
{
    if (view) {
        [MBProgressHUD hideHUDForView:view animated:YES];
    } else
        [self hideAnimated:YES];
}

/**
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 *  @param delay    时长
 */
+ (void)hideAnimated:(BOOL)animated
          afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(hideDelayed:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:delay];
}

+ (void)hideDelayed:(NSNumber *)animated
{
    [self hideAnimated:[animated boolValue]];
}
@end
