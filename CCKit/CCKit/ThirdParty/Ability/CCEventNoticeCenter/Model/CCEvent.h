//
//  CCEventEntity.h
//  CCKit
//
//  Created by CC on 2018/7/23.
//  Copyright © 2018年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEvent : NSObject

@property (nonatomic, strong) id object;

@property (nonatomic, copy) NSDictionary *userInfo;


@end
