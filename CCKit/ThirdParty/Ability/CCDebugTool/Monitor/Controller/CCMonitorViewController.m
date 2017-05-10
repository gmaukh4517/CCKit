//
//  CCMonitorViewController.m
//  CCKit
//
//  Created by CC on 2017/5/9.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCMonitorViewController.h"
#import "CCMonitorHelper.h"
#import "Reachability.h"
#import "UIView+Frame.h"
#import "WMGaugeView.h"

#define LabelWidth [UIScreen mainScreen].bounds.size.width / 2

@interface CCMonitorViewController ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) NSTimeInterval lastTimestamp;

@property (nonatomic, assign) int preRef;

@property (nonatomic, strong) WMGaugeView *guanGeView;

@property (nonatomic, assign) float preWWAN_R;

@property (nonatomic, assign) float preWWAN_S;

@property (nonatomic, assign) float preWifi_R;

@property (nonatomic, assign) float preWifi_S;

@property (nonatomic, strong) UILabel *ramLabel;
@property (nonatomic, strong) UILabel *diskLabel;

@property (nonatomic, strong) UILabel *topLiuLiang;
@property (nonatomic, strong) UILabel *downLiuLiang;

@property (nonatomic, strong) UILabel *memoryPreLabel;

@end

@implementation CCMonitorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:90.0 / 255.0 green:90.0 / 255.0 blue:90.0 / 255.0 alpha:1.0];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initNavigation];
    [self initControl];
    
    _lastTimestamp = -1;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(envokeDisplayLink:)];
    _displayLink.paused = YES;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _displayLink.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _displayLink.paused = YES;
}

- (void)dealloc
{
    _displayLink.paused = YES;
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)initNavigation
{
    self.title = @"Monitor";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControl
{
    [self.view addSubview:self.guanGeView];
    UILabel *guanGeTitle = [self createLabel];
    guanGeTitle.y = self.guanGeView.height - 50;
    guanGeTitle.width = self.guanGeView.width;
    guanGeTitle.text = @"已占用内存";
    [self.guanGeView addSubview:guanGeTitle];
    [self.guanGeView addSubview:self.memoryPreLabel];
    
    [self.view addSubview:self.ramLabel];
    
    UILabel *ramTitle = [self createLabel];
    ramTitle.y = self.ramLabel.bottom + 10;
    ramTitle.text = @"已占用/总内存";
    [self.view addSubview:ramTitle];
    
    [self.view addSubview:self.diskLabel];
    
    UILabel *diskTitle = [self createLabel];
    diskTitle.x = self.diskLabel.x;
    diskTitle.y = self.diskLabel.bottom + 10;
    diskTitle.text = @"已使用/总存储";
    [self.view addSubview:diskTitle];
    
    self.topLiuLiang.y = ramTitle.bottom + 10;
    [self.view addSubview:self.topLiuLiang];
    UILabel *topTitle = [self createLabel];
    topTitle.y = self.topLiuLiang.bottom + 10;
    topTitle.text = @"上行网速";
    [self.view addSubview:topTitle];
    
    self.downLiuLiang.y = diskTitle.bottom + 10;
    [self.view addSubview:self.downLiuLiang];
    UILabel *downTitle = [self createLabel];
    downTitle.x = self.downLiuLiang.x;
    downTitle.y = self.downLiuLiang.bottom + 10;
    downTitle.text = @"下行网速";
    [self.view addSubview:downTitle];
    
    [self currentLiuLiang];
    
    [self setAppearance];
    
    [self monitorRefresh];
    
    float availableMemory = [CCMonitorHelper getUsedMemorySize] / 1024 / 1024;
    self.ramLabel.text = [NSString stringWithFormat:@"%.0f MB", availableMemory];
    
    float allMemory = [CCMonitorHelper getTotalMemorySize] / 1024 / 1024;
    float memoryPre = (availableMemory / allMemory) * 100;
    
    self.guanGeView.value = memoryPre;
}

- (void)setAppearance
{
    self.guanGeView.maxValue = 100.0;
    self.guanGeView.scaleDivisions = 10;
    self.guanGeView.scaleSubdivisions = 5;
    self.guanGeView.scaleStartAngle = 60;
    self.guanGeView.scaleEndAngle = 300;
    self.guanGeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.guanGeView.showScaleShadow = NO;
    //    self.guanGeView.scaleFont = [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.guanGeView.scalesubdivisionsaligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.guanGeView.scaleSubdivisionsWidth = 0.002;
    self.guanGeView.scaleSubdivisionsLength = 0.04;
    self.guanGeView.scaleDivisionsWidth = 0.007;
    self.guanGeView.scaleDivisionsLength = 0.07;
    self.guanGeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    self.guanGeView.needleWidth = 0.012;
    self.guanGeView.needleHeight = 0.4;
    self.guanGeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    self.guanGeView.needleScrewRadius = 0.05;
}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LabelWidth, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    return label;
}

#pragma mark -
#pragma mark :. Monitor

- (void)envokeDisplayLink:(CADisplayLink *)displayLink
{
    if (_lastTimestamp == -1) {
        _lastTimestamp = displayLink.timestamp;
        return;
    }
    
    NSTimeInterval interval = displayLink.timestamp - _lastTimestamp;
    if (interval < 1) {
        return;
    }
    _lastTimestamp = displayLink.timestamp;
    
    [self monitorRefresh];
}

- (void)monitorRefresh
{
    // 内存
    self.ramLabel.text = [NSString stringWithFormat:@"%@ / %@", [CCMonitorHelper getUsedMemory], [CCMonitorHelper getTotalMemory]];
    
    float availableMemory = [CCMonitorHelper getUsedMemorySize] / 1024 / 1024;
    float allMemory = [CCMonitorHelper getTotalMemorySize] / 1024 / 1024;
    float memoryPre = (availableMemory / allMemory) * 100;
    self.memoryPreLabel.text = [NSString stringWithFormat:@"%.2f %%", memoryPre];
    if (self.preRef % 2 == 0) {
        self.guanGeView.value = memoryPre;
        if (self.preRef == 100)
            self.preRef = 0;
    }
    self.preRef++;
    
    self.diskLabel.text = [NSString stringWithFormat:@"%@ / %@", [CCMonitorHelper getAvailableDiskSize], [CCMonitorHelper getTotalDiskSize]];
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"hha"];
    if (reachability.currentReachabilityStatus == ReachableViaWiFi) {
        float wifiS_preSecond = [[CCMonitorHelper getDataCounters][0] floatValue] - self.preWifi_S;
        float wifiR_preSecond = [[CCMonitorHelper getDataCounters][1] floatValue] - self.preWifi_R;
        self.topLiuLiang.text = [NSString stringWithFormat:@"%.0f KB/s", wifiS_preSecond];
        self.downLiuLiang.text = [NSString stringWithFormat:@"%.0f KB/s", wifiR_preSecond];
    } else if (reachability.currentReachabilityStatus == ReachableViaWWAN) {
        float wwanS_preSecond = [[CCMonitorHelper getDataCounters][2] floatValue] - self.preWWAN_S;
        float wwanR_preSecond = [[CCMonitorHelper getDataCounters][3] floatValue] - self.preWWAN_R;
        self.topLiuLiang.text = [NSString stringWithFormat:@"%.0f KB/s", wwanS_preSecond];
        self.downLiuLiang.text = [NSString stringWithFormat:@"%.0f KB/s", wwanR_preSecond];
    } else {
    }
    
    [self currentLiuLiang];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 赋值当前流量
- (void)currentLiuLiang
{
    NSNumber *wifiSendNumber = [CCMonitorHelper getDataCounters][0];
    float wifiS = [wifiSendNumber floatValue];
    self.preWifi_S = wifiS;
    
    NSNumber *wifiReceived = [CCMonitorHelper getDataCounters][1];
    float wifiR = [wifiReceived floatValue];
    self.preWifi_R = wifiR;
    
    NSNumber *wwanSendNumber = [CCMonitorHelper getDataCounters][2];
    float wwanS = [wwanSendNumber floatValue];
    self.preWWAN_S = wwanS;
    
    NSNumber *wwanReceived = [CCMonitorHelper getDataCounters][3];
    float wwanR = [wwanReceived floatValue];
    self.preWWAN_R = wwanR;
}

#pragma mark -
#pragma mark :. getset

- (WMGaugeView *)guanGeView
{
    if (!_guanGeView) {
        _guanGeView = [[WMGaugeView alloc] initWithFrame:CGRectMake((self.view.width - 200) / 2, 20, 200, 190)];
        _guanGeView.backgroundColor = [UIColor clearColor];
    }
    return _guanGeView;
}

- (UILabel *)memoryPreLabel
{
    if (!_memoryPreLabel) {
        _memoryPreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.guanGeView.height - 30, self.guanGeView.width, 20)];
        _memoryPreLabel.textAlignment = NSTextAlignmentCenter;
        _memoryPreLabel.textColor = [UIColor whiteColor];
    }
    return _memoryPreLabel;
}

- (UILabel *)ramLabel
{
    if (!_ramLabel) {
        _ramLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.guanGeView.bottom + 10, LabelWidth, 20)];
        _ramLabel.textColor = [UIColor lightGrayColor];
        _ramLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _ramLabel;
}

- (UILabel *)diskLabel
{
    if (!_diskLabel) {
        _diskLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelWidth, self.guanGeView.bottom + 10, LabelWidth, 20)];
        _diskLabel.textColor = [UIColor lightGrayColor];
        _diskLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _diskLabel;
}

- (UILabel *)topLiuLiang
{
    if (!_topLiuLiang) {
        _topLiuLiang = [[UILabel alloc] initWithFrame:CGRectMake(0, self.ramLabel.bottom + 10, LabelWidth, 20)];
        _topLiuLiang.textColor = [UIColor lightGrayColor];
        _topLiuLiang.textAlignment = NSTextAlignmentCenter;
    }
    return _topLiuLiang;
}

- (UILabel *)downLiuLiang
{
    if (!_downLiuLiang) {
        _downLiuLiang = [[UILabel alloc] initWithFrame:CGRectMake(LabelWidth, self.diskLabel.bottom + 10, LabelWidth, 20)];
        _downLiuLiang.textColor = [UIColor lightGrayColor];
        _downLiuLiang.textAlignment = NSTextAlignmentCenter;
    }
    return _downLiuLiang;
}

@end
