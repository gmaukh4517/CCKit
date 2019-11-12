
//
//  UIDevice+Additions.m
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

#import "UIDevice+CCAdd.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/socket.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>
#import <Security/Security.h>

@implementation UIDevice (CCAdd)

#pragma mark -
#pragma mark :. Hardware

- (NSString *)hardwareString
{
    int name[] = {CTL_HW, HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);

    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

/* This is another way of gtting the system info
 * For this you have to #import <sys/utsname.h>
 */

/*
 NSString* machineName
 {
 struct utsname systemInfo;
 uname(&systemInfo);
 return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 }
 */

- (Hardware)hardware
{
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"]) return IPHONE_2G;
    if ([hardware isEqualToString:@"iPhone1,2"]) return IPHONE_3G;
    if ([hardware isEqualToString:@"iPhone2,1"]) return IPHONE_3GS;
    if ([hardware isEqualToString:@"iPhone3,1"]) return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,2"]) return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,3"]) return IPHONE_4_CDMA;
    if ([hardware isEqualToString:@"iPhone4,1"]) return IPHONE_4S;
    if ([hardware isEqualToString:@"iPhone5,1"]) return IPHONE_5;
    if ([hardware isEqualToString:@"iPhone5,2"]) return IPHONE_5_CDMA_GSM;
    if ([hardware isEqualToString:@"iPhone5,3"]) return IPHONE_5C;
    if ([hardware isEqualToString:@"iPhone5,4"]) return IPHONE_5C_CDMA_GSM;
    if ([hardware isEqualToString:@"iPhone6,1"]) return IPHONE_5S;
    if ([hardware isEqualToString:@"iPhone6,2"]) return IPHONE_5S_CDMA_GSM;

    if ([hardware isEqualToString:@"iPhone7,1"]) return IPHONE_6_PLUS;
    if ([hardware isEqualToString:@"iPhone7,2"]) return IPHONE_6;
    if ([hardware isEqualToString:@"iPhone8,1"]) return IPHONE_6S;
    if ([hardware isEqualToString:@"iPhone8,2"]) return IPHONE_6S_PLUS;
    if ([hardware isEqualToString:@"iPhone8,5"]) return IPHONE_SE;
    if ([hardware isEqualToString:@"iPhone9,1"]) return IPHONE_7;
    if ([hardware isEqualToString:@"iPhone9,3"]) return IPHONE_7_GSM;
    if ([hardware isEqualToString:@"iPhone9,2"]) return IPHONE_7_PLUS;
    if ([hardware isEqualToString:@"iPhone9,4"]) return IPHONE_7_PLUS_GSM;

    if ([hardware isEqualToString:@"iPhone10,1"]) return IPHONE_8_CN;
    if ([hardware isEqualToString:@"iPhone10,2"]) return IPHONE_8_PLUS_CN;
    if ([hardware isEqualToString:@"iPhone10,3"]) return IPHONE_X_CN;
    if ([hardware isEqualToString:@"iPhone10,4"]) return IPHONE_8;
    if ([hardware isEqualToString:@"iPhone10,5"]) return IPHONE_8_PLUS;
    if ([hardware isEqualToString:@"iPhone10,6"]) return IPHONE_X;

    if ([hardware isEqualToString:@"iPhone11,2"]) return IPHONE_XS;
    if ([hardware isEqualToString:@"iPhone11,4"]) return IPHONE_XS_MAX;
    if ([hardware isEqualToString:@"iPhone11,6"]) return IPHONE_XS_MAX_CN;
    if ([hardware isEqualToString:@"iPhone11,8"]) return IPHONE_XR;

    if ([hardware isEqualToString:@"iPod1,1"]) return IPOD_TOUCH_1G;
    if ([hardware isEqualToString:@"iPod2,1"]) return IPOD_TOUCH_2G;
    if ([hardware isEqualToString:@"iPod3,1"]) return IPOD_TOUCH_3G;
    if ([hardware isEqualToString:@"iPod4,1"]) return IPOD_TOUCH_4G;
    if ([hardware isEqualToString:@"iPod5,1"]) return IPOD_TOUCH_5G;
    if ([hardware isEqualToString:@"iPod7,1"]) return IPOD_TOUCH_6G;

    if ([hardware isEqualToString:@"iPad1,1"]) return IPAD;
    if ([hardware isEqualToString:@"iPad1,2"]) return IPAD_3G;
    if ([hardware isEqualToString:@"iPad2,1"]) return IPAD_2_WIFI;
    if ([hardware isEqualToString:@"iPad2,2"]) return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,3"]) return IPAD_2_CDMA;
    if ([hardware isEqualToString:@"iPad2,4"]) return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,5"]) return IPAD_MINI_WIFI;
    if ([hardware isEqualToString:@"iPad2,6"]) return IPAD_MINI;
    if ([hardware isEqualToString:@"iPad2,7"]) return IPAD_MINI_WIFI_CDMA;

    if ([hardware isEqualToString:@"iPad3,1"]) return IPAD_3_WIFI;
    if ([hardware isEqualToString:@"iPad3,2"]) return IPAD_3_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad3,3"]) return IPAD_3;
    if ([hardware isEqualToString:@"iPad3,4"]) return IPAD_4_WIFI;
    if ([hardware isEqualToString:@"iPad3,5"]) return IPAD_4;
    if ([hardware isEqualToString:@"iPad3,6"]) return IPAD_4_GSM_CDMA;

    if ([hardware isEqualToString:@"iPad4,1"]) return IPAD_AIR_WIFI;
    if ([hardware isEqualToString:@"iPad4,2"]) return IPAD_AIR_WIFI_GSM;
    if ([hardware isEqualToString:@"iPad4,3"]) return IPAD_AIR_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad4,4"]) return IPAD_MINI_RETINA_WIFI;
    if ([hardware isEqualToString:@"iPad4,5"]) return IPAD_MINI_RETINA_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad4,6"]) return IPAD_MINI_RETINA_WIFI_CELLULAR_CN;
    if ([hardware isEqualToString:@"iPad4,7"]) return IPAD_MINI_3_WIFI;
    if ([hardware isEqualToString:@"iPad4,8"]) return IPAD_MINI_3_WIFI_CELLULAR;
    if ([hardware isEqualToString:@"iPad4,9"]) return IPAD_MINI_3_WIFI_CELLULAR_CN;

    if ([hardware isEqualToString:@"iPad5,1"]) return IPAD_MINI_4_WIFI;
    if ([hardware isEqualToString:@"iPad5,2"]) return IPAD_MINI_4_WIFI_CELLULAR;
    if ([hardware isEqualToString:@"iPad5,3"]) return IPAD_AIR_2_WIFI;
    if ([hardware isEqualToString:@"iPad5,4"]) return IPAD_AIR_2_WIFI_CELLULAR;

    if ([hardware isEqualToString:@"iPad6,3"]) return IPAD_PRO_97_WIFI;
    if ([hardware isEqualToString:@"iPad6,4"]) return IPAD_PRO_97_WIFI_CELLULAR;
    if ([hardware isEqualToString:@"iPad6,7"]) return IPAD_PRO_WIFI;
    if ([hardware isEqualToString:@"iPad6,8"]) return IPAD_PRO_WIFI_CELLULAR;

    if ([hardware isEqualToString:@"iPad6,11"]) return IPAD_5_WIFI;
    if ([hardware isEqualToString:@"iPad6,12"]) return IPAD_5_WIFI_CELLULAR;

    if ([hardware isEqualToString:@"iPad7,1"]) return IPAD_PRO_2G_WIFI;
    if ([hardware isEqualToString:@"iPad7,2"]) return IPAD_PRO_2G_WIFI_CELLULAR;
    if ([hardware isEqualToString:@"iPad7,3"]) return IPAD_PRO_105_WIFI;
    if ([hardware isEqualToString:@"iPad7,4"]) return IPAD_PRO_105_WIFI_CELLULAR;

    if ([hardware isEqualToString:@"iPad7,5"]) return IPAD_6_WIFI;
    if ([hardware isEqualToString:@"iPad7,6"]) return IPAD_6_WIFI_CELLULAR;

    if ([hardware isEqualToString:@"AppleTV1,1"]) return APPLE_TV_1G;
    if ([hardware isEqualToString:@"AppleTV2,1"]) return APPLE_TV_2G;
    if ([hardware isEqualToString:@"AppleTV3,1"]) return APPLE_TV_3G;
    if ([hardware isEqualToString:@"AppleTV3,2"]) return APPLE_TV_3_2G;
    if ([hardware isEqualToString:@"AppleTV5,3"]) return APPLE_TV_4G;

    if ([hardware isEqualToString:@"Watch1,1"]) return APPLE_WATCH_38;
    if ([hardware isEqualToString:@"Watch1,2"]) return APPLE_WATCH_42;
    if ([hardware isEqualToString:@"Watch2,3"]) return APPLE_WATCH_SERIES_2_38;
    if ([hardware isEqualToString:@"Watch2,4"]) return APPLE_WATCH_SERIES_2_42;
    if ([hardware isEqualToString:@"Watch2,6"]) return APPLE_WATCH_SERIES_1_38;
    if ([hardware isEqualToString:@"Watch2,7"]) return APPLE_WATCH_SERIES_1_42;
    if ([hardware isEqualToString:@"Watch3,1"]) return APPLE_WATCH_SERIES_3_38_CELLULAR;
    if ([hardware isEqualToString:@"Watch3,2"]) return APPLE_WATCH_SERIES_3_42_CELLULAR;
    if ([hardware isEqualToString:@"Watch3,3"]) return APPLE_WATCH_SERIES_3_38;
    if ([hardware isEqualToString:@"Watch3,4"]) return APPLE_WATCH_SERIES_3_42;

    if ([hardware isEqualToString:@"i386"]) return SIMULATOR;
    if ([hardware isEqualToString:@"x86_64"]) return SIMULATOR;
    return NOT_AVAILABLE;
}

- (NSString *)hardwareDescription
{
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";     // (A1203)
    if ([hardware isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";     // (A1241/A1324)
    if ([hardware isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";    // (A1303/A1325)
    if ([hardware isEqualToString:@"iPhone3,1"]) return @"iPhone 4";      // (A1332)
    if ([hardware isEqualToString:@"iPhone3,2"]) return @"iPhone 4";      // (A1332)
    if ([hardware isEqualToString:@"iPhone3,3"]) return @"iPhone 4";      // (A1349)

    if ([hardware isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";     // (A1387/A1431)
    if ([hardware isEqualToString:@"iPhone5,1"]) return @"iPhone 5";      // (A1428)
    if ([hardware isEqualToString:@"iPhone5,2"]) return @"iPhone 5";      // (A1429/A1442)
    if ([hardware isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";     // (A1456/A1532)
    if ([hardware isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";     // (A1507/A1516/A1526/A1529)

    if ([hardware isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";     // (A1453/A1533)
    if ([hardware isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";     // (A1457/A1518/A1528/A1530)

    if ([hardware isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus"; // (A1522/A1524)
    if ([hardware isEqualToString:@"iPhone7,2"]) return @"iPhone 6";      // (A1549/A1586)

    if ([hardware isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([hardware isEqualToString:@"iPhone8,3"]) return @"iPhone SE";
    if ([hardware isEqualToString:@"iPhone8,4"]) return @"iPhone SE";

    if ([hardware isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([hardware isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([hardware isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([hardware isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,6"]) return @"IPhone X";

    if ([hardware isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([hardware isEqualToString:@"iPhone11,4"]) return @"iPhone XS MAX";
    if ([hardware isEqualToString:@"iPhone11,6"]) return @"iPhone XS MAX";
    if ([hardware isEqualToString:@"iPhone11,8"]) return @"iPhone XR";

    if ([hardware isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G"; // (A1213)
    if ([hardware isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G"; // (A1288)
    if ([hardware isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G"; // (A1318)
    if ([hardware isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G"; // (A1367)
    if ([hardware isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G"; // (A1421/A1509)

    if ([hardware isEqualToString:@"iPad1,1"]) return @"iPad 1G"; // (A1219/A1337)

    if ([hardware isEqualToString:@"iPad2,1"]) return @"iPad 2";       // (A1395)
    if ([hardware isEqualToString:@"iPad2,2"]) return @"iPad 2";       // (A1396)
    if ([hardware isEqualToString:@"iPad2,3"]) return @"iPad 2";       // (A1397)
    if ([hardware isEqualToString:@"iPad2,4"]) return @"iPad 2";       // (A1395+New Chip)
    if ([hardware isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G"; // (A1432)
    if ([hardware isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G"; // (A1454)
    if ([hardware isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G"; // (A1455)

    if ([hardware isEqualToString:@"iPad3,1"]) return @"iPad 3"; // (A1416)
    if ([hardware isEqualToString:@"iPad3,2"]) return @"iPad 3"; // (A1403)
    if ([hardware isEqualToString:@"iPad3,3"]) return @"iPad 3"; // (A1430)
    if ([hardware isEqualToString:@"iPad3,4"]) return @"iPad 4"; // (A1458)
    if ([hardware isEqualToString:@"iPad3,5"]) return @"iPad 4"; // (A1459)
    if ([hardware isEqualToString:@"iPad3,6"]) return @"iPad 4"; // (A1460)

    if ([hardware isEqualToString:@"iPad4,1"]) return @"iPad Air";     // (A1474)
    if ([hardware isEqualToString:@"iPad4,2"]) return @"iPad Air";     // (A1475)
    if ([hardware isEqualToString:@"iPad4,3"]) return @"iPad Air";     // (A1476)
    if ([hardware isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G"; // (A1489)
    if ([hardware isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G"; // (A1490)
    if ([hardware isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G"; // (A1491)
    if ([hardware isEqualToString:@"iPad4,7"]) return @"iPad_Mini 3 WIFI";
    if ([hardware isEqualToString:@"iPad4,8"]) return @"iPad_Mini 3 WIFI"; //_CELLULAR
    if ([hardware isEqualToString:@"iPad4,9"]) return @"iPad_Mini 3 WIFI"; //CELLULAR_CN;

    if ([hardware isEqualToString:@"iPad5,1"]) return @"iPad_Mini 4 WIFI";
    if ([hardware isEqualToString:@"iPad5,2"]) return @"iPad_Mini 4 WIFI";//_CELLULAR;
    if ([hardware isEqualToString:@"iPad5,3"]) return @"iPad Air 2 WIFI";
    if ([hardware isEqualToString:@"iPad5,4"]) return @"iPad Air 2 WIFI"; //CELLULAR;

    if ([hardware isEqualToString:@"iPad6,3"]) return @"iPad Pro WIFI";
    if ([hardware isEqualToString:@"iPad6,4"]) return @"iPad Pro WIFI";//_CELLULAR
    if ([hardware isEqualToString:@"iPad6,7"]) return @"iPad Pro WIFI";
    if ([hardware isEqualToString:@"iPad6,8"]) return @"IPad Pro WIFI"; //_CELLULAR

    if ([hardware isEqualToString:@"iPad6,11"]) return @"iPad 5 WIFI";
    if ([hardware isEqualToString:@"iPad6,12"]) return @"iPad 5 WIFI"; //_CELLULAR

    if ([hardware isEqualToString:@"iPad7,1"]) return @"iPad Pro 2G WIFI";
    if ([hardware isEqualToString:@"iPad7,2"]) return @"iPad Pro 2G WIFI";//_CELLULAR
    if ([hardware isEqualToString:@"iPad7,3"]) return @"iPad Pro WIFI";
    if ([hardware isEqualToString:@"iPad7,4"]) return @"iPad Pro WIFI";//_CELLULAR

    if ([hardware isEqualToString:@"iPad7,5"]) return @"iPad 6 WIFI";
    if ([hardware isEqualToString:@"iPad7,6"]) return @"iPad 6 WIFI";//_CELLULAR

    if ([hardware isEqualToString:@"AppleTV1,1"]) return @"APPLE TV 1G";
    if ([hardware isEqualToString:@"AppleTV2,1"]) return @"APPLE TV 2G";
    if ([hardware isEqualToString:@"AppleTV3,1"]) return @"APPLE TV 3G";
    if ([hardware isEqualToString:@"AppleTV3,2"]) return @"APPLE TV 3_2G";
    if ([hardware isEqualToString:@"AppleTV5,3"]) return @"APPLE TV 4G";

    if ([hardware isEqualToString:@"Watch1,1"]) return @"APPLE WATCH 38";
    if ([hardware isEqualToString:@"Watch1,2"]) return @"APPLE WATCH 42";
    if ([hardware isEqualToString:@"Watch2,3"]) return @"APPLE WATCH SERIES 2 38";
    if ([hardware isEqualToString:@"Watch2,4"]) return @"APPLE WATCH SERIES 2 42";
    if ([hardware isEqualToString:@"Watch2,6"]) return @"APPLE WATCH SERIES 1 38";
    if ([hardware isEqualToString:@"Watch2,7"]) return @"APPLE WATCH SERIES 1 42";
    if ([hardware isEqualToString:@"Watch3,1"]) return @"APPLE WATCH SERIES 3 38 CELLULAR";
    if ([hardware isEqualToString:@"Watch3,2"]) return @"APPLE WATCH SERIES 3 42 CELLULAR";
    if ([hardware isEqualToString:@"Watch3,3"]) return @"APPLE WATCH SERIES 3 38";
    if ([hardware isEqualToString:@"Watch3,4"]) return @"APPLE WATCH SERIES 3 42";

    if ([hardware isEqualToString:@"i386"]) return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"]) return @"Simulator";

    NSLog(@"This is a device which is not listed in this category. Please visit https://github.com/inderkumarrathore/UIDevice-Hardware and add a comment there.");
    NSLog(@"Your device hardware string is: %@", hardware);

    if ([hardware hasPrefix:@"iPhone"]) return @"iPhone";
    if ([hardware hasPrefix:@"iPod"]) return @"iPod";
    if ([hardware hasPrefix:@"iPad"]) return @"iPad";

    return nil;
}


- (float)hardwareNumber:(Hardware)hardware
{
    switch (hardware) {
        case IPHONE_2G:
            return 1.1f;
        case IPHONE_3G:
            return 1.2f;
        case IPHONE_3GS:
            return 2.1f;
        case IPHONE_4:
            return 3.1f;
        case IPHONE_4_CDMA:
            return 3.3f;
        case IPHONE_4S:
            return 4.1f;
        case IPHONE_5:
            return 5.1f;
        case IPHONE_5_CDMA_GSM:
            return 5.2f;
        case IPHONE_5C:
            return 5.3f;
        case IPHONE_5C_CDMA_GSM:
            return 5.4f;
        case IPHONE_5S:
            return 6.1f;
        case IPHONE_5S_CDMA_GSM:
            return 6.2f;

        case IPHONE_6:
            return 7.2f;
        case IPHONE_6_PLUS:
            return 7.1f;
        case IPHONE_6S:
            return 8.1f;
        case IPHONE_6S_PLUS:
            return 8.2f;
        case IPHONE_SE:
            return 8.5f;

        case IPHONE_7:
            return 9.1f;
        case IPHONE_7_GSM:
            return 9.3f;
        case IPHONE_7_PLUS:
            return 9.2f;
        case IPHONE_7_PLUS_GSM:
            return 9.4f;

        case IPHONE_8_CN:
            return 10.1f;
        case IPHONE_8_PLUS_CN:
            return 10.2f;
        case IPHONE_X_CN:
            return 10.3f;
        case IPHONE_8:
            return 10.4f;
        case IPHONE_8_PLUS:
            return 10.5f;
        case IPHONE_X:
            return 10.6f;

        case IPHONE_XS:
            return 11.2f;
        case IPHONE_XS_MAX:
            return 11.4f;
        case IPHONE_XS_MAX_CN:
            return 11.6f;
        case IPHONE_XR:
            return 11.8f;

        case IPOD_TOUCH_1G:
            return 1.1f;
        case IPOD_TOUCH_2G:
            return 2.1f;
        case IPOD_TOUCH_3G:
            return 3.1f;
        case IPOD_TOUCH_4G:
            return 4.1f;
        case IPOD_TOUCH_5G:
            return 5.1f;
        case IPOD_TOUCH_6G:
            return 7.1f;

        case IPAD:
            return 1.1f;
        case IPAD_3G:
            return 1.2f;
        case IPAD_2_WIFI:
            return 2.1f;
        case IPAD_2:
            return 2.2f;
        case IPAD_2_CDMA:
            return 2.3f;
        case IPAD_MINI_WIFI:
            return 2.5f;
        case IPAD_MINI:
            return 2.6f;
        case IPAD_MINI_WIFI_CDMA:
            return 2.7f;
        case IPAD_3_WIFI:
            return 3.1f;
        case IPAD_3_WIFI_CDMA:
            return 3.2f;
        case IPAD_3:
            return 3.3f;
        case IPAD_4_WIFI:
            return 3.4f;
        case IPAD_4:
            return 3.5f;
        case IPAD_4_GSM_CDMA:
            return 3.6f;
        case IPAD_AIR_WIFI:
            return 4.1f;
        case IPAD_AIR_WIFI_GSM:
            return 4.2f;
        case IPAD_AIR_WIFI_CDMA:
            return 4.3f;
        case IPAD_MINI_RETINA_WIFI:
            return 4.4f;
        case IPAD_MINI_RETINA_WIFI_CDMA:
            return 4.5f;
        case IPAD_MINI_RETINA_WIFI_CELLULAR_CN:
            return 4.6f;
        case IPAD_MINI_3_WIFI:
            return 4.7f;
        case IPAD_MINI_3_WIFI_CELLULAR:
            return 4.8f;
        case IPAD_MINI_3_WIFI_CELLULAR_CN:
            return 4.9f;

        case IPAD_MINI_4_WIFI:
            return 5.1f;
        case IPAD_MINI_4_WIFI_CELLULAR:
            return 5.2f;
        case IPAD_AIR_2_WIFI:
            return 5.3f;
        case IPAD_AIR_2_WIFI_CELLULAR:
            return 5.4f;

        case IPAD_PRO_97_WIFI:
            return 6.3f;
        case IPAD_PRO_97_WIFI_CELLULAR:
            return 6.4f;
        case IPAD_PRO_WIFI:
            return 6.7f;
        case IPAD_PRO_WIFI_CELLULAR:
            return 6.8f;

        case IPAD_5_WIFI:
            return 6.11f;
        case IPAD_5_WIFI_CELLULAR:
            return 6.12f;

        case IPAD_PRO_2G_WIFI:
            return 7.1f;

        case IPAD_PRO_2G_WIFI_CELLULAR:
            return 7.2f;
        case IPAD_PRO_105_WIFI:
            return 7.3f;
        case IPAD_PRO_105_WIFI_CELLULAR:
            return 7.4f;

        case IPAD_6_WIFI:
            return 7.5f;
        case IPAD_6_WIFI_CELLULAR:
            return 7.6f;

        case APPLE_TV_1G:
            return 1.1f;
        case APPLE_TV_2G:
            return 2.1f;
        case APPLE_TV_3G:
            return 3.1f;
        case APPLE_TV_3_2G:
            return 3.2f;
        case APPLE_TV_4G:
            return 5.3f;

        case APPLE_WATCH_38:
            return 1.1f;
        case APPLE_WATCH_42:
            return 1.2f;
        case APPLE_WATCH_SERIES_2_38:
            return 2.3f;
        case APPLE_WATCH_SERIES_2_42:
            return 2.4f;
        case APPLE_WATCH_SERIES_1_38:
            return 2.6f;
        case APPLE_WATCH_SERIES_1_42:
            return 2.7f;
        case APPLE_WATCH_SERIES_3_38_CELLULAR:
            return 3.1f;
        case APPLE_WATCH_SERIES_3_42_CELLULAR:
            return 3.2f;
        case APPLE_WATCH_SERIES_3_38:
            return 3.3f;
        case APPLE_WATCH_SERIES_3_42:
            return 3.4f;

        case SIMULATOR:
            return 100.0f;
        case NOT_AVAILABLE:
            return 200.0f;
    }
    return 200.0f; //Device is not available
}

- (BOOL)isCurrentDeviceHardwareBetterThan:(Hardware)hardware
{
    float otherHardware = [self hardwareNumber:hardware];
    float currentHardware = [self hardwareNumber:[self hardware]];
    return currentHardware >= otherHardware;
}

- (CGSize)backCameraStillImageResolutionInPixels
{
    switch ([self hardware]) {
        case IPHONE_2G:
        case IPHONE_3G:
            return CGSizeMake(1600, 1200);

        case IPHONE_3GS:
            return CGSizeMake(2048, 1536);

        case IPHONE_4:
        case IPHONE_4_CDMA:
        case IPAD_3_WIFI:
        case IPAD_3_WIFI_CDMA:
        case IPAD_3:
        case IPAD_4_WIFI:
        case IPAD_4:
        case IPAD_4_GSM_CDMA:
            return CGSizeMake(2592, 1936);

        case IPHONE_4S:
        case IPHONE_5:
        case IPHONE_5_CDMA_GSM:
        case IPHONE_5C:
        case IPHONE_5C_CDMA_GSM:
        case IPHONE_6:
        case IPHONE_6_PLUS:
        case IPOD_TOUCH_6G:
        case IPAD_AIR_2_WIFI:
        case IPAD_AIR_2_WIFI_CELLULAR:
        case IPHONE_6S:
        case IPHONE_6S_PLUS:
            return CGSizeMake(3264, 2448);

        case IPHONE_7:
        case IPHONE_7_GSM:
        case IPHONE_7_PLUS:
        case IPHONE_7_PLUS_GSM:
        case IPHONE_8:
        case IPHONE_8_CN:
        case IPHONE_8_PLUS:
        case IPHONE_8_PLUS_CN:
        case IPHONE_X:
        case IPHONE_X_CN:
            return CGSizeMake(4032, 3024);

        case IPOD_TOUCH_4G:
            return CGSizeMake(960, 720);

        case IPOD_TOUCH_5G:
            return CGSizeMake(2440, 1605);

        case IPAD_2_WIFI:
        case IPAD_2:
        case IPAD_2_CDMA:
            return CGSizeMake(872, 720);

        case IPAD_MINI_WIFI:
        case IPAD_MINI:
        case IPAD_MINI_WIFI_CDMA:
            return CGSizeMake(1820, 1304);

        case IPAD_PRO_97_WIFI:
        case IPAD_PRO_97_WIFI_CELLULAR:
            return CGSizeMake(4032, 3024);

        default:
            NSLog(@"We have no resolution for your device's camera listed in this category. Please, make photo with back camera of your device, get its resolution in pixels (via Preview Cmd+I for example) and add a comment to this repository (https://github.com/InderKumarRathore/DeviceUtil) on GitHub.com in format Device = Hpx x Wpx.");
            NSLog(@"Your device is: %@", [self hardwareDescription]);
            break;
    }
    return CGSizeZero;
}

- (BOOL)isIphoneWith4inchDisplay
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        double height = [[UIScreen mainScreen] bounds].size.height;
        if (fabs(height - 568.0f) < DBL_EPSILON) {
            return YES;
        }
    }
    return NO;
}


+ (NSString *)macAddress
{
    int mib[ 6 ];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[ 0 ] = CTL_NET;
    mib[ 1 ] = AF_ROUTE;
    mib[ 2 ] = 0;
    mib[ 3 ] = AF_LINK;
    mib[ 4 ] = NET_RT_IFLIST;

    if ((mib[ 5 ] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. Rrror!\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }

    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                                     *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);

    return outstring;
}

+ (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}
+ (BOOL)hasCamera
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
#pragma mark :. sysctl utils

+ (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    size_t size = sizeof(int);
    int result;
    int mib[ 2 ] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &result, &size, NULL, 0);
    return (NSUInteger)result;
}

#pragma mark :. memory information
+ (NSUInteger)cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

+ (NSUInteger)busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

+ (NSUInteger)ramSize
{
    return [self getSysInfo:HW_MEMSIZE];
}

+ (NSUInteger)cpuNumber
{
    return [self getSysInfo:HW_NCPU];
}


+ (NSUInteger)totalMemoryBytes
{
    return [self getSysInfo:HW_PHYSMEM];
}

+ (NSUInteger)freeMemoryBytes
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;

    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }
    unsigned long mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

#pragma mark :. disk information

+ (long long)freeDiskSpaceBytes
{
    struct statfs buf;
    long long freespace;
    freespace = 0;
    if (statfs("/private/var", &buf) >= 0) {
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    return freespace;
}

+ (long long)totalDiskSpaceBytes
{
    struct statfs buf;
    long long totalspace;
    totalspace = 0;
    if (statfs("/private/var", &buf) >= 0) {
        totalspace = (long long)buf.f_bsize * buf.f_blocks;
    }
    return totalspace;
}

#pragma mark -
#pragma mark :. PasscodeStatus


NSString *const UIDevicePasscodeKeychainService = @"UIDevice-PasscodeStatus_KeychainService";
NSString *const UIDevicePasscodeKeychainAccount = @"UIDevice-PasscodeStatus_KeychainAccount";

- (BOOL)passcodeStatusSupported
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif

#ifdef __IPHONE_8_0
    return (&kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly != NULL);
#else
    return NO;
#endif
}

- (CCPasscodeStatus)passcodeStatus
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"-[%@ %@] - not supported in simulator", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return CCPasscodeStatusUnknown;
#endif

#ifdef __IPHONE_8_0
    if (&kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly != NULL) {
        static NSData *password = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            password = [NSKeyedArchiver archivedDataWithRootObject:NSStringFromSelector(_cmd)];
        });

        NSDictionary *query = @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                (__bridge id)
                                kSecAttrService : UIDevicePasscodeKeychainService,
                                (__bridge id)
                                kSecAttrAccount : UIDevicePasscodeKeychainAccount,
                                (__bridge id)
                                kSecReturnData : @YES,
        };

        CFErrorRef sacError = NULL;
        SecAccessControlRef sacObject;
        sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kNilOptions, &sacError);

        // unable to create the access control item.
        if (sacObject == NULL || sacError != NULL) {
            return CCPasscodeStatusUnknown;
        }


        NSMutableDictionary *setQuery = [query mutableCopy];
        [setQuery setObject:password forKey:(__bridge id)kSecValueData];
        [setQuery setObject:(__bridge id)sacObject forKey:(__bridge id)kSecAttrAccessControl];

        OSStatus status;
        status = SecItemAdd((__bridge CFDictionaryRef)setQuery, NULL);

        // if it failed to add the item.
        if (status == errSecDecode) {
            return CCPasscodeStatusDisabled;
        }

        status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);

        // it managed to retrieve data successfully
        if (status == errSecSuccess) {
            return CCPasscodeStatusEnabled;
        }

        // not sure what happened, returning unknown
        return CCPasscodeStatusUnknown;

    } else {
        return CCPasscodeStatusUnknown;
    }
#else
    return LNPasscodeStatusUnknown;
#endif
}

@end
