//
//  PostNoticeViewController.m
//  CCKitDemo
//
//  Created by CC on 2019/1/9.
//  Copyright © 2019 CC. All rights reserved.
//

#import "PostNoticeViewController.h"

@interface PostNoticeViewController ()

@property (nonatomic, weak) UITextField *postTextField;

@end

@implementation PostNoticeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"PostEventNotice";
    self.view.backgroundColor = [UIColor RandomColor];
    [self initControl];
}

- (void)initControl
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 200, 40)];
    textField.placeholder = @"输入你想发送的信息";
    textField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_postTextField = textField];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, textField.bottom + 20, 200, 40)];
    button.backgroundColor = [UIColor RandomColor];
    [button setTitle:@"发送..."];
    [button addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)postButtonClick:(UIButton *)sender
{
    [CCEventNoticeCenter postEventName:@"VCPost"
                                object:@{ @"text" : _postTextField.text.length ?_postTextField.text: [NSString stringWithFormat:@"VCPost_%d", arc4random() % 100],
                                          @"conetnt" : @"跨区域了咯" }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
