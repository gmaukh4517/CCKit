//
//  EventNoticeCenterViewManager.m
//  CCKitDemo
//
//  Created by CC on 2019/1/8.
//  Copyright © 2019 CC. All rights reserved.
//

#import "EventNoticeCenterViewManager.h"
#import "EventNoticeCenterView.h"
#import "PostNoticeViewController.h"

@interface EventNoticeCenterViewManager ()

@property (nonatomic, weak) UILabel *vcLabel;

@end

@implementation EventNoticeCenterViewManager

- (void)cc_viewManagerWithSuperView:(UIView *)superView
{
    superView.backgroundColor = [UIColor whiteColor];

    EventNoticeCenterView *eventView = [[EventNoticeCenterView alloc] initWithFrame:CGRectMake(0, 0, superView.width, 100)];
    eventView.backgroundColor = [UIColor RandomColor];
    [superView addSubview:eventView];

    NSArray *arr = @[ @{ @"title" : @"post actionSEL",
                         @"SEL" : @"postActiconSel:",
                         @"postName" : @"viewEventLabel" },
                      @{ @"title" : @"post Block",
                         @"SEL" : @"postEventNotice:",
                         @"postName" : @"ViewEventBlock" } ];

    NSInteger rowCount = 2;
    NSInteger x = 10, y = eventView.bottom + 10, width = (superView.width - x * (rowCount + 1)) / rowCount;
    for (NSInteger i = 0; i < arr.count; i++) {
        NSDictionary *item = [arr objectAtIndex:i];

        UIButton *handleButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, 40)];
        handleButton.backgroundColor = [UIColor RandomColor];
        [handleButton setTitle:[item objectForKey:@"title"]];
        [handleButton addTarget:self action:NSSelectorFromString([item objectForKey:@"SEL"]) forControlEvents:UIControlEventTouchUpInside];
        handleButton.carryObjects = [item objectForKey:@"postName"];
        [superView addSubview:handleButton];

        x = handleButton.right + 10;
        if (i + 1 == rowCount) {
            x = 10;
            y = handleButton.bottom + 10;
        }
    }


    UILabel *vcLabel = [[UILabel alloc] initWithFrame:CGRectMake((superView.width - 200) / 2, y + 30, 200, 50)];
    vcLabel.backgroundColor = [UIColor RandomColor];
    vcLabel.textAlignment = NSTextAlignmentCenter;
    vcLabel.textColor = [UIColor whiteColor];
    vcLabel.text = @"ViewController text Label";
    [superView addSubview:_vcLabel = vcLabel];
    [CCEventNoticeCenter addTarget:self eventName:@"VCPost" actionSEL:@selector(vcLabelNotice:)];

    UIButton *pushButton = [[UIButton alloc] initWithFrame:CGRectMake(vcLabel.x, vcLabel.bottom + 30, vcLabel.width, 30)];
    pushButton.backgroundColor = [UIColor RandomColor];
    [pushButton setTitle:@"Push ViewController"];
    [pushButton handleControlEvent:UIControlEventTouchUpInside
                         withBlock:^(UIButton *sender) {
                             [sender.viewController pushNewViewControllerWithBack:[PostNoticeViewController new]];
                         }];
    [superView addSubview:pushButton];
}

- (void)postEventNotice:(UIButton *)sender
{
    [CCEventNoticeCenter postEventName:sender.carryObjects
                                object:[NSString stringWithFormat:@"ViewManagerPost_%d", arc4random() % 100]];
}

- (void)postActiconSel:(UIButton *)sender
{
    [CCEventNoticeCenter postEventName:sender.carryObjects
                                object:[NSString stringWithFormat:@"ViewManagerPostSEL_%d", arc4random() % 100]];
}

- (void)vcLabelNotice:(CCEvent *)event
{
    self.vcLabel.text = [event.userInfo objectForKey:@"text"];
    NSLog(@"PostNoticeViewController____%@", event.description);
}

- (void)dealloc
{
    [CCEventNoticeCenter removeEvent:@"VCPost"];
}

@end
