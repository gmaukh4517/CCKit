//
//  CCToolbar.m
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import "CCToolbar.h"

@implementation CCToolbar

@synthesize previousBarButton = _previousBarButton;
@synthesize nextBarButton = _nextBarButton;
@synthesize titleBarButton = _titleBarButton;
@synthesize doneBarButton = _doneBarButton;
@synthesize fixedSpaceBarButton = _fixedSpaceBarButton;


+ (void)initialize
{
    [super initialize];

    CCToolbar *appearanceProxy = [self appearance];

    NSArray<NSNumber *> *positions = @[ @(UIBarPositionAny), @(UIBarPositionBottom), @(UIBarPositionTop), @(UIBarPositionTopAttached) ];

    for (NSNumber *position in positions) {
        UIToolbarPosition toolbarPosition = [position unsignedIntegerValue];

        [appearanceProxy setBackgroundImage:nil forToolbarPosition:toolbarPosition barMetrics:UIBarMetricsDefault];
        [appearanceProxy setShadowImage:nil forToolbarPosition:toolbarPosition];
    }
}

- (void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth; // | UIViewAutoresizingFlexibleHeight;
    self.translucent = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    self.items = nil;
    _previousBarButton = nil;
    _nextBarButton = nil;
    _doneBarButton = nil;
}

- (CCBarButtonItem *)previousBarButton
{
    if (_previousBarButton == nil) {
        _previousBarButton = [[CCBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        _previousBarButton.accessibilityLabel = @"Toolbar Previous Button";
    }

    return _previousBarButton;
}

- (CCBarButtonItem *)nextBarButton
{
    if (_nextBarButton == nil) {
        _nextBarButton = [[CCBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        _nextBarButton.accessibilityLabel = @"Toolbar Next Button";
    }

    return _nextBarButton;
}

- (CCTitleBarButtonItem *)titleBarButton
{
    if (_titleBarButton == nil) {
        _titleBarButton = [[CCTitleBarButtonItem alloc] initWithTitle:nil];
        _titleBarButton.accessibilityLabel = @"Toolbar Title Button";
    }

    return _titleBarButton;
}

- (CCBarButtonItem *)doneBarButton
{
    if (_doneBarButton == nil) {
        _doneBarButton = [[CCBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
        _doneBarButton.accessibilityLabel = @"Toolbar Done Button";
    }

    return _doneBarButton;
}

- (CCBarButtonItem *)fixedSpaceBarButton
{
    if (_fixedSpaceBarButton == nil) {
        _fixedSpaceBarButton = [[CCBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
#ifdef __IPHONE_11_0
        if (@available(iOS 10.0, *))
#else
        if (IQ_IS_IOS10_OR_GREATER)
#endif
        {
            [_fixedSpaceBarButton setWidth:6];
        } else {
            [_fixedSpaceBarButton setWidth:20];
        }
    }

    return _fixedSpaceBarButton;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFit = [super sizeThatFits:size];

    sizeThatFit.height = 44;

    return sizeThatFit;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    for (UIBarButtonItem *item in self.items) {
        [item setTintColor:tintColor];
    }
}


#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end
