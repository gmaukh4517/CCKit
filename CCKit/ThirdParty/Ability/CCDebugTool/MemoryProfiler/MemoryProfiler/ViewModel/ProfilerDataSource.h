//
//  ProfilerDataSource.h
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "RetainCycleAnalysisCache.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CCMemoryProfilerSortingMode) {
    CCMemoryProfilerSortByClass,
    CCMemoryProfilerSortByAlive,
    CCMemoryProfilerSortBySize,
};

typedef NS_ENUM(NSUInteger, CCMemoryProfilerSortingOrder) {
    CCMemoryProfilerSortingOrderAscending,
    CCMemoryProfilerSortingOrderDescending,
};

@interface ProfilerDataSource : NSObject<UITableViewDataSource>

/**
 classFilter is a string representing part of class name, used to filter data by class name
 */
@property (nonatomic, copy, nullable) NSString *classFilter;

/**
 What mode is used to sort data in table view? Check FBMemoryProfilerSortingMode
 */
@property (nonatomic, assign) CCMemoryProfilerSortingMode sortingMode;

/**
 Is data in ascending or descending order?
 */
@property (nonatomic, assign) CCMemoryProfilerSortingOrder sortingOrder;

/**
 @param analysisCache is a cache of results memory profiler gathered during retain cycle detection. Rows which objects
 were checked for retain cycles will be marked with red or green depending on wether they were cycled or no
 */
- (nonnull instancetype)initWithAnalysisCache:(nullable RetainCycleAnalysisCache *)analysisCache;

/**
 In Generations mode full section can be expanded or collapsed to make it easier to browse
 */
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section;

/**
 Checks if current section is expanded
 */
- (BOOL)isSectionExpanded:(NSInteger)section;

/**
 Summary for section will be a string that will appear next to generation name.
 */
- (nonnull NSString *)summaryForSection:(NSInteger)section;

/**
 If we need new data, because we for example marked new generation, we can force refresh.
 */
- (void)forceDataReload;

/**
 Takes visible cells and returns an array of class names that those cells represent.
 */
- (nonnull NSArray<NSString *> *)classNamesForSection:(NSInteger)section;

@end
