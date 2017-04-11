//
//  CCKeyboardManager.h
//  CCKit
//
//  Created by CC on 2017/4/11.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIViewController.h>

@interface CCKeyboardManager : NSObject

@property(nullable, nonatomic, weak) id<UITextFieldDelegate, UITextViewDelegate> delegate;

+ (instancetype _Nullable)manager;
/**
 销毁监听
 */
- (void)freed;

/**
 注册监听Controller
 
 @param controller 当前Controller
 */
- (void)registeredWithViewController:(nullable UIViewController *)controller;

@end
