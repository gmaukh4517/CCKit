//
//  CCHostFilterRule.h
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 域名过滤规则
@interface CCHostFilterRule : NSObject

+ (void)registerInvailIp:(NSString *)ip;
+ (void)mapHost:(NSString *)host toIp:(NSString *)ip;

+ (BOOL)isIpInvalid:(NSString *)ip;
+ (NSString *)getIpAddressFromHost:(NSString *)host;
+ (NSString *)getHostFromIpAddress:(NSString *)ipAddress;

@end
