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

#import "UINavigationBar+CCAdd.h"
#import <objc/runtime.h>
#import "CCMacroProperty.h"

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
                view.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
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
- (void)setElementsAlpha:(CGFloat)alpha
{
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];

    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];

    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
            *stop = YES;
        }
    }];
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
