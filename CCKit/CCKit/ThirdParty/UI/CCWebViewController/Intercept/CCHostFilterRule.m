//
//  CCHostFilterRule.m
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import "CCHostFilterRule.h"

static inline NSMutableSet *CCinvalidIPs()
{
    static NSMutableSet *CCinvalidIPs;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CCinvalidIPs = [NSMutableSet set];
    });
    return CCinvalidIPs;
}

static inline NSMutableDictionary *CCIPMapper()
{
    static NSMutableDictionary *CCIPMapper;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CCIPMapper = [NSMutableDictionary dictionary];
    });
    return CCIPMapper;
}

static inline NSMutableDictionary *CCHostMapper()
{
    static NSMutableDictionary *CCHostMapper;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CCHostMapper = [NSMutableDictionary dictionary];
    });
    return CCHostMapper;
}


@implementation CCHostFilterRule


+ (void)registerInvailIp:(NSString *)ip
{
    [CCinvalidIPs() addObject:ip];
}

+ (void)mapHost:(NSString *)host toIp:(NSString *)ip
{
    CCIPMapper()[ ip ] = host;
    CCHostMapper()[ host ] = ip;
}

+ (BOOL)isIpInvalid:(NSString *)ip
{
    return [CCinvalidIPs() containsObject:ip];
}

+ (NSString *)getIpAddressFromHost:(NSString *)host
{
    return CCHostMapper()[ host ];
}

+ (NSString *)getHostFromIpAddress:(NSString *)ipAddress
{
    return CCIPMapper()[ ipAddress ];
}

@end
