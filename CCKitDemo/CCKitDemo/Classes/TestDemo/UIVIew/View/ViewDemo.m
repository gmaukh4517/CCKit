//
//  ViewDemo.m
//  CCKitDemo
//
//  Created by CC on 2018/12/29.
//  Copyright © 2018 CC. All rights reserved.
//

#import "ViewDemo.h"

@interface ViewDemo ()

@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation ViewDemo

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    self.backgroundColor = [UIColor RandomColor];

    CGFloat width = (self.width - 90) / 2;

    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, width, 40)];
    testButton.backgroundColor = [UIColor RandomColor];
    testButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [testButton setTitle:@"点击我出发Block事件"];
    [testButton addTarget:self action:@selector(testButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:testButton];

    UIButton *jumpButton = [[UIButton alloc] initWithFrame:CGRectMake(testButton.right + 30, testButton.y, width, testButton.height)];
    jumpButton.backgroundColor = [UIColor RandomColor];
    jumpButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [jumpButton setTitle:@"点击我delegate带你去看看"];
    [jumpButton addTarget:self action:@selector(jumpButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:jumpButton];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, testButton.bottom + 50, self.width, 20)];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"假装我在网络请求......";
    [self addSubview:_textLabel = textLabel];
}

- (void)testButtonClick:(UIButton *)sender
{
    !self.viewEventsBlock ?: self.viewEventsBlock(@"testClick", @{ @"testClick" : @"点击点击" });
}

- (void)jumpButtonClick:(UIButton *)sender
{
    NSLog(@"handleControlEvent === haha");
    if ([self.viewDelegate respondsToSelector:@selector(cc_viewEvent:withEvents:)]) {
        [self.viewDelegate cc_viewEvent:self withEvents:@{ @"jump" : @"" }];
    }
}

- (void)cc_configureViewWithViewModel:(id<CCViewModelProtocol>)viewModel
{
    @weakify(self);
    [viewModel cc_viewModelWithModelBlcok:^(id model) {
        @strongify(self);
        self.textLabel.text = [model objectForKey:@"text"];
    }];
}

@end
