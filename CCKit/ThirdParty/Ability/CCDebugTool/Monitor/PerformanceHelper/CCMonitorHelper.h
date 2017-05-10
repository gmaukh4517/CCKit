//
//  CCMonitorHelper.h
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMonitorHelper : NSObject

+ (NSString *)bytesOfTotalMemory;

//for internal use
+ (BOOL)updateHostStatistics;

// 使用内存
+ (NSString *)bytesOfUsedMemory;

// 获取总内存大小
+ (NSString *)getTotalMemory;
+ (float)getTotalMemorySize;

// 获取已使用内存
+ (NSString *)getUsedMemory;
+ (float)getUsedMemorySize;

// 获取当前设备可用内存
+ (NSString *)availableMemory;
+ (float)availableMemorySize;

//获取总磁盘容量
+ (NSString *)getTotalDiskSize;

// 获取当前设备可用存储
+ (NSString *)getAvailableDiskSize;

// 赋值当前流量
+ (NSArray *)currentLiuLiang;

// 上行、下行流量
+ (NSArray *)getDataCounters;

// cpu
+ (float)cpu_usage;

@end
