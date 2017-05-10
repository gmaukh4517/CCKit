//
//  CCKeychain.h
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

typedef NS_ENUM(OSStatus, CCKeychainErrorCode) {
    CCKeychainErrorBadArguments = -1001,
};

@interface CCKeychain : NSObject

/** 获取 **/
+ (nullable NSString *)loadForService:(NSString *)serviceName;
+ (nullable NSString *)loadForService:(NSString *)serviceName account:(NSString *)account;
+ (nullable NSString *)loadForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (nullable NSData *)loadDataForService:(NSString *)serviceName;
+ (nullable NSData *)loadDataForService:(NSString *)serviceName account:(NSString *)account;
+ (nullable NSData *)loadDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (id)loadObjForService:(NSString *)serviceName;
+ (id)loadObjForService:(NSString *)serviceName account:(NSString *)account;
+ (id)loadObjForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

/** 删除 **/
+ (BOOL)deleteForService:(NSString *)serviceName;
+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

/** 保存 **/
+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName;
+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName;
+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName;
+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));


+ (nullable NSArray<NSDictionary<NSString *, id> *> *)allAccounts;
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)allAccounts:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(nullable NSString *)serviceName;
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(nullable NSString *)serviceName error:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));


/**
 返回保存到钥匙串的所有未来密码的辅助功能类型。
 
 @return返回辅助功能类型。
 
 返回值将为“NULL”或“钥匙串项目辅助功能”之一
 常数“用于确定钥匙串项目何时可读。
 
 @see setAccessibilityType
 */
+ (CFTypeRef)accessibilityType;

/**
 设置保存到钥匙串的所有未来密码的辅助功能类型。
 
 @param accessibilityType“钥匙串项辅助功能常数”之一用于确定钥匙串项目何时可读。
 
 如果值为“NULL”（默认值），则将使用Keychain默认值高度不安全。
 你真的应该使用至少`kSecAttrAccessibleAfterFirstUnlock'对于后台应用程序或者`kSecAttrAccessibleWhenUnlocked`为所有其他应用。
 
 @see accessibilityType
 */
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;

@end

NS_ASSUME_NONNULL_END
