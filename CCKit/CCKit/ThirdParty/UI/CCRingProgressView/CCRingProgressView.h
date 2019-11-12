//
//  CCRingProgressView.h
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

@interface CCRingProgressView : UIView

/**
 *  @author CC, 16-08-23
 *
 *  @brief 百分比数值（0-1）
 */
@property(nonatomic, assign) float progress;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 指示进度的颜色。
 *         默认为白色[的UIColor whiteColor]
 */
@property(nonatomic, strong) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 默认设置为白色[的UIColor whiteColor]
 *         NO=环形。进度背景颜色会受到影响。
 */
@property(nonatomic, strong) UIColor *progressBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 指示器背景（进度条）的颜色。
 *         默认为半透明的白色（alpha 0.1）
 */
@property(nonatomic, strong) UIColor *backgroundTintColor UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 显示或隐藏文本中心百分比（如68％）- NO=隐藏或YES=表演。默认为隐藏。
 */
@property(nonatomic, assign) BOOL percentShow; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

/**
 *  @author CC, 16-08-23
 *
 *  @brief 默认[UIColor whiteColor]
 */
@property(nonatomic, strong) UIColor *percentLabelTextColor UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 默认字体[UIFont boldSystemFontOfSize:12.f]
 */
@property(nonatomic, strong) UIFont *percentLabelFont UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 显示模式 - NO=圆形或 YES=环形。默认为环。
 */
@property(nonatomic, assign) BOOL annular; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

/**
 *  @author CC, 16-08-23
 *
 *  @brief YES =环形。环形LineCapStyle受到影响。
 */
@property (nonatomic, assign) CGLineCap annularLineCapStyle UI_APPEARANCE_SELECTOR;

/**
 *  @author CC, 16-08-23
 *
 *  @brief 进度（0.0〜8.0）默认4.0F
 */
@property (nonatomic, assign) CGFloat annularLineWith UI_APPEARANCE_SELECTOR;

@end
