//
//  UITextView+CCAdd.h
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

@interface UITextView (CCAdd)

@property (nonatomic, copy) BOOL (^shouldChangeCharactersInRangeBlock)(UITextView *textView, NSRange range, NSString *text);
@property (nonatomic, copy) void (^textViewDidChangeBlock)(UITextView *textView);

//主要用于设置maxLength 收到变化通知
@property (nonatomic, copy) void (^textViewTextChangeBlock)(UITextView *textView);

- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextView *textView, NSRange range, NSString *text))shouldChangeCharactersInRangeBlock;
- (void)setTextViewDidChangeBlock:(void (^)(UITextView *textView))textViewDidChangeBlock;

//主要用于设置maxLength 收到变化通知
- (void)setTextViewTextChangeBlock:(void (^)(UITextView *))textViewTextChangeBlock;


/*
 UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
 [self.view addSubview:textView];
 textView.zoomEnabled = YES;
 textView.minFontSize = 10;
 textView.maxFontSize = 40;
 */

@property (nonatomic) CGFloat maxFontSize, minFontSize;

@property (nonatomic) NSInteger maxLength;

@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  提示输入文字
 *
 *  @since 1.0
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  提示文字颜色
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIColor *placeholderColor;

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  提示文字字体
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UIFont *placeholderFont;

/**
 *  @brief  当前选中的字符串范围
 *
 *  @return NSRange
 */
- (NSRange)selectedRange;

/**
 *  @brief  选中所有文字
 */
- (void)selectAllText;

/**
 *  @brief  选中指定范围的文字
 *
 *  @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range;

// 用于计算textview输入情况下的字符数，解决实现限制字符数时，计算不准的问题
- (NSInteger)getInputLengthWithText:(NSString *)text;
/*
 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
 {
 NSInteger textLength = [textView getInputLengthWithText:text];
 if (textLength > 20) {
 //超过20个字可以删除
 if ([text isEqualToString:@""]) {
 return YES;
 }
 return NO;
 }
 return YES;
 }

 - (void)textViewDidChange:(UITextView *)textView
 {
 if ([textView getInputLengthWithText:nil] > 20) {
 textView.text = [textView.text substringToIndex:20];
 }
 }
 */

@end
