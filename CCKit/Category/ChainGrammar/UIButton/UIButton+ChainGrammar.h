//
//  UIButton+ChainGrammar.h
//  CCKit
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
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


typedef void (^TouchBlock)();

@interface UIButtonMaker : ParentMaker

- (UIButtonMaker * (^)(NSString *))setTitle;
- (UIButtonMaker * (^)(UIControlState))forState;
- (UIButtonMaker * (^)(UIColor *))setTitleColor;
- (UIButtonMaker * (^)(UIImage *))setImage;
- (UIButtonMaker * (^)(UIImage *))setBackgroundImage;
- (UIButtonMaker * (^)(UIColor *))setBackgroundColor;
- (UIButtonMaker * (^)(UIFont *))setFont;

@end

typedef void (^UIButtonMakerBlock)(UIButtonMaker *);

@interface UIButton (ChainGrammar)

+ (UIButton * (^)(CGRect))initWithFrame;
+ (UIButton * (^)(UIButtonType))initWithType;

+ (UIButton * (^)(UIButtonMakerBlock))maker;
- (UIButton * (^)(UIButtonMakerBlock))maker;


+ (UIButton *)initWithType: (UIButtonType)type
                     frame: (CGRect)aframe
                     maker:(void (^)(UIButtonMaker * make))block;

+ (UIButton *)init:(void (^)(UIButtonMaker * make))block;

+ (UIButton *)initWithFrame: (CGRect)aframe
                      maker:(void (^)(UIButtonMaker * make))block;

- (void (^)(TouchBlock))touchUpInside;

@end
