//
//  CCDownLoadOperation.m
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

#import "CCDownLoadOperation.h"

#import "CCDownLoadHelper.h"

#define kCCExecuting @"isExecuting"
#define kCCCancelled @"isCancelled"
#define kCCFinished @"isFinished"

@interface CCDownLoadOperation () <NSURLSessionDataDelegate> {
    BOOL _executing;
    //    BOOL _cancelled;
    BOOL _finished;
    //    BOOL _ready;
}

@property (nonatomic, strong) CCSessionDownload *sessionModel;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOutputStream *outputStream;
//当前下载大小
@property (nonatomic, assign) NSInteger currentSize;

@property (nonatomic, assign) NSInteger totalRead;
@property (nonatomic, copy) NSDate *lastSpeedTime;

@end

@implementation CCDownLoadOperation

/**
 创建任务
 
 @param model 下载对象
 */
- (instancetype)initWithModel:(CCSessionDownload *)model
{
    self = [super init];
    if (self) {
        self.sessionModel = model;
        [self creatDownloadSessionTask];
    }
    return self;
}

/**
 暂停任务
 */
- (void)suspendTask
{
    [self willChangeValueForKey:kCCExecuting];
    _executing = NO;
    [self.dataTask suspend];
    [self downloadStateHandler:CCDownloadStateStopped];
    self.lastSpeedTime = nil;
    [self didChangeValueForKey:kCCExecuting];
}

/**
 继续任务
 */
- (void)resumeTask
{
    [self willChangeValueForKey:kCCExecuting];
    _executing = YES;
    [self.dataTask resume];
    [self downloadStateHandler:CCDownloadStateReady];
    self.lastSpeedTime = [NSDate date];
    [self didChangeValueForKey:kCCExecuting];
}

/**
 创建下载任务
 */
- (void)creatDownloadSessionTask
{
    //获取缓存的长度
    NSInteger cacheLength = [CCDownLoadHelper cacheFileWithPath:self.sessionModel.model.absolutePath];
    self.sessionModel.model.currentSize = cacheLength;
    [self downloadStateHandler:CCDownloadStateReady];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSMutableURLRequest *request = [CCDownLoadHelper requestWithUrl:self.sessionModel.model.url Range:cacheLength];
    self.dataTask = [self.session dataTaskWithRequest:request];
}

#pragma mark -
#pragma mark :. NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.sessionModel.model.absolutePath append:YES];
    [self.outputStream open];
    self.sessionModel.model.totalSize = response.expectedContentLength;
    [self downloadStateHandler:CCDownloadStateRunning];
    self.lastSpeedTime = [NSDate date];
    //允许收到响应
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (self.sessionModel.status != CCDownloadStateRunning)
        [self downloadStateHandler:CCDownloadStateRunning];
    
    [self.outputStream write:data.bytes maxLength:data.length];
    self.currentSize += data.length;
    self.sessionModel.model.currentSize = self.currentSize;
    self.totalRead += data.length;
    if (self.sessionModel.model.totalSize > 0) {
        double progress = (double)self.currentSize / self.sessionModel.model.totalSize;
        
        id<CCSessionDownloadDelegate> downloadDelegate = (id<CCSessionDownloadDelegate>)self.sessionModel;
        if ([downloadDelegate respondsToSelector:@selector(dataDownloadAtPercent:withUniqueid:percent:)]) //下载进度回调
            [downloadDelegate dataDownloadAtPercent:self.sessionModel
                                       withUniqueid:self.sessionModel.uniqueId
                                            percent:[NSNumber numberWithDouble:progress]];
    }
    
    NSTimeInterval timeInterval = [self.lastSpeedTime timeIntervalSinceDate:[NSDate date]];
    timeInterval = -timeInterval;
    if (timeInterval >= 1) {
        NSInteger speed = self.totalRead / timeInterval;
        self.totalRead = 0;
        self.lastSpeedTime = [NSDate date];
        
        id<CCSessionDownloadDelegate> downloadDelegate = (id<CCSessionDownloadDelegate>)self.sessionModel;
        if ([downloadDelegate respondsToSelector:@selector(dataDownloadAtRate:withUniqueid:rate:)]) //下载速度回调
            [downloadDelegate dataDownloadAtRate:self.sessionModel withUniqueid:self.sessionModel.uniqueId rate:[NSNumber numberWithDouble:speed]];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error) {
        [self downloadStateHandler:CCDownloadStateFailed];
        id<CCSessionDownloadDelegate> downloadDelegate = (id<CCSessionDownloadDelegate>)self.sessionModel;
        if ([downloadDelegate respondsToSelector:@selector(dataDownloadFailed:withUniqueid:reason:)])
            [downloadDelegate dataDownloadFailed:self.sessionModel withUniqueid:self.sessionModel.uniqueId reason:error.domain];
    } else {
        [self downloadStateHandler:CCDownloadStateSuccess];
        [self completion];
    }
    [self.outputStream close];
    self.outputStream = nil;
    [self.session finishTasksAndInvalidate];
}

- (void)downloadStateHandler:(CCDownloadState)status
{
    self.sessionModel.status = status;
    id<CCSessionDownloadDelegate> downloadDelegate = (id<CCSessionDownloadDelegate>)self.sessionModel;
    if ([downloadDelegate respondsToSelector:@selector(downloader:withUniqueid:didChangeDownloadStatus:)])
        [downloadDelegate downloader:self.sessionModel withUniqueid:self.sessionModel.uniqueId didChangeDownloadStatus:status];
}

#pragma mark -
#pragma mark :. override

- (void)start
{
    [self downloadStateHandler:CCDownloadStateReady];
    if (self.isCancelled) {
        [self willChangeValueForKey:kCCFinished];
        _finished = YES;
        [self didChangeValueForKey:kCCFinished];
    } else {
        [self willChangeValueForKey:kCCExecuting];
        _executing = YES;
        [self.dataTask resume];
        [self downloadStateHandler:CCDownloadStateReady];
        [self didChangeValueForKey:kCCExecuting];
    }
}

- (void)cancel
{
    [self willChangeValueForKey:kCCCancelled];
    [super cancel];
    [self.dataTask cancel];
    self.dataTask = nil;
    [self didChangeValueForKey:kCCCancelled];
    [self completion];
}

- (void)completion
{
    [self willChangeValueForKey:kCCExecuting];
    [self willChangeValueForKey:kCCFinished];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:kCCExecuting];
    [self didChangeValueForKey:kCCFinished];
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

@end
