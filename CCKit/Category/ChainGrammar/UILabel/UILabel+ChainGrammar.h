//
//  UILabel+ChainGrammar.h
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

#import "ParentMaker.h"
#import <UIKit/UIKit.h>

@interface UILabelMaker : ParentMaker

- (UILabelMaker * (^)(NSString *))setText;
- (UILabelMaker * (^)(UIFont *))setFont;
- (UILabelMaker * (^)(UIColor *))setTextColor;
- (UILabelMaker * (^)(UIColor *))setShadowColor;

- (UILabelMaker * (^)(CGSize))setShadowOffset;
- (UILabelMaker * (^)(NSTextAlignment))setTextAlignment;
- (UILabelMaker * (^)(NSLineBreakMode))setLineBreakMode;
- (UILabelMaker * (^)(NSAttributedString *))setAttributedText;
- (UILabelMaker * (^)(UIColor *))setHighlightedTextColor;
- (UILabelMaker * (^)(BOOL))isUserInteractionEnabled;
- (UILabelMaker * (^)(BOOL))isEnabled;
- (UILabelMaker * (^)(NSInteger))numberOfLines;

@end
typedef void (^UILabelMakerBlock)(UILabelMaker *make);

@interface UILabel (ChainGrammar)

+ (UILabel * (^)(CGRect))initWithFrame;
+ (UILabel * (^)(UILabelMakerBlock))maker;
- (UILabel * (^)(UILabelMakerBlock))maker;

+ (UILabel *)init:(void (^)(UILabelMaker *make))block;

+ (UILabel *)initWithFrame:(CGRect)aframe
                     maker:(void (^)(UILabelMaker *make))block;

@end
