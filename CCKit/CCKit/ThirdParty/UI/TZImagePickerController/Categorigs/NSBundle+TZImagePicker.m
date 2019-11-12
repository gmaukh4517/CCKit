//
//  NSBundle+TZImagePicker.m
//  TZImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "NSBundle+TZImagePicker.h"
#import "CCLanguage.h"

@implementation NSBundle (TZImagePicker)

+ (NSBundle *)tz_imagePickerBundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CCKit" ofType:@"bundle"];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:@"CCKit.bundle/PhotoPicker" ofType:@"bundle" inDirectory:@"Frameworks/CCKit.framework/"];
    }
    return [NSBundle bundleWithPath:path];
}

+ (NSString *)tz_localizedStringForKey:(NSString *)key {
    return [self tz_localizedStringForKey:key value:@""];
}

+ (NSString *)tz_localizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [CCLanguage shareManager].currentLanguage;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle tz_imagePickerBundle] pathForResource:[NSString stringWithFormat:@"PhotoPicker/%@",language] ofType:@"lproj"]];
    }
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    if(!value1)
        value1 = key;
    return value1;
}
@end
