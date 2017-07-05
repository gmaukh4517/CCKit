//
//  ProfilerGenerationsSectionHeaderView.h
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfilerGenerationsSectionHeaderView;

@protocol ProfilerSectionHeaderDelegate <NSObject>

- (void)sectionHeaderRequestedExpandCollapseAction:(nonnull ProfilerGenerationsSectionHeaderView *)sectionHeader;
- (void)sectionHeaderRequestedRetainCycleDetection:(nonnull ProfilerGenerationsSectionHeaderView *)sectionHeader;

@end

@interface ProfilerGenerationsSectionHeaderView : UITableViewHeaderFooterView

/**
 Delegate to support header button actions
 */
@property (nonatomic, weak, nullable) id<ProfilerSectionHeaderDelegate> delegate;

/**
 Is section expanded
 */
@property (nonatomic, assign) BOOL expanded;

/**
 What is the index of this section
 */
@property (nonatomic, assign) NSInteger index;


@end
