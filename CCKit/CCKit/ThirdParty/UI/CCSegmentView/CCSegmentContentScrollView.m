//
//  CCSegmentContentScrollView.m
//  CCKit
//
//  Created by CC on 2019/4/15.
//  Copyright © 2019 CC. All rights reserved.
//

#import "CCSegmentContentScrollView.h"

@implementation CCSegmentContentScrollView


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
}
//location_X可自己定义,其代表的是滑动返回距左边的有效长度
- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer
{
    //是滑动返回距左边的有效长度
    int location_X = 150;
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];

            if (point.x > 0 && location.x < location_X && self.contentOffset.x == 0) {
                return YES;
            } else if (point.x < 0 && location.x > (self.contentOffset.x + self.bounds.size.width) - location_X && self.contentOffset.x == self.contentSize.width - self.bounds.size.width) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;

}

@end
