//
//  HomeViewManager.m
//  CCKitDemo
//
//  Created by CC on 2018/7/5.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "HomeViewManager.h"

@implementation HomeViewManager

-(void)cc_viewManagerWithSuperView:(UIView *)superView
{
    superView.backgroundColor = [UIColor colorFromHexCode:@"f3f5f7"];
}

-(void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos
{
    if ([infos.allKeys containsObject:@"model"]) {
        NSString *message = [infos objectForKey:@"message"];
        if (message.length > 0) {
            [CCProgressHUD showMessages:message];
            return;
        }


    }
}

@end
