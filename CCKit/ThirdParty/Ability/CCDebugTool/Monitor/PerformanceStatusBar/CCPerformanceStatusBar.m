//
//  CCPerformanceStatusBar.m
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

#import "CCPerformanceStatusBar.h"
#import "UIView+Frame.h"

@implementation CCPerformanceStatusBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.layer.cornerRadius = 3;
    
    _fpsLabel = [[CCMonitorLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
    _fpsLabel.font = [UIFont systemFontOfSize:8];
    _fpsLabel.textAlignment = NSTextAlignmentCenter;
    _fpsLabel.textColor = [UIColor whiteColor];
    _fpsLabel.text = @"FPS: -";
    _fpsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_fpsLabel];
    
    CGFloat width = (self.width - _fpsLabel.right);// / 2;
    
    _cpuLabel = [[CCMonitorLabel alloc] initWithFrame:CGRectMake(_fpsLabel.right, _fpsLabel.y, width, 10)];
    _cpuLabel.font = [UIFont systemFontOfSize:8];
    _cpuLabel.textAlignment = NSTextAlignmentCenter;
    _cpuLabel.textColor = [UIColor whiteColor];
    _cpuLabel.text = @"CPU: -";
    _cpuLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_cpuLabel];
    
//    _ramLabel = [[CCMonitorLabel alloc] initWithFrame:CGRectMake(_cpuLabel.right, _cpuLabel.y, width, 10)];
//    _ramLabel.font = [UIFont systemFontOfSize:8];
//    _ramLabel.textAlignment = NSTextAlignmentCenter;
//    _ramLabel.textColor = [UIColor whiteColor];
//    _ramLabel.text = @"RAM: -";
//    _ramLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:_ramLabel];
    
    _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _fpsLabel.bottom, self.width, 10)];
    _networkLabel.font = [UIFont systemFontOfSize:8];
    _networkLabel.textAlignment = NSTextAlignmentCenter;
    _networkLabel.textColor = [UIColor whiteColor];
    _networkLabel.text = @"↑: -/- ↓: -/-";
    _networkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_networkLabel];
}

@end
