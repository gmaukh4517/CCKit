//
//  CCToolbar.h
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBarButtonItem.h"
#import "CCTitleBarButtonItem.h"

@interface CCToolbar : UIToolbar

/**
 Previous bar button of toolbar.
 */
@property (nonnull, nonatomic, strong) CCBarButtonItem *previousBarButton;

/**
 Next bar button of toolbar.
 */
@property (nonnull, nonatomic, strong) CCBarButtonItem *nextBarButton;

/**
 Title bar button of toolbar.
 */
@property(nonnull, nonatomic, strong, readonly) CCTitleBarButtonItem *titleBarButton;

/**
 Done bar button of toolbar.
 */
@property (nonnull, nonatomic, strong) CCBarButtonItem *doneBarButton;

/**
 Fixed space bar button of toolbar.
 */
@property(nonnull, nonatomic, strong) CCBarButtonItem *fixedSpaceBarButton;

@end
