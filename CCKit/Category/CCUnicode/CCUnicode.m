//
//  CCUnicode.m
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

#import "CCUnicode.h"
#import <objc/runtime.h>

static inline void cc_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSString (CCUnicode)

- (NSString *)stringByReplaceUnicode
{
    NSMutableString *convertedString = [self mutableCopy];
    
    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

@end

@implementation NSArray (CCUnicode)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        cc_swizzleSelector(class, @selector(description), @selector(cc_description));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(cc_descriptionWithLocale:));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(cc_descriptionWithLocale:indent:));
    });
}

- (NSString *)cc_description
{
    return [[self cc_description] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale
{
    return [[self cc_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    return [[self cc_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSDictionary (CCUnicode)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        cc_swizzleSelector(class, @selector(description), @selector(cc_description));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(cc_descriptionWithLocale:));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(cc_descriptionWithLocale:indent:));
    });
}

- (NSString *)cc_description
{
    return [[self cc_description] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale
{
    return [[self cc_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    return [[self cc_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSSet (CCUnicode)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        cc_swizzleSelector(class, @selector(description), @selector(cc_description));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(cc_descriptionWithLocale:));
        cc_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(cc_descriptionWithLocale:indent:));
    });
}

- (NSString *)cc_description
{
    return [[self cc_description] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale
{
    return [[self cc_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)cc_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    return [[self cc_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end
