//
//  CCPhotoModel.h
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

@interface CCPhoto : NSObject

@property(nonatomic, copy) NSString *fileName;

@property(nonatomic, copy) NSURL *url;
// 完整的图片
@property(nonatomic, copy) UIImage *image;
//缩略图
@property(nonatomic, copy) UIImage *thumbImage;
// 来源view
@property(nonatomic, copy) UIImageView *srcImageView;

@property(nonatomic, copy) UIImage *placeholderImage;

@property(nonatomic, strong, readonly) UIImage *capture;

+(CCPhoto *)initPhoto:(UIImage *)image;

+(CCPhoto *)initPhoto:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;



@end
