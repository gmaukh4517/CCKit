//
//  UncaughtExceptionHandler.m
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

#import "CCUncaughtExceptionHandler.h"
#import "AvoidCrash.h"
#import "CCDebugCrashHelper.h"
#import <UIKit/UIKit.h>
#include <execinfo.h>
#include <libkern/OSAtomic.h>
#include <sys/signal.h>
//#import "CCMacros.h"
#import "UIDevice+CCAdd.h"

NSString *const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString *const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation CCUncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++)
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
        dismissed = YES;
    else if (anIndex == 1)
        NSLog(@"应用继续使用");
}

- (void)setDismissed
{
    dismissed = NO;
}


- (void)validateAndSaveCriticalApplicationData
{
}

- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData];
    dismissed = YES;
    
    NSMutableString *errorStr = [NSMutableString string];
    [errorStr appendFormat:@"Name of the device owner: %@ \n", [[UIDevice currentDevice] name]];
    [errorStr appendFormat:@"Device Type：%@ \n", [[UIDevice currentDevice] model]];
    [errorStr appendFormat:@"Hardware Model：%@ \n",[[UIDevice currentDevice] hardwareDescription]];
    [errorStr appendFormat:@"Device operation system：%@ \n", [[UIDevice currentDevice] systemName]];
    [errorStr appendFormat:@"Version of the current system：%@ \n", [[UIDevice currentDevice] systemVersion]];
    [errorStr appendFormat:@"Device Identity：%@ \n", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [errorStr appendFormat:@"Application version：%@ \n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [errorStr appendFormat:@"Application Build version：%@ \n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
//    [errorStr appendFormat:@"Device is jailbreak：%@\n", cc_isJailbreak() ? @"YES" : @"NO"];
    [errorStr appendFormat:@"Error Cause：%@\n", [exception reason]];
    [errorStr appendFormat:@"%@ \n", [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    
    
    NSMutableDictionary *carsDic = [NSMutableDictionary dictionary];
    [carsDic setObject:exception.name forKey:@"ErrName"];
    [carsDic setObject:[exception reason] forKey:@"ErrCause"];
    [carsDic setObject:[NSDate date] forKey:@"ErrDate"];
    [carsDic setObject:errorStr forKey:@"ErrMsg"];
    [carsDic setObject:@"6" forKey:@"ErrType"];
    
    [[CCDebugCrashHelper manager] saveCrashException:carsDic];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes)
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    else
        [exception raise];
    
    [self performSelector:@selector(setDismissed) withObject:nil afterDelay:2];
}

+ (NSArray *)obtainCrashLogs
{
    return [CCDebugCrashHelper obtainCrashLogs];
}

@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
        return;
    
    NSArray *callStack = [CCUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[CCUncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                                withObject:[NSException exceptionWithName:[exception name]
                                                                                                   reason:[exception reason]
                                                                                                 userInfo:userInfo]
                                                             waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
        return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [CCUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[CCUncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                                withObject:[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                                                                   reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil), signal]
                                                                                                 userInfo:userInfo]
                                                             waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    [AvoidCrash becomeEffective];
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}