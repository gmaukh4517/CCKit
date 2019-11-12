//
//  UITableViewRowAction+CCAdd.h
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

@interface UITableViewRowAction (CCAdd)

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *backgroundImage;

@property (nonatomic, copy) UIColor *titleColor;

@property (nonatomic, assign) BOOL enabled;

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                             title:(NSString *)title
                             image:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *_Nonnull, NSIndexPath *_Nonnull))handler;

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                             image:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *action, NSIndexPath *indexPath))handler;

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style
                   backgroundImage:(UIImage *)image
                           handler:(void (^)(UITableViewRowAction *action, NSIndexPath *indexPath))handler;

@end

NS_ASSUME_NONNULL_END
