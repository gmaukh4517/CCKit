//
//  CCRingProgressView.m
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

#import "CCRingProgressView.h"

static const CGFloat kDetailsLabelFontSize = 12.f;
static const CGFloat kAnnularLineWith = 4.f;

@interface CCRingProgressView ()

@property(nonatomic, strong) UILabel *percentLabel;
//@property(nonatomic, assign) BOOL _percentShow;

@end

@implementation CCRingProgressView

#pragma mark - Lifecycle

- (id)init
{
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupStrings];
    }
    return self;
}

- (void)setupStrings
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    _progress = 0.f;
    _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
    _progressBackgroundColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
    _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];

    _percentLabelTextColor = [UIColor whiteColor];
    _percentLabelFont = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];


    _annular = YES;			//Defaults to YES: 环形
    _annularLineCapStyle = kCGLineCapButt; // kCGLineCapButt is Defaults
    _annularLineWith = kAnnularLineWith;


    _percentShow = YES; //show percent

    _percentLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _percentLabel.adjustsFontSizeToFitWidth = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    _percentLabel.textAlignment = NSTextAlignmentCenter;
#else
    _percentLabel.textAlignment = UITextAlignmentCenter;
#endif
    _percentLabel.opaque = NO;
    _percentLabel.backgroundColor = [UIColor clearColor];
    _percentLabel.textColor = _percentLabelTextColor;
    _percentLabel.font = _percentLabelFont;
    _percentLabel.text = @"0%";
    _percentLabel.hidden = !_percentShow;
    [self addSubview:_percentLabel];


    [self registerForKVO];
}

- (void)dealloc
{
    [self unregisterFromKVO];
#if !__has_feature(objc_arc)
    [_progressTintColor release];
    [_progressBackgroundColor release];
    [_backgroundTintColor release];
    [_pecentLabel release];
    [_percentLabelFont release];
    [_percentLabelTextColor release];
    [super dealloc];
#endif
}

- (void)setPercentShow:(BOOL)show
{
    _percentShow = show;
    _percentLabel.hidden = !show;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (_percentShow) {
        _percentLabel.text = [NSString stringWithFormat:@"%.0f%%", roundf(self.progress * 100.0)];
        _percentLabel.textColor = self.percentLabelTextColor;
        _percentLabel.font = self.percentLabelFont;
    }

    if (_annular) {
        // Draw background
        CGFloat lineWidth = self.annularLineWith;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapRound;
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) - lineWidth) / 2;
        CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = self.annularLineCapStyle;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        CGRect allRect = self.bounds;
        CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();

        // Draw background
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        CGContextSetLineWidth(context, 2.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (MIN(allRect.size.width, allRect.size.height) - 4) / 2;
        CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        CGContextSetFillColorWithColor(context, self.progressBackgroundColor.CGColor);
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

#pragma mark - KVO

- (void)registerForKVO
{
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO
{
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths
{
    return [NSArray arrayWithObjects:
            @"progressTintColor",
            @"backgroundTintColor",
            @"progressBackgroundColor",
            @"progress",
            @"percentShow",
            @"percentLabelTextColor",
            @"percentLabelFont",
            @"annular",
            @"annularLineCapStyle",
            @"annularLineWith",
            nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self setNeedsDisplay];
}


@end
