//
//  CCDownLoadModel.h
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

@interface CCDownLoadModel : NSObject

//文件名字 xxx.xx
@property (nonatomic, copy) NSString *name;
//下载url
@property (nonatomic, copy) NSString *url;
//存储目录
@property (nonatomic, copy) NSString *filePath;
//下载文件的绝对路径
@property (nonatomic, copy) NSString *absolutePath;
//总大小
@property (nonatomic, assign) long long totalSize;
//当前下载大小
@property (nonatomic, assign) NSInteger currentSize;
//进度状况
@property (nonatomic, assign) double progress;

//创建一个新任务
+ (instancetype)modelWithUrl:(NSString *)url;
@end
