//
//  DataBaseViewModel.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "DataBaseViewModel.h"
#import "DataBaseDAO.h"

#define selectCount 15

@implementation DataBaseViewModel

- (void)cc_viewModelWithGetData:(NSDictionary *)parameters
{
    NSArray *daoArr = [CCDBManager ccdb_selectTablePage:@"DataBaseDAO"
                                                  limit:selectCount
                                                 offset:[[parameters objectForKey:@"index"] intValue] * selectCount
                                                  where:nil];

    NSMutableArray *dataArray = [NSMutableArray array];
    for (DataBaseDAO *dao in daoArr) {
        TableViewCellEntity *entity = [[TableViewCellEntity alloc] init];
        entity.cellText = [NSString stringWithFormat:@"%@ %@", dao.ccdb_identifier, dao.sequenceID];
        entity.cellDetailText = [dao.addTime timeFormat:@"yyyy-MM-dd HH:mm:ss"];
        entity.cellType = [dao.ccdb_identifier integerValue];
        [dataArray addObject:entity];
    }

    if ([self.viewModelDelegate respondsToSelector:@selector(cc_viewModel:withInfos:)]) {
        [self.viewModelDelegate cc_viewModel:self withInfos:@{ @"model" : dataArray }];
    }
}

- (void)cc_viewManagerEvent:(NSString *)info withEvent:(NSDictionary *)eventDic
{
    if ([info isEqualToString:@"add"]) {
        [self addDataBase:eventDic];
    } else if ([info isEqualToString:@"delete"]) {
        [self deleteDataBase:eventDic];
    } else if ([info isEqualToString:@"Refresh"]) {
        [self cc_viewModelWithGetData:eventDic];
    }
}

- (void)addDataBase:(NSDictionary *)event
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < selectCount; i++) {
        DataBaseDAO *dDao = [[DataBaseDAO alloc] init];
        dDao.sequenceID = [NSString stringWithUUID];
        dDao.Name = [NSString stringWithFormat:@"%zi", i];
        dDao.addTime = [NSDate date];
        [array addObject:dDao];
    }

    [CCDBManager ccdb_insertArray:array];

    [self cc_viewModelWithGetData:event];
}

- (void)deleteDataBase:(NSDictionary *)event
{
    [CCDBManager ccdb_deleteSqlConditions:@"DataBaseDAO"
                               conditions:[NSString stringWithFormat:@" where ccdb_identifier = '%@'", [event objectForKey:@"id"]]];
}

@end
