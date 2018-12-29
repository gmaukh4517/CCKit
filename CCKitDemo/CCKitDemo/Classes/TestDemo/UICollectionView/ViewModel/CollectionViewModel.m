//
//  CollectionViewModel.m
//  CCKitDemo
//
//  Created by CC on 2018/12/28.
//  Copyright © 2018 CC. All rights reserved.
//

#import "CollectionViewModel.h"

@implementation CollectionViewModel

- (void)cc_viewModelWithData:(NSDictionary *)parameters
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        TableViewCellEntity *entity = [[TableViewCellEntity alloc] init];
        entity.cellText = [NSString stringWithFormat:@"%@%zi", [parameters objectForKey:@"index"], i];
        [array addObject:entity];
    }

    if ([self.viewModelDelegate respondsToSelector:@selector(cc_viewModel:withInfos:)]) {
        [self.viewModelDelegate cc_viewModel:self withInfos:@{ @"model" : array }];
    }
}

- (void)cc_viewManagerEvent:(NSString *)info withEvent:(NSDictionary *)eventDic
{
    if ([info isEqualToString:@"loadData"]) {
        [self cc_viewModelWithData:eventDic];
    }
}

@end
