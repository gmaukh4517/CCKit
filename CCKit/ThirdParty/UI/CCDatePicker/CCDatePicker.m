//
//  CCDatePicker.m
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

#import "CCDatePicker.h"
#import "NSDate+CCAdd.h"
#import "UIView+Frame.h"

#define MAXYEAR 2050
#define MINYEAR 1970

@interface CCDatePicker () <UIPickerViewDelegate, UIPickerViewDataSource> {
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSString *_dateFormatter;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    
    NSInteger preRow;
}

@property (nonatomic, strong) UILabel *showYearView;
@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, retain) NSDate *scrollToDate; //滚到指定日期
@property (nonatomic, retain) NSDate *currentDate;  //默认显示时间

@end

@implementation CCDatePicker

- (instancetype)initWithDataStyle:(CCDateStyle)dataPickerStyle
{
    if (self = [super init]) {
        self.datePickerStyle = dataPickerStyle;
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.width, 240);
    switch (self.datePickerStyle) {
        case CCDateStyleYearMonthDayHourMinute:
            _dateFormatter = @"yyyy-MM-dd HH:mm";
            break;
        case CCDateStyleMonthDayHourMinute:
            _dateFormatter = @"yyyy-MM-dd HH:mm";
            break;
        case CCDateStyleYearMonthDay:
            _dateFormatter = @"yyyy-MM-dd";
            break;
        case CCDateStyleMonthDay:
            _dateFormatter = @"yyyy-MM-dd";
            break;
        case CCDateStyleHourMinute:
            _dateFormatter = @"HH:mm";
            break;
        default:
            _dateFormatter = @"yyyy-MM-dd HH:mm";
            break;
    }
    [self.showYearView addSubview:self.datePicker];
    [self addSubview:self.showYearView];
    [self defaultConfig];
    
    UIButton *handleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.showYearView.bottom, self.width, 40)];
    handleButton.backgroundColor = [UINavigationBar appearance].barTintColor;
    [handleButton setTitle:@"确定" forState:UIControlStateNormal];
    [handleButton addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:handleButton];
}

- (void)defaultConfig
{
    if (!_scrollToDate)
        _scrollToDate = self.currentDate ? self.currentDate : [NSDate date];
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year - MINYEAR) * 12 + self.scrollToDate.month - 1;
    
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    
    for (int i = 0; i < 60; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d", i];
        if (0 < i && i <= 12)
            [_monthArray addObject:num];
        if (i < 24)
            [_hourArray addObject:num];
        [_minuteArray addObject:num];
    }
    for (NSInteger i = MINYEAR; i < MAXYEAR; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld", (long)i];
        [_yearArray addObject:num];
    }
    
    //最大最小限制
    if (!self.maxLimitDate) {
        self.maxLimitDate = [NSDate dateWithString:@"2049-12-31 23:59" format:@"yyyy-MM-dd HH:mm"];
    }
    
    //最小限制
    if (!self.minLimitDate) {
        self.minLimitDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
}

- (void)addLabelWithName:(NSArray *)nameArr
{
    for (id subView in self.showYearView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat rowWidth = self.width / nameArr.count;
    
    for (int i = 0; i < nameArr.count; i++) {
        CGFloat labelX = (i + 1) * rowWidth - 7;
        if (i == nameArr.count - 1) {
            labelX -= 15;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, (self.showYearView.height - 40) / 2, 15, 40)];
        label.text = nameArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        [self.showYearView addSubview:label];
    }
}


- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

- (void)handleClick:(UIButton *)sender
{
    if (self.didHandleBlock) {
        self.didHandleBlock(self.scrollToDate);
    }
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.datePickerStyle) {
        case CCDateStyleYearMonthDayHourMinute:
            [self addLabelWithName:@[ @"年", @"月", @"日", @"时", @"分" ]];
            return 5;
        case CCDateStyleYearMonthDay:
            [self addLabelWithName:@[ @"年", @"月", @"日" ]];
            return 3;
        case CCDateStyleMonthDayHourMinute:
            [self addLabelWithName:@[ @"月", @"日", @"时", @"分" ]];
            return 4;
        case CCDateStyleMonthDay:
            [self addLabelWithName:@[ @"月", @"日" ]];
            return 2;
        case CCDateStyleHourMinute:
            [self addLabelWithName:@[ @"时", @"分" ]];
            return 2;
        default:
            return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

- (NSArray *)getNumberOfRowsInComponent
{
    
    NSInteger yearNum = _yearArray.count;
    NSInteger monthNum = _monthArray.count;
    NSInteger dayNum = [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
    NSInteger hourNum = _hourArray.count;
    NSInteger minuteNUm = _minuteArray.count;
    
    NSInteger timeInterval = MAXYEAR - MINYEAR;
    
    switch (self.datePickerStyle) {
        case CCDateStyleYearMonthDayHourMinute:
            return @[ @(yearNum), @(monthNum), @(dayNum), @(hourNum), @(minuteNUm) ];
            break;
        case CCDateStyleMonthDayHourMinute:
            return @[ @(monthNum * timeInterval), @(dayNum), @(hourNum), @(minuteNUm) ];
            break;
        case CCDateStyleYearMonthDay:
            return @[ @(yearNum), @(monthNum), @(dayNum) ];
            break;
        case CCDateStyleMonthDay:
            return @[ @(monthNum * timeInterval), @(dayNum), @(hourNum) ];
            break;
        case CCDateStyleHourMinute:
            return @[ @(hourNum), @(minuteNUm) ];
            break;
        default:
            return @[];
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSString *title;
    
    switch (self.datePickerStyle) {
        case CCDateStyleYearMonthDayHourMinute:
            if (component == 0) title = _yearArray[row];
            if (component == 1) title = _monthArray[row];
            if (component == 2) title = _dayArray[row];
            if (component == 3) title = _hourArray[row];
            if (component == 4) title = _minuteArray[row];
            break;
        case CCDateStyleYearMonthDay:
            if (component == 0) title = _yearArray[row];
            if (component == 1) title = _monthArray[row];
            if (component == 2) title = _dayArray[row];
            break;
        case CCDateStyleMonthDayHourMinute:
            if (component == 0) title = _monthArray[row % 12];
            if (component == 1) title = _dayArray[row];
            if (component == 2) title = _hourArray[row];
            if (component == 3) title = _minuteArray[row];
            break;
        case CCDateStyleMonthDay:
            if (component == 0) title = _monthArray[row % 12];
            if (component == 1) title = _dayArray[row];
            break;
        case CCDateStyleHourMinute:
            if (component == 0) title = _hourArray[row];
            if (component == 1) title = _minuteArray[row];
            break;
        default:
            title = @"";
            break;
    }
    
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.datePickerStyle) {
        case CCDateStyleYearMonthDayHourMinute: {
            if (component == 0) {
                yearIndex = row;
                self.showYearView.text = _yearArray[yearIndex];
            }
            
            if (component == 1) monthIndex = row;
            if (component == 2) dayIndex = row;
            if (component == 3) hourIndex = row;
            if (component == 4) minuteIndex = row;
            if (component == 0 || component == 1) {
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count - 1 < dayIndex) {
                    dayIndex = _dayArray.count - 1;
                }
            }
        } break;
        case CCDateStyleYearMonthDay: {
            if (component == 0) {
                yearIndex = row;
                self.showYearView.text = _yearArray[yearIndex];
            }
            if (component == 1) monthIndex = row;
            if (component == 2) dayIndex = row;
            if (component == 0 || component == 1) {
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count - 1 < dayIndex) {
                    dayIndex = _dayArray.count - 1;
                }
            }
        } break;
        case CCDateStyleMonthDayHourMinute: {
            if (component == 1) dayIndex = row;
            if (component == 2) hourIndex = row;
            if (component == 3) minuteIndex = row;
            
            if (component == 0) {
                [self yearChange:row];
                if (_dayArray.count - 1 < dayIndex)
                    dayIndex = _dayArray.count - 1;
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        } break;
            
        case CCDateStyleMonthDay: {
            if (component == 1) dayIndex = row;
            if (component == 0) {
                [self yearChange:row];
                if (_dayArray.count - 1 < dayIndex)
                    dayIndex = _dayArray.count - 1;
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        } break;
            
        case CCDateStyleHourMinute: {
            if (component == 0) hourIndex = row;
            if (component == 1) minuteIndex = row;
        } break;
            
        default:
            break;
    }
    
    [pickerView reloadAllComponents];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", _yearArray[yearIndex], _monthArray[monthIndex], _dayArray[dayIndex], _hourArray[hourIndex], _minuteArray[minuteIndex]];
    self.scrollToDate = [[NSDate dateWithString:dateStr format:@"yyyy-MM-dd HH:mm"] dateWithFormatter:_dateFormatter];
    
    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.minLimitDate animated:YES];
    } else if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending) {
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
}

- (void)yearChange:(NSInteger)row
{
    
    monthIndex = row % 12;
    
    //年份状态变化
    if (row - preRow < 12 && row - preRow > 0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow % 12] integerValue]) {
        yearIndex++;
    } else if (preRow - row < 12 && preRow - row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow % 12] integerValue]) {
        yearIndex--;
    } else {
        NSInteger interval = (row - preRow) / 12;
        yearIndex += interval;
    }
    
    self.showYearView.text = _yearArray[yearIndex];
    
    preRow = row;
}

#pragma mark - tools
//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year % 4 == 0 ? (num_year % 100 == 0 ? (num_year % 400 == 0 ? YES : NO) : YES) : NO;
    switch (num_month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12: {
            [self setdayArray:31];
            return 31;
        }
        case 4:
        case 6:
        case 9:
        case 11: {
            [self setdayArray:30];
            return 30;
        }
        case 2: {
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            } else {
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i = 1; i <= num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d", i]];
    }
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date)
        date = [NSDate date];
    
    [self DaysfromYear:date.year andMonth:date.month];
    
    yearIndex = date.year - MINYEAR;
    monthIndex = date.month - 1;
    dayIndex = date.day - 1;
    hourIndex = date.hour;
    minuteIndex = date.minute;
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year - MINYEAR) * 12 + self.scrollToDate.month - 1;
    
    NSArray *indexArray;
    if (self.datePickerStyle == CCDateStyleYearMonthDayHourMinute)
        indexArray = @[ @(yearIndex), @(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex) ];
    if (self.datePickerStyle == CCDateStyleYearMonthDay)
        indexArray = @[ @(yearIndex), @(monthIndex), @(dayIndex) ];
    if (self.datePickerStyle == CCDateStyleMonthDayHourMinute)
        indexArray = @[ @(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex) ];
    if (self.datePickerStyle == CCDateStyleMonthDay)
        indexArray = @[ @(monthIndex), @(dayIndex) ];
    if (self.datePickerStyle == CCDateStyleHourMinute)
        indexArray = @[ @(hourIndex), @(minuteIndex) ];
    
    self.showYearView.text = _yearArray[yearIndex];
    [self.datePicker reloadAllComponents];
    
    for (int i = 0; i < indexArray.count; i++) {
        if ((self.datePickerStyle == CCDateStyleMonthDayHourMinute || self.datePickerStyle == CCDateStyleMonthDay) && i == 0) {
            NSInteger mIndex = [indexArray[i] integerValue] + (12 * (self.scrollToDate.year - MINYEAR));
            [self.datePicker selectRow:mIndex inComponent:i animated:animated];
        } else {
            [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
    }
}

#pragma mark - getter / setter

- (UILabel *)showYearView
{
    if (!_showYearView) {
        _showYearView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 40)];
        _showYearView.textColor = [UIColor colorWithRed:237.0 / 255.0 green:241.0 / 255.0 blue:245.0 / 255.0 alpha:1];
        _showYearView.font = [UIFont systemFontOfSize:110];
        _showYearView.textAlignment = NSTextAlignmentCenter;
        _showYearView.userInteractionEnabled = YES;
    }
    return _showYearView;
}

- (UIPickerView *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] initWithFrame:self.showYearView.bounds];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

- (void)setMinLimitDate:(NSDate *)minLimitDate
{
    _minLimitDate = minLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedAscending)
        _scrollToDate = self.minLimitDate;
    
    [self getNowDate:self.scrollToDate animated:NO];
}

- (void)setMaxLimitDate:(NSDate *)maxLimitDate
{
    _maxLimitDate = maxLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedDescending)
        _scrollToDate = self.minLimitDate;
    
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)handleBlock:(didCompleteBlock)didHandleBlock
{
    _didHandleBlock = didHandleBlock;
}

@end
