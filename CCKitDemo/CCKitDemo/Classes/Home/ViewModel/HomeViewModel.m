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
    NSArray *arr = @[ @[ @{ @"title" : @"ViewManager Block",
                            @"type" : @1 } ],
                      @[ @{ @"title" : @"UICollectionView Demo",
                            @"type" : @2 } ],
                      @[ @{ @"title" : @"Event Handle",
                            @"push" : @"ViewDemoViewController" },
                         @{ @"title" : @"DataBase",
                            @"push" : @"DataBaseViewController" },
                         @{ @"title" : @"Web Interaction",
                            @"push" : @"WebViewController" } ] ];
    NSMutableArray *groupArray = [NSMutableArray array];
    for (NSArray *itemArr in arr) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in itemArr) {
            TableViewCellEntity *entity = [[TableViewCellEntity alloc] init];
            entity.cellText = [item objectForKey:@"title"];
            entity.cellType = [[item objectForKey:@"type"] integerValue];
            entity.cellData = [item objectForKey:@"push"];
            [array addObject:entity];
        }
        [groupArray addObject:array];
    }

    if ([self.viewModelDelegate respondsToSelector:@selector(cc_viewModel:withInfos:)]) {
        [self.viewModelDelegate cc_viewModel:self
                                   withInfos:@{ @"model" : groupArray,
                                                @"message" : @"" }];
    }
}

@end
