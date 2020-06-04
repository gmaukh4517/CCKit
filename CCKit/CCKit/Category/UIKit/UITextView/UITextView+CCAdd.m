//
//  UITextView+CCAdd.m
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

#import "UITextView+CCAdd.h"
#import "objc/runtime.h"

static int minFontSizeKey;
static int maxFontSizeKey;
static int zoomEnabledKey;

static const void *UITextViewDelegateKey = &UITextViewDelegateKey;
static const void *UITextViewShouldChangeCharactersInRangeKey = &UITextViewShouldChangeCharactersInRangeKey;
static const void *UITextViewDidChange = &UITextViewDidChange;

static const void *UITextViewTextChange = &UITextViewTextChange;

@implementation UITextView (CCAdd)

static inline void AutomaticWritingSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], NSSelectorFromString(@"dealloc"), @selector(cc_dealloc));
        AutomaticWritingSwizzleSelector([self class], @selector(setText:), @selector(cc_setText:));
    });
}

/**
 *  @brief  当前选中的字符串范围
 *
 *  @return NSRange
 */
- (NSRange)selectedRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}
/**
 *  @brief  选中所有文字
 */
- (void)selectAllText
{
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}
/**
 *  @brief  选中指定范围的文字
 *
 *  @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}


// 用于计算textview输入情况下的字符数，解决实现限制字符数时，计算不准的问题
- (NSInteger)getInputLengthWithText:(NSString *)text
{
    NSInteger textLength = 0;
    //获取高亮部分
    UITextRange *selectedRange = [self markedTextRange];
    if (selectedRange) {
        NSString *newText = [self textInRange:selectedRange];
        textLength = (newText.length + 1) / 2 + [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start] + text.length;
    } else {
        textLength = self.text.length + text.length;
    }
    return textLength;
}

- (void)setMaxFontSize:(CGFloat)maxFontSize
{
    objc_setAssociatedObject(self, &maxFontSizeKey, [NSNumber numberWithFloat:maxFontSize],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maxFontSize
{
    return [objc_getAssociatedObject(self, &maxFontSizeKey) floatValue];
}

- (void)setMinFontSize:(CGFloat)maxFontSize
{
    objc_setAssociatedObject(self, &minFontSizeKey, [NSNumber numberWithFloat:maxFontSize],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minFontSize
{
    return [objc_getAssociatedObject(self, &minFontSizeKey) floatValue];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if (!self.isZoomEnabled) return;
    
    CGFloat pointSize = (gestureRecognizer.velocity > 0.0f ? 1.0f : -1.0f) + self.font.pointSize;
    
    pointSize = MAX(MIN(pointSize, self.maxFontSize), self.minFontSize);
    
    self.font = [UIFont fontWithName:self.font.fontName size:pointSize];
}


- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    objc_setAssociatedObject(self, &zoomEnabledKey, [NSNumber numberWithBool:zoomEnabled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (zoomEnabled) {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) // initialized already
            if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) return;
        
        self.minFontSize = self.minFontSize ?: 8.0f;
        self.maxFontSize = self.maxFontSize ?: 42.0f;
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(pinchGesture:)];
        [self addGestureRecognizer:pinchRecognizer];
#if !__has_feature(objc_arc)
        [pinchRecognizer release];
#endif
    }
}

- (BOOL)isZoomEnabled
{
    return [objc_getAssociatedObject(self, &zoomEnabledKey) boolValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.placeholderLabel.frame;
    frame.origin.x = 8;
    frame.size.width = self.bounds.size.width - 16;
    self.placeholderLabel.frame = frame;
    [self.placeholderLabel sizeToFit];
    
    NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.placeholderLabel.attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8 - (self.placeholderLabel.font.lineHeight - self.placeholderLabel.font.pointSize)];
    [textAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textAttributedString.length)];
    self.placeholderLabel.attributedText = textAttributedString;
}

#pragma make :.设置默认提示

- (NSString *)placeholder
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [self initPlaceholder];
    self.placeholderLabel.text = placeholder;
    [self.placeholderLabel sizeToFit];
    self.placeholderLabel.frame = CGRectMake(8, 5, self.placeholderLabel.frame.size.width - 16, self.placeholderLabel.frame.size.height);
    
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)placeholderColor
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [self initPlaceholder];
    self.placeholderLabel.textColor = placeholderColor;
    objc_setAssociatedObject(self, @selector(placeholderColor), placeholderColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIFont *)placeholderFont
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    [self initPlaceholder];
    self.placeholderLabel.font = placeholderFont;
    objc_setAssociatedObject(self, @selector(placeholderFont), placeholderFont, OBJC_ASSOCIATION_RETAIN);
}

- (UILabel *)placeholderLabel
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlaceholderLabel:(UILabel *)placeholderLabel
{
    objc_setAssociatedObject(self, @selector(placeholderLabel), placeholderLabel, OBJC_ASSOCIATION_RETAIN);
}

- (void)initPlaceholder
{
    if (!self.placeholderLabel) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTextViewChange:) name:UITextViewTextDidChangeNotification object:nil];
        float left = 5, top = 5, hegiht = 30;
        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, CGRectGetWidth(self.frame) - 2 * left, hegiht)];
        self.placeholderLabel.numberOfLines = 0;
        self.placeholderLabel.font = self.font;
        [self addSubview:self.placeholderLabel];
    }
}

- (void)didTextViewChange:(NSNotification *)notification
{
    if (self.placeholder.length == 0 || [self.placeholder isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }
    
    self.placeholderLabel.hidden = NO;
    if (self.text.length > 0) {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)_firstBaselineOffsetFromTop
{
}
- (void)_baselineOffsetFromBottom
{
}
- (void)cc_setText:(NSString *)text
{
    [self cc_setText:text];
    [self didTextViewChange:nil];
}

- (void)cc_dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.placeholderLabel removeFromSuperview];
}

#pragma mark -
#pragma mark UITextView maxLength

- (NSInteger)maxLength
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setMaxLength:(NSInteger)maxLength
{
    objc_setAssociatedObject(self, @selector(maxLength), [NSNumber numberWithInteger:maxLength], OBJC_ASSOCIATION_RETAIN);
    
    __weak typeof(self) weakSelf = self;
    [self setShouldChangeCharactersInRangeBlock:^BOOL(UITextView *textView, NSRange range, NSString *text) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
        //获取高亮部分内容
        //NSString * selectedtext = [textView textInRange:selectedRange];
        //如果有高亮且当前字数开始位置小于最大限制时允许输入
        if (selectedRange && pos) {
            NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
            NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
            NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
            if (offsetRange.location < strongSelf.maxLength) {
                return YES;
            } else {
                return NO;
            }
        }
        
        NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSInteger caninputlen = strongSelf.maxLength - comcatstr.length;
        if (caninputlen >= 0) {
            return YES;
        } else {
            NSInteger len = text.length + caninputlen;
            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            NSRange rg = {0, MAX(len, 0)};
            if (rg.length > 0) {
                // 因为我的是不需要输入表情，所以没有计算表情的宽度
                //            NSString *s =@"";
                //            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
                //            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
                //            if (asc) {
                //                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
                //            }else{
                //                __block NSInteger idx = 0;
                //                __block NSString  *trimString =@"";//截取出的字串
                //                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                //                [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString* substring,NSRange substringRange,NSRange enclosingRange,BOOL* stop) {
                //                    if (idx >= rg.length) {
                //                        *stop =YES;//取出所需要就break，提高效率
                //                        return ;
                //                    }
                //                    trimString = [trimString stringByAppendingString:substring];
                //                    idx++;
                //                }];
                //                s = trimString;
                //            }
                //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
                //                textView.text =
                textView.text = [textView.text stringByReplacingCharactersInRange:range withString:[text substringWithRange:rg]];
                //既然是超出部分截取了，哪一定是最大限制了。
                !strongSelf.textViewTextChangeBlock ?: strongSelf.textViewTextChangeBlock(textView);
                //                self.surplusLbl.text = [NSString stringWithFormat:@"%d/%ld", 0, (long)self.maxLength];
            }
            return NO;
        }
    }];
    
    
    [self setTextViewDidChangeBlock:^(UITextView *textView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
        //如果在变化中是高亮部分在变，就不要计算字符了
        if (selectedRange && pos) {
            return;
        }
        NSString *nsTextContent = textView.text;
        NSInteger existTextNum = nsTextContent.length;
        if (existTextNum > strongSelf.maxLength) {
            //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
            NSRange rangeRange = [nsTextContent rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, strongSelf.maxLength)];
            textView.text = [nsTextContent substringWithRange:rangeRange];
        }
        //不让显示负数
        //        self.surplusLbl.text = [NSString stringWithFormat:@"%ld/%ld", MAX(0, self.maxLength - existTextNum), self.maxLength];
        !strongSelf.textViewTextChangeBlock ?: strongSelf.textViewTextChangeBlock(textView);
        
        // 自动增加textView的高度
        //    CGRect bouns = textView.bounds;
        //    CGSize maxSize = CGSizeMake(bouns.size.width, CGFLOAT_MAX);
        //    CGSize newSize = [textView sizeThatFits:maxSize];
        //    NSLog(@"%@", NSStringFromCGSize(self.size));
        //    if (newSize.height > self.height) {
        //        textView.height = newSize.height + 20;
        //        self.surplusLbl.top = textView.height - 20;
        //        self.placeholderLbl.top = CGRectGetMaxY(textView.frame);
        //    }
        
        //不支持系统表情的输入
        //        if ([NSString isStringContainsEmoji:textView.text]) {
        //            [[UIViewController currentViewController] showInfo:@"不支持输入表情，请重新输入!"];
        //            self.text = [textView.text substringToIndex:textView.text.length - 2];
        //        }
    }];
}

#pragma mark -
#pragma mark UITextView Delegate methods

+ (BOOL)textView:(UITextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textView.shouldChangeCharactersInRangeBlock) {
        return textView.shouldChangeCharactersInRangeBlock(textView, range, string);
    }
    id delegate = objc_getAssociatedObject(self, UITextViewDelegateKey);
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [delegate textView:textView shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

+ (void)textViewDidChange:(UITextView *)textView
{
    if (textView.textViewDidChangeBlock) {
        textView.textViewDidChangeBlock(textView);
    }
    
    id delegate = objc_getAssociatedObject(self, UITextViewDidChange);
    if ([delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [delegate textViewDidChange:textView];
    }
}

#pragma mark UITextView Block getter/setter methods
- (BOOL (^)(UITextView *, NSRange, NSString *))shouldChangeCharactersInRangeBlock
{
    return objc_getAssociatedObject(self, UITextViewShouldChangeCharactersInRangeKey);
}

- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextView *, NSRange, NSString *))shouldChangeCharactersInRangeBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextViewShouldChangeCharactersInRangeKey, shouldChangeCharactersInRangeBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UITextView *))textViewDidChangeBlock
{
    return objc_getAssociatedObject(self, UITextViewDidChange);
}

- (void)setTextViewDidChangeBlock:(void (^)(UITextView *textView))textViewDidChangeBlock
{
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextViewDidChange, textViewDidChangeBlock, OBJC_ASSOCIATION_COPY);
}


- (void (^)(UITextView *))textViewTextChangeBlock
{
    return objc_getAssociatedObject(self, UITextViewTextChange);
}

- (void)setTextViewTextChangeBlock:(void (^)(UITextView *))textViewTextChangeBlock
{
    objc_setAssociatedObject(self, UITextViewTextChange, textViewTextChangeBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark control method
/*
 Setting itself as delegate if no other delegate has been set. This ensures the UITextField will use blocks if no delegate is set.
 */
- (void)setDelegateIfNoDelegateSet
{
    if (self.delegate != (id<UITextViewDelegate>)[self class]) {
        objc_setAssociatedObject(self, UITextViewDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UITextViewDelegate>)[self class];
    }
}
@end
