//
//  CCSessionDownload.h
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

#import <Foundation/Foundation.h>
#import "CCSessionDownloadDelegate.h"
#import "CCDownLoadModel.h"

@interface CCSessionDownload : NSObject

@property (nonatomic, strong, readonly) NSDictionary *downloadInfo;
@property (nonatomic, strong, readonly) CCDownLoadModel *model;

@property (nonatomic, copy) NSDictionary *downloadUserInfo;

/**
 唯一标识
 */
@property (nonatomic, copy) NSString *uniqueId;

/**
 当前状态
 */
@property (nonatomic, assign, getter=Status) CCDownloadState status;

///**
// 设置下载是否使用后台会话
// */
//@property (nonatomic, assign) BOOL backgroundMode;
//
///**
// 后台下载会话标识符
// */
//@property (nonatomic, copy, readonly) NSString *sessionId;
//
///**
// 后台完成回调
// */
//@property (nonatomic, copy) void (^completeBlock)(void);

/**
 初始化下载器

 @param url 下载地址
 @return CCSessionDownload 对象
 */
- (instancetype)initWithUrl:(NSString *)url;

/**
 初始化下载器

 @param model 下载模型
 @return CCSessionDownload 对象
 */
- (instancetype)initWithDownLoadModel:(CCDownLoadModel *)model;

/**
 重新设置下载地址

 @param url 下载地址
 */
- (void)resetDownLoadURL:(NSString *)url;

/**
 *  开始下载
 */
- (void)start;

/**
 *  停止下载
 */
- (void)stop;

/**
 *  是否已停止下载
 *
 *  @return 是否已停止下载
 */
- (BOOL)isStoped;

/**
 *  取消下载会话
 */
- (void)cleanSession;

/**
 下载代理回调
 */
- (void)setDownloadDelegate:(id<CCSessionDownloadDelegate>)downloadDelegate;
-(void)removeDownloadDelegate:(id<CCSessionDownloadDelegate>)downloadDelegate;

@end
