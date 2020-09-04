//
//  CCHostMapper.m
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import "CCHostMapper.h"
#import "CCHostFilterRule.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/socket.h>
#import <sys/types.h>

static CCHostMap sCCHostMap;

@implementation CCHostMapper

+ (BOOL)validIp:(NSString *)ip
{
    return [self validIpv4:ip];
}

+ (BOOL)validIpv4:(NSString *)ip
{
    NSString *ipRegExp = @"^(([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3})|(0\\.0\\.0\\.0)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject:ip];
}

+ (BOOL)validIpv6:(NSString *)ip
{
    NSString *ipRegExp = @"^(^((\\p{XDigit}{1,4}):){7}(\\p{XDigit}{1,4})$)|(^(::((\\p{XDigit}//{1,4}):){0,5}(\\p{XDigit}{1,4}))$)|(^((\\p{XDigit}{1,4})(:|::)){0,6}(\\p//{XDigit}{1,4})$)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject:ip];
}

+ (BOOL)validHost:(NSString *)host
{
    NSString *hostRegExp = @"[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})"; //@"((http[s]?|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", hostRegExp];
    return [predicate evaluateWithObject:host];
}

+ (void)setHostMap:(CCHostMap)hostMap
{
    sCCHostMap = hostMap;
}

+ (void)parseHost:(NSString *)host complete:(void (^)(NSString *ip))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        !complete ?: complete([self parseHost:host]);
    });
}

+ (NSString *)parseHost:(NSString *)host
{
    if ([self validIp:host])
        return host;
    
    if (![self validHost:host])
        return nil;
    
    NSString *ipAddress = [CCHostFilterRule getIpAddressFromHost:host];
    if (ipAddress != nil) {
        return ipAddress;
    }
    
    if (sCCHostMap != nil) {
        NSString *ipAddress = sCCHostMap(host);
        if (ipAddress == nil) {
            ipAddress = [self getIpAddressFromHostName:host];
            [CCHostFilterRule mapHost:host toIp:ipAddress];
            return ipAddress;
        }
    } else {
        ipAddress = [self getIpAddressFromHostName:host];
    }
    [CCHostFilterRule mapHost:host toIp:ipAddress];
    return ipAddress;
}

+ (NSString *)getIpAddressFromHostName:(NSString *)host
{
    NSString *ipAddress = [self getIpv6AddressFromHost:host];
    if (ipAddress == nil) {
        ipAddress = [self getIpv4AddressFromHost:host];
    }
    return ipAddress;
}

+ (NSString *)getIpv4AddressFromHost:(NSString *)host
{
    const char *hostName = host.UTF8String;
    struct hostent *phost = [self getHostByName:hostName
                                                execute:^struct hostent *{
        return gethostbyname(hostName);
    }];
    
    if (phost == NULL)
        return nil;
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phost->h_addr_list[ 0 ], 4);
    
    char ip[ 20 ] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    return [NSString stringWithUTF8String:ip];
}

+ (NSString *)getIpv6AddressFromHost:(NSString *)host
{
    const char *hostName = host.UTF8String;
    struct hostent *phost = [self getHostByName:hostName
                                                execute:^struct hostent *{
        return gethostbyname2(hostName, AF_INET6);
    }];
    
    if (phost == NULL) {
        return nil;
    }
    
    char ip[ 32 ] = {0};
    char **aliases;
    switch (phost->h_addrtype) {
        case AF_INET:
        case AF_INET6: {
            for (aliases = phost->h_addr_list; *aliases != NULL; aliases++) {
                NSString *ipAddress = [NSString stringWithUTF8String:inet_ntop(phost->h_addrtype, *aliases, ip, sizeof(ip))];
                if (ipAddress)
                    return ipAddress;
            }
        } break;
        default:
            break;
    }
    return nil;
}


+ (struct hostent *)getHostByName:(const char *)hostName execute:(struct hostent * (^)(void))execute
{
    if (execute == nil)
        return NULL;
    
    __block struct hostent *phost = NULL;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperationWithBlock:^{
        phost = execute();
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC));
    [queue cancelAllOperations];
    return phost;
}

@end
