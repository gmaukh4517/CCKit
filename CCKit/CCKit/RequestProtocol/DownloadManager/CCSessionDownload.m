//
//  CCSessionDownload.m
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

#import "CCSessionDownload.h"
#import "CCDownLoadOperation.h"
#import "CCDownLoadHelper.h"
#import "NSString+CCAdd.h"
#import "CCDownloadStore.h"
#import "CCExtension.h"
#import <pthread.h>

@interface CCDownloadMultiProxy : NSObject {
    NSHashTable *_delegates;
    dispatch_semaphore_t _semaphore;
}

@end

@implementation CCDownloadMultiProxy

+ (CCDownloadMultiProxy *)proxy
{
    return [CCDownloadMultiProxy alloc];
}

#pragma mark - 多委托
+ (id)alloc
{
    CCDownloadMultiProxy *instance = [super alloc];
    if (instance) {
        instance->_semaphore = dispatch_semaphore_create(1);
        instance->_delegates = [NSHashTable weakObjectsHashTable];
    }
    return instance;
}

- (void)addDelegate:(id)delegate
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates addObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeDelete:(id)delegate
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates removeObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeAllDelegates
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - Forward Methods

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMethodSignature *methodSignature;
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:selector]) {
            methodSignature = [delegate methodSignatureForSelector:selector];
            break;
        }
    }
    dispatch_semaphore_signal(_semaphore);
    if (methodSignature) return methodSignature;

    // Avoid crash, must return a methodSignature "- (void)method"
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSHashTable *copyDelegates = [_delegates copy];
    dispatch_semaphore_signal(_semaphore);

    SEL selector = invocation.selector;
    for (id delegate in copyDelegates) {
        if ([delegate respondsToSelector:selector]) {
            // must use duplicated invocation when you invoke with async
            NSInvocation *dupInvocation = [self duplicateInvocation:invocation];
            dupInvocation.target = delegate;
            if (pthread_main_np()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dupInvocation invoke];
                });
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [dupInvocation invoke];
                });
            }
        }
    }
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)invocation
{
    SEL selector = invocation.selector;
    NSMethodSignature *methodSignature = invocation.methodSignature;
    NSInvocation *dupInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    dupInvocation.selector = selector;

    NSUInteger count = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < count; i++) {
        void *value;
        [invocation getArgument:&value atIndex:i];
        [dupInvocation setArgument:&value atIndex:i];
    }
    [dupInvocation retainArguments];
    return dupInvocation;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return YES;
}

@end


@interface CCSessionDownload () {
    CCDownloadMultiProxy *_proxy;
}

//下载具体执行对象
@property (nonatomic, strong) CCDownLoadOperation *operation;

@end

@implementation CCSessionDownload

- (instancetype)initWithUrl:(NSString *)url
{
    if (self = [super init]) {
        _proxy = [CCDownloadMultiProxy proxy];
        _model = [CCDownLoadModel modelWithUrl:url];
        self.uniqueId = [url MD5];
    }
    return self;
}

/**
 初始化下载器

 @param model 下载模型
 @return CCSessionDownload 对象
 */
- (instancetype)initWithDownLoadModel:(CCDownLoadModel *)model
{
    if (self = [super init]) {
        _proxy = [CCDownloadMultiProxy proxy];
        _model = model;
        self.uniqueId = [model.url MD5];
    }
    return self;
}

/**
 重新设置下载地址

 @param url 下载地址
 */
- (void)resetDownLoadURL:(NSString *)url
{
    _model = [CCDownLoadModel modelWithUrl:url];
    self.uniqueId = [url MD5];
}

- (NSDictionary *)downloadInfo
{
    return [self.model cc_keyValues];
}

- (CCDownLoadOperation *)getOperation
{
    if (!_operation)
        _operation = [[CCDownLoadOperation alloc] initWithModel:self];

    return _operation;
}

/**
 *  开始下载
 */
- (void)start
{
    if (self.operation) {
        [self.operation resumeTask];
    } else {
        self.operation = [[CCDownLoadOperation alloc] initWithModel:self];
        [self.operation resumeTask];
    }
}

/**
 *  停止下载
 */
- (void)stop
{
    if (!self.isStoped) {
        [self.operation suspendTask];
    }
}

/**
 *  是否已停止下载
 *
 *  @return 是否已停止下载
 */
- (BOOL)isStoped
{
    return self.status == CCDownloadStateStopped;
}

/**
 *  取消下载会话
 */
- (void)cleanSession
{
    [self.operation cancel];
    [CCDownLoadHelper deleteCacheFile:self.model.absolutePath];
}

- (void)setDownloadDelegate:(id<CCSessionDownloadDelegate>)downloadDelegate
{
    if (!_proxy)
        _proxy = [CCDownloadMultiProxy proxy];

    [_proxy addDelegate:downloadDelegate];
}

- (void)removeDownloadDelegate:(id<CCSessionDownloadDelegate>)downloadDelegate
{
    [_proxy removeDelete:downloadDelegate];
}

/**
 下载失败回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param reason 错误信息
 */
- (void)dataDownloadFailed:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid reason:(NSString *)reason
{
    [(id<CCSessionDownloadDelegate>)self->_proxy dataDownloadFailed:downloader withUniqueid:uniqueid reason:reason];
}

/**
 下载进度回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param aPercent 下载进度，取值 0-100
 */
- (void)dataDownloadAtPercent:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid percent:(NSNumber *)aPercent
{
    [(id<CCSessionDownloadDelegate>)self->_proxy dataDownloadAtPercent:downloader withUniqueid:uniqueid percent:aPercent];
}

/**
 下载速率回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param aRate 下载速率
 */
- (void)dataDownloadAtRate:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid rate:(NSNumber *)aRate
{
    [(id<CCSessionDownloadDelegate>)self->_proxy dataDownloadAtRate:downloader withUniqueid:uniqueid rate:aRate];
}

/**
 下载状态回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param status 下载状态
 */
- (void)downloader:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid didChangeDownloadStatus:(CCDownloadState)status
{
    [(id<CCSessionDownloadDelegate>)self->_proxy downloader:downloader withUniqueid:uniqueid didChangeDownloadStatus:status];
}



@end
