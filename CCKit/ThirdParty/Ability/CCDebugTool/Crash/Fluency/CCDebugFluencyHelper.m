//
//  CCDebugFluencyHelper.m
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

#import "CCDebugFluencyHelper.h"

const int maxCrashLogNum = 20;

#define fluencyPlistName @"CCfluencyLog.plist"

@interface CCDebugFluencyHelper ()

@property (nonatomic, strong) NSString *fluencyLogPath;
@property (nonatomic, strong) NSMutableArray *fluencyLogPlist;

@end


@implementation CCDebugFluencyHelper

+ (instancetype)manager
{
    static CCDebugFluencyHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CCDebugFluencyHelper new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *sandBoxPath = [paths objectAtIndex:0];
    
    _fluencyLogPath = [sandBoxPath stringByAppendingPathComponent:@"CCfluencyLog"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_fluencyLogPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_fluencyLogPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    //creat plist
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_fluencyLogPath stringByAppendingPathComponent:fluencyPlistName]])
        _fluencyLogPlist = [[NSMutableArray arrayWithContentsOfFile:[_fluencyLogPath stringByAppendingPathComponent:fluencyPlistName]] mutableCopy];
    else
        _fluencyLogPlist = [NSMutableArray new];
}

- (void)saveFluencyException:(NSMutableDictionary *)exdic
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[exdic objectForKey:@"ErrDate"]];
    [exdic setObject:dateString forKey:@"ErrDate"];
    
    NSString *saceCrashPath = [[_fluencyLogPath stringByAppendingPathComponent:dateString] stringByAppendingString:@".plist"];
    
    if (![exdic writeToFile:saceCrashPath atomically:YES]) {
//        NSLog(@"CCDebugTool:crash report failed!");
    } else
//        NSLog(@"CCDebugTool:save crash report succeed!");
    
    [_fluencyLogPlist insertObject:dateString atIndex:0];
    [_fluencyLogPlist writeToFile:[_fluencyLogPath stringByAppendingPathComponent:fluencyPlistName] atomically:YES];
    
    if (_fluencyLogPlist.count > maxCrashLogNum) {
        [[NSFileManager defaultManager] removeItemAtPath:[_fluencyLogPath stringByAppendingPathComponent:[_fluencyLogPlist objectAtIndex:0]] error:nil];
        [_fluencyLogPlist writeToFile:[_fluencyLogPath stringByAppendingPathComponent:fluencyPlistName] atomically:YES];
    }
}

- (NSArray *)obtainFluencyLogs
{
    NSMutableArray *crashArray = [NSMutableArray array];
    for (NSString *key in self.fluencyLogPlist) {
        NSString *filePath = [_fluencyLogPath stringByAppendingPathComponent:key];
        NSString *path = [filePath stringByAppendingString:@".plist"];
        NSDictionary *log = [NSDictionary dictionaryWithContentsOfFile:path];
        [crashArray addObject:log];
    }
    return [crashArray copy];
}
@end
