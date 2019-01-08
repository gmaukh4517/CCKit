//
//  WebViewController.m
//  CCKitDemo
//
//  Created by CC on 2019/1/5.
//  Copyright © 2019 CC. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ShowJS" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];

    [self didCapture:@"testObjcCallback"
        ResponseBlock:^(NSString *functionName, id arguments) {
            NSLog(@"JS calling handler '%@' responded: %@", functionName, arguments);
        }];

    [self didCapture:@"clearObjcCallback"
        ResponseBlock:^(NSString *functionName, id arguments) {
            NSLog(@"JS calling handler '%@' responded: %@", functionName, arguments);
        }];
}

- (void)rightBarButtonClick:(UIBarButtonItem *)sender
{
    NSString *JSFunction = [NSString stringWithFormat:@"testJavascriptHandler(%@)", @"{\"Object-c\":\"Hi, I am Object-c\"}"];
    [self evaluateJavaScript:JSFunction
           completionHandler:^(id response, NSError *error) {
               if (error)
                   NSLog(@"testJavascriptHandler response:%@ error:%@", response, error);
           }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //     [self loadRequest:@"www.baidu.com"];
    [self loadLocalFiles:@"WebAPPDemo" expansion:@"html"];
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
