//
//  NSFileManager+CCAdd.h
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

@interface NSFileManager (CCAdd)

/**
 Get URL of Documents directory.
 
 @return Documents directory URL.
 */
+ (NSURL *)documentsURL;

/**
 Get path of Documents directory.
 
 @return Documents directory path.
 */
+ (NSString *)documentsPath;

/**
 Get URL of Library directory.
 
 @return Library directory URL.
 */
+ (NSURL *)libraryURL;

/**
 Get path of Library directory.
 
 @return Library directory path.
 */
+ (NSString *)libraryPath;

/**
 Get URL of Caches directory.
 
 @return Caches directory URL.
 */
+ (NSURL *)cachesURL;

/**
 Get path of Caches directory.
 
 @return Caches directory path.
 */
+ (NSString *)cachesPath;

/**
 Adds a special filesystem flag to a file to avoid iCloud backup it.
 
 @param path Path to a file to set an attribute.
 */
+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path;

/**
 Get available disk space.
 
 @return An amount of available disk space in Megabytes.
 */
+ (double)availableDiskSpace;

/** 根据路径返回目录或文件的大小 */
+ (unsigned long long)sizeOfFolder:(NSString *)folderPath;

/** 得到指定目录下的所有文件 */
+ (NSArray *)getAllFileNames:(NSString *)dirPath;

/** 删除指定目录或文件 */
+ (BOOL)clearCachesWithFilePath:(NSString *)path;

/** 清空指定目录下文件 */
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath;

/** 清理网页缓存 */
+ (BOOL)clearCachesWeb;

/** 清理信息类缓存 */
+ (BOOL)clearCachesInfo;

/** 清理所有缓存 */
+ (void)clearAllCaches;

/** 获取缓存大小 */
+ (NSUInteger)getCachesSize;

/** 获取缓存大小字符串 */
+ (NSString *)getCachesSizeString;

/** 创建cache/User文件夹 */
+ (void)createUserCacheFile;

/** 获取cache/User文件夹路径 */
+ (NSString *)getCacheUserPath;

@end
