//
//  CCTitleBarButtonItem.m
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import "CCTitleBarButtonItem.h"

@interface CCTitleBarButtonItem ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *titleButton;

@end

@implementation CCTitleBarButtonItem

- (nonnull instancetype)initWithTitle:(nullable NSString *)title
{
    self = [super init];
    if (self) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];

        _titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _titleButton.enabled = NO;
        _titleButton.titleLabel.numberOfLines = 3;
        [_titleButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [_titleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_titleButton setBackgroundColor:[UIColor clearColor]];
        [_titleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self setTitle:title];
        [self setTitleFont:[UIFont systemFontOfSize:13.0]];
        [_titleView addSubview:_titleButton];

#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            CGFloat layoutDefaultLowPriority = UILayoutPriorityDefaultLow - 1;
            CGFloat layoutDefaultHighPriority = UILayoutPriorityDefaultHigh - 1;

            _titleView.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleView setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisHorizontal];
            [_titleView setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisHorizontal];

            _titleButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleButton setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleButton setContentHuggingPriority:layoutDefaultLowPriority forAxis:UILayoutConstraintAxisHorizontal];
            [_titleButton setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisVertical];
            [_titleButton setContentCompressionResistancePriority:layoutDefaultHighPriority forAxis:UILayoutConstraintAxisHorizontal];

            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            [_titleView addConstraints:@[ top, bottom, leading, trailing ]];
        } else
#endif
        {
            _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }

        self.customView = _titleView;
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;

    if (titleFont) {
        _titleButton.titleLabel.font = titleFont;
    } else {
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [_titleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [_titleButton setTitleColor:_titleColor ?: [UIColor lightGrayColor] forState:UIControlStateDisabled];
}

- (void)setSelectableTitleColor:(UIColor *)selectableTitleColor
{
    _selectableTitleColor = selectableTitleColor;
    [_titleButton setTitleColor:_selectableTitleColor ?: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
}

- (void)setInvocation:(NSInvocation *)invocation
{
    [super setInvocation:invocation];

    if (invocation.target == nil || invocation.selector == NULL) {
        self.enabled = NO;
        _titleButton.enabled = NO;
        [_titleButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.enabled = YES;
        _titleButton.enabled = YES;
        [_titleButton addTarget:invocation.target action:invocation.selector forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)dealloc
{
    self.customView = nil;
    [_titleButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    _titleView = nil;
    _titleButton = nil;
}

@end
