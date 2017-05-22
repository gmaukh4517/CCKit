//
//  UIButton+ChainGrammar.m
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

#import "UIButton+ChainGrammar.h"
#import <objc/runtime.h>

static void *touchKey = &touchKey;

@implementation UIButton (ChainGrammar)

+ (UIButton *)init:(void (^)(UIButtonMaker *make))block
{
    return [self initWithType:UIButtonTypeSystem frame:CGRectZero maker:block];
}

+ (UIButton *)initWithType:(UIButtonType)type
                     frame:(CGRect)aframe
                     maker:(void (^)(UIButtonMaker *))block
{
    UIButton *button = [UIButton buttonWithType:type];
    [button setFrame:aframe];
    UIButtonMaker *instance = [[UIButtonMaker alloc] initWith:button];
    block(instance);
    return button;
}

+ (UIButton *)initWithFrame:(CGRect)aframe
                      maker:(void (^)(UIButtonMaker *))block
{
    return [self initWithType:UIButtonTypeSystem frame:aframe maker:block];
}

+ (UIButton * (^)(CGRect))initWithFrame
{
    return ^UIButton *(CGRect rect)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        return button;
    };
}

+ (UIButton * (^)(UIButtonType))initWithType
{
    return ^UIButton *(UIButtonType type)
    {
        UIButton *button = [UIButton buttonWithType:type];
        return button;
    };
}

- (UIButton * (^)(UIButtonMakerBlock))maker
{
    return ^UIButton *(UIButtonMakerBlock block)
    {
        UIButtonMaker *instance = [[UIButtonMaker alloc] initWith:self];
        block(instance);
        return self;
    };
}

+ (UIButton * (^)(UIButtonMakerBlock))maker
{
    return ^UIButton *(UIButtonMakerBlock block)
    {
        UIButton *button = [[UIButton alloc] init];
        UIButtonMaker *instance = [[UIButtonMaker alloc] initWith:button];
        block(instance);
        return button;
    };
}

- (void (^)(TouchBlock))touchUpInside
{
    return ^(TouchBlock block) {
        objc_setAssociatedObject(self, touchKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self addTarget:self action:@selector(touchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        return;
    };
}


- (void)touchUpInSide:(UIButton *)btn
{
    TouchBlock block = objc_getAssociatedObject(self, touchKey);
    if (block) {
        block();
    }
}


@end

@implementation UIButtonMaker {
    
    NSString *_title;
    UIColor *_titleColor;
    UIImage *_backgroundImage;
    UIImage *_iconImage;
    
    UIButton *_button;
}

- (instancetype)initWith:(id)obj
{
    if (self = [super initWith:obj]) {
        _button = obj;
    }
    return self;
}

- (UIButtonMaker * (^)(UIFont *))setFont
{
    return ^UIButtonMaker *(UIFont *font)
    {
        [_button.titleLabel setFont:font];
        return self;
    };
}

- (UIButtonMaker * (^)(UIColor *))setBackgroundColor
{
    return ^UIButtonMaker *(UIColor *color)
    {
        _button.backgroundColor = color;
        return self;
    };
}

- (UIButtonMaker * (^)(NSString *))setTitle
{
    return ^UIButtonMaker *(NSString *title)
    {
        _title = title;
        return self;
    };
}

- (UIButtonMaker * (^)(UIColor *))setTitleColor
{
    return ^UIButtonMaker *(UIColor *color)
    {
        _titleColor = color;
        return self;
    };
}

- (UIButtonMaker * (^)(UIControlState))forState
{
    return ^UIButtonMaker *(UIControlState state)
    {
        if (_title) {
            [_button setTitle:_title forState:state];
            _title = nil;
        } else {
            assert(@"SetTitle or Color need for state");
        }
        
        if (_titleColor) {
            [_button setTitleColor:_titleColor forState:state];
            _titleColor = nil;
        }
        
        if (_backgroundImage) {
            [_button setBackgroundImage:_backgroundImage forState:state];
            _backgroundImage = nil;
        }
        
        if (_iconImage) {
            [_button setImage:_iconImage forState:state];
            _iconImage = nil;
        }
        
        return self;
    };
}

- (UIButtonMaker * (^)(UIImage *))setImage
{
    return ^UIButtonMaker *(UIImage *image)
    {
        _iconImage = image;
        return self;
    };
}

- (UIButtonMaker * (^)(UIImage *))setBackgroundImage
{
    return ^UIButtonMaker *(UIImage *image)
    {
        _backgroundImage = image;
        return self;
    };
}


@end
