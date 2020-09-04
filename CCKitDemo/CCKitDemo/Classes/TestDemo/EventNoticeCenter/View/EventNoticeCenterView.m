//
//  EventNoticeCenterView.m
//  CCKitDemo
//
//  Created by CC on 2019/1/9.
//  Copyright © 2019 CC. All rights reserved.
//

#import "EventNoticeCenterView.h"

@interface EventNoticeCenterView ()

@property (nonatomic, weak) UILabel *eventLabel;

@property (nonatomic, weak) UILabel *blockLabel;

@end

@implementation EventNoticeCenterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, (self.width - 60) / 2, 20)];
    eventLabel.textColor = [UIColor whiteColor];
    eventLabel.textAlignment = NSTextAlignmentCenter;
    eventLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_eventLabel = eventLabel];

    UILabel *blockLabel = [[UILabel alloc] initWithFrame:CGRectMake(eventLabel.right + 20, eventLabel.y, eventLabel.width, eventLabel.height)];
    blockLabel.textColor = [UIColor whiteColor];
    blockLabel.textAlignment = NSTextAlignmentCenter;
    blockLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_blockLabel = blockLabel];


    [CCEventNoticeCenter addTarget:self eventName:@"viewEventLabel" actionSEL:@selector(eventLabelNotcie:)];

    @weakify(self);
    [CCEventNoticeCenter addTarget:self
                         eventName:@"ViewEventBlock"
                            action:^(CCEvent *info) {
                                @strongify(self);
                                self.blockLabel.text = info.object;
                            }];
}

- (void)eventLabelNotcie:(CCEvent *)event
{
    self.eventLabel.text = event.object;
}

- (void)dealloc
{
    [CCEventNoticeCenter removeEvent:@"viewEventLabel"];
    [CCEventNoticeCenter removeEvent:@"ViewEventBlock"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
