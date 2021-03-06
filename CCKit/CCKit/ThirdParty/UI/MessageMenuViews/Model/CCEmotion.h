//
//  CCEmotion.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kCCEmotionImageViewSize 60
#define kCCEmotionMinimumLineSpacing 12

@interface CCEmotion : NSObject

/**
 封面图片
 */
@property(nonatomic, strong) UIImage *emotionConverPhoto;

/**
 *  gif表情的封面路径
 */
@property(nonatomic, copy) NSString *emotionConverPath;

/**
 *  @author CC, 2015-12-10
 *  
 *  @brief  网络封面
 */
@property(nonatomic, copy) NSString *emotionConverPhotoUrl;

/**
 *  gif表情的路径
 */
@property(nonatomic, copy) NSString *emotionPath;

/**
 *  @author CC, 2015-12-08
 *  
 *  @brief  表情名
 */
@property(nonatomic, copy) NSString *emotionTitle;

/**
 表情标签
 */
@property(nonatomic, copy) NSString *emotionLabel;

/**
 图片固定大小
 */
@property(nonatomic, assign) CGSize emotionSize;

@end
