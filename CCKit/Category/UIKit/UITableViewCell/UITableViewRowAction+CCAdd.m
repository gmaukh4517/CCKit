//
//  UITableViewRowAction+CCAdd.m
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

#import "UITableViewRowAction+CCAdd.h"
#import <objc/runtime.h>

@implementation UITableViewRowAction (CCAdd)

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                             title:(NSString *)title
                             image:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *_Nonnull, NSIndexPath *_Nonnull))handler
{
    UITableViewRowAction *rowAction = [self rowActionWithStyle:style title:title handler:handler];
    rowAction.image = image;
    return rowAction;
}

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                             image:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *_Nullable, NSIndexPath *_Nullable))handler
{
    UITableViewRowAction *rowAction = [self rowActionWithStyle:style title:@"CC" handler:handler];
    rowAction.image = image;
    return rowAction;
}

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                   backgroundImage:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *_Nullable, NSIndexPath *_Nullable))handler
{
    UITableViewRowAction *rowAction = [self rowActionWithStyle:style title:@"CC" handler:handler];
    rowAction.backgroundImage = image;
    return rowAction;
}

- (void)setImage:(UIImage *)image
{
    objc_setAssociatedObject(self, @selector(image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)image
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    objc_setAssociatedObject(self, @selector(backgroundImage), backgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)backgroundImage
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEnabled:(BOOL)enabled
{
    objc_setAssociatedObject(self, @selector(enabled), @(enabled), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)enabled
{
    id enabled = objc_getAssociatedObject(self, _cmd);
    return enabled ? [enabled boolValue] : true;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    objc_setAssociatedObject(self, @selector(titleColor), titleColor, OBJC_ASSOCIATION_COPY);
}

- (UIColor *)titleColor
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
