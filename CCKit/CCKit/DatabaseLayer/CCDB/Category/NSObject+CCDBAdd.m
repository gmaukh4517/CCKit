//
//  NSObject+CCDBAdd.m
//  CCKit
//
// Copyright (c) 2017 CC ( https://github.com/gmaukh4517/CCKit )
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

#import "NSObject+CCDBAdd.h"
#import <objc/runtime.h>

static const char CCDBObjectClassInArrayKey = '\0';

@implementation NSObject (CCDBAdd)

static NSMutableDictionary *objectClassInArrayDict_;

+ (void)load
{
    objectClassInArrayDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    @synchronized(self)
    {
        if (key == &CCDBObjectClassInArrayKey) return objectClassInArrayDict_;
        return nil;
    }
}

#pragma mark -
#pragma mark :. getter/setter
- (NSNumber *)cc_identifier
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCc_identifier:(NSNumber *)cc_identifier
{
    objc_setAssociatedObject(self, @selector(cc_identifier), cc_identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)cc_createTime
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCc_createTime:(NSString *)cc_createTime
{
    objc_setAssociatedObject(self, @selector(cc_createTime), cc_createTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)cc_updateTime
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCc_updateTime:(NSString *)cc_updateTime
{
    objc_setAssociatedObject(self, @selector(cc_updateTime), cc_updateTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - block和方法处理:存储block的返回值
+ (void)ccdb_setupBlockReturnValue:(id (^)(void))block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // 清空数据
    [[self dictForKey:key] removeAllObjects];
}

+ (void)ccdb_setupObjectClassInArray:(CCDBObjectClassInArray)objectClassInArray
{
    [self ccdb_setupBlockReturnValue:objectClassInArray key:&CCDBObjectClassInArrayKey];
    [[self dictForKey:&CCDBObjectClassInArrayKey] removeAllObjects];
}

@end
