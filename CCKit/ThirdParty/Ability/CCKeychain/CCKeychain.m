//
//  CCKeychain.m
//  CCKit
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

#import "CCKeychain.h"
#import "CCKeychainQuery.h"

static CFTypeRef CCKeychainAccessibilityType = NULL;

@implementation CCKeychain

/** 获取 **/
+ (nullable NSString *)loadForService:(NSString *)serviceName
{
    return [CCKeychain loadForService:serviceName account:serviceName];
}

+ (nullable NSString *)loadForService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain loadForService:serviceName account:account error:nil];
}

+ (nullable NSString *)loadForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.value;
}

+ (nullable NSData *)loadDataForService:(NSString *)serviceName
{
    return [CCKeychain loadDataForService:serviceName account:serviceName];
}

+ (nullable NSData *)loadDataForService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain loadDataForService:serviceName account:account error:nil];
}

+ (nullable NSData *)loadDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    
    return query.valueData;
}

+ (id)loadObjForService:(NSString *)serviceName
{
    return [CCKeychain loadObjForService:serviceName account:serviceName];
}

+ (id)loadObjForService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain loadObjForService:serviceName account:account error:nil];
}

+ (id)loadObjForService:(NSString *)serviceName account:(NSString *)account error:(NSError *_Nullable __autoreleasing *)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.valueObject;
}

/** 删除 **/
+ (BOOL)deleteForService:(NSString *)serviceName
{
    return [CCKeychain deleteForService:serviceName account:serviceName];
}

+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain deleteForService:serviceName account:account error:nil];
}

+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    return [query deleteItem:error];
}

/** 保存 **/
+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName
{
    return [CCKeychain saveForService:value forService:serviceName account:serviceName];
}

+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain saveForService:value forService:serviceName account:account error:nil];
}

+ (BOOL)saveForService:(NSString *)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.value = value;
    return [query save:error];
}

+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName
{
    return [CCKeychain saveDataForService:value forService:serviceName account:serviceName];
}

+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain saveDataForService:value forService:serviceName account:account error:nil];
}

+ (BOOL)saveDataForService:(NSData *)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.valueData = value;
    return [query save:error];
}

+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName
{
    return [CCKeychain saveObjForService:value forService:serviceName account:serviceName];
}

+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName account:(NSString *)account
{
    return [CCKeychain saveObjForService:value forService:serviceName account:account error:nil];
}

+ (BOOL)saveObjForService:(id)value forService:(NSString *)serviceName account:(NSString *)account error:(NSError *_Nullable __autoreleasing *)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.valueObject = value;
    return [query save:error];
}

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)allAccounts
{
    return [CCKeychain allAccounts:nil];
}

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)allAccounts:(NSError *__autoreleasing *)error
{
    return [CCKeychain accountsForService:nil error:error];
}

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(nullable NSString *)serviceName
{
    return [CCKeychain accountsForService:serviceName error:nil];
}

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(nullable NSString *)serviceName error:(NSError *__autoreleasing *)error
{
    CCKeychainQuery *query = [[CCKeychainQuery alloc] init];
    query.service = serviceName;
    return [query fetchAll:error];
}

+ (CFTypeRef)accessibilityType
{
    return CCKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType
{
    CFRetain(accessibilityType);
    if (CCKeychainAccessibilityType) {
        CFRelease(CCKeychainAccessibilityType);
    }
    CCKeychainAccessibilityType = accessibilityType;
}

@end
