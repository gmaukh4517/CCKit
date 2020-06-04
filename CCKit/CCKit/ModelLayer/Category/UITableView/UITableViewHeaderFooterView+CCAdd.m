//
//  UITableViewHeaderFooterView+CCAdd.m
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

#import "UITableViewHeaderFooterView+CCAdd.h"
#import <objc/runtime.h>

@implementation UITableViewHeaderFooterView (CCAdd)

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

- (void)cc_layoutSubviews
{
    [self cc_layoutSubviews];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];

    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"_UITableViewHeaderFooterViewBackground"]){
            if (self.backgroundViewColor || self.backgroundImage) {
                UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:obj.bounds];
                backgroundImageView.backgroundColor = [UIColor clearColor];
                if (self.backgroundImage)
                    backgroundImageView.image = self.backgroundImage;

                if (self.backgroundViewColor)
                    backgroundImageView.backgroundColor = self.backgroundViewColor;

                [obj addSubview:backgroundImageView];
            }
        }
    }];
}

#pragma mark :. getset
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    objc_setAssociatedObject(self, @selector(backgroundImage), backgroundImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)backgroundImage
{
    return objc_getAssociatedObject(self, @selector(backgroundImage));
}

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    objc_setAssociatedObject(self, @selector(backgroundViewColor), backgroundViewColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)backgroundViewColor
{
    return objc_getAssociatedObject(self, @selector(backgroundViewColor));
}

- (void)setCc_dataSources:(id)cc_dataSources
{
    objc_setAssociatedObject(self, @selector(cc_dataSources), cc_dataSources, OBJC_ASSOCIATION_RETAIN);
}

- (id)cc_dataSources
{
    return objc_getAssociatedObject(self, @selector(cc_dataSources));
}

- (void)setCc_Section:(NSInteger)cc_Section
{
    objc_setAssociatedObject(self, @selector(cc_Section), [NSNumber numberWithInteger:cc_Section], OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)cc_Section
{
    return [objc_getAssociatedObject(self, @selector(cc_Section)) integerValue];
}

- (void)setCc_rowCount:(NSInteger)cc_rowCount
{
    objc_setAssociatedObject(self, @selector(cc_rowCount), [NSNumber numberWithInteger:cc_rowCount], OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)cc_rowCount
{
    return [objc_getAssociatedObject(self, @selector(cc_rowCount)) integerValue];
}

- (void)cc_headerFooterWillDisplayWithModel:(id)cModel
                                    section:(NSInteger)section
{
    // Rewrite this func in SubClass !
}

@end
