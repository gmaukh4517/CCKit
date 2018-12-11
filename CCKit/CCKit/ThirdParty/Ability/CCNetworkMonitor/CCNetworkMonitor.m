//
//  CCNetworkMonitor.m
//  CCKit
//
// Copyright (c) 2018 CC 
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CCNetworkMonitor.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#pragma mark -
#pragma mark :. 协议模块

NSString *const CCNetworkReachabilityDidChangeNotification = @"com.cc.network.reachability.change";
NSString *const CCNetworkReachabilityNotificationStatusItem = @"CCNetworkReachabilityNotificationStatusItem";

typedef void (^CCNetworkReachabilityStatusBlock)(CCNetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, CCNetworkReachabilityAssociation) {
    CCNetworkReachabilityForAddress = 1,
    CCNetworkReachabilityForAddressPair = 2,
    CCNetworkReachabilityForName = 3,
};

NSString *CCStringFromNetworkReachabilityStatus(CCNetworkReachabilityStatus status)
{
    switch (status) {
        case CCNetworkReachabilityStatusNone: //无网络
            return NSLocalizedStringFromTable(@"No network", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusReachableViaWiFi: //Wifi网络
            return NSLocalizedStringFromTable(@"WiFi", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusReachableViaWWAN: //WWAN网络
            return NSLocalizedStringFromTable(@"WWAN", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusReachableVia2G: //2G网络
            return NSLocalizedStringFromTable(@"2G", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusReachableVia3G: //3G网络
            return NSLocalizedStringFromTable(@"3G", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusReachableVia4G: //4G网络
            return NSLocalizedStringFromTable(@"4G", @"CCNetworkMonitor", nil);
        case CCNetworkReachabilityStatusUnknown: //未知网络
            return NSLocalizedStringFromTable(@"Unknown", @"CCNetworkMonitor", nil);
    }
}

static CCNetworkReachabilityStatus CCNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags)
{
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    CCNetworkReachabilityStatus status = CCNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO)
        status = CCNetworkReachabilityStatusNone;
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
        status = CCNetworkReachabilityStatusReachableViaWWAN;
#endif
    else
        status = CCNetworkReachabilityStatusReachableViaWiFi;

    return status;
}

static void CCNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info)
{
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[CCNetworkMonitor class]], @"info was wrong class in ReachabilityCallback");

    CCNetworkMonitor *noteObject = (__bridge CCNetworkMonitor *)info;
    noteObject.networkReachabilityStatus = CCNetworkReachabilityStatusForFlags(flags);
    [noteObject performSelectorOnMainThread:NSSelectorFromString(@"networkStatusChangedNotification") withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark :. CCNetworkMonitor

@interface CCNetworkMonitor ()

@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) CCNetworkReachabilityAssociation networkReachabilityAssociation;

@property (readwrite, nonatomic, copy) CCNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@property (readwrite, nonatomic, weak) id<CCNetworkMonitorProtocol> networkReachabilityStatusDelegate;

@end

@implementation CCNetworkMonitor

+ (CCNetworkMonitor *)sharedInstance
{
    static CCNetworkMonitor *comInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        comInstance = [[CCNetworkMonitor alloc] init];
    });
    return comInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self reachabilityForInternetConnection];
    }
    return self;
}

#pragma mark - 当前网络状态枚举
/** 网络可达性状态 **/
+ (CCNetworkReachabilityStatus)currentNetworkStatus
{
    return [CCNetworkMonitor sharedInstance].networkReachabilityStatus;
}

/** 本地化网络可达性状态字符串 **/
+ (NSString *)localizedNetworkReachabilityStatusString
{
    return CCStringFromNetworkReachabilityStatus([CCNetworkMonitor sharedInstance].networkReachabilityStatus);
}


- (void)networkStatusChangedNotification
{
    !self.networkReachabilityStatusBlock ?: self.networkReachabilityStatusBlock(self.networkReachabilityStatus);
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNetworkReachabilityDidChangeNotification object:nil userInfo:@{ CCNetworkReachabilityNotificationStatusItem : @(self.networkReachabilityStatus) }];

    NSDictionary *userInfo = @{ @"CCNetworkStatus" : @(self.networkReachabilityStatus),
                                @"CCNetworkStatusString" : CCStringFromNetworkReachabilityStatus(self.networkReachabilityStatus) };
    !self.networkReachabilityStatusDelegate ?: [self.networkReachabilityStatusDelegate networkStatusChangeNotification:userInfo];
}

- (void)setReachabilityStatusChangeBlock:(void (^)(CCNetworkReachabilityStatus status))block
{
    self.networkReachabilityStatusBlock = block;
}

- (void)networkChangeDelegate:(id<CCNetworkMonitorProtocol>)delegate
{
    self.networkReachabilityStatusDelegate = delegate;
}

#pragma mark - 网络模块

#pragma mark -
#pragma mark :. Reachability Manager

- (void)reachabilityForInternetConnection
{
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    [self reachabilityWithAddress:&address];
}

- (void)reachabilityWithAddress:(const void *)hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);

    self.networkReachability = reachability;
    self.networkReachabilityStatus = CCNetworkReachabilityStatusUnknown;
    self.networkReachabilityAssociation = CCNetworkReachabilityForAddress;

    [self startMonitoring];
}

#pragma mark :. Reachability judgment

- (BOOL)isReachable
{
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN
{
    return self.networkReachabilityStatus == CCNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi
{
    return self.networkReachabilityStatus == CCNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark :. Reachability
- (void)startMonitoring
{
    [self stopMonitoring];
    if (!self.networkReachability)
        return;

    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, CCNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    switch (self.networkReachabilityAssociation) {
        case CCNetworkReachabilityForName:
            break;
        case CCNetworkReachabilityForAddress:
        case CCNetworkReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
                CCNetworkReachabilityStatus status = CCNetworkReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.networkReachabilityStatus = status;
                    [self networkStatusChangedNotification];
                });
            });
        } break;
    }
}

- (void)stopMonitoring
{
    if (!self.networkReachability)
        return;

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

@end
