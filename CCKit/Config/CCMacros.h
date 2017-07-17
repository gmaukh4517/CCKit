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

#import <pthread.h>

#pragma mark -
#pragma mark :. GCD 线程处理

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
static inline void cc_dispatch_after(NSTimeInterval second, void (^block)())
{
    dispatch_after(cc_dispatch_walltime_delay(second), dispatch_get_main_queue(), block);
}

/** 是否在主队列/线程中。 **/
static inline bool cc_dispatch_is_main_queue()
{
    return pthread_main_np() != 0;
}

/** 在主队列上提交用于异步执行的块 **/
static inline void cc_dispatch_async_on_global_queue(void (^block)())
{
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

/** 在主队列上提交用于异步执行的块，并立即返回。**/
static inline void cc_dispatch_async_on_main_queue(void (^block)())
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 在主队列上提交执行块，并等待直到块完成。*/
static inline void cc_dispatch_sync_on_main_queue(void (^block)())
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
#pragma mark :. 其他

/** 越狱工具路径 **/
const char *jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt",
};

/** 判断设备是否越狱 **/
static inline int cc_isJailbreak()
{
    int appay_size = sizeof(jailbreak_tool_pathes) / sizeof(jailbreak_tool_pathes[0]);
    for (int i = 0; i < appay_size; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}

#endif /* CCMacros_h */
