//
//  UIControl+ActionBlocks.h
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
#define defaultInterval .5  //默认时间间隔

typedef void (^UIControlActionBlock)(id sender);

@interface UIControlActionBlockWrapper : NSObject

@property(nonatomic, copy) UIControlActionBlock actionBlock;
@property(nonatomic, assign) UIControlEvents controlEvents;

- (void)invokeBlock:(id)sender;

@end


@interface UIControl (CCAdd)

/**
 *  @author CC, 16-09-02
 *
 *  @brief 设置点击时间间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/**
 *  @author CC, 16-09-02
 *
 *  @brief 用于设置单个按钮需要被hook
 */
@property (nonatomic, assign) BOOL isNotIgnore;


#pragma mark -
#pragma mark :. ActionBlocks

- (void)handleControlEvent:(UIControlEvents)controlEvents withBlock:(UIControlActionBlock)actionBlock;
- (void)removeActionBlocksForControlEvent:(UIControlEvents)controlEvents;

@end
