//
//  UIView+CCHierarchy.h
//  CCKit
//
//  Created by CC on 2017/4/11.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCHierarchy)

@property (nonnull, nonatomic, readonly, copy) NSArray *deepResponderViews;

@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;

@end
