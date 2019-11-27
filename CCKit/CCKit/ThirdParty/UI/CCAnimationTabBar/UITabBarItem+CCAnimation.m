//
//  UITabBarItem+CCAnimation.m
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

#import "UITabBarItem+CCAnimation.h"
#import <objc/runtime.h>

#define kDuration 0.5f
#define kAnimationKeyPathTranslationY @"transform.translation.y"
#define kAnimationKeyPathScale @"transform.scale"
#define kAnimationKeyPathRotation @"transform.rotation"
#define kAnimationKeyPathKeyFrame @"contents"
#define kAnimationKeyPathPositionY @"position.y"
#define kAnimationKeyPathOpacity @"opacity"

@implementation UITabBarItem (CCAnimation)

/// 创建CAKeyframeAnimation动画
CAKeyframeAnimation *createAnimation(NSString *keyPath, NSArray *values, CGFloat duration)
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.values = values;
    animation.duration = duration;
    animation.calculationMode = @"cubic";

    return animation;
}

/// 播放贞动画
void frameAnimation(UIImageView *icon, NSArray<CIImage *> *images)
{
    CAKeyframeAnimation *animation = createAnimation(kAnimationKeyPathKeyFrame, images, kDuration);
    animation.calculationMode = @"discrete";
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;

    [icon.layer addAnimation:animation forKey:nil];
}

#pragma mark -
#pragma mark :. CCTabBarItemAnimationProtocol

- (void)didSelectAnimationWhitTabBarButton:(nonnull UIView *)tabbarItem
{
    if (self.animationStyle == CCTabBarItemAnimationStyleElasticity) {
        if (!self.animation) {
            self.animation = createAnimation(kAnimationKeyPathScale, @[ @1.0, @0.85, @1.15, @0.95, @1.02, @1.0 ], kDuration);
        }
        [tabbarItem.layer addAnimation:self.animation forKey:nil];
    } else if (self.animationStyle == CCTabBarItemAnimationStyleGravityBounce) {
        if (!self.animation) {
            self.animation = createAnimation(kAnimationKeyPathTranslationY, @[ @0.0, @-4.15, @-7.26, @-9.34, @-10.37, @-9.34, @-7.26, @-4.15, @0.0, @2.0, @-2.9, @-4.94, @-6.11, @-6.42, @-5.86, @-4.44, @-2.16, @0.0 ], 0.9);
        }
        UIImageView *imageView = tabbarItemImageView(tabbarItem);
        [imageView.layer addAnimation:self.animation forKey:nil];
    } else if (self.animationStyle == CCTabBarItemAnimationStyleRotate) {
        UIImageView *imageView = tabbarItemImageView(tabbarItem);
        if (!self.animation) {
            CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:kAnimationKeyPathRotation];
            rotateAnimation.fromValue = @0.0;
            rotateAnimation.toValue = @(-M_PI * 2);
            rotateAnimation.duration = kDuration;
            self.animation = rotateAnimation;
        }
        [imageView.layer addAnimation:self.animation forKey:nil];
    } else if (self.animationStyle == CCTabBarItemAnimationStyleFrame) {
        frameAnimation(tabbarItemImageView(tabbarItem), self.images);
    } else if (self.animationStyle == CCTabBarItemAnimationStyleTransition) {
        if (self.direction <= 0) self.direction = 1;
        if (self.direction > 6) self.direction = 6;
        NSUInteger opts = [@[ @1, @2, @6, @7, @3, @4 ][ self.direction - 1 ] integerValue] << 20;
        [UIView transitionWithView:tabbarItemImageView(tabbarItem) duration:kDuration options:opts animations:nil completion:nil];
    }

    if (self.isBackgroundAnimation) {
    }
}

- (void)didDeselectAnimationWhitTabBarButton:(UIView *)tabbarItem
                             buttonImageView:(UIImageView *)imageView
                             buttonTextLabel:(UILabel *)textLabel
{
    if (self.animationStyle == CCTabBarItemAnimationStyleElasticity) {
    } else if (self.animationStyle == CCTabBarItemAnimationStyleGravityBounce) {
    } else if (self.animationStyle == CCTabBarItemAnimationStyleRotate) {
    } else if (self.animationStyle == CCTabBarItemAnimationStyleFrame) {
        frameAnimation(imageView, [[self.images reverseObjectEnumerator] allObjects]);
    } else if (self.animationStyle == CCTabBarItemAnimationStyleTransition) {
        if (self.isBackgroundAnimation) return;

        NSUInteger index = self.direction % 2 == 0 ? self.direction - 1 : self.direction + 1;
        NSUInteger opts = [@[ @1, @2, @6, @7, @3, @4 ][ index - 1 ] integerValue] << 20;
        [UIView transitionWithView:imageView duration:kDuration options:opts animations:nil completion:nil];
    }
}

UILabel *tabbarItemTextLabel(UIView *item)
{
    if ([item isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        if (@available(iOS 13.0, *)) {
            for (UIView *subView in item.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")])
                    return (UILabel *)subView;
            }
            return nil;
        }
        return [item valueForKeyPath:@"_label"];
    } else if ([item isKindOfClass:NSClassFromString(@"UIButton")]) {
        return [(UIButton *)item titleLabel];
    }
    return nil;
}

UIImageView *tabbarItemImageView(UIView *item)
{
    if ([item isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        if (@available(iOS 13.0, *)) {
            for (UIView *subView in item.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")])
                    return (UIImageView *)subView;
            }
            return nil;
        }
        return [item valueForKeyPath:@"_info"];
    } else if ([item isKindOfClass:NSClassFromString(@"UIButton")]) {
        return [(UIButton *)item imageView];
    }
    return nil;
}

#pragma mark -
#pragma mark :. Setter/Getter

- (void)setIsBackgroundAnimation:(BOOL)isBackgroundAnimation
{
    objc_setAssociatedObject(self, @selector(isBackgroundAnimation), @(isBackgroundAnimation), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isBackgroundAnimation
{
    return (BOOL)objc_getAssociatedObject(self, _cmd);
}

- (void)setAnimationStyle:(CCTabBarItemAnimationStyle)animationStyle
{
    objc_setAssociatedObject(self, @selector(animationStyle), @(animationStyle), OBJC_ASSOCIATION_RETAIN);
}

- (CCTabBarItemAnimationStyle)animationStyle
{
    return (CCTabBarItemAnimationStyle)[ objc_getAssociatedObject(self, _cmd) integerValue ];
}

- (void)setImages:(NSArray<CIImage *> *)images
{
    objc_setAssociatedObject(self, @selector(images), images, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray<CIImage *> *)images
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAnimation:(CAAnimation *)animation
{
    objc_setAssociatedObject(self, @selector(animation), animation, OBJC_ASSOCIATION_RETAIN);
}

- (CAAnimation *)animation
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDirection:(NSInteger)direction
{
    objc_setAssociatedObject(self, @selector(direction), @(direction), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)direction
{
    return (NSInteger)objc_getAssociatedObject(self, _cmd);
}

@end
