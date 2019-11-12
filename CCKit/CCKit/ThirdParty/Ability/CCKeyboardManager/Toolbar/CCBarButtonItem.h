//
//  CCBarButtonItem.h
//  CCKit
//
//  Created by CC on 2019/4/20.
//  Copyright © 2019 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSInvocation;

@interface CCBarButtonItem : UIBarButtonItem

/**
 Boolean to know if it's a system item or custom item
 */
@property (nonatomic, readonly) BOOL isSystemItem;

/**
 Additional target & action to do get callback action. Note that setting custom target & selector doesn't affect native functionality, this is just an additional target to get a callback.

 @param target Target object.
 @param action Target Selector.
 */
- (void)setTarget:(nullable id)target action:(nullable SEL)action;

/**
 Customized Invocation to be called when button is pressed. invocation is internally created using setTarget:action: method.
 */
@property (nullable, strong, nonatomic) NSInvocation *invocation;

@end
