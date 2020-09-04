//
//  CCHostMapper.h
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * (^CCHostMap)(NSString *host);

@interface CCHostMapper : NSObject

+ (BOOL)validIp:(NSString *)ip;
+ (void)setHostMap:(CCHostMap)hostMap;
+ (void)parseHost:(NSString *)host complete:(void (^)(NSString *ip))complete;

+ (NSString *)parseHost:(NSString *)host;
+ (NSString *)getIpv4AddressFromHost:(NSString *)host;
+ (NSString *)getIpv6AddressFromHost:(NSString *)host;

@end
