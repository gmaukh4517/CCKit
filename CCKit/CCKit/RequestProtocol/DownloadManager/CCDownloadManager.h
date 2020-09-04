//
//  CCDownloadManager.h
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
#import "CCSessionDownload.h"
#import <Foundation/Foundation.h>

@protocol CCDownloadManagerDelegate <NSObject>

@optional

/**
 单个完成回调
 
 @param downloader 下载器
 @param uniqueid 下载文件 id
 */
- (void)downloader:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid;

/**
 所有下载任务完成回调
 */
- (void)downloaderComplete;

/**
 删除单个下载回调
 
 @param downloader 下载器
 @param uniqueid 下载文件 id
 */
- (void)downloaderDelete:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid;

@end

@interface CCDownloadManager : NSObject

/**
 *  设置最大并发量
 *
 *  @notice 上限为5，默认3，不能为0
 */
@property (nonatomic, assign) NSInteger maxSubThread;

@property (nonatomic, strong, readonly) NSArray *downloadArr;

/**
 下载代理回调
 */
- (void)setDownloadDelegate:(id<CCDownloadManagerDelegate>)downloadDelegate;
- (void)removeDownloadDelegate:(id<CCDownloadManagerDelegate>)downloadDelegate;


+ (instancetype)sharedManager;

/**
 添加下载任务
 
 @param url 下载地址
 */
- (void)addTaskWithUrl:(NSString *)url;

/**
 添加下载任务
 
 @param model 下载模型
 */
- (void)addTaskWithModel:(CCSessionDownload *)model;

/**
 *  开始任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)startTaskWithUniqueId:(NSString *)uniqueId;

/**
 *  暂停任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)suspendTaskWithUniqueId:(NSString *)uniqueId;
/**
 *  继续任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (BOOL)resumeTaskWithUniqueId:(NSString *)uniqueId;
/**
 *  撤销任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)cancelTaskWithUniqueId:(NSString *)uniqueId;

/**
 暂停所有下载任务
 */
- (void)puaseAllDownLoad;

/**
 启动所有下载任务
 */
- (void)startAllDownLoad;

@end
