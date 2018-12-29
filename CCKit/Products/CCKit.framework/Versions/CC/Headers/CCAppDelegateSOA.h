//
//  CCAppDelegateSOA.h
//  CCKit
//
// Copyright (c) 2015 CC ( https://github.com/gmaukh4517/CCKit )
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

NS_ASSUME_NONNULL_BEGIN

@import UIKit;

@interface CCAppDelegateSOA : NSObject

+ (instancetype)instance;

/**
 动态注册服务
 
 @param service 服务对象
 */
+ (void)registeServices:(id<UIApplicationDelegate>)service;

/**
 动态注册服务
 通过服务名称创建注册服务
 
 @param serviceName 服务名称
 */
+ (void)registeServicesWithName:(NSString *)serviceName;

#pragma mark -
#pragma mark :. 分发服务

+ (void)applicationDidFinishLaunching:(UIApplication *)application;

+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

+ (void)applicationDidBecomeActive:(UIApplication *)application;

+ (void)applicationWillResignActive:(UIApplication *)application;

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

+ (void)applicationWillTerminate:(UIApplication *)application;

+ (void)applicationSignificantTimeChange:(UIApplication *)application;

+ (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration;

+ (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation;

+ (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame;

+ (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame;

+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)(void))completionHandler;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)(void))completionHandler;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)(void))completionHandler;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)(void))completionHandler;

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

+ (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler API_AVAILABLE(ios(9.0));

+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void (^)(NSDictionary *__nullable replyInfo))reply;

+ (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application;

+ (void)applicationDidEnterBackground:(UIApplication *)application;

+ (void)applicationWillEnterForeground:(UIApplication *)application;
+ (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application;

+ (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application;

+ (nullable UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;

+ (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder;

+ (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder;

+ (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder;

+ (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder;

+ (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType;
+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler;

+ (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error;

+ (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity;

+ (void)application:(UIApplication *)application userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata;

@end

NS_ASSUME_NONNULL_END
