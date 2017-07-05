//
//  ProfilerTableHeader.h
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfilerTableHeaderDelegate <NSObject>

- (void)markGeneration;
- (void)sortValueChanged:(UISegmentedControl *)sortControl;
- (void)textFieldDidChange:(NSString *)textField;

@end

@interface ProfilerTableHeader : UIView

@property (nonatomic, weak) id<ProfilerTableHeaderDelegate> delegate;

@end
