//
//  CCAppDelegateSOA.m
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

#import "CCAppDelegateSOA.h"

@protocol CCSOADelegate <UIApplicationDelegate>

@end

@interface CCAppDelegateSOA () <UIApplicationDelegate>

@property (nonatomic, strong) NSMutableArray<id<UIApplicationDelegate>> *allServices;

@end

@implementation CCAppDelegateSOA

#pragma mark - 获取SOA单实例
+ (instancetype)instance
{
    static CCAppDelegateSOA *insance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        insance = [[CCAppDelegateSOA alloc] init];
    });
    return insance;
}

#pragma mark - 获取全部服务

- (NSMutableArray *)allServices
{
    if (!_allServices) {
        _allServices = [[NSMutableArray alloc] init];
    }
    return _allServices;
}

#pragma mark - 服务动态注册

- (void)registeService:(id<UIApplicationDelegate>)service
{
    if (![self.allServices containsObject:service]) {
        [self.allServices addObject:service];
    }
}

+ (void)registeServices:(id<UIApplicationDelegate>)service
{
    [[CCAppDelegateSOA instance] registeService:service];
}

+ (void)registeServicesWithName:(NSString *)serviceName
{
    [[CCAppDelegateSOA instance] registeService:[NSClassFromString(serviceName) new]];
}

#pragma mark -
#pragma mark :. 分发服务

+ (void)applicationDidFinishLaunching:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationDidFinishLaunching:application];
    }
}

+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application willFinishLaunchingWithOptions:launchOptions];
    }
    return isOptions;
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application didFinishLaunchingWithOptions:launchOptions];
    }
    return isOptions;
}

+ (void)applicationDidBecomeActive:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationDidBecomeActive:application];
    }
}

+ (void)applicationWillResignActive:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationWillResignActive:application];
    }
}

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application handleOpenURL:url];
    }
    return isOptions;
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return isOptions;
}

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:app openURL:url options:options];
    }
    return isOptions;
}

+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationDidReceiveMemoryWarning:application];
    }
}

+ (void)applicationWillTerminate:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationWillTerminate:application];
    }
}

+ (void)applicationSignificantTimeChange:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationSignificantTimeChange:application];
    }
}

+ (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application willChangeStatusBarOrientation:newStatusBarOrientation duration:duration];
    }
}

+ (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
    }
}

+ (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application willChangeStatusBarFrame:newStatusBarFrame];
    }
}

+ (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didChangeStatusBarFrame:oldStatusBarFrame];
    }
}

+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didRegisterUserNotificationSettings:notificationSettings];
    }
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didReceiveRemoteNotification:userInfo];
    }
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didReceiveLocalNotification:notification];
    }
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:responseInfo completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application performFetchWithCompletionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }
}

+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void (^)(NSDictionary *__nullable replyInfo))reply
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application handleWatchKitExtensionRequest:userInfo reply:reply];
    }
}

+ (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationShouldRequestHealthAuthorization:application];
    }
}

+ (void)applicationDidEnterBackground:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationDidEnterBackground:application];
    }
}

+ (void)applicationWillEnterForeground:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationWillEnterForeground:application];
    }
}

+ (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationProtectedDataWillBecomeUnavailable:application];
    }
}

+ (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa applicationProtectedDataDidBecomeAvailable:application];
    }
}

+ (nullable UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *viewController;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            viewController = [soa application:application viewControllerWithRestorationIdentifierPath:identifierComponents coder:coder];
    }
    return viewController;
}

+ (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application shouldSaveApplicationState:coder];
    }
    return isOptions;
}

+ (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application shouldRestoreApplicationState:coder];
    }
    return isOptions;
}

+ (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application willEncodeRestorableStateWithCoder:coder];
    }
}

+ (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didDecodeRestorableStateWithCoder:coder];
    }
}

+ (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application willContinueUserActivityWithType:userActivityType];
    }
    return isOptions;
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler
{
    BOOL isOptions = NO;
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            isOptions = [soa application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    return isOptions;
}

+ (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didFailToContinueUserActivityWithType:userActivityType error:error];
    }
}


+ (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application didUpdateUserActivity:userActivity];
    }
}

+ (void)application:(UIApplication *)application userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata
{
    for (id<CCSOADelegate> soa in [CCAppDelegateSOA instance].allServices) {
        if ([soa respondsToSelector:_cmd])
            [soa application:application userDidAcceptCloudKitShareWithMetadata:cloudKitShareMetadata];
    }
}
@end
