//
//  NSFileManager+CCAdd.m
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

#import "NSFileManager+CCAdd.h"
#include <sys/xattr.h>

#define FILE_CACHE_USER @"User"
#define FILE_CACHE_WebKit @"WebKit"

@implementation NSFileManager (CCAdd)

+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directory
{
    return [self.defaultManager URLsForDirectory:directory inDomains:NSUserDomainMask].lastObject;
}

+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directory
{
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES)[0];
}

+ (NSURL *)documentsURL
{
    return [self URLForDirectory:NSDocumentDirectory];
}

+ (NSString *)documentsPath
{
    return [self pathForDirectory:NSDocumentDirectory];
}

+ (NSURL *)libraryURL
{
    return [self URLForDirectory:NSLibraryDirectory];
}

+ (NSString *)libraryPath
{
    return [self pathForDirectory:NSLibraryDirectory];
}

+ (NSURL *)cachesURL
{
    return [self URLForDirectory:NSCachesDirectory];
}

+ (NSString *)cachesPath
{
    return [self pathForDirectory:NSCachesDirectory];
}

+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path
{
    return [[NSURL.alloc initFileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

+ (double)availableDiskSpace
{
    NSDictionary *attributes = [self.defaultManager attributesOfFileSystemForPath:self.documentsPath error:nil];
    
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

/** 根据路径返回目录或文件的大小 */
+ (unsigned long long)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [self.defaultManager contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [self.defaultManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}

/** 得到指定目录下的所有文件 */
+ (NSArray *)getAllFileNames:(NSString *)dirPath
{
    NSArray *files = [self.defaultManager subpathsOfDirectoryAtPath:dirPath error:nil];
    return files;
}

/** 删除指定目录或文件 */
+ (BOOL)clearCachesWithFilePath:(NSString *)path
{
    return [self.defaultManager removeItemAtPath:path error:nil];
}

/** 清空指定目录下文件 */
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath
{
    // 获得全部文件数组
    NSArray *fileArr = [self getAllFileNames:dirPath];
    BOOL flag = NO;
    for (NSString *fileName in fileArr) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        flag = [self clearCachesWithFilePath:filePath];
        if (!flag) {
            break;
        }
    }
    return flag;
}

/** 清理网页缓存 */
+ (BOOL)clearCachesWeb
{
    NSString *path = [[self cachesPath] stringByAppendingPathComponent:FILE_CACHE_WebKit];
    return [self clearCachesWithFilePath:path];
}

/** 清理信息类缓存 */
+ (BOOL)clearCachesInfo
{
    return [self clearCachesWithFilePath:[self getCacheUserPath]];
}

/** 清理所有缓存 */
+ (void)clearAllCaches
{
    [self clearCachesWeb];
    [self clearCachesInfo];
}

/** 获取缓存大小 */
+ (NSUInteger)getCachesSize
{
    NSUInteger totalSize = 0;
    // 用户浏览信息列表缓存
    NSArray *filesArr = [self getAllFileNames:[self getCacheUserPath]];
    NSUInteger infoSize = 0;
    for (NSString *filePath in filesArr) {
        NSString *filePathAppend = [[self getCacheUserPath] stringByAppendingPathComponent:filePath];
        NSData *data = [NSData dataWithContentsOfFile:filePathAppend];
        infoSize += data.length;
    }
    
    // WebKit缓存
    NSString *webKitPath = [[self cachesPath] stringByAppendingPathComponent:FILE_CACHE_WebKit];
    NSArray *webFileArr = [self getAllFileNames:webKitPath];
    NSUInteger webSize = 0;
    for (NSString *filePath in webFileArr) {
        NSString *filePathAppend = [webKitPath stringByAppendingPathComponent:filePath];
        NSData *data = [NSData dataWithContentsOfFile:filePathAppend];
        webSize += data.length;
    }
    
    totalSize = infoSize + webSize;
    
    return totalSize;
}

/** 获取缓存大小字符串 */
+ (NSString *)getCachesSizeString
{
    NSUInteger cacheSize = [self getCachesSize] / 1024 / 1024;
    if (cacheSize == 0) return nil;
    
    NSString *cacheSizeStr = cacheSize >= 1 ? [NSString stringWithFormat:@"%luM", (unsigned long)cacheSize] : [NSString stringWithFormat:@"%luK", (unsigned long)cacheSize];
    return cacheSizeStr;
}

/** 创建cache/User文件夹 */
+ (void)createUserCacheFile
{
    NSString *path = [[self cachesPath] stringByAppendingPathComponent:FILE_CACHE_USER];
    if (![self.defaultManager fileExistsAtPath:path]) {
        [self.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else
        NSLog(@"File path Cache/User has been existed !");
}

/** 获取cache/User文件夹路径 */
+ (NSString *)getCacheUserPath
{
    NSString *userPath = [[self cachesPath] stringByAppendingPathComponent:FILE_CACHE_USER];
    return userPath;
}


@end
