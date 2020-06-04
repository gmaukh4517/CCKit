//
//  CCDropDownListMenuItemView.m
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

#import "CCDropDownListMenuItemView.h"

@interface CCDropDownListMenuItemView ()

@property (nonatomic, strong) UIView *menuSelectedBackgroundView;

@property (nonatomic, strong) UIImageView *separatorLineImageView;

@property (nonatomic, strong) UIButton *accessoryButton;

@property (nonatomic, strong) NSIndexPath *cIndexPath;

@end

@implementation CCDropDownListMenuItemView

- (void)setupDorpDownMenuItem:(CCDropDownListItem *)dropDownItem
                  atIndexPath:(NSIndexPath *)indexPath
                     isBottom:(BOOL)isBottom
{
    self.dropDownItem = dropDownItem;
    self.textLabel.text = dropDownItem.title;
    self.imageView.image = dropDownItem.image;
    self.cIndexPath = indexPath;
    if (dropDownItem.rightImage) {
        [self.accessoryButton setImage:dropDownItem.rightImage forState:UIControlStateNormal];
        [self.accessoryButton setImage:dropDownItem.rightImage forState:UIControlStateHighlighted];
    }
    
    if (!self.accessoryView)
        self.accessoryView = self.accessoryButton;
    self.separatorLineImageView.hidden = isBottom;
}

- (void)accessoryButtonClick:(UIButton *)sender
{
    !self.accessoryButtonClick ?: self.accessoryButtonClick(self.cIndexPath);
}

#pragma mark - Propertys

- (UIView *)menuSelectedBackgroundView
{
    if (!_menuSelectedBackgroundView) {
        _menuSelectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _menuSelectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _menuSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.216 green:0.242 blue:0.263 alpha:0.9];
    }
    return _menuSelectedBackgroundView;
}

- (UIImageView *)separatorLineImageView
{
    if (!_separatorLineImageView) {
        _separatorLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 0.2, CGRectGetWidth(self.bounds), 0.2)];
        _separatorLineImageView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
    }
    return _separatorLineImageView;
}

- (UIButton *)accessoryButton
{
    if (!_accessoryButton) {
        _accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.bounds) - 0.2, CGRectGetHeight(self.bounds) - 0.2)];
        [_accessoryButton addTarget:self action:@selector(accessoryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessoryButton;
}

#pragma mark - Life Cycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        //        self.selectedBackgroundView = self.menuSelectedBackgroundView;
        [self.contentView addSubview:self.separatorLineImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _separatorLineImageView.frame;
    frame.origin.y = CGRectGetHeight(self.bounds) - 0.2;
    frame.size.width = CGRectGetWidth(self.bounds);
    _separatorLineImageView.frame = frame;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
    textLabelFrame.size.width = CGRectGetWidth(self.bounds) - textLabelFrame.origin.x - CGRectGetHeight(self.bounds) - 15.2;
    self.textLabel.frame = textLabelFrame;
    
    CGRect accessoryFrame = self.accessoryView.frame;
    accessoryFrame.origin.x = CGRectGetMaxX(self.textLabel.frame) + 10;
    self.accessoryView.frame = accessoryFrame;
}


@end
