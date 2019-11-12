//
//  CCKeyboardManager.m
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

#import "CCKeyboardManager.h"
#import "UIView+CCHierarchy.h"

NSString *const kCCTextFiled = @"kCCTextFiled";
NSString *const kCCTextFiledDelegate = @"kCCTextFiledDelegate";
NSString *const kCCTextFiledReturnKeyType = @"kCCTextFiledRetrurnKeyType";

@interface CCKeyboardManager () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) CGFloat keyboardDistanceFromTextField;

@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, assign) CGRect topViewBeginRect;

@property (nonatomic, strong) NSMutableSet *textFieldInfoCache;

@property (nonatomic, weak) UIView *textFieldView;

@property (nonatomic, assign) CGSize kSize;

@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) NSInteger animationCurve;

@property (nonatomic, assign) BOOL keyboardShowing;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation CCKeyboardManager

static CCKeyboardManager *keyboardManager;
static dispatch_once_t onceToken;

+ (instancetype)manager
{
    dispatch_once(&onceToken, ^{
        keyboardManager = [[CCKeyboardManager alloc] init];
    });
    return keyboardManager;
}

- (void)dealloc
{
    for (NSDictionary *dict in _textFieldInfoCache) {
        UIView *view = dict[ kCCTextFiled ];

        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            textField.returnKeyType = [dict[ kCCTextFiledReturnKeyType ] integerValue];
            textField.delegate = dict[ kCCTextFiledDelegate ];
        }
    }
    [_rootViewController.view removeGestureRecognizer:_tapGestureRecognizer];
    [_textFieldInfoCache removeAllObjects];
}

/**
 销毁单列
 */
- (void)freed
{
    [self keyboardHide];
    onceToken = 0;
    keyboardManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self registeredWithViewController:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        _keyboardDistanceFromTextField = 10;
        _animationDuration = 0.25;
    }
    return self;
}

- (void)globalKeyboardHide:(UITapGestureRecognizer *)tap
{
    [self keyboardHide];
    [tap.view endEditing:YES];
}

- (void)keyboardHide
{
    for (NSDictionary *dict in _textFieldInfoCache) {
        UIView *view = dict[ kCCTextFiled ];
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            [textField resignFirstResponder];
        }
    }
}

#pragma mark -
#pragma mark :. 初始化注册
- (void)registeredWithViewController:(nullable UIViewController *)controller
{
    if (controller.view) {
        controller.edgesForExtendedLayout = UIRectEdgeAll;
        controller.automaticallyAdjustsScrollViewInsets = NO;
        _rootViewController = controller;
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(globalKeyboardHide:)];
        _tapGestureRecognizer.cancelsTouchesInView = NO;
        [controller.view addGestureRecognizer:_tapGestureRecognizer];
        _textFieldInfoCache = [NSMutableSet set];
        [self addResponderFromView:controller.view];
    }
}

- (NSDictionary *)textFieldViewCachedInfo:(UIView *)textField
{
    for (NSDictionary *infoDict in _textFieldInfoCache)
        if (infoDict[ kCCTextFiled ] == textField) return infoDict;

    return nil;
}

#pragma mark -
#pragma mark :. UIKeyboad Notification methods
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (CGRectEqualToRect(_topViewBeginRect, CGRectZero))
        _topViewBeginRect = self.rootViewController.view.frame;

    _keyboardShowing = YES;
    NSInteger curve = [[aNotification userInfo][ UIKeyboardAnimationCurveUserInfoKey ] integerValue];
    _animationCurve = curve << 16;
    CGFloat duration = [[aNotification userInfo][ UIKeyboardAnimationDurationUserInfoKey ] floatValue];

    if (duration != 0.0) _animationDuration = duration;

    CGSize oldKBSize = _kSize;
    CGRect kbFrame = [[aNotification userInfo][ UIKeyboardFrameEndUserInfoKey ] CGRectValue];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGRect intersectRect = CGRectIntersection(kbFrame, screenSize);

    if (CGRectIsNull(intersectRect))
        _kSize = CGSizeMake(screenSize.size.width, 0);
    else
        _kSize = intersectRect.size;

    if (!CGSizeEqualToSize(_kSize, oldKBSize)) {
        if (_keyboardShowing == YES &&
            _textFieldView != nil &&
            [_textFieldView isAlertViewTextField] == NO) {
            [self adjustFrame];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _keyboardShowing = NO;

    CGFloat aDuration = [[aNotification userInfo][ UIKeyboardAnimationDurationUserInfoKey ] floatValue];
    if (aDuration != 0.0f)
        _animationDuration = aDuration;

    if (!CGRectEqualToRect(self.topViewBeginRect, CGRectMake(0, 0, 0, 0)))
        [self setRootViewFrame:self.topViewBeginRect];
    _kSize = CGSizeZero;
}

/**
 调整位置
 */
- (void)adjustFrame
{
    UIWindow *keyWindow = [self keyWindow];
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
    UIViewController *rootViewController = [_textFieldView viewController];
    if (!rootViewController) rootViewController = [keyWindow topMostController];
    CGRect rootViewRect = rootViewController.view.frame;

    CGSize kbSize = _kSize;
    kbSize.height += _keyboardDistanceFromTextField;

    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat topLayoutGuide = CGRectGetHeight(statusBarFrame);

    CGFloat move = MIN(CGRectGetMinY(textFieldViewRect) - (topLayoutGuide + 5), CGRectGetMaxY(textFieldViewRect) - (CGRectGetHeight(keyWindow.frame) - kbSize.height));

    if (move >= 0) {
        rootViewRect.origin.y -= move;
        rootViewRect.origin.y = MAX(rootViewRect.origin.y, MIN(0, -kbSize.height + _keyboardDistanceFromTextField));
        [self setRootViewFrame:rootViewRect];
    } else {
        CGFloat disturbDistance = CGRectGetMinY(rootViewRect) - CGRectGetMinY(_topViewBeginRect);
        if (disturbDistance < 0) {
            rootViewRect.origin.y -= MAX(move, disturbDistance);
            [self setRootViewFrame:rootViewRect];
        }
    }
}

- (void)setRootViewFrame:(CGRect)controllerFrame
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_animationDuration
                          delay:0
                        options:(_animationCurve | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         [strongSelf.rootViewController.view setFrame:controllerFrame];
                     }
                     completion:NULL];
}

- (UIWindow *)keyWindow
{
    if (_textFieldView.window) {
        return _textFieldView.window;
    } else {
        static UIWindow *_keyWindow = nil;
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        if (originalKeyWindow != nil && _keyWindow != originalKeyWindow)
            _keyWindow = originalKeyWindow;

        return _keyWindow;
    }
}

#pragma mark -
#pragma mark :. add/remove TextFields
- (void)addResponderFromView:(UIView *)view
{
    NSArray *textFields = [view deepResponderViews];

    for (UIView *textField in textFields)
        [self addTextFieldView:textField];
}

- (void)removeResponderFromView:(UIView *)view
{
    NSArray *textFields = [view deepResponderViews];

    for (UIView *textField in textFields)
        [self removeTextFieldView:textField];
}

- (void)removeTextFieldView:(UIView *)view
{
    NSDictionary *dict = [self textFieldViewCachedInfo:view];

    if (dict) {
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            textField.returnKeyType = [dict[ kCCTextFiledReturnKeyType ] integerValue];
            textField.delegate = dict[ kCCTextFiledDelegate ];
        }
        [_textFieldInfoCache removeObject:dict];
    }
}


- (void)addTextFieldView:(UIView *)view
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[ kCCTextFiled ] = view;

    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
        UITextField *textField = (UITextField *)view;
        dict[ kCCTextFiledReturnKeyType ] = @(textField.returnKeyType);

        CCToolbar *toolbar = textField.keyboardToolbar;
        NSMutableArray<UIBarButtonItem *> *items = [[NSMutableArray alloc] init];

        //Flexible space
        [items addObject:[[self class] flexibleBarButtonItem]];
        toolbar.titleBarButton.title = textField.placeholder;
        [items addObject:toolbar.titleBarButton];
        //Flexible space
        [items addObject:[[self class] flexibleBarButtonItem]];

        CCBarButtonItem *done = toolbar.doneBarButton;
        done = [[CCBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        done.invocation = toolbar.doneBarButton.invocation;
        done.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = done;
        [items addObject:done];


        [toolbar setItems:items];

        [textField setInputAccessoryView:toolbar];
        if ([textField respondsToSelector:@selector(keyboardAppearance)]) {
            switch ([(UITextField *)textField keyboardAppearance]) {
                case UIKeyboardAppearanceDark:
                    toolbar.barStyle = UIBarStyleBlack;
                    break;
                default:
                    toolbar.barStyle = UIBarStyleDefault;
                    break;
            }
        }

        if (textField.delegate) dict[ kCCTextFiledDelegate ] = textField.delegate;
        [textField setDelegate:self];
    }

    [_textFieldInfoCache addObject:dict];
}

- (void)doneAction:(CCBarButtonItem *)sender
{
    [self keyboardHide];
}

+ (CCBarButtonItem *)flexibleBarButtonItem
{
    static CCBarButtonItem *nilButton = nil;
    if (nilButton == nil) {
        nilButton = [[CCBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }

    return nilButton;
}

#pragma mark -
#pragma mark :. TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [delegate textFieldShouldBeginEditing:textField];
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _textFieldView = textField;

    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [delegate textFieldDidBeginEditing:textField];

    if (_keyboardShowing == YES &&
        _textFieldView != nil &&
        [_textFieldView isAlertViewTextField] == NO) {
        [self adjustFrame];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [delegate textFieldShouldEndEditing:textField];
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [delegate textFieldDidEndEditing:textField];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)])
        [delegate textFieldDidEndEditing:textField reason:reason];
}

#endif

#pragma mark -
#pragma mark :. TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [delegate textViewShouldBeginEditing:textView];
    else
        return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [delegate textViewShouldEndEditing:textView];
    else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _textFieldView = textView;

    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [delegate textViewDidBeginEditing:textView];

    if (_keyboardShowing == YES &&
        _textFieldView != nil &&
        [_textFieldView isAlertViewTextField] == NO) {
        [self adjustFrame];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    BOOL shouldReturn = YES;
    if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        shouldReturn = [delegate textView:textView shouldChangeTextInRange:range replacementText:text];

    return shouldReturn;
}

- (void)textViewDidChange:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewDidChange:)])
        [delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [delegate textViewDidChangeSelection:textView];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    else
        return YES;
}
#endif

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[ kCCTextFiledDelegate ];
    }

    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    else
        return YES;
}

@end
