//
//  CCPhotoBrowser.m
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
#import "CCPhotoBrowser.h"
#import "CCPhotoBrowserCell.h"
#import "UIView+Frame.h"
#import "CCConfig.h"
#import "CCProgressHUD.h"
#import "UIImage+CCAdd.h"

#define kPadding 10

#define selfSize self.view.frame.size

#define themeColor [[UIColor blackColor] colorWithAlphaComponent:0.4]

@interface CCPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *photoPreviewCollectionView;

@property (nonatomic, strong) UIView *navigationView;

@property (nonatomic, assign) UIStatusBarStyle barStyle;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIButton *originalButton;

@property (nonatomic, strong) UIButton *detailsButton;

@end

@implementation CCPhotoBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self initNaigation];
    [self initControls];

    [self.view addSubview:_navigationView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _barStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (_currentIndex) [_photoPreviewCollectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0) animated:NO];
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:_barStyle];
}

- (void)initNaigation
{
    CGFloat height = device_iPhoneXAbove ? 88 : 64;
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height)];
    _navigationView.backgroundColor = themeColor;

    CGFloat y = device_iPhoneXAbove ? 44 : 20;

    UIImage *backIndicatorImage = [UINavigationBar appearance].backIndicatorImage;
    if (!backIndicatorImage)
        backIndicatorImage = [UINavigationBar appearance].backIndicatorTransitionMaskImage;
    if (!backIndicatorImage)
        backIndicatorImage = [UIImage imageNamed:@"nav_back"];

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y, 44, 44)];
    [backButton setImage:[backIndicatorImage imageChangeColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBackAction) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:backButton];

    CGFloat witdh = _navigationView.width - 88 - 88;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(88, backButton.y, witdh, 44)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, witdh, 25)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [titleView addSubview:_titleLabel = titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, witdh, 20)];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.font = [UIFont systemFontOfSize:13];
    [titleView addSubview:_subtitleLabel = subtitleLabel];
    [_navigationView addSubview:titleView];

    if (self.isDelete) {
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(_navigationView.width - 50, backButton.y, 40, 44)];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        UIImage *deleteImage = [UIImage imageNamed:@"bottom_open_details"];
        if (!deleteImage)
            [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:deleteButton];
    }
}

- (void)initControls
{
    [self.view addSubview:self.photoPreviewCollectionView];
    [self.view addSubview:self.originalButton];
}

- (void)refreshNaviBarAndBottomBarState
{
    CCPhoto *model;
    if (_currentIndex >= self.photos.count) {
        model = self.photos[ _currentIndex - 1 ];
    } else {
        model = self.photos[ _currentIndex ];
    }

    self.titleLabel.text = model.fileName;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%d/%zi", (int)self.currentIndex + 1, self.photos.count];
    self.originalButton.hidden = YES;

    NSString *fileSize; //= [self fileSize:model.fileLength];
    if (fileSize) {
        [self.originalButton setTitle:fileSize forState:UIControlStateNormal];
        [self.originalButton sizeToFit];
        CGRect frame = self.originalButton.frame;
        frame.size.width += 20;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = self.view.frame.size.height - frame.size.height - 57;
        self.originalButton.frame = frame;
    }
}

- (NSString *)fileSize:(NSInteger)fileLength
{
    NSString *result;
    float unit = 1024.0f;
    if (fileLength < unit) {
        result = [NSString stringWithFormat:@"%@ %ziB", @"查看原图", fileLength];
    } else if (fileLength < pow(unit, 2)) {
        result = [NSString stringWithFormat:@"%@ %.2fKB", @"查看原图", fileLength / unit];
    } else if (fileLength < pow(unit, 3)) {
        result = [NSString stringWithFormat:@"%@ %.2fMB", @"查看原图", fileLength / pow(unit, 2)];
    } else {
        result = [NSString stringWithFormat:@"%@ %.2fGB", @"查看原图", fileLength / pow(unit, 3)];
    }
    return result;
}

- (void)photoViewSingleTap
{
    self.navigationView.hidden = !self.navigationView.hidden;
}

#pragma mark -
#pragma mark :. event Handle

- (void)handleBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
    cc_dispatch_after(0.25, ^{
        self.view.backgroundColor = [UIColor clearColor];
        self.photoPreviewCollectionView.backgroundColor = [UIColor clearColor];
    });
}

- (void)deleteButtonClick:(UIButton *)sender
{
    if ([self.photoDelegate respondsToSelector:@selector(didPhotoDelete:index:)])
        [self.photoDelegate didPhotoDelete:self.photos[ self.currentIndex ] index:self.currentIndex];

    [self didMoreHandle:@"删除" error:nil];
}

- (void)originalImageButtonClick:(UIButton *)sender
{
    __block CCPhoto *model = self.photos[ _currentIndex ];
    //    model.original = NO;

    self.originalButton.hidden = YES;
    __block CCPhotoBrowserCell *photoPreviewCell = (CCPhotoBrowserCell *)[self.photoPreviewCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];

    [photoPreviewCell photoProgress:0.001 pathURL:model.url.absoluteString];
    //    [CCImageManager downloadOriginalPicture:model.filePath
    //        fileSize:model.fileLength
    //        progress:^(float progress, NSString *pathURL) {
    //            cc_dispatch_async_on_main_queue(^{
    //                [photoPreviewCell photoProgress:progress pathURL:pathURL];
    //            });
    //        }
    //        completion:^(UIImage *image, NSString *pathURL) {
    //            cc_dispatch_async_on_main_queue(^{
    //                if ([model.filePath isEqualToString:pathURL]) {
    //                    model.image = image;
    //                    [photoPreviewCell photoRefresh];
    //                }
    //            });
    //        }];
}

#pragma mark -
#pragma mark :. CJMoreViewDelegate

- (void)didHandleEnd
{
}

- (void)didMoreHandle:(NSString *)handleTitle error:(NSError *)error
{
    if ([handleTitle isEqualToString:@"删除"]) {
        NSTimeInterval second = 0.01;
        if (error && error.code != 0) {
            second = 2;
            [CCProgressHUD showMessages:error.domain];
        }

        NSMutableArray *array = [NSMutableArray arrayWithArray:self.photos];
        [array removeObjectAtIndex:self.currentIndex];
        self.photos = array;
        cc_dispatch_after(second, ^{
            [self.photoPreviewCollectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:self.currentIndex inSection:0] ]];
            [self.photoPreviewCollectionView setContentOffset:CGPointMake((self.view.width + 20) * self.currentIndex - 1, 0) animated:NO];
            if (!self.photos.count)
                [self.navigationController popViewControllerAnimated:YES];
            else
                [self refreshNaviBarAndBottomBarState];


        });
    }
}

#pragma mark -
#pragma mark :. UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth + ((self.view.width + 20) * 0.5);

    NSInteger currentIndex = offSetWidth / (self.view.width + 20);

    if (currentIndex < self.photos.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
}

#pragma mark -
#pragma mark :. UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCPhotoBrowserCell *photoPreviewCell = (CCPhotoBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CCPhotoBrowserCell" forIndexPath:indexPath];
    [photoPreviewCell cc_cellWillDisplayWithModel:self.photos[ indexPath.row ]];

    @weakify(self);
    [photoPreviewCell setSingleTapGestureBlock:^{
        @strongify(self);
        [self photoViewSingleTap];
    }];

    return photoPreviewCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CCPhotoBrowserCell class]]) {
        [(CCPhotoBrowserCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CCPhotoBrowserCell class]]) {
        [(CCPhotoBrowserCell *)cell recoverSubviews];
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (UICollectionView *)photoPreviewCollectionView
{
    if (!_photoPreviewCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _photoPreviewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:layout];
//        _photoPreviewCollectionView.backgroundColor = [UIColor blackColor];
        _photoPreviewCollectionView.dataSource = self;
        _photoPreviewCollectionView.delegate = self;
        _photoPreviewCollectionView.pagingEnabled = YES;
        _photoPreviewCollectionView.scrollsToTop = NO;
        _photoPreviewCollectionView.showsHorizontalScrollIndicator = NO;
        _photoPreviewCollectionView.contentOffset = CGPointMake(0, 0);
        _photoPreviewCollectionView.contentSize = CGSizeMake(self.photos.count * (self.view.width + 20), 0);
        [_photoPreviewCollectionView registerClass:[CCPhotoBrowserCell class] forCellWithReuseIdentifier:@"CCPhotoBrowserCell"];
    }
    return _photoPreviewCollectionView;
}

- (UIButton *)originalButton
{
    if (!_originalButton) {
        _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        _originalButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _originalButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_originalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _originalButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        cc_view_border_radius(_originalButton, 3, 1, [UIColor whiteColor]);
        [_originalButton addTarget:self action:@selector(originalImageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalButton;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark :. 转屏handle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
