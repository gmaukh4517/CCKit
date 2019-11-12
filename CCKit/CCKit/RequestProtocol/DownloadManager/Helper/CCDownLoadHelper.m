//
//  CCDownLoadHelper.m
//  CCKit
//
// Copyright (c) 2015 CC
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

#import "CCDownLoadHelper.h"

@implementation CCDownLoadHelper

/**
 获取文件缓存路径

 @return 路径地址
 */
+ (NSString *)cacheFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Download"];
    BOOL isDir = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioDir isDirectory:&isDir] == NO) {
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSuccess) {
            NSLog(@"创建Download目录失败T_T");
        }
    }
    return audioDir;
}

/**
 获取本地缓存字节

 @param path 缓存路径
 @return 返回文件大小
 */
+ (NSInteger)cacheFileWithPath:(NSString *)path
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *contentData = [fh readDataToEndOfFile];
    return contentData ? contentData.length : 0;
}

/**
 缓存文件路径

 @param url 下载链接
 @return 返回缓存路径
 */
+ (NSString *)cacheFileWithURL:(NSString *)url
{
    return [[CCDownLoadHelper cacheFilePath] stringByAppendingPathComponent:[url lastPathComponent]];
}

/**
 文件是否存在，若不存在，则创建并返回结果，若存在则返回YES

 @param path 缓存路径
 @return 返回是否存在
 */
+ (BOOL)fileIsExistAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL flag = [manager fileExistsAtPath:path];
    if (!flag)
        flag = [manager createFileAtPath:path contents:nil attributes:nil];

    return flag;
}

/**
 文件夹是否存在，若不存在，则创建并返回结果，若存在则返回YES

 @param path 缓存路径
 @return 返回是否存在
 */
+ (BOOL)directoryIsExistAtPath:(NSString *)path
{
    BOOL isDir;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL flag = [manager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && !flag)) //文件夹不存在
        flag = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return flag;
}

/**
 删除文件

 @param path 缓存路径
 @return 是否删除成功
 */
+ (BOOL)deleteCacheFile:(NSString *)path
{
    BOOL isSuccess = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:path])
        isSuccess = [fileManage removeItemAtPath:path error:nil];

    return isSuccess;
}

/**
 获取请求

 @param url 下载地址
 @param length 读取位置
 @return 返回请求
 */
+ (NSMutableURLRequest *)requestWithUrl:(id)url Range:(long long)length
{
    NSURL *requestUrl = [url isKindOfClass:[NSURL class]] ? url : [NSURL URLWithString:url];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:5 * 60];

    if (length)
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-", length] forHTTPHeaderField:@"Range"];

    return request;
}

@end
