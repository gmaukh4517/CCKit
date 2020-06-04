//
//  CCDropDownList.h
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

typedef NS_ENUM(NSInteger, DorpDownListType) {
    DorpDownListTypeUP,
    DorpDownListTypeDown,
};

@interface CCDropDownListItem : NSObject

@property (nonatomic, copy) UIImage *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) UIImage *rightImage;

@property (nonatomic, strong) id carryObjects;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

+ (instancetype)initWithTitle:(NSString *)title;

@end

typedef void (^DropDownMenuDidSelectedCompledBlock)(NSInteger index, CCDropDownListItem *menuItem);
typedef void (^DropDownMenuDidDeleteBlock)(NSInteger index, CCDropDownListItem *menuItem);


#pragma mark -_- CCDropDownList

@interface CCDropDownList : UIView

- (instancetype)initDropDownListWithMenus:(UIView *)dropDownView
                                withMenus:(NSArray *)menus
                       animationDirection:(DorpDownListType)direction;

- (void)showMenuOnView:(UIView *)view atPoint:(CGPoint)point;

- (void)setItems:(NSArray *)items;

- (void)setViewSender:(UIView *)viewSender;

/**
 *  @author CC, 2015-11-04
 *
 *  @brief  行高
 */
@property (nonatomic, assign) CGFloat menuItemViewHeight;

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  菜单背景颜色
 */
@property (nonatomic, copy) UIColor *menuBackgroundColor;

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  菜单文字颜色
 */
@property (nonatomic, copy) UIColor *menuItemTextColor;

@property (nonatomic, assign) NSTextAlignment menuItemTextAlignment;

@property (nonatomic, copy) DropDownMenuDidSelectedCompledBlock dropDownMenuDidSelectedCompled;

@property (nonatomic, copy) DropDownMenuDidSelectedCompledBlock dropDownMenuDidDismissCompled;

@property (nonatomic, copy) DropDownMenuDidDeleteBlock dropDownMenuDidDelete;

@end
