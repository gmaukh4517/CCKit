//
//  CCTitleBarButtonItem.h
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import "CCBarButtonItem.h"

@interface CCTitleBarButtonItem : CCBarButtonItem

/**
 Font to be used in bar button. Default is (system font 12.0 bold).
 */
@property (nullable, nonatomic, strong) UIFont *titleFont;

/**
 titleColor to be used for displaying button text when displaying title (disabled state).
 */
@property (nullable, nonatomic, strong) UIColor *titleColor;

/**
 selectableTitleColor to be used for displaying button text when button is enabled.
 */
@property (nullable, nonatomic, strong) UIColor *selectableTitleColor;

/**
 Initialize with frame and title.

 @param title Title of barButtonItem.
 */
- (nonnull instancetype)initWithTitle:(nullable NSString *)title NS_DESIGNATED_INITIALIZER;

/**
 Unavailable. Please use initWithFrame:title: method
 */
- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
- (nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
+ (nonnull instancetype) new NS_UNAVAILABLE;


@end
