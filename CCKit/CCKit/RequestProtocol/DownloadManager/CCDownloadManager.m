//
//  CCDownloadManager.m
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

#import "CCDownloadManager.h"
#import "CCDownloadMultiProxy.h"
#import "CCDownloadStore.h"
#import <CCKit/CCExtension.h>
#import <UIKit/UIApplication.h>

#define kArrayName @"taskLists"

#import "CCEventNoticeCenter.h"

@interface CCDownloadManager () {
    CCDownloadMultiProxy *_proxy;
}

@property (nonatomic, strong) CCDownloadStore *store;

@property (nonatomic, strong) NSOperationQueue *taskQueue;
@property (nonatomic, strong) NSMutableArray *taskLists;
//@property (nonatomic, copy) didDownLoadCompleteBlock completeBlock;

@property (nonatomic, assign) BOOL isQueueComplete;

@end

static NSString *const CCDownloadCache = @"CCDownloadCache.sqlite";
static NSString *const CCCacheTableName = @"CCDownloadCacheTable";

@implementation CCDownloadManager

- (CCDownloadStore *)store
{
    if (!_store) {
        _store = [[CCDownloadStore alloc] initDBWithName:CCDownloadCache];
    }
    return _store;
}

static CCDownloadManager *manager;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        //注册通知，当应用将要退出时
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(storeDownloadList) name:UIApplicationWillTerminateNotification object:nil];
        //从数据库读取之前的下载列表
        [manager getDownloadListFromStore];
        //观察self.taskLists
        [manager addObserver:manager forKeyPath:kArrayName options:NSKeyValueObservingOptionNew context:nil];
        
        [CCEventNoticeCenter addTarget:self eventName:@"CCDownloadStateSuccess" actionSEL:@selector(downloaderComplete:)];
    });
    return manager;
}

- (void)dealloc
{
    //销毁前，需要将当前下载列表对象进行存储
    [self storeDownloadList];
    //移除观察
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kArrayName];
}

- (NSArray *)downloadArr
{
    return self.taskLists;
}
- (void)setDownloadDelegate:(id<CCDownloadManagerDelegate>)downloadDelegate
{
    if (!_proxy)
        _proxy = [CCDownloadMultiProxy proxy];
    
    [_proxy addDelegate:downloadDelegate];
}

- (void)removeDownloadDelegate:(id<CCSessionDownloadDelegate>)downloadDelegate
{
    [_proxy removeDelete:downloadDelegate];
}

#pragma mark :. define
/**
 *  设置最大并发量
 *
 *  @notice 上限为5，默认3，不能为0
 *  @param count 个数
 */
- (void)setMaxSubThread:(NSInteger)maxSubThread
{
    _maxSubThread = maxSubThread;
    if (maxSubThread >= 5) {
        self.taskQueue.maxConcurrentOperationCount = 5;
    } else if (maxSubThread <= 0) {
        self.taskQueue.maxConcurrentOperationCount = 1;
    } else {
        self.taskQueue.maxConcurrentOperationCount = maxSubThread;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"operations"]) {
        if (0 == ((NSOperationQueue *)object).operations.count) {
            if (!self.isQueueComplete) {
                if ([(id<CCDownloadManagerDelegate>)self->_proxy respondsToSelector:@selector(downloaderComplete)])
                    [(id<CCDownloadManagerDelegate>)self->_proxy downloaderComplete];
            }
            self.isQueueComplete = NO;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)operationCompletion:(NSString *)uniqueId
{
    CCSessionDownload *download = [self modelWithUniqueId:uniqueId];
    if (download.status == CCDownloadStateSuccess || download.status == CCDownloadStateFailed) {
        [self.taskLists removeObject:download];
        if ([(id<CCDownloadManagerDelegate>)self->_proxy respondsToSelector:@selector(downloader:withUniqueid:)])
            [(id<CCDownloadManagerDelegate>)self->_proxy downloader:download withUniqueid:download.uniqueId];
    }
}

#pragma mark :. private

/**
 根据标识从列表获取下载对象
 
 @param uniqueId 绘画ID
 */
- (CCSessionDownload *)modelWithUniqueId:(NSString *)uniqueId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId = %@", uniqueId];
    return [[self.taskLists filteredArrayUsingPredicate:predicate] firstObject];
}

/**
 销毁前，处理状态，存储列表
 */
- (void)storeDownloadList
{
    for (CCSessionDownload *model in self.taskLists) {
        if (model.status == CCDownloadStateRunning)
            [model stop];
        
        if (model.status == CCDownloadStateReady)
            model.status = CCDownloadStateStopped;
        
        NSMutableDictionary *storeDic = [NSMutableDictionary dictionary];
        [storeDic setObject:[model.model cc_keyValues] forKey:@"model"];
        [storeDic setObject:model.downloadUserInfo forKey:@"downloadUserInfo"];
        [storeDic setObject:model.uniqueId forKey:@"uniqueId"];
        [storeDic setObject:@(model.status) forKey:@"status"];
        
        [self.store putObject:storeDic withId:model.uniqueId intoTable:CCCacheTableName];
    }
}

/**
 从数据库读取之前的下载列表数据
 */
- (void)getDownloadListFromStore
{
    NSArray *list = [self.store getAllItemsWithTable:CCCacheTableName];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in list)
        [array addObject:[CCSessionDownload cc_objectWithKeyValues:item]];
    
    [self.taskLists addObjectsFromArray:array];
}

#pragma mark :. getter/setter
- (NSOperationQueue *)taskQueue
{
    if (!_taskQueue) {
        _taskQueue = [[NSOperationQueue alloc] init];
        _taskQueue.maxConcurrentOperationCount = 3;
        [_taskQueue addObserver:self forKeyPath:@"operations" options:0 context:nil];
    }
    return _taskQueue;
}
- (NSMutableArray *)taskLists
{
    if (!_taskLists) {
        _taskLists = [NSMutableArray array];
    }
    return _taskLists;
}

#pragma mark -
#pragma mark :. handler

/**
 添加下载任务
 
 @param url 下载地址
 */
- (void)addTaskWithUrl:(NSString *)url
{
    NSString *cachePath = [CCDownLoadHelper cacheFileWithURL:url];
    if ([CCDownLoadHelper directoryIsExistAtPath:cachePath]) {
        [self addTaskWithModel:[[CCSessionDownload alloc] initWithUrl:url]];
    }
}

/**
 添加下载任务
 
 @param model 下载模型
 */
- (void)addTaskWithModel:(CCSessionDownload *)model
{
    if (![self modelWithUniqueId:model.uniqueId]) {
        [self.taskLists addObject:model];
        [self.taskQueue addOperation:[model valueForKey:@"getOperation"]];
    }
}

/**
 *  开始任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)startTaskWithUniqueId:(NSString *)uniqueId
{
    CCSessionDownload *model = [self modelWithUniqueId:uniqueId];
    [self.taskQueue addOperation:[model valueForKey:@"getOperation"]];
}

/**
 *  暂停任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)suspendTaskWithUniqueId:(NSString *)uniqueId
{
    CCSessionDownload *model = [self modelWithUniqueId:uniqueId];
    [model stop];
}

/**
 *  继续任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (BOOL)resumeTaskWithUniqueId:(NSString *)uniqueId
{
    BOOL isStart = NO;
    CCSessionDownload *model = [self modelWithUniqueId:uniqueId];
    if (model) {
        if (model.status == CCDownloadStateStopped ||
            model.status == CCDownloadStateFailed ||
            model.status == CCDownloadStateReady ||
            model.status == CCDownloadStatePreparing) {
            [model start];
            isStart = YES;
        }
    }
    return isStart;
}

/**
 *  撤销任务
 *
 *  @param uniqueId 任务uniqueId
 */
- (void)cancelTaskWithUniqueId:(NSString *)uniqueId
{
    CCSessionDownload *download = [self modelWithUniqueId:uniqueId];
    [download cleanSession];
    [self.taskLists removeObject:download];
    [self.store deleteObjectById:download.uniqueId fromTable:CCCacheTableName];
    
    dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
        if ([(id<CCDownloadManagerDelegate>)self->_proxy respondsToSelector:@selector(downloaderDelete:withUniqueid:)])
            [(id<CCDownloadManagerDelegate>)self->_proxy downloaderDelete:download withUniqueid:download.uniqueId];
    });
}

/**
 暂停所有下载任务
 */
- (void)puaseAllDownLoad
{
    self.isQueueComplete = YES;
    for (CCSessionDownload *model in self.taskLists) {
        if (model.status == CCDownloadStateRunning) {
            [model stop];
        }
    }
}

/**
 启动所有下载任务
 */
- (void)startAllDownLoad
{
    self.isQueueComplete = YES;
    for (CCSessionDownload *model in self.taskLists) {
        if (model.status != CCDownloadStateRunning || model.status != CCDownloadStateSuccess || model.status != CCDownloadStateFailed) {
            [model start];
        }
    }
}

// 删除完成删除并且回调
- (void)downloaderComplete:(CCEvent *)event
{
    CCSessionDownload *downloader = event.object;
    if ([(id<CCDownloadManagerDelegate>)self->_proxy respondsToSelector:@selector(downloader:withUniqueid:)])
        [(id<CCDownloadManagerDelegate>)self->_proxy downloader:downloader withUniqueid:downloader.uniqueId];
    
    [self.taskLists removeObject:downloader];
}

@end
