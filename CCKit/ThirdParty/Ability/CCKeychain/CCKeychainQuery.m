//
//  CCKeychainQuery.m
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

#import "CCKeychainQuery.h"
#import "CCKeychain.h"

NSString *const kCCKeychainErrorDomain = @"com.cckit.CCkeychain";
NSString *const kCCKeychainAccountKey = @"acct";
NSString *const kCCKeychainCreatedAtKey = @"cdat";
NSString *const kCCKeychainClassKey = @"labl";
NSString *const kCCKeychainDescriptionKey = @"desc";
NSString *const kCCKeychainLabelKey = @"labl";
NSString *const kCCKeychainLastModifiedKey = @"mdat";
NSString *const kCCKeychainWhereKey = @"svce";

@implementation CCKeychainQuery

- (BOOL)save:(NSError *__autoreleasing *)error
{
    OSStatus status = CCKeychainErrorBadArguments;
    if (!self.service || !self.account || !self.valueData) {
        if (error) {
            *error = [[self class] errorWithCode:status];
        }
        return NO;
    }
    NSMutableDictionary *query = nil;
    NSMutableDictionary *searchQuery = [self query];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (status == errSecSuccess) { //item already exists, update it!
        query = [[NSMutableDictionary alloc] init];
        [query setObject:self.valueData forKey:(__bridge id)kSecValueData];
        
        CFTypeRef accessibilityType = [CCKeychain accessibilityType];
        if (accessibilityType)
            [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        
        status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
    } else if (status == errSecItemNotFound) { //item not found, create it!
        query = [self query];
        if (self.label)
            [query setObject:self.label forKey:(__bridge id)kSecAttrLabel];
        
        [query setObject:self.valueData forKey:(__bridge id)kSecValueData];
        
        CFTypeRef accessibilityType = [CCKeychain accessibilityType];
        if (accessibilityType)
            [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    if (status != errSecSuccess && error != NULL)
        *error = [[self class] errorWithCode:status];
    
    return (status == errSecSuccess);
}


- (BOOL)deleteItem:(NSError *__autoreleasing *)error
{
    OSStatus status = CCKeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error)
            *error = [[self class] errorWithCode:status];
        
        return NO;
    }
    
    NSMutableDictionary *query = [self query];
    status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != errSecSuccess && error != NULL)
        *error = [[self class] errorWithCode:status];
    
    return (status == errSecSuccess);
}

- (nullable NSArray *)fetchAll:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    
    CFTypeRef accessibilityType = [CCKeychain accessibilityType];
    if (accessibilityType)
        [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
    
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
        return nil;
    }
    
    return (__bridge_transfer NSArray *)result;
}

- (BOOL)fetch:(NSError *__autoreleasing *)error
{
    OSStatus status = CCKeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error)
            *error = [[self class] errorWithCode:status];
        
        return NO;
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status != errSecSuccess) {
        if (error)
            *error = [[self class] errorWithCode:status];
        
        return NO;
    }
    
    self.valueData = (__bridge_transfer NSData *)result;
    return YES;
}

#pragma mark - Accessors
- (void)setValueObject:(id<NSCoding>)valueObject
{
    self.valueData = [NSKeyedArchiver archivedDataWithRootObject:valueObject];
}

- (id<NSCoding>)valueObject
{
    if ([self.valueData length])
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.valueData];
    
    return nil;
}

- (void)setValue:(NSString *)value
{
    self.valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)value
{
    if ([self.valueData length])
        return [[NSString alloc] initWithData:self.valueData encoding:NSUTF8StringEncoding];
    
    return nil;
}


+ (BOOL)isSynchronizationAvailable
{
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
}

- (NSMutableDictionary *)query
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (self.service)
        [dictionary setObject:self.service forKey:(__bridge id)kSecAttrService];
    
    if (self.account)
        [dictionary setObject:self.account forKey:(__bridge id)kSecAttrAccount];
    
    if (self.accessGroup)
        [dictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    
    if ([[self class] isSynchronizationAvailable]) {
        id value;
        
        switch (self.synchronizationMode) {
            case CCKeychainQuerySynchronizationModeNo: {
                value = @NO;
                break;
            }
            case CCKeychainQuerySynchronizationModeYes: {
                value = @YES;
                break;
            }
            case CCKeychainQuerySynchronizationModeAny: {
                value = (__bridge id)(kSecAttrSynchronizableAny);
                break;
            }
        }
        
        [dictionary setObject:value forKey:(__bridge id)(kSecAttrSynchronizable)];
    }
    
    return dictionary;
}

+ (NSError *)errorWithCode:(OSStatus)code
{
    NSString *message = nil;
    switch (code) {
        case errSecSuccess:
            return nil;
        case CCKeychainErrorBadArguments:
            message = @"某些参数无效";
            break;
        case errSecUnimplemented:
            message = @"功能或操作未实现";
            break;
        case errSecParam:
            message = @"传递给函数的一个或多个参数无效";
            break;
        case errSecAllocate:
            message = @"无法分配内存";
            break;
        case errSecNotAvailable:
            message = @"没有钥匙串可用，您可能需要重新启动计算机";
            break;
        case errSecDuplicateItem:
            message = @"指定的项目已经存在于钥匙串中";
            break;
        case errSecItemNotFound:
            message = @"在钥匙串中找不到指定的项目";
            break;
        case errSecInteractionNotAllowed:
            message = @"不允许用户交互";
            break;
        case errSecDecode:
            message = @"无法解码提供的数据";
            break;
        case errSecAuthFailed:
            message = @"您输入的用户名或密码不正确";
            break;
        default:
            message = @"参考SecBase.h进行说明";
    }
    
    NSDictionary *userInfo = nil;
    if (message)
        userInfo = @{NSLocalizedDescriptionKey : message};
    
    return [NSError errorWithDomain:kCCKeychainErrorDomain code:code userInfo:userInfo];
}

@end
