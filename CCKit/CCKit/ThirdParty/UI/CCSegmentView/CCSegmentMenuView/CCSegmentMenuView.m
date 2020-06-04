//
//  CCSegmentMenuView.m
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
//opyright © 2019 CC. All rights reserved.
//

#import "CCSegmentMenuView.h"
#import "CCConfig.h"
#import "UIColor+CCAdd.h"
#import "UIView+Frame.h"
#import "UIView+Method.h"

@interface CCSegmentMenuView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sliderView;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) NSArray *titleArr;

@property (nonatomic, strong) NSMutableArray *titleButtons;

@property (nonatomic, assign) BOOL isint;

@property (nonatomic, assign) CGPoint lastContentOffset;

/** 是否是点击按钮 **/
@property (nonatomic, assign) BOOL isForbidScroll;


@end

static NSInteger const kSiderWidth = 18;

static CGFloat const kSpacing = 15;


@implementation CCSegmentMenuView

- (instancetype)init
{
    if (self = [super init]) {
        [self initCongfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCongfig];
    }
    return self;
}

- (void)initCongfig
{
    if (self.height == 0)
        self.height = 40;
    
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.backgroundColor = [UIColor whiteColor];
    
    _titleColor = [UIColor colorFromHexCode:@"303943"];
    _titleSelectedColor = [UIColor colorFromHexCode:@"303943"];
    _titleFont = [UIFont systemFontOfSize:15];
    _titleSelectedFont = [UIFont boldSystemFontOfSize:15];
    
    _lineHeight = 2;
    _isLine = NO;
    _isint = YES;
    _isSlider = YES;
    
    _shadow = NO;
    
    _titleButtons = [NSMutableArray array];
    
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 4;
}

- (void)initialization
{
    for (NSInteger i = 0; i < _titleArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        btn.tag = i + 100;
        [btn setTitle:[self titleHandle:_titleArr[ i ]] forState:UIControlStateNormal];
        [btn.titleLabel setFont:_titleFont];
        
        [btn setTitleColor:_titleColor forState:UIControlStateNormal];
        [btn setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        [btn setTitleColor:_titleSelectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == self.currentIndex) {
            btn.selected = YES;
            btn.titleLabel.font = _titleSelectedFont;
            self.selectedBtn = btn;
        }
        
        [self.titleButtons addObject:btn];
        
        if (self.isFullofLine) {
            UIView *lineView = [UIView new];
            lineView.tag = 1111;
            lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:lineView];
        }
    }
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
    lineView.backgroundColor = [UIColor colorFromHexCode:@"EAEBEC"];
    [self addSubview:_lineView = lineView];
    
    if (self.isSlider) { //滑块
        UIView *sliderView = [[UIView alloc] init];
        [self addSubview:sliderView];
        sliderView.backgroundColor = self.titleSelectedColor;
        self.sliderView = sliderView;
    }
}

- (NSString *)titleHandle:(NSString *)title
{
    if (self.isTitleLength) {
        if (title.length > 5)
            title = [NSString stringWithFormat:@"%@...", [title substringToIndex:5]];
    }
    return title;
}

- (void)setItems:(NSArray *)arr
{
    [self removeAllSubviews];
    [self.titleButtons removeAllObjects];
    if (!arr.count)
        return;
    
    _currentIndex = 0;
    cc_dispatch_after(0.1, ^{
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    
    if (self.isSlider && self.isint) {
        _titleFont = [self.titleFont fontWithSize:self.titleFont.pointSize - 2];
        _titleSelectedFont = [self.titleFont fontWithSize:self.titleSelectedFont.pointSize - 2];
    }
    
    _titleArr = arr;
    _isint = YES;
    [self initialization];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.titleButtons enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj setTitleColor:titleColor forState:UIControlStateNormal];
    }];
}
- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    if (self.titleButtons.count) {
        [self.titleButtons enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (idx != self.currentIndex)
                obj.titleLabel.font = titleFont;
        }];
    }
}

- (void)setTitleSelectedFont:(UIFont *)titleSelectedFont
{
    _titleSelectedFont = titleSelectedFont;
    if (self.titleButtons.count)
        ((UIButton *)[self.titleButtons objectAtIndex:self.currentIndex]).titleLabel.font = titleSelectedFont;
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor
{
    _titleSelectedColor = titleSelectedColor;
    self.sliderView.backgroundColor = self.titleSelectedColor;
    
    [self.titleButtons enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
        [obj setTitleColor:self.titleSelectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
    }];
}

- (void)setShadow:(BOOL)shadow
{
    _shadow = shadow;
    UIColor *color = [UIColor clearColor];
    if (_shadow)
        color = [UIColor colorFromHexCode:@"303943"];
    self.layer.shadowColor = color.CGColor;
}

- (void)showBadgePointOnItemIndex:(NSInteger)index
{
    //移除之前的小红点
    [self removeBadgePointOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [UIView new];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 2.5;             //圆形
    badgeView.backgroundColor = [UIColor redColor]; //颜色：红色
    badgeView.size = CGSizeMake(5, 5);
    
    UIButton *itemButtont = (UIButton *)[self.titleButtons objectAtIndex:index];
    badgeView.x = itemButtont.titleLabel.right;
    badgeView.y = itemButtont.titleLabel.y - 3;
    badgeView.clipsToBounds = YES;
    [itemButtont addSubview:badgeView];
}

- (void)hideBadgePointOnItemIndex:(NSInteger)index
{
    [self removeBadgePointOnItemIndex:index];
}

- (void)removeBadgePointOnItemIndex:(NSInteger)index
{
    for (NSInteger i = 0; i < self.titleButtons.count; i++) {
        UIView *itemView = [self.titleButtons objectAtIndex:i];
        if (i == index)
            [[itemView viewWithTag:888 + index] removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.sliderView.hidden = !self.isSlider;
    if (_isint) {
        self.lineView.y = self.height - self.lineView.height;
        self.lineView.hidden = self.isLine;
        
        //    按钮
        CGFloat btnH = self.height - 2;
        __block CGFloat totalX = self.isFullof ? 0 : 5;
        
        __block UIButton *currentBtn;
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)obj;
                if (btn.selected)
                    currentBtn = btn;
                
                if (self.isFullof) {
                    btn.x = totalX;
                    btn.y = 1;
                    btn.width = self.width / self.titleArr.count;
                    btn.height = self.height;
                    if (self.titleArr.count == 1) {
                        CGRect btnRect = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, btnH) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleSelectedFont ?: self.titleFont, NSFontAttributeName, nil] context:nil];
                        btn.x = kSpacing / 2;
                        btn.width = btnRect.size.width + kSpacing;
                    }
                    totalX = totalX + btn.width;
                } else {
                    CGRect btnRect = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, btnH) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleSelectedFont ?: self.titleFont, NSFontAttributeName, nil] context:nil];
                    btn.x = totalX;
                    btn.y = 1;
                    btn.width = btnRect.size.width + kSpacing;
                    btn.height = btnH;
                    
                    if (self.isSlider) {
                        btn.width = btnRect.size.width + 30;
                        btn.height = btnRect.size.height + 8;
                        btn.y = (btnH - btn.height) / 2;
                        
                        if (self.isSlider)
                            cc_view_border_radius(btn, btn.height / 2, 0.5, btn.selected ? self.titleSelectedColor : self.titleColor);
                    }
                    
                    totalX = totalX + btn.width;
                }
            } else if (obj.tag == 1111) {
                obj.frame = CGRectMake(totalX, (self.height - 20) / 2, 0.5, 20);
                totalX += 0.5;
            }
        }];
        
        if (totalX - 10 < winsize.width) {
            self.contentSize = CGSizeMake(winsize.width, 0);
        } else {
            self.contentSize = CGSizeMake(totalX, 0);
        }
        
        if (self.isSlider) {
            if (self.isFullof) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:_titleFont forKey:NSFontAttributeName];
                CGSize textSize = [currentBtn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
                self.sliderView.width = textSize.width;
                if (self.lineWidth > 0)
                    self.sliderView.width = self.lineWidth;
            }
            self.sliderView.centerX = currentBtn.centerX;
        }
        
        self.lineView.width = self.contentSize.width;
        _isint = NO;
        
        self.sliderView.width = kSiderWidth;
        if (self.isFullof) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:_titleFont forKey:NSFontAttributeName];
            CGSize textSize = [_titleArr[ _currentIndex ] boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            self.sliderView.width = textSize.width;
            
            if (self.lineWidth > 0)
                self.sliderView.width = self.lineWidth;
        }
        self.sliderView.height = self.lineHeight;
        self.sliderView.y = self.height - self.lineHeight - self.lineOffsetY;
        cc_view_radius(self.sliderView, self.sliderView.height / 2);
    }
}

//按钮点击事件
- (void)btnClick:(UIButton *)sender
{
    [self setCurrentIndex:sender.tag - 100];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    [self changeCurrentIndex:currentIndex];
    if ([self.segmentDelegate respondsToSelector:@selector(didScrollSelectedIndex:)])
        [self.segmentDelegate didScrollSelectedIndex:self->_currentIndex];
}

- (void)changeCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex == self.currentIndex) return;
    
    UIButton *currentButton = self.titleButtons[ currentIndex ];
    UIButton *oldButton = self.titleButtons[ self.currentIndex ];
    
    currentButton.titleLabel.font = _titleSelectedFont;
    [currentButton setTitleColor:self.titleSelectedColor forState:UIControlStateNormal];
    [currentButton setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
    currentButton.selected = YES;
    
    [oldButton setTitleColor:self.titleColor forState:UIControlStateNormal];
    [oldButton setTitleColor:self.titleColor forState:UIControlStateSelected];
    oldButton.titleLabel.font = _titleFont;
    oldButton.selected = NO;
    
    self.isForbidScroll = YES;
    _currentIndex = currentIndex;
    [self titleViewDidEndScroll];
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
        self.sliderView.centerX = currentButton.centerX;
    }
                     completion:nil];
}

- (void)didBeginDraaWillBeginDragging:(CGPoint)offset
{
    self.isForbidScroll = NO;
    _lastContentOffset = offset;
}

- (void)didScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isForbidScroll) return;
    
    CGFloat progress = 0.0;
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;
    
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    if (currentOffsetX > self.lastContentOffset.x) { //左滑
        progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        sourceIndex = (NSInteger)(currentOffsetX / scrollViewW);
        targetIndex = sourceIndex + 1;
        if (targetIndex >= self.titleArr.count) {
            targetIndex = self.titleArr.count - 1;
            sourceIndex = self.titleArr.count - 1;
        }
        
        if (currentOffsetX - self.lastContentOffset.x == scrollViewW) {
            progress = 1.0;
            targetIndex = sourceIndex;
        }
    } else { //右滑
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        targetIndex = (NSInteger)(currentOffsetX / scrollViewW);
        
        sourceIndex = targetIndex + 1;
        if (sourceIndex >= self.titleArr.count)
            sourceIndex = self.titleArr.count - 1;
    }
    
    [self setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView afterDelay:0.2];
}

- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex
{
    //取出sourceLabel和targetLabel
    UIButton *sourceLabel = self.titleButtons[ sourceIndex ];
    UIButton *targetLabel = self.titleButtons[ targetIndex ];
    
    
    UIColor *selectedColor = self.titleSelectedColor, *normalColor = self.titleColor;
    if (self.selectedColorRGB && self.normalColorRGB) {
        UIColor *delataColor = [UIColor colorWithRed:self.selectedColorRGB[ 0 ] - self.normalColorRGB[ 0 ] green:self.selectedColorRGB[ 1 ] - self.normalColorRGB[ 1 ] blue:self.selectedColorRGB[ 2 ] - self.normalColorRGB[ 2 ] alpha:1.0];
        const CGFloat *colorDelta = [self getRGBWithColor:delataColor];
        selectedColor = [UIColor colorWithRed:self.selectedColorRGB[ 0 ] - colorDelta[ 0 ] * progress green:self.selectedColorRGB[ 1 ] - colorDelta[ 1 ] * progress blue:self.selectedColorRGB[ 2 ] - colorDelta[ 2 ] * progress alpha:1.0];
        normalColor = [UIColor colorWithRed:self.normalColorRGB[ 0 ] + colorDelta[ 0 ] * progress green:self.normalColorRGB[ 1 ] + colorDelta[ 1 ] * progress blue:self.normalColorRGB[ 2 ] + colorDelta[ 2 ] * progress alpha:1.0];
    }
    
    CGFloat pointSize = self.titleSelectedFont.pointSize - self.titleFont.pointSize;
    //颜色渐变
    sourceLabel.titleLabel.font = [self.titleFont fontWithSize:self.titleSelectedFont.pointSize - (pointSize * progress)];
    [sourceLabel setTitleColor:selectedColor forState:UIControlStateNormal];
    [sourceLabel setTitleColor:selectedColor forState:UIControlStateSelected];
    
    targetLabel.titleLabel.font = [self.titleSelectedFont fontWithSize:self.titleFont.pointSize + (pointSize * progress)];
    [targetLabel setTitleColor:normalColor forState:UIControlStateNormal];
    [targetLabel setTitleColor:normalColor forState:UIControlStateSelected];
    
    //记录最新的index
    _currentIndex = targetIndex;
    CGFloat moveTotalX = targetLabel.centerX - sourceLabel.centerX;
    CGFloat moveTotalW = targetLabel.frame.size.width - sourceLabel.frame.size.width;
    
    //计算滚动的范围差值
    if (self.isSlider) {
        CGFloat x = sourceLabel.frame.origin.x + ((sourceLabel.frame.size.width - (self.isFullof ? self.sliderView.width : self.lineWidth)) / 2.0) + moveTotalX * progress;
        CGFloat width = self.lineWidth + moveTotalW * progress;
        self.sliderView.x = x;
        self.sliderView.width = width;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    for (UIButton *oldButton in self.titleButtons) {
        [oldButton setTitleColor:self.titleColor forState:UIControlStateNormal];
        [oldButton setTitleColor:self.titleColor forState:UIControlStateSelected];
        oldButton.titleLabel.font = self.titleFont;
        oldButton.selected = NO;
    }
    UIButton *currentButton = self.titleButtons[ _currentIndex ];
    currentButton.titleLabel.font = self.titleSelectedFont;
    [currentButton setTitleColor:self.titleSelectedColor forState:UIControlStateNormal];
    [currentButton setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
    currentButton.selected = YES;
}

- (void)didScrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    
    //快速滑动之后 可能会出现偏差 需要重置
    NSInteger targetIndex = (NSInteger)(currentOffsetX / scrollViewW);
    if (targetIndex >= self.titleArr.count - 1) {
        NSInteger sourceIndex = targetIndex;
        CGFloat progress = 1.0;
        [self setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    }
    
    [self titleViewDidEndScroll];
    
    if ([self.segmentDelegate respondsToSelector:@selector(didScrollSelectedIndex:)])
        [self.segmentDelegate didScrollSelectedIndex:self->_currentIndex];
}

- (void)didScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self titleViewDidEndScroll];
    }
}

#pragma mark -
#pragma mark :. handle

- (void)titleViewDidEndScroll
{
    UIButton *targetLabel = self.titleButtons[ self.currentIndex ];
    
    targetLabel.selected = YES;
    targetLabel.titleLabel.font = self.titleSelectedFont;
    
    CGFloat offset = targetLabel.center.x - winsize.width * 0.5;
    if (offset < 0)
        offset = 0;
    
    CGFloat maxOffset = self.contentSize.width - winsize.width;
    if (offset > maxOffset) {
        offset = maxOffset;
        if (!self.isFullof && offset > 0)
            offset += targetLabel.width + kSpacing;
    }
    
    [self setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark -
#pragma mark :. 颜色处理

- (const CGFloat *)normalColorRGB
{
    return [self getRGBWithColor:self.titleColor];
}

- (const CGFloat *)selectedColorRGB
{
    return [self getRGBWithColor:self.titleSelectedColor];
}

- (const CGFloat *)getRGBWithColor:(UIColor *)color
{
    CGColorRef refColor = [color CGColor];
    const CGFloat *components = nil;
    long numComponents = CGColorGetNumberOfComponents(refColor);
    if (numComponents == 4) {
        components = CGColorGetComponents(refColor);
    }
    return components;
}

@end
