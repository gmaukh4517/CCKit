//
//  UINavigationController+CCAdd.m
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
#import "UINavigationController+CCAdd.h"
#import "UIViewController+CCAdd.h"
#import <objc/runtime.h>

@interface _CCFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _CCFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1)
        return NO;

    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.cc_interactivePopDisabled) {
        return NO;
    }

    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.cc_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance == 0)
        maxAllowedInitialDistance = 40;

    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance)
        return NO;

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue])
        return NO;

    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0)
        return NO;

    self.navigationController.cc_grTransitioning = YES;

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return self.navigationController.viewControllers.count > 1;
}

@end

@implementation UINavigationController (CCAdd)

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
        AutomaticWritingSwizzleSelector([self class], @selector(pushViewController:animated:), @selector(cc_pushViewController:animated:));
        AutomaticWritingSwizzleSelector([self class], NSSelectorFromString(@"_updateInteractiveTransition:"), @selector(cc_updateInteractiveTransition:));
        AutomaticWritingSwizzleSelector([self class], @selector(popViewControllerAnimated:), @selector(cc_popViewControllerAnimated:));
    });
}

- (void)cc_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count)
        viewController.hidesBottomBarWhenPushed = YES;
    objc_setAssociatedObject(viewController, @"navigationBarAlpha", @(1), OBJC_ASSOCIATION_COPY_NONATOMIC);


    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.cc_fullscreenPopGestureRecognizer]) {
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.cc_fullscreenPopGestureRecognizer];

        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.cc_fullscreenPopGestureRecognizer.delegate = self.cc_popGestureRecognizerDelegate;
        [self.cc_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];

        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }

    // Handle perferred navigation bar appearance.
    [self cc_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController animated:animated];

    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
        [[windowView viewWithTag:999999] removeFromSuperview];
        [self cc_pushViewController:viewController animated:animated];
    }
}

#pragma mark :. 转场效果
- (void)cc_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController animated:(BOOL)animated
{
    if (!self.cc_viewControllerBasedNavigationBarAppearanceEnabled || !self.viewControllers.count)
        return;

    id fromVCAlpha = objc_getAssociatedObject(self.topViewController, @"navigationBarAlpha");
    CGFloat fromAlpha = 1;
    if (fromVCAlpha)
        fromAlpha = [fromVCAlpha floatValue];

    id toVCAlpha = objc_getAssociatedObject(appearingViewController, @"navigationBarAlpha");
    CGFloat toAlpha = 1;
    if (toVCAlpha)
        toAlpha = [toVCAlpha floatValue];

    if (fromAlpha == 0 && toAlpha == 0 && self.viewControllers.count) {
        [self.navigationBar setSlideNavigationBackground:0];
        self.topViewController.navigationBarView.hidden = YES;
        appearingViewController.navigationBarView.hidden = YES;
    } else if (fromAlpha == 0 && toAlpha == 1 && self.viewControllers.count) {
        appearingViewController.navigationBarView.hidden = NO;
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            CGFloat alpha = [objc_getAssociatedObject(appearingViewController, @"navigationBarAlpha") floatValue];
            if (toAlpha == alpha)
                [self.navigationBar setSlideNavigationBackground:1];
            appearingViewController.navigationBarView.hidden = YES;
        });

    } else if (fromAlpha == 1 && toAlpha == 0 && self.viewControllers.count) {
        self.topViewController.navigationBarView.hidden = NO;
        [self.navigationBar setSlideNavigationBackground:0];
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            self.topViewController.navigationBarView.hidden = YES;
        });
    } else if (fromAlpha == 1 && toAlpha == 1 && self.viewControllers.count) {
        self.topViewController.navigationBarView.hidden = NO;
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            self.topViewController.navigationBarView.hidden = YES;
        });
    } else if (fromAlpha > 0 && fromAlpha < 1 && toAlpha == 1 && self.viewControllers.count) {
        [self.navigationBar setSlideNavigationBackground:fromAlpha];
        appearingViewController.navigationBarView.hidden = NO;
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            [self.navigationBar setSlideNavigationBackground:toAlpha];
            appearingViewController.navigationBarView.hidden = YES;
        });
    }

    __weak typeof(self) weakSelf = self;
    _CCViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
            [strongSelf setNavigationBarHidden:viewController.cc_prefersNavigationBarHidden animated:animated];
    };

    // Setup will appear inject block to appearing view controller.
    // Setup disappearing view controller as well, because not every view controller is added into
    // stack by pushing, maybe by "-setViewControllers:".
    appearingViewController.cc_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.cc_willAppearInjectBlock) {
        disappearingViewController.cc_willAppearInjectBlock = block;
    }
}

- (_CCFullscreenPopGestureRecognizerDelegate *)cc_popGestureRecognizerDelegate
{
    _CCFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);

    if (!delegate) {
        delegate = [[_CCFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;

        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)cc_fullscreenPopGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);

    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;

        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

- (BOOL)cc_viewControllerBasedNavigationBarAppearanceEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.cc_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setCc_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled
{
    SEL key = @selector(cc_viewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
#pragma mark :. Navigation Alpha

- (void)cc_updateInteractiveTransition:(CGFloat)percentComplete
{
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator != nil) {
            //            [self viewcontrollerOver: [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey] fromViewController:[coordinator viewControllerForKey:UITransitionContextToViewControllerKey]];
            UIViewController *fromViewController = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            id fromVCAlpha = objc_getAssociatedObject(fromViewController, @"navigationBarAlpha");
            CGFloat fromAlpha = 1;
            if (fromVCAlpha)
                fromAlpha = [fromVCAlpha floatValue];

            UIViewController *toViewController = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            id toVCAlpha = objc_getAssociatedObject(toViewController, @"navigationBarAlpha");
            CGFloat toAlpha = 1;
            if (toVCAlpha)
                toAlpha = [toVCAlpha floatValue];

            CGFloat newAlpha = fromAlpha + ((toAlpha - fromAlpha) * percentComplete);
            if (toAlpha == 0 && fromAlpha == 0) {
                [self.navigationBar setSlideNavigationBackground:0];
                toViewController.navigationBarView.hidden = YES;
                fromViewController.navigationBarView.hidden = YES;
            } else if (toAlpha == 0 && fromAlpha == 1) {
                fromViewController.navigationBarView.hidden = NO;
                [self.navigationBar setSlideNavigationBackground:0];
            } else if (toAlpha == 1 && fromAlpha == 0) {
                [self.navigationBar setSlideNavigationBackground:0];
                toViewController.navigationBarView.hidden = NO;
            } else if (toAlpha == 1 && fromAlpha == 1) {
                toViewController.navigationBarView.hidden = YES;
                fromViewController.navigationBarView.hidden = YES;
                [self.navigationBar setSlideNavigationBackground:1];
            } else if (fromAlpha == 1 && toAlpha > 0 && toAlpha < 1) {
                [self.navigationBar setSlideNavigationBackground:newAlpha];
                if (fromViewController.navigationBarView.hidden)
                    fromViewController.navigationBarView.hidden = NO;
            } else if (fromAlpha == 1 && toAlpha == 0 && fromViewController.navigationBarView.hidden) {
                fromViewController.navigationBarView.hidden = NO;
            }
        }
    }

    [self cc_updateInteractiveTransition:percentComplete];
}

- (UIViewController *)cc_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *popVc = [self cc_popViewControllerAnimated:animated];
    if (self.viewControllers.count <= 0)
        return popVc;

    UIViewController *topVC = [self.viewControllers lastObject];
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator != nil) {
            if ([[UIDevice currentDevice].systemVersion intValue] >= 10) { //适配iOS10
                [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [self dealNavBarChangeAction:context];
                }];
            } else {
                [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                    [self dealNavBarChangeAction:context];
                }];
            }
            if (!self.cc_grTransitioning)
                [self dealNavBarChangeAction:coordinator];
        }
    }
    return popVc;
}

- (void)dealNavBarChangeAction:(id<UIViewControllerTransitionCoordinatorContext>)context
{
    if ([context isCancelled]) { // 取消了(还在当前页面)
        CGFloat animdDuration = [context transitionDuration] * [context percentComplete];
        UIViewController *fromViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        id fromAlpha = objc_getAssociatedObject(fromViewController, @"navigationBarAlpha");
        CGFloat fromVCAlpha = 1;
        if (fromAlpha)
            fromVCAlpha = [fromAlpha floatValue];

        [UIView animateWithDuration:animdDuration
                         animations:^{
                             [self.navigationBar setSlideNavigationBackground:fromVCAlpha];
                         }];
    } else { // 自动完成(pop到上一个界面了)
        [self viewcontrollerOver:[context viewControllerForKey:UITransitionContextToViewControllerKey] fromViewController:[context viewControllerForKey:UITransitionContextFromViewControllerKey]];
    };
    self.cc_grTransitioning = NO;
}

- (void)viewcontrollerOver:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController
{
    id toVCAlpha = objc_getAssociatedObject(toViewController, @"navigationBarAlpha");
    CGFloat toAlpha = 1;
    if (toVCAlpha)
        toAlpha = [toVCAlpha floatValue];

    id fromVCAlpha = objc_getAssociatedObject(fromViewController, @"navigationBarAlpha");
    CGFloat fromAlpha = 1;
    if (fromVCAlpha)
        fromAlpha = [fromVCAlpha floatValue];

    if (toAlpha == 0 && fromAlpha == 0) {
        [self.navigationBar setSlideNavigationBackground:0];
        toViewController.navigationBarView.hidden = YES;
        fromViewController.navigationBarView.hidden = YES;
    } else if (toAlpha == 0 && fromAlpha == 1) {
        fromViewController.navigationBarView.hidden = NO;
        [self.navigationBar setSlideNavigationBackground:0];
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            fromViewController.navigationBarView.hidden = YES;
        });
    } else if (toAlpha == 1 && fromAlpha == 0) {
        UIColor *backgroundColor = self.navigationBar.barTintColor;
        [self.navigationBar setSlideNavigationBackground:0];
        toViewController.navigationBarView.hidden = NO;
        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            toViewController.navigationBarView.backgroundColor = self.navigationBar.barTintColor;
        });

        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
            toViewController.navigationBarView.hidden = YES;
            toViewController.navigationBarView.backgroundColor = backgroundColor;
            [self.navigationBar setSlideNavigationBackground:1];
        });
    } else if (toAlpha == 1 && fromAlpha == 1) {
        toViewController.navigationBarView.hidden = YES;
        fromViewController.navigationBarView.hidden = YES;
        [self.navigationBar setSlideNavigationBackground:1];
    }
}

- (BOOL)cc_isGrTransitioning
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCc_grTransitioning:(BOOL)cc_grTransitioning
{
    objc_setAssociatedObject(self, @selector(cc_isGrTransitioning), @(cc_grTransitioning), OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark -
#pragma mark :. Handle
- (void)pushViewController:(UIViewController *)controller withTransition:(UIViewAnimationTransition)transition
{
    [UIView beginAnimations:nil context:NULL];
    [self pushViewController:controller animated:NO];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:transition forView:self.view cache:YES];
    [UIView commitAnimations];
}

- (UIViewController *)popViewControllerWithTransition:(UIViewAnimationTransition)transition
{
    [UIView beginAnimations:nil context:NULL];
    UIViewController *controller = [self popViewControllerAnimated:NO];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:transition forView:self.view cache:YES];
    [UIView commitAnimations];
    return controller;
}

/**
 *  @brief  寻找Navigation中的某个viewcontroler对象
 *
 *  @param className viewcontroler名称
 *
 *  @return viewcontroler对象
 */
- (id)findViewController:(NSString *)className
{
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }

    return nil;
}
/**
 *  @brief  判断是否只有一个RootViewController
 *
 *  @return 是否只有一个RootViewController
 */
- (BOOL)isOnlyContainRootViewController
{
    if (self.viewControllers &&
        self.viewControllers.count == 1) {
        return YES;
    }
    return NO;
}
/**
 *  @brief  RootViewController
 *
 *  @return RootViewController
 */
- (UIViewController *)rootViewController
{
    if (self.viewControllers && [self.viewControllers count] > 0) {
        return [self.viewControllers firstObject];
    }
    return nil;
}
/**
 *  @brief  返回指定的viewcontroler
 *
 *  @param className 指定viewcontroler类名
 *  @param animated  是否动画
 *
 *  @return pop之后的viewcontrolers
 */
- (NSArray *)popToViewControllerWithClassName:(NSString *)className
                                     animated:(BOOL)animated;
{
    return [self popToViewController:[self findViewController:className] animated:YES];
}
/**
 *  @brief  pop n层
 *
 *  @param level  n层
 *  @param animated  是否动画
 *
 *  @return pop之后的viewcontrolers
 */
- (NSArray *)popToViewControllerWithLevel:(NSInteger)level
                                 animated:(BOOL)animated
{
    NSInteger viewControllersCount = self.viewControllers.count;
    if (viewControllersCount > level) {
        NSInteger idx = viewControllersCount - level - 1;
        UIViewController *viewController = self.viewControllers[ idx ];
        return [self popToViewController:viewController animated:animated];
    } else {
        return [self popToRootViewControllerAnimated:animated];
    }
}

@end
