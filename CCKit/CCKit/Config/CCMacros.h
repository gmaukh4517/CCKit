//
//  CCMacros.h
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

#ifndef CCMacros_h
#define CCMacros_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <pthread.h>
#include <sys/param.h>
#include <sys/mount.h>

#pragma mark -
#pragma mark :. GCD 线程处理

/** 阻塞等待执行函数 **/
static inline void cc_dispatch_semaphore(void (^block)(dispatch_semaphore_t semaphore))
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (block)
        block(semaphore);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

/** 异步等待执行函数 **/
static inline void cc_dispatch_async_global_semaphore(void (^block)(dispatch_semaphore_t semaphore))
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (block)
            block(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

/** 快速迭代方法 **/
static inline void cc_dispatch_apply(int count, void (^block)(size_t index))
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(count, queue, block);
}

/** 从现在返回dispatch_time延迟。 **/
static inline dispatch_time_t cc_dispatch_time_delay(NSTimeInterval second)
{
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 从现在返回dispatch_wall_time延迟。 **/
static inline dispatch_time_t cc_dispatch_walltime_delay(NSTimeInterval second)
{
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 在进队列上提交延时执行的快，并立即返回。**/
static inline void cc_dispatch_after(NSTimeInterval second, void (^block)(void))
{
    dispatch_after(cc_dispatch_walltime_delay(second), dispatch_get_main_queue(), block);
}

/** 是否在主队列/线程中。 **/
static inline bool cc_dispatch_is_main_queue()
{
    return pthread_main_np() != 0;
}

/** 在主队列上提交用于异步执行的块 **/
static inline void cc_dispatch_async_on_global_queue(void (^block)(void))
{
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

/** 在主队列上提交用于异步执行的块，并立即返回。**/
static inline void cc_dispatch_async_on_main_queue(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 在主队列上提交执行块，并等待直到块完成。*/
static inline void cc_dispatch_sync_on_main_queue(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark -
#pragma mark :. 数据验证

static inline bool cc_isNull_NilORNull(id ref)
{
    return (((ref) == nil) || ([(ref) isEqual:[NSNull null]]) || ([(ref) isEqualToString:@""]));
}

static inline bool cc_isNull_String(NSString *string)
{
    return (string != nil && [string isKindOfClass:[NSString class]] && ![string isEqualToString:@""]);
}

static inline bool cc_isNull_Array(NSArray *arr)
{
    return (arr != nil && [arr isKindOfClass:[NSArray class]] && [arr count] > 0);
}

static inline bool cc_isNull_Dictionary(NSDictionary *dic)
{
    return (dic != nil && [dic isKindOfClass:[NSDictionary class]] && [[dic allKeys] count] > 0);
}

static inline bool cc_isNull_Data(NSData *data)
{
    return (data != nil && [data isKindOfClass:[NSData class]]);
}

static inline bool cc_isNull_Number(NSNumber *number)
{
    return (number != nil && [number isKindOfClass:[NSNumber class]]);
}

static inline bool cc_isNull_Class(NSObject *obj, Class cls)
{
    return (obj != nil && [obj isKindOfClass:cls]);
}

static inline bool cc_verification_Has(NSString *string, NSString *key)
{
    return ([string rangeOfString:key].location != NSNotFound);
}

#pragma mark -
#pragma mark :. View
/** 设置投影 **/
static inline void cc_view_shadow(UIView *view, UIColor *color, CGSize offset, CGFloat opacity, CGFloat radius)
{
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
}

/** 设置阴影和圆角(必须给视图加背景颜色) **/
static inline void cc_view_shadow_radius(UIView *view, UIColor *color, CGSize offset, CGFloat opacity, CGFloat shadowRadius, CGFloat radius)
{
    view.layer.cornerRadius = radius;
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = shadowRadius;
}


/** view 圆角 */
static inline void cc_view_radius(UIView *view, CGFloat radius)
{
    [view.layer setCornerRadius:radius];
    [view.layer setMasksToBounds:YES];
}

/** view 边框 */
static inline void cc_view_border(UIView *view, CGFloat width, UIColor *color)
{
    [view.layer setBorderWidth:(width)];
    [view.layer setBorderColor:[color CGColor]];
}

/** view 圆角 边框 */
static inline void cc_view_border_radius(UIView *view, CGFloat radius, CGFloat width, UIColor *color)
{
    cc_view_radius(view, radius);
    cc_view_border(view, width, color);
}

/**
 view 单个圆角

 @param view 试图
 @param angle 某个圆角
 * UIRectCornerTopLeft
 * UIRectCornerTopRight
 * UIRectCornerBottomLeft
 * UIRectCornerBottomRight
 * UIRectCornerAllCorners
 @param radius 圆角度
 */
static inline void cc_view_singleFillet(UIView *view, UIRectCorner angle, CGFloat radius)
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:angle
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

static inline void cc_view_singleFilletSize(UIView *view, CGSize size, UIRectCorner angle, CGFloat radius)
{
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:angle
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

static inline void cc_view_singleARC(UIView *view, UIRectCorner angle, CGSize radiusSize)
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:angle
                                                         cornerRadii:radiusSize];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

#pragma mark -
#pragma mark :. 文件

/** 获取Documents目录 */
static inline NSString *cc_documentsPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

/** 获得Documents下指定文件名的文件路径 */
static inline NSString *cc_documentsPathName(NSString *fileName)
{
    return [cc_documentsPath() stringByAppendingPathComponent:fileName];
}

/** 获取Library目录 */
static inline NSString *cc_libraryPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

/** 获取Caches目录 */
static inline NSString *cc_cachesPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

/**
 生成子文件夹(如果子文件夹不存在，则直接创建；如果已经存在，则直接返回)

 @param path 文件路径
 @param subFolder 子文件夹名
 @return 返回文件夹路径
 */
static inline NSString *cc_createSubFolder(NSString *path, NSString *subFolder)
{
    NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", path, subFolder];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:subFolderPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }

    return subFolderPath;
}

#pragma mark -
#pragma mark :. 其他

/** 判断设备是否越狱 **/
static inline int cc_isJailbreak()
{
    /** 越狱工具路径 **/
    const char *jailbreak_tool_pathes[] = {
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt",
    };

    int appay_size = sizeof(jailbreak_tool_pathes) / sizeof(jailbreak_tool_pathes[ 0 ]);
    for (int i = 0; i < appay_size; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[ i ]]]) {
            return YES;
        }
    }
    return NO;
}

/** 手机剩余存储空间 **/
static inline double cc_freeDiskSpace()
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

/**
 等比计算(iPhone 6 基础)

 @param value 换算值
 */
static inline CGFloat autoSizeScale(CGFloat value)
{
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    return value * (mainSize.width / 320);
}

#endif /* CCMacros_h */
