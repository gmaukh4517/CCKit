//
//  RetainCycleAnalysisCache.h
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCRetainCycleStatus) {
    CCRetainCyclePresent,
    CCRetainCycleNotPresent,
    CCRetainCycleUnknown
};

@interface RetainCycleAnalysisCache : NSObject

/**
 What is the status of retain cycle detection for class in given generation
 
 @param generationIndex generation to check
 @param className class to check
 */
- (CCRetainCycleStatus)statusInGeneration:(NSUInteger)generationIndex
                            forClassNamed:(nullable NSString *)className;

/**
 Sets new state for given class in given generation
 
 @param status new status to set
 @param generationIndex generation to update
 @param className class to update
 */
- (void)updateAnalysisStatus:(CCRetainCycleStatus)status
             forInGeneration:(NSUInteger)generationIndex
               forClassNamed:(nullable NSString *)className;

@end
