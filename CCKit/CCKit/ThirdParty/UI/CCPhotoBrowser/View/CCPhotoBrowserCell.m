//
//  CJPhotoBrowserCell.m
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

#import "CCPhotoBrowserCell.h"
#import "CCPhotoLoadingView.h"
#import "UIView+Frame.h"
#import "CCConfig.h"
#import "UIImageView+WebCache.h"

@interface CCPhotoBrowserCell ()

@property (nonatomic, strong) CCPhotoBrowserView *previewView;

@end

@implementation CCPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _previewView = [[CCPhotoBrowserView alloc] initWithFrame:CGRectMake(10, 0, self.width - 20, self.height)];
        @weakify(self);
        _previewView.singleTapGestureBlock = ^() {
            @strongify(self);
            !self.singleTapGestureBlock ?: self.singleTapGestureBlock();
        };
        [self addSubview:_previewView];
    }
    return self;
}

- (void)cc_cellWillDisplayWithModel:(CCPhoto *)photo
{
    _previewView.photo = photo;
}

- (void)recoverSubviews
{
    [_previewView recoverSubviews];
}

- (void)photoProgress:(float)progress pathURL:(NSString *)pathUrl
{
    [_previewView photoProgress:progress pathURL:pathUrl];
}

- (void)photoRefresh;
{
    [_previewView photoRefresh];
}

@end

@interface CCPhotoBrowserView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) CCPhotoLoadingView *photoLoadingView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) id asset;
@property (nonatomic, assign) int32_t imageRequestID;


@end

@implementation CCPhotoBrowserView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initalization];
    }
    return self;
}

- (void)initalization
{
    self.clipsToBounds = YES;
    // 属性
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = NO;

    // 图片
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];

    _photoLoadingView = [[CCPhotoLoadingView alloc] init];

    // 监听点击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delaysTouchesBegan = YES;
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];

    [singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)setPhoto:(CCPhoto *)photo
{
    _photo = photo;
    [self showImage];
}

- (void)photoRefresh
{
    self.imageView.image = _photo.image;
//    [self adjustFrame];
}

- (void)showImage
{
    [_photoLoadingView removeFromSuperview];
    if (_photo.image) {
        self.imageView.image = _photo.image;
    } else {
        self.imageView.image = _photo.thumbImage;
        if (!_photo.thumbImage) {
            @weakify(self);
            [_photoLoadingView showLoading];
            [self addSubview:_photoLoadingView];
            [self.imageView sd_setImageWithPreviousCachedImageWithURL:_photo.url placeholderImage:_photo.placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                cc_dispatch_async_on_main_queue(^{
                    @strongify(self);
                    if (receivedSize > kMinProgress) {
                          [self photoProgress:receivedSize/expectedSize pathURL:targetURL.absoluteString];
                    }
                });
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                cc_dispatch_async_on_main_queue(^{
                    @strongify(self);
                    if ([self.photo.url.absoluteString isEqualToString:imageURL.absoluteString]) {
                        self.photo.thumbImage = image;
                        [self photoDidFinishLoadWithImage:image];
                    }
                });
            }];
        }
    }

    [self adjustFrame];
}

- (void)photoProgress:(float)progress pathURL:(NSString *)pathUrl
{
    if ([_photo.url.absoluteString isEqualToString:pathUrl]) {
        if (!_photoLoadingView.superview) {
            [_photoLoadingView showLoading];
            [self addSubview:_photoLoadingView];
        }
        _photoLoadingView.progress = progress;
    }
}


- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.imageView.image = image;
        _imageView.backgroundColor = [UIColor whiteColor];
        _photoLoadingView.progress = kMinProgress;
        if (_photoLoadingView.superview)
            [_photoLoadingView removeFromSuperview];
    } else {
        _imageView.image = nil;
        _imageView.backgroundColor = [UIColor clearColor];
        [_photoLoadingView showFailure];
        [self addSubview:_photoLoadingView];
    }
    [self adjustFrame];
}

- (void)adjustFrame
{
    if (_imageView.image == nil || CGSizeEqualToSize(_imageView.image.size, CGSizeMake(0, 0))) return;
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = _imageView.image.size.width;
    CGFloat imageHeight = _imageView.image.size.height;

    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1)
        minScale = 1.0;

    CGFloat maxScale = 2.5;
    if ([UIScreen instancesRespondToSelector:@selector(scale)])
        maxScale = maxScale / [[UIScreen mainScreen] scale];

    self.maximumZoomScale = 2.5;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;

    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    imageFrame.origin.y = 0;
    if (imageFrame.size.height < boundsHeight)
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    _imageView.frame = imageFrame;
}

- (void)recoverSubviews
{
    [self adjustFrame];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}

#pragma mark - 手势处理

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    !_singleTapGestureBlock ?: _singleTapGestureBlock();
}

- (void)resets
{
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat width = self.frame.size.width / self.maximumZoomScale;
        CGFloat height = self.frame.size.height / self.maximumZoomScale;
        CGRect rect = CGRectMake(touchPoint.x * (1 - 1 / self.maximumZoomScale), touchPoint.y * (1 - 1 / self.maximumZoomScale), width, height);
        [self zoomToRect:rect animated:YES];
    }
}

@end
