//
//  HomeViewModel.m
//  CCKitDemo
//
//  Created by CC on 2018/7/5.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "HomeViewModel.h"
#import "CCNetowrkRequests.h"

@implementation HomeViewModel

- (void)cc_viewModelWithGetDataSuccessHandler
{
    [CCNetowrkRequests handleGET:API_DEMO
        parameters:@{ @"id" : @"2081" }
        responseBlock:^(id responseObject, NSError *error) {
            NSString *message = error.domain;
            if (!error) {
                message = @"";
            }

            if ([self.viewModelDelegate respondsToSelector:@selector(cc_viewModel:withInfos:)]) {
                [self.viewModelDelegate cc_viewModel:self
                                           withInfos:@{ @"model" : @"",
                                                        @"message" : message }];
            }
        }];
}

@end
