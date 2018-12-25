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
@property (nonatomic, weak) UILabel *networkLabel;

@end

@implementation HomeViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    superView.backgroundColor = [UIColor colorFromHexCode:@"f3f5f7"];

    UILabel *networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, superView.width, 20)];
    networkLabel.textAlignment = NSTextAlignmentCenter;
    networkLabel.text = @"当前网络";
    [superView addSubview:_networkLabel = networkLabel];
    [self networkMonitorService];

    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, networkLabel.bottom + 10, 200, 30)];
    phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.placeholder = @"电话号码";
    [superView addSubview:_phoneTextField = phoneTextField];

    UIButton *checkPhoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [checkPhoneButton setTitle:@"校验电话"];
    [checkPhoneButton addTarget:self action:@selector(checkPhoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    checkPhoneButton.backgroundColor = [UIColor blackColor];
    phoneTextField.rightView = checkPhoneButton;
    phoneTextField.rightViewMode = UITextFieldViewModeAlways;

    //弹窗按钮
    UIButton *alerButton = [[UIButton alloc] initWithFrame:CGRectMake(20, phoneTextField.bottom + 10, 100, 30)];
    [alerButton setTitle:@"alser弹窗"];
    alerButton.backgroundColor = [UIColor RandomColor];
    [alerButton addTarget:self action:@selector(alertButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:alerButton];
}

- (void)networkMonitorService
{
    [[CCNetworkMonitor sharedInstance] setReachabilityStatusChangeBlock:^(CCNetworkReachabilityStatus status) {
        if (status == CCNetworkReachabilityStatusNone || status == CCNetworkReachabilityStatusUnknown)
            [CCProgressHUD showMessages:@"当前网络不可用,请检查你的网络设置"];

        NSString *networkStr = @"无网络";
        if (status == CCNetworkReachabilityStatusReachableVia3G)
            networkStr = @"3G";
        else if (status == CCNetworkReachabilityStatusReachableVia4G)
            networkStr = @"4G";
        else if (status == CCNetworkReachabilityStatusReachableViaWiFi)
            networkStr = @"WIFI";

        self.networkLabel.text = [NSString stringWithFormat:@"当前网络：%@", networkStr];
    }];
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

#pragma mark -
#pragma mark :. demo

- (void)alertButtonClick:(UIButton *)sender
{
    CCAlertButtonModel *cancel = [[CCAlertButtonModel alloc] init];
    cancel.buttonTitle = @"取消";
    cancel.buttonColor = [UIColor colorFromHexCode:@"303943"];
    cancel.buttonFont = [UIFont systemFontOfSize:16];

    CCAlertButtonModel *ok = [[CCAlertButtonModel alloc] init];
    ok.buttonTitle = @"确定";
    ok.buttonColor = [UIColor colorFromHexCode:@"3073F4"];
    ok.buttonFont = [UIFont systemFontOfSize:16];

    [CCAlertView showWithMessage:@"弹窗"
            withButtonTitleArray:@[ cancel, ok ]
           OnButtonTouchUpInside:^(NSInteger buttonIndex) {
               if (buttonIndex == 1) {
               }
           }];
}

@end
