//
//  HomeViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/7/5.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "HomeViewManager.h"

@interface HomeViewManager ()

@property (nonatomic, weak) UITextField *phoneTextField;

@end

@implementation HomeViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    superView.backgroundColor = [UIColor colorFromHexCode:@"f3f5f7"];

    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.placeholder = @"电话号码";
    [superView addSubview:_phoneTextField = phoneTextField];

    UIButton *checkPhoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [checkPhoneButton setTitle:@"校验电话"];
    [checkPhoneButton addTarget:self action:@selector(checkPhoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    checkPhoneButton.backgroundColor = [UIColor blackColor];
    phoneTextField.rightView = checkPhoneButton;
    phoneTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos
{
    if ([infos.allKeys containsObject:@"model"]) {
        NSString *message = [infos objectForKey:@"message"];
        if (message.length > 0) {
            [CCProgressHUD showMessages:message];
            return;
        }
    }
}

- (void)checkPhoneButtonClick:(UIButton *)sender
{
    if ([self.phoneTextField.text isMobileNumber]) {
        [CCProgressHUD showMessages:@"通过"];
    } else {
        [CCProgressHUD showMessages:@"错误"];
    }
}

@end
