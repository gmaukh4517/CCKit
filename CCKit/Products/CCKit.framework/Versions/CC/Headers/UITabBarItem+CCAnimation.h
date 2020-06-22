//
//  UITabBarItem+CCAnimation.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CCTabBarItemAnimationStyle) {
    CCTabBarItemAnimationStyleNone = 0,
    // 弹性动画
    CCTabBarItemAnimationStyleElasticity,
    // 重力弹跳动画
    CCTabBarItemAnimationStyleGravityBounce,
    // 旋转动画
    CCTabBarItemAnimationStyleRotate,
    // 贞动画
    CCTabBarItemAnimationStyleFrame,
    // 转场动画
    CCTabBarItemAnimationStyleTransition,
};

@interface UITabBarItem (CCAnimation)

/// 背景动画，默认NO
@property (nonatomic, assign) BOOL isBackgroundAnimation;

@property (nonatomic, assign) CCTabBarItemAnimationStyle animationStyle;
// 播放动画图片
@property(nonatomic, strong) NSArray <CIImage *>*images;

@end

NS_ASSUME_NONNULL_END
