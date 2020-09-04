//
//  UIView+CCHierarchy.h
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
#import "CCToolbar.h"

@interface UIView (CCHierarchy)

@property (nonnull, nonatomic, readonly, copy) NSArray *deepResponderViews;

@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;

@property (nullable, nonatomic, readonly, strong) UIViewController *cc_viewController;
@property (nullable, nonatomic, readonly, strong) UIViewController *topMostController;

@end


@interface UIView (CCToolbarAddition)

/**
 CCToolbar references for better customization control.
 */
@property (readonly, nonatomic, nonnull) CCToolbar *keyboardToolbar;

/**
 If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
 */
@property (assign, nonatomic) BOOL shouldHideToolbarPlaceholder;

/**
 `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
 */
@property (nullable, strong, nonatomic) NSString *toolbarPlaceholder;

/**
 `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. This would either `placeholder` or `toolbarPlaceholder`.
 */
@property (nullable, strong, nonatomic, readonly) NSString *drawingToolbarPlaceholder;

@end
