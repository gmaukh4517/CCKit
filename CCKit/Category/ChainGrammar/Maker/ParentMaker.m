//
//  ParentMaker.m
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

@implementation ParentMaker

- (instancetype)initWith:(id)obj
{
    if (self = [super init]) {
        self.result = obj;
    }
    return self;
}

- (ParentMaker * (^)(BOOL))isUserInteractionEnabled
{
    return ^ParentMaker *(BOOL is)
    {
        [(UIView *)self.result setUserInteractionEnabled:is];
        return self;
    };
}

- (ParentMaker * (^)(CGRect))setFrame
{
    return ^ParentMaker *(CGRect rect)
    {
        [(UIView *)self.result setFrame:rect];
        return self;
    };
}

- (ParentMaker * (^)(CGFloat))setCornerRadius
{
    return ^ParentMaker *(CGFloat force)
    {
        if (!((UIView *)self.result).layer.masksToBounds) {
            ((UIView *)self.result).layer.masksToBounds = true;
        }
        ((UIView *)self.result).layer.cornerRadius = force;
        return self;
    };
}

- (ParentMaker * (^)(CGFloat))setBorderWidth
{
    return ^ParentMaker *(CGFloat force)
    {
        if (!((UIView *)self.result).layer.masksToBounds) {
            ((UIView *)self.result).layer.masksToBounds = true;
        }
        ((UIView *)self.result).layer.borderWidth = force;
        return self;
    };
}

- (ParentMaker * (^)(UIColor *))setBorderColor
{
    return ^ParentMaker *(UIColor *color)
    {
        if (!((UIView *)self.result).layer.masksToBounds) {
            ((UIView *)self.result).layer.masksToBounds = true;
        }
        ((UIView *)self.result).layer.borderColor = color.CGColor;
        return self;
    };
}


@end
