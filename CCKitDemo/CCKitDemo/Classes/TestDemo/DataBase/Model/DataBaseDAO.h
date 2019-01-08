//
//  DataBaseEntity.h
//  CCKitDemo
//
//  Created by CC on 2019/1/2.
//  Copyright © 2019 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataBaseDAO : NSObject

@property (nonatomic, copy) NSString *sequenceID;

@property (nonatomic, copy) NSString *Name;

@property (nonatomic, copy) NSDate *addTime;

@end

NS_ASSUME_NONNULL_END
