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
#import "config.h"

@implementation CCProgressHUD

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  初始化弹出对象
 */
+ (MBProgressHUD *)initialization
{
    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = (MBProgressHUD *)[windowView viewWithTag:999999];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:windowView animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor clearColor];
        hud.tag = 999999;
    }
    
    return hud;
}

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  初始化弹窗消息类型
 */
+ (MBProgressHUD *)initializationMessages
{
    MBProgressHUD *hud = [self initialization];
    hud.mode = MBProgressHUDModeText;
    //    HUD.labelFont = Font19And17(systemFontOfSize, 15);
    hud.label.textColor = [UIColor whiteColor];
    //    HUD.detailsLabelFont = Font19And17(systemFontOfSize, 15);
    hud.detailsLabel.textColor = [UIColor whiteColor];
    return hud;
}

/**
 *  @author CC, 16-03-21
 *
 *  @brief 提示消息
 *
 *  @param detailsLabelText 消息内容
 */
+ (void)showMessages:(NSString *)detailsLabelText
{
    [self showMessages:nil DetailsLabelText:detailsLabelText];
}

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  提示消息
 *
 *  @param LabelText        标题内容
 *  @param detailsLabelText 详细内容
 */
+ (void)showMessages:(NSString *)LabelText
    DetailsLabelText:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initializationMessages];
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
+ (void)showMessageWithIcon:(NSString *)icon
                    Message:(NSString *)message
{
    MBProgressHUD *hud = [self initializationMessages];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  底部提示
 *
 *  @param detailsLabelText 提示内容
 */
+ (void)showToastMessage:(NSString *)detailsLabelText
{
    MBProgressHUD *hud = [self initializationMessages];
    hud.label.text = nil;
    hud.detailsLabel.text = detailsLabelText;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2];
}


#pragma mark :. Show & hide
/**
 *  @author CC, 2016-01-08
 *
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
 *  @author CC, 16-03-07
 *
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
 *  @author CC, 2016-12-29
 *
 *  @brief  显弹窗
 *
 *  @param animated 动画
 */
+ (void)showAnimated:(BOOL)animated
{
    [[self initialization] showAnimated:animated];
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
 *  @author CC, 2016-12-29
 *
 *  @brief  隐藏弹窗
 *
 *  @param animated 动画
 */
+ (void)hideAnimated:(BOOL)animated
{
    [[self initialization] hideAnimated:animated];
}

/**
 *  @author CC, 2016-12-29
 *
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
