//
//  CCLanguage.h
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

#define kCCLanguage [CCLanguage sharedInstance]
#define CCLocalization(text) [kCCLanguage loalizedStringForKey:(text)]

/** 切换语言通知 **/
static NSString *const CCNotificationLanguageChanged = @"CCNotificationLanguageChanged";

@interface CCLanguage : NSObject

/** 支持语言集合 默认(zh-Hans,English) **/
@property (readonly, nonatomic) NSArray *languagesArray;
/** 是否设置语言 **/
@property (assign, nonatomic) BOOL saveInUserDefaults;
/** 当前语言 **/
@property (assign, nonatomic) NSString *currentLanguage;

+ (id)sharedInstance;

/**
 获取语言对应值
 
 @param key 语言对应KEY
 */
- (NSString *)loalizedStringForKey:(NSString *)key;

/**
 设置当前语言
 
 @param newLanguage 语言KEY
 */
- (BOOL)setLanguage:(NSString *)newLanguage;

/**
 设置当前语言
 
 @param newLanguage 语言KEY
 */
- (void)setSaveLanguage:(NSString *)newLanguage;

/**
 设置语言集合
 
 @param languagesArray 语言集合
 */
-(void)setLanguagesArray:(NSArray *)languagesArray;

@end
