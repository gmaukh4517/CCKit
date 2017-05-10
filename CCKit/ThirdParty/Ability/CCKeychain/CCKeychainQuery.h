//
//  CCKeychainQuery.h
//  CCKit
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

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CCKeychainQuerySynchronizationMode) {
    CCKeychainQuerySynchronizationModeAny,
    CCKeychainQuerySynchronizationModeNo,
    CCKeychainQuerySynchronizationModeYes
};

@interface CCKeychainQuery : NSObject

@property(nonatomic, copy, nullable) NSString *account;

@property(nonatomic, copy, nullable) NSString *service;

@property(nonatomic, copy, nullable) NSString *label;

@property(nonatomic, copy, nullable) NSString *accessGroup;

@property(nonatomic) CCKeychainQuerySynchronizationMode synchronizationMode;

@property(nonatomic, copy, nullable) NSData *valueData;

/**
 此属性会自动在对象和值之间转换 passwordData`使用NSKeyedArchiver和NSKeyedUnarchiver。
 */
@property(nonatomic, copy, nullable) id<NSCoding> valueObject;

/**
 方便的访问者设置和获取密码字符串。 经过到`passwordData`使用UTF-8字符串编码。
 */
@property(nonatomic, copy, nullable) NSString *value;

- (BOOL)save:(NSError **)error;

- (BOOL)deleteItem:(NSError **)error;

- (nullable NSArray<NSDictionary<NSString *, id> *> *)fetchAll:(NSError **)error;

- (BOOL)fetch:(NSError **)error;

+ (BOOL)isSynchronizationAvailable;

@end
NS_ASSUME_NONNULL_END
