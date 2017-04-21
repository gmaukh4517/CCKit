//
//  CCVoiceCommonHelper.h
//  CCKit
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
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

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#define AUDIO_LOCAL_FILE @"localfile"

typedef void (^DidDeleteAudioFileBlock)();

@interface CCVoiceCommonHelper : NSObject

/**
 *  根据文件名字(不包含后缀)，删除文件
 *
 *  @param fileName 文件名字(不包含后缀)
 *  @param block   删除成功后的回调
 */
+ (void)removeRecordedFileWithOnlyName:(NSString *)fileName block:(DidDeleteAudioFileBlock)block;


/**
 *  删除/documents/Audio下的文件
 *
 *  @param exception 有包含些字符串就不删除（为空表示全部删除）
 *  @param block     删除成功后的回调
 */
+ (void)removeAudioFile:(NSString *)exception block:(DidDeleteAudioFileBlock)block;


/**
 *  根据当前时间生成字符串
 *
 *  @return 当前时间字符串
 */
+ (NSString *)getCurrentTimeString;


/**
 *  获取缓存路径
 *
 *  @return 缓存路径
 */
+ (NSString *)getCacheDirectory;


/**
 *  判断文件是否存在
 *
 *  @param _path 文件路径
 *
 *  @return 存在返回YES
 */
+ (BOOL)fileExistsAtPath:(NSString *)_path;


/**
 *  删除文件
 *
 *  @param _path 文件路径
 *
 *  @return 成功返回YES
 */
+ (BOOL)deleteFileAtPath:(NSString *)_path;


/**
 *  生成文件路径
 *
 *  @param _fileName 文件名
 *  @param _type 文件类型
 *  @return 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;


/**
 *  获取录音设置
 *
 *  @return 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict;


@end
