//
//  CCWebViewController.m
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

#import "CCWebViewController.h"
#import "CCMacroProperty.h"
#import "CCProgressHUD.h"
#import "CCWebViewProgress.h"
#import "CCWebViewProgressView.h"
#import "UINavigationBar+CCAdd.h"
#import "UIView+Method.h"
#import "UIViewController+CCAdd.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

@interface CCScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

@implementation CCScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface CCProcessPool : WKProcessPool

+ (id)sharedProcessPool;

@end

@implementation CCProcessPool

+ (id)sharedProcessPool
{
    static id _sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

@end


NSString *const kEstimatedProgress = @"estimatedProgress";
NSString *const kTitle = @"title";
NSString *const kCanGoBack = @"canGoBack";

typedef void (^ResponseBlock)(NSString *functionName, NSArray *arguments);

@interface CCWebViewController () <UIGestureRecognizerDelegate>

@end

@interface CCWebViewController () <WKNavigationDelegate, WKUIDelegate, CCWebViewProgressDelegate, CCWebViewProgressDelegate, UIWebViewDelegate, WKScriptMessageHandler, UIScrollViewDelegate>

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL actionSEL;

// script脚本数组
@property (nonatomic, strong) NSMutableArray *scriptMessages;

@property (nonatomic, strong) JSContext *webViewJSContext;

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) WKWebView *webWKView;

@property (nonatomic, strong) UILabel *originLable;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) CCWebViewProgress *webViewProgress;

@property (nonatomic, strong) CCWebViewProgressView *progressView;

@property (nonatomic, copy) ResponseBlock responseBlock;

// HTML字符串加载模式
@property (nonatomic, strong) NSString *htmlString;

// URL加载模式
@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, assign) BOOL navigationbarScroll;
@property (nonatomic, copy) UIColor *navigationColor;

@property (nonatomic, assign) BOOL isBackward;

@end

@implementation CCWebViewController

- (instancetype)init
{
    if (self = [super init]) {
        _isTitleFollowChange = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.userAgent) {
        NSString *wkUserAgent = [self.webWKView valueForKey:@"applicationNameForUserAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@%@", wkUserAgent, self.userAgent];
        [self.webWKView setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
    }

    self.view.backgroundColor = [UIColor whiteColor];
    self.scriptMessages = [NSMutableArray array];
    if (_navigationbarTransparent)
        self.navigationColor = self.navigationController.navigationBar.barTintColor;

    [self initControlLayout];

    [self initControl];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self handlerUserAgent];
    [self handlerCookie];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[CCWebViewProgressView class]]) {
            [obj removeFromSuperview];
        }
    }];

    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)initControl
{
    if (!self.isSource)
        [self.view addSubview:self.backgroundView];
    UIView *view;
    if (NSClassFromString(@"WKWebView"))
        view = self.webWKView;
    else
        view = self.webView;

    if (!self.navigationbarTransparent) {
        CGRect frame = self.view.frame;
        frame.size.height -= [self obtainNavigationbarHeight];
        view.frame = frame;
        if (_isAdapterBottom) {
            UIView *bottomCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height, frame.size.width, self.view.frame.size.height - frame.size.height)];
            bottomCoverView.backgroundColor = [UIColor blackColor];
            [self.view addSubview:bottomCoverView];
        }
    }

    if (self.urlString)
        [self loadRequest];
    else if (self.htmlString)
        [self loadHTMLString];

    [self.view addSubview:view];
    typeof(self) __weak weakSelf = self;
    [self backButtonTouched:^(UIViewController *vc) {
        [weakSelf backButtonTouchedHandel:vc];
    }];
}

#pragma mark -
#pragma mark :. handler

- (void)loadRequest
{
    NSURL *url = [NSURL URLWithString:[self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", url.host];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    for (NSString *key in self.cookie.allKeys)
    //        [request addValue:[NSString stringWithFormat:@"%@=%@", key, [self.cookie objectForKey:key]] forHTTPHeaderField:@"Cookie"];

    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadRequest:request];
    else
        [self.webView loadRequest:request];
}

- (void)loadHTMLString
{
    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadHTMLString:self.htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    else
        [self.webView loadHTMLString:self.htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (BOOL)isGoBack
{
    BOOL isBack = NO;
    if (NSClassFromString(@"WKWebView")) {
        if (self.webWKView.backForwardList.backList.count > 0)
            isBack = YES;
    } else {
        if (self.webView.canGoBack)
            isBack = YES;
    }
    return isBack;
}

- (BOOL)isGoForward
{
    BOOL isForward = NO;
    if (NSClassFromString(@"WKWebView")) {
        if (self.webWKView.backForwardList.forwardList.count > 0)
            isForward = YES;
    } else {
        if (self.webView.canGoForward)
            isForward = YES;
    }
    return isForward;
}

- (void)goBack
{
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView goBack];
    else
        [self.webView goBack];
}

- (void)goForward
{
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView goForward];
    else
        [self.webView goForward];
}

- (void)initControlLayout
{
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)) {
        self.edgesForExtendedLayout = _navigationbarTransparent ? UIRectEdgeAll : UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = _navigationbarTransparent;
        self.modalPresentationCapturesStatusBarAppearance = _navigationbarTransparent;

        if (_navigationbarTransparent)
            [self.navigationController.navigationBar setSlideNavigationBackground:0];
    }
}

- (CGFloat)obtainNavigationbarHeight
{
    CGFloat height = self.navigationController.navigationBarHidden ?: 64;
    if (@available(iOS 11.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.top == 44)
            height = (self.navigationController.navigationBarHidden ? 22 : 88) + (_isAdapterBottom ? 22 : 0);
    }
    return height;
}

+ (void)clearCache
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeOfflineWebApplicationCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                   modifiedSince:dateFrom
                                               completionHandler:^{
                                                   // 结束回调
                                               }];
    } else {
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[ 0 ];
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit", libraryDir];
        NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit", libraryDir, bundleId];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    }
}

- (void)setUserAgent:(NSString *)userAgent
{
    _userAgent = userAgent;
    [self handlerUserAgent];
}

- (void)setCookie:(NSDictionary *)cookie
{
    _cookie = cookie;
    [self handlerCookie];
}

- (void)reload
{
    [self loadRequest];
}

#pragma mark -
#pragma mark :. JSBlock

- (void)didCapture:(NSString *)functionName
     ResponseBlock:(void (^)(NSString *functionName, id arguments))block
{
    if (NSClassFromString(@"WKWebView")) {
        self.responseBlock = block;
        [self.configuration.userContentController addScriptMessageHandler:[[CCScriptMessageDelegate alloc] initWithDelegate:self] name:functionName];
    } else {
        self.webViewJSContext[ functionName ] = ^() {
            block ? block(functionName, [JSContext currentArguments]) : nil;
        };
    }
}

- (void)didCapture:(NSString *)functionName target:(id)target actionSEL:(SEL)action
{
    if (NSClassFromString(@"WKWebView")) {
        self.target = target;
        self.actionSEL = action;
        [self.configuration.userContentController addScriptMessageHandler:[[CCScriptMessageDelegate alloc] initWithDelegate:self] name:functionName];
    } else {
        __weak typeof(self) weakself = self;
        self.webViewJSContext[ functionName ] = ^() {
            if ([weakself.target respondsToSelector:weakself.actionSEL]) {
                IMP imp = [weakself.target methodForSelector:weakself.actionSEL];
                void (*func)(id, SEL, id) = (void *)imp;
                func(weakself.target, weakself.actionSEL, [JSContext currentArguments]);
            }
        };
    }
}

- (void)didCaptures:(NSArray<NSString *> *)functionNames
      ResponseBlock:(void (^)(NSString *functionName, id arguments))block
{
    for (NSString *fName in functionNames)
        [self didCapture:fName ResponseBlock:block];
}

#pragma mark -
#pragma mark :. OCTransferJs
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id response, NSError *error))completionHandler
{
    if (NSClassFromString(@"WKWebView")) {
        [self.scriptMessages addObject:javaScriptString];
        [self.webWKView evaluateJavaScript:javaScriptString
                         completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                             completionHandler ? completionHandler(response, error) : nil;
                         }];
    } else {
        [self.webViewJSContext evaluateScript:javaScriptString];
    }
}

#pragma mark -
#pragma mark :. EventHandle

- (void)backButtonTouchedHandel:(UIViewController *)vc
{
    if (NSClassFromString(@"WKWebView")) {
        if (self.webWKView.backForwardList.backList.count > 0) {
            [self.webWKView goBack];
        } else {
            [(vc ?: self).navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.webView.canGoBack) {
            [self.webView goBack];
        } else {
            [(vc ?: self).navigationController popViewControllerAnimated:YES];
        }
    }
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  加载页面
 *
 *  @param baseURL 网页地址
 */
- (void)loadRequest:(NSString *)baseURL
{
    if ([baseURL rangeOfString:@"http://"].location != NSNotFound || [baseURL rangeOfString:@"https://"].location != NSNotFound)
        baseURL = baseURL;
    else if ([baseURL rangeOfString:@"http://"].location == NSNotFound)
        baseURL = [NSString stringWithFormat:@"http://%@", baseURL];
    else if ([baseURL rangeOfString:@"https://"].location == NSNotFound)
        baseURL = [NSString stringWithFormat:@"https://%@", baseURL];

    if (!_urlString) {
        _urlString = baseURL;
    }
}

/**
 加载本地文件

 @param fileName 文件名
 @param expansionName 文件扩展名
 */
- (void)loadLocalFiles:(NSString *)fileName
             expansion:(NSString *)expansionName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:expansionName];
    NSString *appHtml = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:filePath];
    if (NSClassFromString(@"WKWebView")) {
        [self.webWKView loadHTMLString:appHtml baseURL:baseURL];
    } else {
        [self.webView loadHTMLString:appHtml baseURL:baseURL];
    }
}

/**
 *  @author CC, 2016-01-25
 *
 *  @brief 加载HTML页面
 *
 *  @param string HTML文件或者字符串
 */
- (void)loadHTMLString:(NSString *)string
{
    _htmlString = string;
}


- (void)jumpPage:(NSString *)baseURL
{
    if ([baseURL rangeOfString:@"http://"].location == NSNotFound)
        baseURL = [NSString stringWithFormat:@"http://%@", baseURL];

    NSURL *url = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    self.originLable.text = [NSString stringWithFormat:@"网页由 %@ 提供", url.host];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (NSClassFromString(@"WKWebView"))
        [self.webWKView loadRequest:request];
    else
        [self.webView loadRequest:request];
}

// 页面处理是否关闭返回
- (void)handleBackClose
{
    self.navigationItem.leftBarButtonItems = nil;
    if ([self isGoBack]) {
        UIBarButtonItem *backButtonItem;

        UIImage *backIndicatorImage = [UINavigationBar appearance].backIndicatorImage;
        if (!backIndicatorImage)
            backIndicatorImage = [UINavigationBar appearance].backIndicatorTransitionMaskImage;

        if (backIndicatorImage) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setImage:backIndicatorImage forState:UIControlStateNormal];
            [backButton setImage:backIndicatorImage forState:UIControlStateHighlighted];
            [backButton setTitle:@"返回" forState:UIControlStateNormal];
            [backButton setTitle:@"返回" forState:UIControlStateHighlighted];
            backButton.titleLabel.font = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
            [backButton sizeToFit];
            [backButton addTarget:self action:@selector(backBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
            backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        } else {
            backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonClick)];
        }

        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeBarButtonClick:)];
        //        self.navigationItem.leftBarButtonItems = @[ backButtonItem, closeButtonItem ];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        if (!self.navigationItem.rightBarButtonItem)
            self.navigationItem.rightBarButtonItem = closeButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

//返回事件处理
- (void)backBarButtonClick
{
    [self backButtonTouchedHandel:nil];
}

//关闭页面事件处理
- (void)closeBarButtonClick:(UIBarButtonItem *)sender
{
    [self popViewControllerAnimated];
}

- (void)networkErrorTap:(UITapGestureRecognizer *)sender
{
    [[self.view viewWithTag:123321] removeFromSuperview];
    [self loadRequest];
}

- (void)handlerUserAgent
{
    if (self.userAgent && _webWKView) {
        __weak typeof(self) weakSelf = self;
        [self.webWKView evaluateJavaScript:@"navigator.userAgent"
                         completionHandler:^(id result, NSError *error) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             NSString *newUserAgent = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstUserAgent"] ?: result;
                             if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstUserAgent"]) {
                                 [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"firstUserAgent"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                             }
                             newUserAgent = [newUserAgent stringByAppendingString:self.userAgent];
                             if (@available(iOS 9.0, *))
                                 [strongSelf.webWKView setCustomUserAgent:newUserAgent];
                             else
                                 [strongSelf.webWKView setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
                         }];
    }
}

- (void)handlerCookie
{
    if (self.cookie && _webWKView) {
        NSMutableString *cookieStr = [[NSMutableString alloc] init];
        for (NSString *key in self.cookie.allKeys)
            [cookieStr appendFormat:@"document.cookie = '%@=%@';path:/;", key, [self.cookie objectForKey:key]];

        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.configuration.userContentController addUserScript:cookieScript];
        [_webWKView evaluateJavaScript:cookieStr
                     completionHandler:^(id result, NSError *error){

                     }];
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (void)setAllowsBackForwardNavigationGestures:(BOOL)allowsBackForwardNavigationGestures
{
    _allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures;
    _webWKView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures;
}

- (void)setIsScrollEnabled:(BOOL)isScrollEnabled
{
    _isScrollEnabled = isScrollEnabled;
    _webWKView.scrollView.scrollEnabled = _isScrollEnabled;
}

- (void)networkError
{
    [[self.view viewWithTag:123321] removeFromSuperview];

    UIView *networkErrorView = [[UIView alloc] initWithFrame:self.view.bounds];
    networkErrorView.backgroundColor = [UIColor whiteColor];
    networkErrorView.tag = 123321;
    networkErrorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    networkErrorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(networkErrorTap:)];
    tap.numberOfTapsRequired = 1;
    [networkErrorView addGestureRecognizer:tap];
    [self.view addSubview:networkErrorView];

    UIImage *reloadImage = CCResourceImage(@"web_networkError");

    UIImageView *reloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((networkErrorView.frame.size.width - reloadImage.size.width) / 2, 60, reloadImage.size.width, reloadImage.size.height)];
    reloadImageView.image = reloadImage;
    [networkErrorView addSubview:reloadImageView];

    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, reloadImageView.frame.origin.y + reloadImage.size.height + 15, networkErrorView.bounds.size.width - 20, 20)];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:13];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.text = @"网络出错，轻点屏幕重新加载";
    [networkErrorView addSubview:tipsLabel];
}

- (UILabel *)originLable
{
    if (!_originLable) {
        CGFloat y = 10;
        if (_navigationbarTransparent)
            y = [self obtainNavigationbarHeight];

        _originLable = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.bounds), 20)];
        _originLable.backgroundColor = [UIColor clearColor];
        _originLable.textAlignment = NSTextAlignmentCenter;
        _originLable.textColor = [UIColor lightGrayColor];
        _originLable.font = [UIFont systemFontOfSize:12];
        _originLable.text = @"网页由 www.CCKit.com 提供";
    }
    return _originLable;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_backgroundView addSubview:self.originLable];
    }
    return _backgroundView;
}

- (WKWebViewConfiguration *)configuration
{
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        _configuration.preferences = [[WKPreferences alloc] init];
        _configuration.preferences.minimumFontSize = 10;
        _configuration.preferences.javaScriptEnabled = YES;
        _configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        _configuration.processPool = [CCProcessPool sharedProcessPool];

        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        _configuration.userContentController = userContentController;
    }
    return _configuration;
}

- (WKWebView *)webWKView
{
    if (!_webWKView) {
        WKWebView *webWKView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:self.configuration];
        webWKView.backgroundColor = [UIColor whiteColor];
        webWKView.UIDelegate = self;
        webWKView.navigationDelegate = self;
        webWKView.scrollView.delegate = self;
        webWKView.allowsBackForwardNavigationGestures = YES;
        if (@available(iOS 11.0, *))
            [webWKView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];

        [webWKView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [webWKView addObserver:self forKeyPath:kEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
        [webWKView addObserver:self forKeyPath:kTitle options:NSKeyValueObservingOptionNew context:nil];
        [webWKView addObserver:self forKeyPath:kCanGoBack options:NSKeyValueObservingOptionNew context:nil];

        _webWKView = webWKView;
    }
    return _webWKView;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化UIWebView
 *
 *  @return 返回UIWebView
 */
- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.delegate = self;

        _webViewProgress = [[CCWebViewProgress alloc] init];
        _webView.delegate = _webViewProgress;
        _webViewProgress.webViewProxyDelegate = self;
        _webViewProgress.progressDelegate = self;

        if (@available(iOS 11.0, *))
            [_webView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];

        [_webView addObserver:self forKeyPath:kEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
        self.webViewJSContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    }
    return _webView;
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  初始化进度条
 *
 *  @return 返回进度条
 */
- (CCWebViewProgressView *)progressView
{
    if (!_progressView) {
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[CCWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.navigationController.navigationBar addSubview:_progressView];
    }
    return _progressView;
}

#pragma mark -
#pragma mark :. 监听

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  观察
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kEstimatedProgress]) {
        [self progressChanged:[change objectForKey:NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:kTitle]) {
        _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];

        if (self.isTitleFollowChange) {
            NSString *changeTitle = change[ NSKeyValueChangeNewKey ];
            if (![self.title isEqualToString:changeTitle]) {
                self.title = changeTitle;
            }
        }
    } else if ([keyPath isEqualToString:kCanGoBack]) {
        BOOL isCanGoBack = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        self.navigationController.interactivePopGestureRecognizer.enabled = !isCanGoBack;
        self.cc_interactivePopDisabled = isCanGoBack;
        [self handleBackClose];
    }
}

#pragma mark :. CCWebViewProgressDelegate
- (void)webViewProgress:(CCWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    if (self.isTitleFollowChange) {
        NSString *changeTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (![self.title isEqualToString:changeTitle]) {
            self.title = changeTitle;
        }
    }
}

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  设置进度条
 *
 *  @param newValue 进度百分比
 */
- (void)progressChanged:(NSNumber *)newValue
{
    if (!self.progressView) return;

    self.progressView.progress = newValue.floatValue;
    if (newValue.floatValue == 1) {
        self.progressView.progress = 0;
        [UIView animateWithDuration:.02
                         animations:^{
                             self.progressView.alpha = 0;
                         }];
    } else if (self.progressView.alpha == 0) {
        [UIView animateWithDuration:.02
                         animations:^{
                             self.progressView.alpha = 1;
                         }];
    }
}

- (void)delaySetColor
{
    if (self.navigationbarTransparent)
        self.navigationbarScroll = YES;

    if (NSClassFromString(@"WKWebView")) {
        self.webWKView.opaque = NO;
        self.webWKView.backgroundColor = [UIColor clearColor];
        self.webWKView.scrollView.backgroundColor = [UIColor clearColor];
    } else {
        self.webView.opaque = NO;
        for (UIView *subview in [self.webView.scrollView subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                ((UIImageView *)subview).image = nil;
                subview.backgroundColor = [UIColor clearColor];
            }
        }
    }
}

#pragma mark -
#pragma mark :. UISrcollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_navigationbarTransparent && _navigationbarScroll) {
        CGFloat navbar_change_point = [self obtainNavigationbarHeight];
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > navbar_change_point) {
            CGFloat alpha = MIN(1, 1 - ((navbar_change_point + 64 - offsetY) / 64));
            [self.navigationController.navigationBar setbarbackgroundView:[self.navigationColor colorWithAlphaComponent:alpha]];
        } else {
            [self.navigationController.navigationBar setbarbackgroundView:[self.navigationColor colorWithAlphaComponent:0]];
        }
    }
}

#pragma mark -
#pragma mark :. UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

#pragma mark -
#pragma mark :. WKWebViewDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *urlStr = [webView.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.isBackward && [self.refreshURL containsObject:urlStr])
        [webView reload];

    [self performSelector:@selector(delaySetColor)
               withObject:nil
               afterDelay:0.5];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code == kCFURLErrorNotConnectedToInternet) { //无网络
        [self networkError];
    }
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.isBackward = (navigationAction.navigationType == WKNavigationTypeBackForward);
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
}

#pragma mark - WKUIDelegate

// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    return webView;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView
{
}

// 调用JS的alert()方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    completionHandler();
}

// 调用JS的confirm()方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
}

// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler
{
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.responseBlock ? self.responseBlock(message.name, message.body) : nil;
    if ([self.target respondsToSelector:self.actionSEL]) {
        IMP imp = [self.target methodForSelector:self.actionSEL];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.target, self.actionSEL, message.body);
    }
}

- (void)keyboardWillHide
{
    if (@available(iOS 12.0, *)) {
        for (UIView *v in self.webWKView.subviews) {
            if ([v isKindOfClass:NSClassFromString(@"WKScrollView")]) {
                UIScrollView *scrollView = (UIScrollView *)v;
                [scrollView setContentOffset:CGPointMake(0, 0)];
            }
        }
    }
}

- (void)dealloc
{
    if (NSClassFromString(@"WKWebView")) {
        for (NSString *scriptMessage in self.scriptMessages)
            [_configuration.userContentController removeScriptMessageHandlerForName:scriptMessage];
        self.scriptMessages = nil;
        _webWKView.UIDelegate = nil;
        _webWKView.navigationDelegate = nil;
        _webWKView.scrollView.delegate = nil;
        [_webWKView removeObserver:self forKeyPath:kEstimatedProgress];
        [_webWKView removeObserver:self forKeyPath:kTitle];
        [_webWKView removeObserver:self forKeyPath:kCanGoBack];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    } else {
        [_webView removeObserver:self forKeyPath:kEstimatedProgress];
        [_webView removeObserver:self forKeyPath:kTitle];
    }
    [_progressView removeFromSuperview];
}

@end
