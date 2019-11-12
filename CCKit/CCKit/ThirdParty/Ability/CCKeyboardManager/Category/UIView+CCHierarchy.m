//
//  UIView+CCHierarchy.m
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

#import "UIView+CCHierarchy.h"
#import <objc/runtime.h>

@implementation UIView (CCHierarchy)

- (void)_setIsAskingCanBecomeFirstResponder:(BOOL)isAskingCanBecomeFirstResponder
{
    objc_setAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder), @(isAskingCanBecomeFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAskingCanBecomeFirstResponder
{
    NSNumber *isAskingCanBecomeFirstResponder = objc_getAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder));
    return [isAskingCanBecomeFirstResponder boolValue];
}

- (BOOL)isSearchBarTextField
{
    static Class UISearchBarTextFieldClass = Nil; //UISearchBar

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UISearchBarTextFieldClass = NSClassFromString(@"UISearchBarTextField");
    });
    return ([self isKindOfClass:UISearchBarTextFieldClass] || [self isKindOfClass:[UISearchBar class]]);
}

- (BOOL)isAlertViewTextField
{
    //Special textFields,textViews,scrollViews
    static Class UIAlertSheetTextFieldClass = Nil;      //UIAlertView
    static Class UIAlertSheetTextFieldClass_iOS8 = Nil; //UIAlertView

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIAlertSheetTextFieldClass = NSClassFromString(@"UIAlertSheetTextField");
        UIAlertSheetTextFieldClass_iOS8 = NSClassFromString(@"_UIAlertControllerTextField");
    });

    return ([self isKindOfClass:UIAlertSheetTextFieldClass] || [self isKindOfClass:UIAlertSheetTextFieldClass_iOS8]);
}


- (BOOL)_IQcanBecomeFirstResponder
{
    [self _setIsAskingCanBecomeFirstResponder:YES];
    BOOL _IQcanBecomeFirstResponder = ([self canBecomeFirstResponder] && [self isUserInteractionEnabled] && ![self isHidden] && [self alpha] != 0.0 && ![self isAlertViewTextField] && ![self isSearchBarTextField]);

    if (_IQcanBecomeFirstResponder == YES) {
        if ([self isKindOfClass:[UITextField class]]) {
            _IQcanBecomeFirstResponder = [(UITextField *)self isEnabled];
        } else if ([self isKindOfClass:[UITextView class]]) {
            _IQcanBecomeFirstResponder = [(UITextView *)self isEditable];
        }
    }

    [self _setIsAskingCanBecomeFirstResponder:NO];

    return _IQcanBecomeFirstResponder;
}

- (NSArray *)deepResponderViews
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];

    for (UIView *textField in self.subviews) {
        if ([textField _IQcanBecomeFirstResponder]) {
            [textFields addObject:textField];
        }

        //Sometimes there are hidden or disabled views and textField inside them still recorded, so we added some more validations here (Bug ID: #458)
        //Uncommented else (Bug ID: #625)
        if (textField.subviews.count && [textField isUserInteractionEnabled] && ![textField isHidden] && [textField alpha] != 0.0) {
            [textFields addObjectsFromArray:[textField deepResponderViews]];
        }
    }

    //subviews are returning in incorrect order. Sorting according the frames 'y'.
    return [textFields sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {

        CGRect frame1 = [view1 convertRect:view1.bounds toView:self];
        CGRect frame2 = [view2 convertRect:view2.bounds toView:self];

        CGFloat x1 = CGRectGetMinX(frame1);
        CGFloat y1 = CGRectGetMinY(frame1);
        CGFloat x2 = CGRectGetMinX(frame2);
        CGFloat y2 = CGRectGetMinY(frame2);

        if (y1 < y2)
            return NSOrderedAscending;

        else if (y1 > y2)
            return NSOrderedDescending;

        //Else both y are same so checking for x positions
        else if (x1 < x2)
            return NSOrderedAscending;

        else if (x1 > x2)
            return NSOrderedDescending;

        else
            return NSOrderedSame;
    }];

    return textFields;
}

- (UIViewController *)viewController
{
    UIResponder *nextResponder = self;
    do {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UINavigationController class]])
            return ((UINavigationController *)nextResponder).topViewController;

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController *)nextResponder;
    } while (nextResponder != nil);

    return nil;
}


- (UIViewController *)topMostController
{
    NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];

    UIViewController *topController = self.window.rootViewController;

    if (topController) {
        [controllersHierarchy addObject:topController];
    }

    while ([topController presentedViewController]) {
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }

    UIResponder *matchController = [self viewController];

    while (matchController != nil && [controllersHierarchy containsObject:matchController] == NO) {
        do {
            matchController = [matchController nextResponder];

        } while (matchController != nil && [matchController isKindOfClass:[UIViewController class]] == NO);
    }

    return (UIViewController *)matchController;
}

@end


@implementation UIView (CCToolbarAddition)

- (CCToolbar *)keyboardToolbar
{
    CCToolbar *keyboardToolbar = nil;
    if ([[self inputAccessoryView] isKindOfClass:[CCToolbar class]]) {
        keyboardToolbar = [self inputAccessoryView];
    } else {
        keyboardToolbar = objc_getAssociatedObject(self, @selector(keyboardToolbar));

        if (keyboardToolbar == nil) {
            keyboardToolbar = [[CCToolbar alloc] init];
            objc_setAssociatedObject(self, @selector(keyboardToolbar), keyboardToolbar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }

    return keyboardToolbar;
}

- (void)setShouldHideToolbarPlaceholder:(BOOL)shouldHideToolbarPlaceholder
{
    objc_setAssociatedObject(self, @selector(shouldHideToolbarPlaceholder), @(shouldHideToolbarPlaceholder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
}

- (BOOL)shouldHideToolbarPlaceholder
{
    NSNumber *shouldHideToolbarPlaceholder = objc_getAssociatedObject(self, @selector(shouldHideToolbarPlaceholder));
    return [shouldHideToolbarPlaceholder boolValue];
}

- (void)setToolbarPlaceholder:(NSString *)toolbarPlaceholder
{
    objc_setAssociatedObject(self, @selector(toolbarPlaceholder), toolbarPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
}

- (NSString *)toolbarPlaceholder
{
    NSString *toolbarPlaceholder = objc_getAssociatedObject(self, @selector(toolbarPlaceholder));
    return toolbarPlaceholder;
}

- (NSString *)drawingToolbarPlaceholder
{
    if (self.shouldHideToolbarPlaceholder) {
        return nil;
    } else if (self.toolbarPlaceholder.length != 0) {
        return self.toolbarPlaceholder;
    } else if ([self respondsToSelector:@selector(placeholder)]) {
        return [(UITextField *)self placeholder];
    } else {
        return nil;
    }
}

@end
