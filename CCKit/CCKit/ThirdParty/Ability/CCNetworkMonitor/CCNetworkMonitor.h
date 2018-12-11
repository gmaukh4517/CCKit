//
//  CCNetworkMonitor.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCNetworkReachabilityStatus) {
    /** 未知网络 **/
    CCNetworkReachabilityStatusUnknown = -1,
    /** 无网络 **/
    CCNetworkReachabilityStatusNone = 0,
    /** WWAN网络 **/
    CCNetworkReachabilityStatusReachableViaWWAN,
    /** WiFi网络 **/
    CCNetworkReachabilityStatusReachableViaWiFi,
    /** 2G网络 **/
    CCNetworkReachabilityStatusReachableVia2G,
    /** 3G网络 **/
    CCNetworkReachabilityStatusReachableVia3G,
    /** 4G网络 **/
    CCNetworkReachabilityStatusReachableVia4G,

};

@protocol CCNetworkMonitorProtocol <NSObject>

@optional
- (void)networkStatusChangeNotification:(NSDictionary *)userInfo; //网络状态变动通知

@end

/** 通知消息 **/
extern NSString *const CCNetworkReachabilityDidChangeNotification;
/** 通知状态 **/
extern NSString *const CCNetworkReachabilityNotificationStatusItem;

@interface CCNetworkMonitor : NSObject

/** 可通过的网络状态 **/
@property (readwrite, nonatomic, assign) CCNetworkReachabilityStatus networkReachabilityStatus;

/** 是否可以访问网络。  **/
@property (readonly, nonatomic, assign, getter=isReachable) BOOL reachable;

/** 是否可通过WWAN访问网络。 **/
@property (readonly, nonatomic, assign, getter=isReachableViaWWAN) BOOL reachableViaWWAN;

/** 是否可通过WiFi访问网络。 **/
@property (readonly, nonatomic, assign, getter=isReachableViaWiFi) BOOL reachableViaWiFi;

/** 网络监听单例 **/
+ (CCNetworkMonitor *)sharedInstance;

/** 网络可达性状态 **/
+ (CCNetworkReachabilityStatus)currentNetworkStatus;

/** 本地化网络可达性状态字符串 **/
+ (NSString *)localizedNetworkReachabilityStatusString;

/** 设置网络监听回调委托 **/
- (void)networkChangeDelegate:(id<CCNetworkMonitorProtocol>)delegate;

/** 设置网络监听回调Block **/
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(CCNetworkReachabilityStatus status))block;

@end
