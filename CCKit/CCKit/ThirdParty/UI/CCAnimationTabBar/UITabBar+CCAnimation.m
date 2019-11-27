//
//  UITabBar+CCAnimation.m
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

#import "NSObject+CCAdd.h"
#import "UITabBar+CCAnimation.h"
#import "UITabBarItem+CCAnimation.h"
#import <objc/runtime.h>


@implementation UITabBar (CCAnimation)

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
        AutomaticWritingSwizzleSelector([self class], @selector(setSelectedItem:), @selector(cc_setSelectedItem:));
    });
}

- (void)didAddSubview:(UIView *)subview
{
    if ([self isKindOfClass:[UITabBar class]]) {
        if (self.itemViews == nil) {
            self.itemViews = @[];
            self.selectedIndex = 0;
        }
        if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {// || // 原生
//            [subview isKindOfClass:NSClassFromString(@"UIButton")]) {       // 自定义Button
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.itemViews];
            [temp addObject:subview];
            self.itemViews = temp;
        }
    }

    // 使用方法交换时出现错误，用此方法替代
    SEL sel = NSSelectorFromString(@"cc_didAddSubview:");
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:subview afterDelay:0];
    }
}

- (void)cc_setSelectedItem:(UITabBarItem *)selectedItem
{
    NSUInteger index = [self.items indexOfObject:selectedItem];
    NSUInteger previousIndex = self.selectedIndex;

    if (previousIndex != index && self.items.count > index) {
        UITabBarItem *deselectItem = self.items[ previousIndex ];
        if (deselectItem.animationStyle != CCTabBarItemAnimationStyleNone) // 撤销选中动画
            [deselectItem performSelectors:@"didDeselectAnimationWhitTabBarButton:"
                                withObject:self.itemViews[ previousIndex ], nil];


        UITabBarItem *selectItem = self.items[ index ];
        if (selectItem.animationStyle != CCTabBarItemAnimationStyleNone) // 选中动画
            [selectItem performSelectors:@"didSelectAnimationWhitTabBarButton:"
                              withObject:self.itemViews[ index ], nil];

        self.selectedIndex = index;
    }
    [self cc_setSelectedItem:selectedItem];
}

- (void)setItemViews:(NSArray *)itemViews
{
    objc_setAssociatedObject(self, @selector(itemViews), itemViews, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)itemViews
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    objc_setAssociatedObject(self, @selector(selectedIndex), @(selectedIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)selectedIndex
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
