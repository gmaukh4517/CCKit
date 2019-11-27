//
//  UINavigationBar+CCAdd.m
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

#import "CCMacroProperty.h"
#import "UINavigationBar+CCAdd.h"
#import <objc/runtime.h>

@implementation UINavigationBar (CCAdd)

static inline void AutomaticWritingSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], @selector(layoutSubviews), @selector(cc_layoutSubviews));
    });
}

#pragma mark -
#pragma mark :. Awesome

- (void)cc_layoutSubviews
{
    [self cc_layoutSubviews];
    if (iOS11Later) {
        self.layoutMargins = UIEdgeInsetsZero;
        for (UIView *view in self.subviews) {
            if ([NSStringFromClass(view.classForCoder) containsString:@"ContentView"]) {
                if (iOS13Later) {
                    UIEdgeInsets margins = view.layoutMargins;
                    view.frame = CGRectMake(-margins.left + 15, -margins.top, margins.left + margins.right + view.frame.size.width -  25, margins.top + margins.bottom + view.frame.size.height);
                } else {
                    view.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
                }
            }
        }
    }
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  设置背景颜色
 *
 *  @param backgroundColor 颜色
 */
- (void)setbarbackgroundView:(UIColor *)backgroundColor
{
    [self setNavigationBackground:0
                  backgroundColor:backgroundColor
                          isAlpha:YES];
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  设置背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setNeedsNavigationBackground:(CGFloat)alpha
{
    [self setNavigationBackground:alpha
                  backgroundColor:nil
                          isAlpha:YES];
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  侧滑设置背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setSlideNavigationBackground:(CGFloat)alpha
{
    [self setNavigationBackground:alpha
                  backgroundColor:nil
                          isAlpha:NO];
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  动态设置背景
 *
 *  @param alpha 透明度
 *  @param backgroundColor 颜色
 */
- (void)setNavigationBackground:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor isAlpha:(BOOL)isAlpha
{
    //将导航栏的子控件添加到数组当中,取首个子控件设置透明度(防止导航栏上存在非导航栏自带的控件)
    NSMutableArray *barSubviews = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (![view isMemberOfClass:[UIView class]])
            [barSubviews addObject:view];
    }

    if (alpha == 0 && backgroundColor) {
        const CGFloat *components = CGColorGetComponents(backgroundColor.CGColor);
        alpha = MAX(1, components[ 3 ] ?: 1);
    }

    Ivar backgroundOpacityVar = class_getInstanceVariable([UINavigationBar class], "__backgroundOpacity");
    if (backgroundOpacityVar)
        [self setValue:@(alpha) forKey:@"__backgroundOpacity"];

    UIView *barBackgroundView = [barSubviews firstObject];
    barBackgroundView.alpha = alpha;
    barBackgroundView.subviews.firstObject.alpha = !alpha;
    if (backgroundColor)
        barBackgroundView.backgroundColor = backgroundColor;

    if (isAlpha) {
        UINavigationController *superNav = (UINavigationController *)[self viewController];
        if (superNav && superNav.topViewController)
            objc_setAssociatedObject(superNav.topViewController, @"navigationBarAlpha", @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}


- (void)setTranslationY:(CGFloat)translationY
{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  设置要素透明度
 *
 *  @param alpha 透明度
 */
- (void)setNeedsNavigationTitle:(CGFloat)alpha
{
    NSMutableArray *barSubviews = [NSMutableArray array];
    if (@available(iOS 11.0, *)) {
        __block UIView *_UINavigationBarContentView;
        [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarContentView")])
                _UINavigationBarContentView = obj;
        }];

        for (UIView *view in _UINavigationBarContentView.subviews) {
            if (![view isMemberOfClass:NSClassFromString(@"_UIButtonBarButton")])
                [barSubviews addObject:view];
        }

    } else if (@available(iOS 9.0, *)) {
        for (UIView *view in self.subviews) {
            if (![view isMemberOfClass:[UIView class]] && ([view isKindOfClass:NSClassFromString(@"UINavigationItemView")] || [view isKindOfClass:NSClassFromString(@"UINavigationButton")])) {
                [barSubviews addObject:view];
            }
        }
    }

    for (UIView *view in barSubviews)
        view.alpha = alpha;
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  重置
 */
- (void)reset
{
    [self setNeedsNavigationBackground:1];
}

- (UIViewController *)viewController
{
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}


@end
