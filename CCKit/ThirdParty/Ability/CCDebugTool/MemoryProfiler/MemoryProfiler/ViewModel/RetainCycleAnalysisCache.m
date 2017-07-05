//
//  RetainCycleAnalysisCache.m
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "RetainCycleAnalysisCache.h"

@interface RetainCycleAnalysisCache ()

@property (nonatomic, strong) NSMutableArray *analysis;

@end

@implementation RetainCycleAnalysisCache

- (instancetype)init
{
    if (self = [super init]) {
        _analysis = [NSMutableArray new];
    }
    
    return self;
}

- (CCRetainCycleStatus)statusInGeneration:(NSUInteger)generationIndex
                            forClassNamed:(NSString *)className
{
    if (_analysis.count <= generationIndex || (_analysis[generationIndex][className] == nil)) {
        return CCRetainCycleUnknown;
    }
    
    return (CCRetainCycleStatus)[_analysis[generationIndex][className] unsignedIntegerValue];
}

- (void)updateAnalysisStatus:(CCRetainCycleStatus)status
             forInGeneration:(NSUInteger)generationIndex
               forClassNamed:(NSString *)className
{
    // If first class in new generation, expand array
    while (_analysis.count <= generationIndex) {
        [_analysis addObject:[NSMutableDictionary new]];
    }
    
    [_analysis[generationIndex] setObject:@(status) forKey:className];
}


@end
