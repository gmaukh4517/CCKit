//
//  CCDatePicker.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCDateStyle) {
    CCDateStyleYearMonthDay = 0,	   // 年月日
    CCDateStyleYearMonthDayHourMinute = 1, //年月日时分
    CCDateStyleMonthDayHourMinute = 2,     //月日时分
    CCDateStyleMonthDay = 3,		   // 月日
    CCDateStyleHourMinute = 4,		   //时分
};

typedef void (^didCompleteBlock)(NSDate *date);

@interface CCDatePicker : UIView

@property (nonatomic, assign) CCDateStyle datePickerStyle;

@property (nonatomic, retain) NSDate *maxLimitDate; //限制最大时间（没有设置默认2049）
@property (nonatomic, retain) NSDate *minLimitDate; //限制最小时间（没有设置默认1970）

@property (nonatomic, copy) didCompleteBlock didHandleBlock;

- (instancetype)initWithDataStyle:(CCDateStyle)dataPickerStyle;

-(void)handleBlock:(didCompleteBlock)didHandleBlock;

@end
