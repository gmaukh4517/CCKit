//
//  ProfilerTableHeader.m
//  CCKit
//
//  Created by CC on 2017/7/4.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "ProfilerTableHeader.h"
#import "UIView+Frame.h"

@implementation ProfilerTableHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, self.width - 130, 25)];
    fieldView.backgroundColor = [UIColor whiteColor];
    fieldView.layer.borderWidth = 0.5;
    fieldView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:fieldView];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, fieldView.width, fieldView.height)];
    textField.font = [UIFont systemFontOfSize:14];
    textField.placeholder = @"Filter...";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [fieldView addSubview:textField];
    
    UIButton *markGenerationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    markGenerationButton.frame = CGRectMake(fieldView.right + 10, fieldView.y, 100, 25);
    markGenerationButton.backgroundColor = [UIColor whiteColor];
    markGenerationButton.layer.borderWidth = 1.0;
    markGenerationButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [markGenerationButton setTitle:@"Mark Gen." forState:UIControlStateNormal];
    [markGenerationButton addTarget:self action:@selector(markGenerationClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:markGenerationButton];
    
    UISegmentedControl *sortControl = [[UISegmentedControl alloc] initWithItems:@[ @"Class", @"Alive", @"Size" ]];
    sortControl.selectedSegmentIndex = 0;
    sortControl.frame = CGRectMake(fieldView.x, fieldView.bottom + 7, 200, fieldView.height);
    [sortControl addTarget:self action:@selector(sortControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:sortControl];
}

- (void)markGenerationClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(markGeneration)])
        [self.delegate markGeneration];
}

- (void)sortControlValueChanged:(UISegmentedControl *)sender
{
    if ([self.delegate respondsToSelector:@selector(sortValueChanged:)])
        [self.delegate sortValueChanged:sender];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidChange:)]) {
        [self.delegate textFieldDidChange:textField.text];
    }
}

@end
