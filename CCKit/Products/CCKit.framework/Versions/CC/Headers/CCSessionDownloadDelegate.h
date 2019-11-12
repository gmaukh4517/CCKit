//
//  CCSessionDownloadDelegate.h
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

#ifndef CCSessionDownloadDelegate_h
#define CCSessionDownloadDelegate_h

typedef NS_ENUM(NSInteger, CCDownloadState) {
    CCDownloadStatePreparing = 0, // 准备
    CCDownloadStateReady = 1,     // 就绪
    CCDownloadStateRunning = 2,   // 正在下载
    CCDownloadStateStopping = 3,  // 正在停止
    CCDownloadStateStopped = 4,   // 停止下载
    CCDownloadStateSuccess = 5,   // 下载成功
    CCDownloadStateFailed = 6     // 下载失败
};

@class CCSessionDownload;

@protocol CCSessionDownloadDelegate <NSObject>

@optional
/**
 下载失败回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param reason 错误信息
 */
- (void)dataDownloadFailed:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid reason:(NSString *)reason;

/**
 下载进度回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param aPercent 下载进度，取值 0-100
 */
- (void)dataDownloadAtPercent:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid percent:(NSNumber *)aPercent;

/**
 下载速率回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param aRate 下载速率
 */
- (void)dataDownloadAtRate:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid rate:(NSNumber *)aRate;

/**
 下载状态回调

 @param downloader 下载器
 @param uniqueid 下载文件 id
 @param status 下载状态
 */
- (void)downloader:(CCSessionDownload *)downloader withUniqueid:(NSString *)uniqueid didChangeDownloadStatus:(CCDownloadState)status;

@end

#endif /* CCSessionDownloadDelegate_h */
