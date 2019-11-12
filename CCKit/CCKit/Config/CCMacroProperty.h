//
//  CCProperty.h
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

#ifndef CCMacroProperty_h
#define CCMacroProperty_h

#import <UIKit/UIDevice.h>
#import <pthread.h>

#define Bundle [NSBundle mainBundle]

/** 资源文件 */
#define cc_Resource(bundleName, Extaension) ([[NSBundle mainBundle] URLForResource:bundleName withExtension:Extaension] ? [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:bundleName withExtension:Extaension]] : nil)

/** 资源图片 */
#define CCResourceImage(name) (cc_Resource(@"CCKit", @"bundle") ? [UIImage imageWithContentsOfFile:[[cc_Resource(@"CCKit", @"bundle") resourcePath] stringByAppendingPathComponent:name]] : [UIImage new])


/** 版本号 */
#define kVersonNumber [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
/** Build ID **/
#define kBuildIdentifier [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
/** Build 版本号 **/
#define kBuildNumber [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]
/** 应用名称 */
#define AppName [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
/** 设备编号 */
#define deviceUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

/** 设备类型 */
#define deviceType [[UIDevice currentDevice] model];
#define iOS7Later (CURRENT_SYS_VERSION >= 7.0f)
#define iOS8Later (CURRENT_SYS_VERSION >= 8.0f)
#define iOS9Later (CURRENT_SYS_VERSION >= 9.0f)
#define iOS10Later (CURRENT_SYS_VERSION >= 10.0f)
#define iOS11Later (CURRENT_SYS_VERSION >= 11.0f)
#define iOS12Later (CURRENT_SYS_VERSION >= 12.0f)
#define iOS13Later (CURRENT_SYS_VERSION >= 13.0f)

/** 设备版本号 */
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

/** 获取缓存 */
#define userDefaults [NSUserDefaults standardUserDefaults]

/** 应用委托 */
#define ApplicationDelegate [[UIApplication sharedApplication] delegate]
#define SharedApplication [UIApplication sharedApplication]
#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

/** 设置网络活动指示灯 */
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x) [UIApplication sharedApplication].networkActivityIndicatorVisible = x

/** 导航栏 */
#define SelfNavBar self.navigationController.navigationBar
#define SelfNavBarHeight self.navigationController.navigationBar.bounds.size.height
#define SelfDefaultToolbarHeight self.navigationController.navigationBar.frame.size.height

/** 底部导航 */
#define SelfTabBar self.tabBarController.tabBar
#define SelfTabBarHeight self.tabBarController.tabBar.bounds.size.height

/** 主屏幕 */
#define MainScreen [UIScreen mainScreen]

/** 屏幕高宽 */
#define ScreenRect [[UIScreen mainScreen] bounds]

/** 屏幕大小 */
#define winsize [[UIScreen mainScreen] bounds].size

/** 获取一段时间间隔 */
#define kStartTime NSDate *startTime = [NSDate date]
#define kEndTime NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

#pragma mark -
#pragma mark :. 注册事件
/*************************  注册事件  *************************/
/** 注册通知 */
#define cc_NoticeObserver(TARGET, SELECTOR, NAME, OBJECT) [[NSNotificationCenter defaultCenter] addObserver:TARGET selector:SELECTOR name:NAME object:OBJECT];
#define cc_NoticeremoveObserver(TARGET, NAME, OBJECT) [[NSNotificationCenter defaultCenter] removeObserver:TARGET name:NAME object:OBJECT];
/** 发送通知 */
#define cc_NoticePost(NAME, OBJECT) [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJECT];
#define cc_NoticePostInfo(NAME, OBJECT, USERINFO) [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJECT userInfo:USERINFO];

#pragma mark -
#pragma mark :. 设备
/*************************  设备  *************************/
/** 判断是否为iPhone */
#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

/** 判断是否是iPad */
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/** 判断是否为iPod */
#define isiPod ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

/** 判断是否 Retina屏 */
#define isRetina ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0f))

/** 设备是否为iPhone 4/4S 分辨率320x480，像素640x960，@2x */
#define device_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 5C/5/5S 分辨率320x568，像素640x1136，@2x */
#define device_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 6 分辨率375x667，像素750x1334，@2x */
#define device_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 6 Plus 分辨率414x736，像素1242x2208，@3x */
#define device_iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 7 分辨率375x667，像素750x1334，@2x */
#define device_iPhone7 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 7 Plus 分辨率414x736，像素1242x2208，@3x */
#define device_iPhone7P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 8 分辨率375x667，像素750x1334，@2x */
#define device_iPhone8 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 8 Plus 分辨率414x736，像素1242x2208，@3x */
#define device_iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone X 分辨率375x812，像素1125x2436，@3x */
#define device_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone XS 分辨率375x812，像素1125x2436，@3x */
#define device_iPhoneXS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone XR 分辨率414x896，像素828x1792，@3x */
#define device_iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone X MAx 分辨率424x896，像素1242x2688，@3x */
#define device_iPhoneXMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

/** 设备是否为iPhone 是否是X及以上设备 */
#define device_iPhoneXAbove ({                                                    \
    BOOL isBool = NO;                                                             \
    if (@available(iOS 11.0, *)) {                                                \
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.top == 44) \
            isBool = YES;                                                         \
    }                                                                             \
    isBool;                                                                       \
})

#pragma mark -
#pragma mark :. 本地文档相关
/*************************  本地文档相关  *************************/

/** 定义UIImage对象 */
#define cc_ImageNamed(_pointer) ([UIImage imageNamed:[UIUtil imageName:_pointer]])

/** 定义UIImage对象并从本地文件读取加载图片 */
#define cc_Image(name) ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]])

/** 读取本地图片 */
#define cc_LoadImage(file, ext) ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:ext]])

/** 获取Documents目录 */
#define cc_DocumentsPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

/** 获得Documents下指定文件名的文件路径 */
#define cc_FilePath(filename) ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:filename];)

/** 获取Library目录 */
#define cc_LibraryPath ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Caches目录 */
#define cc_CachesPath ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Tmp目录 */
#define cc_TmpPath NSTemporaryDirectory()

/** NSFileManager 实例化 */
#define cc_FileManager [NSFileManager defaultManager]

/** NSRunLoop 实例化 */
#define cc_MainRunLoop [NSRunLoop mainRunLoop]

#endif /* CCProperty_h */
