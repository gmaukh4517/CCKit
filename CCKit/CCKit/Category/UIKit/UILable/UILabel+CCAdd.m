//
//  UILabel+CCAdd.m
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

#import "UILabel+CCAdd.h"
#include <objc/runtime.h>

typedef void (^UILabelActionBlock)(UILabel *sender, id linkData);

@interface UILabelActionBlockWrapper : NSObject

@property (nonatomic, copy) UILabelActionBlock actionBlock;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL actionSEL;

- (void)invokeBlock:(UILabel *)sender linkData:(id)linkData;

@end

static const void *UILabelActionBlockArray = &UILabelActionBlockArray;

@implementation UILabelActionBlockWrapper

- (void)invokeBlock:(UILabel *)sender linkData:(id)linkData
{
    !self.actionBlock ?: self.actionBlock(sender, linkData);
    if ([self.target respondsToSelector:self.actionSEL]) {
        IMP imp = [self.target methodForSelector:self.actionSEL];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.target, self.actionSEL, linkData);
    }
}

@end


@implementation UILabel (CCAdd)

#pragma mark -
#pragma mark :. CCAdd
/**
 *  @author CC, 15-09-25
 *
 *  @brief  设置CellLabel背景颜色
 *
 *  @param color 颜色值
 */
- (void)cellLabelSetColor:(UIColor *)color
{
    [self setBackgroundColor:color];
    [self performSelector:@selector(setBackgroundColor:)
               withObject:color
               afterDelay:0.01];
}

#pragma mark -
#pragma mark :. AutomaticWriting


NSTimeInterval const UILabelAWDefaultDuration = 0.4f;

unichar const UILabelAWDefaultCharacter = 124;

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

static char kAutomaticWritingOperationQueueKey;
static char kAutomaticWritingEdgeInsetsKey;


#pragma mark :. Public Methods

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], @selector(textRectForBounds:limitedToNumberOfLines:), @selector(automaticWritingTextRectForBounds:limitedToNumberOfLines:));
        AutomaticWritingSwizzleSelector([self class], @selector(drawTextInRect:), @selector(drawAutomaticWritingTextInRect:));
        AutomaticWritingSwizzleSelector([self class], @selector(setText:), @selector(automaticWritingSetText:));
    });
}

- (void)automaticWritingSetText:(NSString *)text
{
    self.attributedString = nil;
    [self automaticWritingSetText:text];
}

- (void)drawAutomaticWritingTextInRect:(CGRect)rect
{
    [self drawAutomaticWritingTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGRect)automaticWritingTextRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [self automaticWritingTextRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    return textRect;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    objc_setAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey, [NSValue valueWithUIEdgeInsets:edgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)edgeInsets
{
    NSValue *edgeInsetsValue = objc_getAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey);
    
    if (edgeInsetsValue) {
        return edgeInsetsValue.UIEdgeInsetsValue;
    }
    
    edgeInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
    
    objc_setAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey, edgeInsetsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return edgeInsetsValue.UIEdgeInsetsValue;
}

- (void)setAutomaticWritingOperationQueue:(NSOperationQueue *)automaticWritingOperationQueue
{
    objc_setAssociatedObject(self, &kAutomaticWritingOperationQueueKey, automaticWritingOperationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSOperationQueue *)automaticWritingOperationQueue
{
    NSOperationQueue *operationQueue = objc_getAssociatedObject(self, &kAutomaticWritingOperationQueueKey);
    
    if (operationQueue) {
        return operationQueue;
    }
    
    operationQueue = NSOperationQueue.new;
    operationQueue.name = @"Automatic Writing Operation Queue";
    operationQueue.maxConcurrentOperationCount = 1;
    
    objc_setAssociatedObject(self, &kAutomaticWritingOperationQueueKey, operationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return operationQueue;
}

- (void)setTextWithAutomaticWritingAnimation:(NSString *)text
{
    [self setText:text automaticWritingAnimationWithBlinkingMode:UILabelCCBlinkingModeNone];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithBlinkingMode:(UILabelCCBlinkingMode)blinkingMode
{
    [self setText:text automaticWritingAnimationWithDuration:UILabelAWDefaultDuration blinkingMode:blinkingMode];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:UILabelCCBlinkingModeNone];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:blinkingMode blinkingCharacter:UILabelAWDefaultCharacter];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:blinkingMode blinkingCharacter:blinkingCharacter completion:nil];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter completion:(void (^)(void))completion
{
    self.automaticWritingOperationQueue.suspended = YES;
    self.automaticWritingOperationQueue = nil;
    
    self.text = @"";
    
    NSMutableString *automaticWritingText = NSMutableString.new;
    
    if (text) {
        [automaticWritingText appendString:text];
    }
    
    [self.automaticWritingOperationQueue addOperationWithBlock:^{
        [self automaticWriting:automaticWritingText duration:duration mode:blinkingMode character:blinkingCharacter completion:completion];
    }];
}

- (NSInteger)displayNumberOfLines:(CGFloat)width
{
    UILabel *label = [UILabel new];
    label.font = self.font;
    NSInteger numberLines = 0;
    NSArray *rowType = [self.text componentsSeparatedByString:@"\n"];
    for (NSString *currentText in rowType) {
        label.text = currentText;
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        NSInteger lines = ceil(textSize.width / width);
        lines = lines == 0 ? 1 : lines;
        numberLines += lines;
    }
    return numberLines;
}

#pragma mark :. Private Methods

- (void)automaticWriting:(NSMutableString *)text duration:(NSTimeInterval)duration mode:(UILabelCCBlinkingMode)mode character:(unichar)character completion:(void (^)(void))completion
{
    NSOperationQueue *currentQueue = NSOperationQueue.currentQueue;
    if ((text.length || mode >= UILabelCCBlinkingModeWhenFinish) && !currentQueue.isSuspended) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (mode != UILabelCCBlinkingModeNone) {
                if ([self isLastCharacter:character]) {
                    [self deleteLastCharacter];
                } else if (mode != UILabelCCBlinkingModeWhenFinish || !text.length) {
                    [text insertString:[self stringWithCharacter:character] atIndex:0];
                }
            }
            
            if (text.length) {
                [self appendCharacter:[text characterAtIndex:0]];
                [text deleteCharactersInRange:NSMakeRange(0, 1)];
                if ((![self isLastCharacter:character] && mode == UILabelCCBlinkingModeWhenFinishShowing) || (!text.length && mode == UILabelCCBlinkingModeWhenFinishShowing)) {
                    [self appendCharacter:character];
                }
            }
            
            if (!currentQueue.isSuspended) {
                [currentQueue addOperationWithBlock:^{
                    [self automaticWriting:text duration:duration mode:mode character:character completion:completion];
                }];
            } else if (completion) {
                completion();
            }
        });
    } else if (completion) {
        completion();
    }
}

- (NSString *)stringWithCharacter:(unichar)character
{
    return [self stringWithCharacters:@[ @(character) ]];
}

- (NSString *)stringWithCharacters:(NSArray *)characters
{
    NSMutableString *string = NSMutableString.new;
    
    for (NSNumber *character in characters) {
        [string appendFormat:@"%C", character.unsignedShortValue];
    }
    
    return string.copy;
}

- (void)appendCharacter:(unichar)character
{
    [self appendCharacters:@[ @(character) ]];
}

- (void)appendCharacters:(NSArray *)characters
{
    self.text = [self.text stringByAppendingString:[self stringWithCharacters:characters]];
}

- (BOOL)isLastCharacters:(NSArray *)characters
{
    if (self.text.length >= characters.count) {
        return [self.text hasSuffix:[self stringWithCharacters:characters]];
    }
    return NO;
}

- (BOOL)isLastCharacter:(unichar)character
{
    return [self isLastCharacters:@[ @(character) ]];
}

- (BOOL)deleteLastCharacters:(NSUInteger)characters
{
    if (self.text.length >= characters) {
        self.text = [self.text substringToIndex:self.text.length - characters];
        return YES;
    }
    return NO;
}

- (BOOL)deleteLastCharacter
{
    return [self deleteLastCharacters:1];
}

#pragma mark -
#pragma mark :. CCAdjustableLabel

// General method. If minSize is set to CGSizeZero then
// it is ignored.
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                     minimumSize:(CGSize)minSize
                 minimumFontSize:(CGFloat)minFontSize
{
    //// 1) Calculate new label size
    //// ---------------------------
    // First, reset some basic parameters
    [self setNumberOfLines:0];
    //    [self setLineBreakMode:UILineBreakModeWordWrap];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    
    // If maxSize is set to CGSizeZero, then assume the max width
    // is the size of the device screen minus the default
    // recommended edge distances (2 * 20)
    if (maxSize.height == CGSizeZero.height) {
        maxSize.width = [[UIScreen mainScreen] bounds].size.width - 40.0;
        maxSize.height = MAXFLOAT; // infinite height
    }
    
    // Now, calculate the size of the label constrained to maxSize
    CGSize tempSize = [[self text] boundingRectWithSize:maxSize
                                                options:NSStringDrawingTruncatesLastVisibleLine
                                             attributes:@{NSFontAttributeName : [self font]}
                                                context:nil]
    .size;
    
    // If minSize is specified (not CGSizeZero) then
    // check if the new calculated size is smaller than
    // the minimum size
    if (minSize.height != CGSizeZero.height) {
        if (tempSize.width <= minSize.width) tempSize.width = minSize.width;
        if (tempSize.height <= minSize.height) tempSize.height = minSize.height;
    }
    
    // Create rect
    CGRect newFrameSize = CGRectMake([self frame].origin.x, [self frame].origin.y, tempSize.width, tempSize.height);
    
    //// 2) Change the font size if necessary
    //// ------------------------------------
    UIFont *labelFont = [self font];          // temporary label object
    CGFloat fSize = [labelFont pointSize];    // temporary font size value
    CGSize calculatedSizeWithCurrentFontSize; // temporary frame size
    
    // Calculate label size as if there was no constrain
    CGSize unconstrainedSize = CGSizeMake(tempSize.width, MAXFLOAT);
    
    // Keep reducing the font size until the calculated frame size
    // is smaller than the maxSize parameter
    do {
        // Create a temporary font object
        labelFont = [UIFont fontWithName:[labelFont fontName]
                                    size:fSize];
        // Calculate the frame size
        calculatedSizeWithCurrentFontSize = [[self text] boundingRectWithSize:unconstrainedSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : labelFont} context:nil].size;
        // Reduce the temporary font size value
        fSize--;
    } while (calculatedSizeWithCurrentFontSize.height > maxSize.height);
    
    // Reset the font size to the last calculated value
    [self setFont:labelFont];
    
    // Reset the frame size
    [self setFrame:newFrameSize];
}

// Adjust label using only the maximum size and the
// font size as constraints
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                 minimumFontSize:(CGFloat)minFontSize
{
    [self adjustLabelToMaximumSize:maxSize
                       minimumSize:CGSizeZero
                   minimumFontSize:minFontSize];
}

// Adjust the size of the label using only the font
// size as a constraint (the maximum size will be
// calculated automatically based on the screen size)
// =====================================================
- (void)adjustLabelSizeWithMinimumFontSize:(CGFloat)minFontSize
{
    [self adjustLabelToMaximumSize:CGSizeZero
                       minimumSize:CGSizeZero
                   minimumFontSize:minFontSize];
}

// Adjust label without any constraints (the maximum
// size will be calculated automatically based on the
// screen size)
// =====================================================
- (void)adjustLabel
{
    [self adjustLabelToMaximumSize:CGSizeZero
                       minimumSize:CGSizeZero
                   minimumFontSize:[self minimumScaleFactor]];
}

#pragma mark -
#pragma mark :. SuggestSize

- (CGSize)suggestedSizeForWidth:(CGFloat)width
{
    if (self.attributedText)
        return [self suggestSizeForAttributedString:self.attributedText width:width];
    
    return [self suggestSizeForString:self.text width:width];
}

- (CGSize)suggestSizeForAttributedString:(NSAttributedString *)string width:(CGFloat)width
{
    if (!string) {
        return CGSizeZero;
    }
    return [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
}

- (CGSize)suggestSizeForString:(NSString *)string width:(CGFloat)width
{
    if (!string) {
        return CGSizeZero;
    }
    return [self suggestSizeForAttributedString:[[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : self.font}] width:width];
}

#pragma mark -
#pragma mark :. AutoSize

- (UILabel *)resizeLabelHorizontal
{
    return [self resizeLabelHorizontal:0];
}

- (UILabel *)resizeLabelVertical
{
    return [self resizeLabelVertical:0];
}

- (UILabel *)resizeLabelVertical:(CGFloat)minimumHeigh
{
    CGRect newFrame = self.frame;
    CGSize constrainedSize = CGSizeMake(newFrame.size.width, CGFLOAT_MAX);
    NSString *text = self.text;
    UIFont *font = self.font;
    CGSize size = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy};
        
        size = [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    } else {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)
        size = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    newFrame.size.height = ceilf(size.height);
    if (minimumHeigh > 0) {
        newFrame.size.height = (newFrame.size.height < minimumHeigh ? minimumHeigh : newFrame.size.height);
    }
    self.frame = newFrame;
    return self;
}

- (UILabel *)resizeLabelHorizontal:(CGFloat)minimumWidth
{
    CGRect newFrame = self.frame;
    CGSize constrainedSize = CGSizeMake(CGFLOAT_MAX, newFrame.size.height);
    NSString *text = self.text;
    UIFont *font = self.font;
    CGSize size = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy};
        
        size = [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    } else {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)
        size = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    newFrame.size.width = ceilf(size.width);
    if (minimumWidth > 0) {
        newFrame.size.width = (newFrame.size.width < minimumWidth ? minimumWidth : newFrame.size.width);
    }
    self.frame = newFrame;
    return self;
}

#pragma mark -
#pragma mark :. textSite

- (void)setAttributedString:(NSMutableAttributedString *)attributedString
{
    objc_setAssociatedObject(self, @selector(attributedString), attributedString, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableAttributedString *)attributedString
{
    return (NSMutableAttributedString *)objc_getAssociatedObject(self, @selector(attributedString));
}

- (NSMutableAttributedString *)setTextAttributedString
{
    if (!self.attributedString)
        self.attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    return self.attributedString;
}

/**
 *  @brief  设置文本位置
 *
 *  @param Alignment 位置
 */
- (void)setAlignmentCenter:(NSTextAlignment)Alignment
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:Alignment];
    [[self setTextAttributedString] addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
    [self drawRectTextAttributedString];
}

/**
 *  @brief  设置某段字的颜色
 *
 *  @param color    文字颜色
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setTextColor:(UIColor *)color
           fromIndex:(NSInteger)location
              length:(NSInteger)length
{
    if (location < 0 || location > self.text.length - 1 || length + location > self.text.length)
        return;
    
    [[self setTextAttributedString] addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(location, length)];
    [self drawRectTextAttributedString];
}

/**
 *  @brief  设置某段字的字体
 *
 *  @param font     文字字体
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setTextFont:(UIFont *)font
          fromIndex:(NSInteger)location
             length:(NSInteger)length
{
    if (location < 0 || location > self.text.length - 1 || length + location > self.text.length)
        return;
    
    [[self setTextAttributedString] addAttribute:NSFontAttributeName value:font range:NSMakeRange(location, length)];
    [self drawRectTextAttributedString];
}

/**
 *  @brief  设置某段字的风格
 *
 *  @param style    文字风格
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setTextStyle:(NSUnderlineStyle)style
           fromIndex:(NSInteger)location
              length:(NSInteger)length
{
    if (location < 0 || location > self.text.length - 1 || length + location > self.text.length)
        return;
    
    [[self setTextAttributedString] addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:style] range:NSMakeRange(location, length)];
    [self drawRectTextAttributedString];
}

/**
 *  @brief  设置下划线
 *
 *  @param location 开始位置
 *  @param length   结束位置
 */
- (void)setTextUnderline:(NSInteger)location
                  length:(NSInteger)length
{
    [[self setTextAttributedString] addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(location, length)];
    [self drawRectTextAttributedString];
}

/**
 设置行间距
 
 @param spacing 间距大小
 */
- (void)setTextLineSpacing:(NSInteger)spacing
{
    NSMutableAttributedString *textAttributedString = [self setTextAttributedString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:spacing - (self.font.lineHeight - self.font.pointSize)];
    [textAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textAttributedString.length)];
    [self drawRectTextAttributedString];
}

- (void)drawRectTextAttributedString
{
    self.attributedText = self.attributedString;
}


#pragma mark -
#pragma mark :. text Click

- (NSMutableArray *)actionBlocksArray
{
    NSMutableArray *actionBlocksArray = objc_getAssociatedObject(self, UILabelActionBlockArray);
    if (!actionBlocksArray) {
        actionBlocksArray = [NSMutableArray array];
        objc_setAssociatedObject(self, UILabelActionBlockArray, actionBlocksArray, OBJC_ASSOCIATION_RETAIN);
    }
    return actionBlocksArray;
}

/**
 *  @brief  设置某段字点击事件
 *
 *  @param range 文字段
 *  @param linkColor 文颜色
 *  @param actionBlock 点击回调
 */
- (void)setTextLinkWithRange:(NSRange)range
                   linkColor:(UIColor *)linkColor
                 withLinBloc:(void (^)(UILabel *sender, id linkData))actionBlock
{
    [self setTextLinkWithData:nil
                    linkColor:linkColor
                        range:range
                  withLinBloc:actionBlock];
}

/**
 *  @brief  设置某段字点击事件
 *
 *  @param range 文字段
 *  @param linkColor 文颜色
 *  @param actionBlock 点击回调
 *  @param target 回调对象
 *  @param action 回到事件
 */
- (void)setTextLinkWithRange:(NSRange)range
                   linkColor:(UIColor *)linkColor
                   andTarget:(id)target
                      action:(SEL)action
{
    [self setTextLinkWithData:nil
                    linkColor:linkColor
                        range:range
                    andTarget:target
                       action:action
                  withLinBloc:nil];
}

/**
 *  @brief  设置某段字点击事件
 *
 *  @param linkData 点击数据
 *  @param range 文字段
 *  @param linkColor 文颜色
 *  @param actionBlock 点击回调
 */
- (void)setTextLinkWithData:(id)linkData
                  linkColor:(UIColor *)linkColor
                      range:(NSRange)range
                withLinBloc:(void (^)(UILabel *sender, id linkData))actionBlock
{
    [self setTextLinkWithData:linkData
                    linkColor:linkColor
                        range:range
                    andTarget:nil
                       action:nil
                  withLinBloc:actionBlock];
}

- (void)setTextLinkWithData:(id)linkData
                  linkColor:(UIColor *)linkColor
                      range:(NSRange)range
                  andTarget:(id)target
                     action:(SEL)action
                withLinBloc:(void (^)(UILabel *sender, id linkData))actionBlock
{
    NSMutableAttributedString *textAttributedString = [self setTextAttributedString];
    if (self.text.length < range.location + range.length)
        return;
    
    NSMutableDictionary *linkEvent = [NSMutableDictionary dictionary];
    [linkEvent setObject:[NSValue valueWithRange:range] forKey:@"range"];
    if (linkData)
        [linkEvent setObject:linkData forKey:@"linkData"];
    [textAttributedString addAttribute:@"CCLinkAttributeName" value:linkEvent range:range];
    
    [textAttributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
    [self drawRectTextAttributedString];
    
    if (@available(iOS 11.0, *)) {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture.name isEqualToString:@"CCLinkAttributeName"])
                [self removeGestureRecognizer:gesture];
        }
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLinkTapGestureRecognizer:)];
    if (@available(iOS 11.0, *))
        [tapGestureRecognizer setName:@"CCLinkAttributeName"];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    
    NSMutableArray *actionBlocksArray = [self actionBlocksArray];
    UILabelActionBlockWrapper *blockActionWrapper = [[UILabelActionBlockWrapper alloc] init];
    blockActionWrapper.actionBlock = actionBlock;
    blockActionWrapper.actionSEL = action;
    blockActionWrapper.target = target;
    blockActionWrapper.range = range;
    [actionBlocksArray addObject:blockActionWrapper];
}

- (void)textLinkTapGestureRecognizer:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        CGPoint point = [gesture locationInView:self];
        NSDictionary *event = [self textAttributesAtPoint:point];
        if ([event.allKeys containsObject:@"CCLinkAttributeName"]) {
            NSRange range = [[[event objectForKey:@"CCLinkAttributeName"] objectForKey:@"range"] rangeValue];
            NSMutableArray *actionBlocksArray = [self actionBlocksArray];
            for (UILabelActionBlockWrapper *blockActionWrapper in actionBlocksArray) {
                if (NSEqualRanges(range, blockActionWrapper.range)) {
                    [blockActionWrapper invokeBlock:self
                                           linkData:[[event objectForKey:@"CCLinkAttributeName"] objectForKey:@"linkData"]];
                }
            }
        }
    }
}

- (NSDictionary *)textAttributesAtPoint:(CGPoint)point
{
    // Locate the attributes of the text within the label at the specified point
    NSDictionary *dictionary = nil;
    // First, create a CoreText framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    // Get each of the typeset lines
    NSArray *lines = (__bridge id)CTFrameGetLines(frameRef);
    CFIndex linesCount = [lines count];
    CGPoint *lineOrigins = (CGPoint *)malloc(sizeof(CGPoint) * linesCount);
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, linesCount), lineOrigins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    // Correct each of the typeset lines (which have origin (0,0)) to the correct orientation (typesetting offsets from the bottom of the frame)
    CGFloat bottom = self.frame.size.height;
    for (CFIndex i = 0; i < linesCount; ++i) {
        lineOrigins[ i ].y = self.frame.size.height - lineOrigins[ i ].y;
        bottom = lineOrigins[ i ].y;
    }
    // Offset the touch point by the amount of space between the top of the label frame and the text
    point.y -= (self.frame.size.height - bottom) / 2;
    // Scan through each line to find the line containing the touch point y position
    for (CFIndex i = 0; i < linesCount; ++i) {
        line = (__bridge CTLineRef)[lines objectAtIndex:i];
        lineOrigin = lineOrigins[ i ];
        CGFloat descent, ascent;
        CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, nil);
        if (point.y < (floor(lineOrigin.y) + floor(descent))) {
            // Cater for text alignment set in the label itself (not in the attributed string)
            if (self.textAlignment == NSTextAlignmentCenter) {
                point.x -= (self.frame.size.width - width) / 2;
            } else if (self.textAlignment == NSTextAlignmentRight) {
                point.x -= (self.frame.size.width - width);
            }
            // Offset the touch position by the actual typeset line origin. pt is now the correct touch position with the line bounds
            point.x -= lineOrigin.x;
            point.y -= lineOrigin.y;
            // Find the text index within this line for the touch position
            CFIndex i = CTLineGetStringIndexForPosition(line, point);
            // Iterate through each of the glyph runs to find the run containing the character index
            NSArray *glyphRuns = (__bridge id)CTLineGetGlyphRuns(line);
            CFIndex runCount = [glyphRuns count];
            for (CFIndex run = 0; run < runCount; ++run) {
                CTRunRef glyphRun = (__bridge CTRunRef)[glyphRuns objectAtIndex:run];
                CFRange range = CTRunGetStringRange(glyphRun);
                if (i >= range.location && i <= range.location + range.length) {
                    dictionary = (__bridge NSDictionary *)CTRunGetAttributes(glyphRun);
                    break;
                }
            }
            if (dictionary) {
                break;
            }
        }
    }
    free(lineOrigins);
    CFRelease(frameRef);
    CFRelease(framesetter);
    return dictionary;
}

@end
