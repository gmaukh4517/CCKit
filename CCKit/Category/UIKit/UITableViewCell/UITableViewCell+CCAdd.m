//
//  UITableViewCell+CCAdd.m
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

#import "UITableViewCell+CCAdd.h"
#import "UITableViewRowAction+CCAdd.h"
#import <objc/runtime.h>

@implementation UITableViewCell (CCAdd)

+ (void)load
{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method willTransitionToState = class_getInstanceMethod(self, @selector(willTransitionToState:));
        Method __willTransitionToState = class_getInstanceMethod(self, @selector(__willTransitionToState:));
        method_exchangeImplementations(willTransitionToState, __willTransitionToState);
    });
}

- (void)ios_8
{
    UIView *swipeToDeleteConfirmationView = [self valueForKey:@"_swipeToDeleteConfirmationView"];
    
    for (UIButton *rowButton in swipeToDeleteConfirmationView.subviews) {
        
        UITableViewRowAction *rowAction = [rowButton valueForKey:@"_action"];
        if (rowAction.backgroundColor) {
            rowButton.backgroundColor = rowAction.backgroundColor;
        }
        
        rowButton.enabled = rowAction.enabled;
        
        if (rowAction.titleColor)
            [rowButton setTitleColor:rowAction.titleColor forState:UIControlStateNormal];
        
        if (rowAction.image) {
            NSTextAttachment *imageAtt = [[NSTextAttachment alloc] init];
            imageAtt.image = rowAction.image;
            [rowButton setAttributedTitle:[NSAttributedString attributedStringWithAttachment:imageAtt] forState:UIControlStateNormal];
        }
        
        if (![rowAction.title isEqualToString:@"CC"] && rowAction.image) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:rowButton.currentAttributedTitle];
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:rowAction.title]];
            if (rowAction.titleColor)
                [attStr addAttribute:NSForegroundColorAttributeName value:rowAction.titleColor range:NSMakeRange(0, [attStr length])];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:5];
            [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attStr length])];
            
            
            [rowButton setAttributedTitle:attStr forState:UIControlStateNormal];
        }
        
        if (rowAction.backgroundImage) {
            [rowButton setBackgroundImage:rowAction.backgroundImage forState:UIControlStateNormal];
        }
    }
}

- (void)IOS_11
{
    UIView *swipeToDeleteConfirmationView;
    for (UIView *v in self.superview.subviews) {
        if ([[NSString stringWithUTF8String:object_getClassName(v)] isEqualToString:@"UISwipeActionPullView"]) {
            swipeToDeleteConfirmationView = v;
        }
    }
    
//    NSArray *rowBtns = [swipeToDeleteConfirmationView valueForKey:@"_buttons"];
//    NSArray *rowActions = [swipeToDeleteConfirmationView valueForKey:@"_actions"];
//    
//    for (NSInteger i = 0; i < rowBtns.count; i++) {
//        UIButton *rowButton = [rowBtns objectAtIndex:i];
//        UIContextualAction *rowAction = [rowActions objectAtIndex:i];
//        UIImage *image = rowAction.image;
//    }
}

- (void)__willTransitionToState:(UITableViewCellStateMask)state
{
    
    [self __willTransitionToState:state];
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        UITableView *tableView = [self valueForKey:@"_tableView"];
        if (![tableView.delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *version = [UIDevice currentDevice].systemVersion;
            if (version.doubleValue >= 11.0) {
                [self IOS_11];
                return;
            } else if (version.doubleValue >= 8.0) {
                [self ios_8];
                return;
            }
            
            UIView *swipeToDeleteConfirmationView = [self valueForKey:@"_swipeToDeleteConfirmationView"];
            
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            
            NSArray *rowActions = [tableView.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
            self.rowActions = rowActions;
            
            UIButton *deleteConfirmButton = swipeToDeleteConfirmationView.subviews.firstObject;
            deleteConfirmButton.titleLabel.textColor = deleteConfirmButton.backgroundColor;
            CGFloat buttonWidth = deleteConfirmButton.bounds.size.width / rowActions.count;
            CGFloat buttonHeight = deleteConfirmButton.bounds.size.height;
            for (NSInteger index = 0; index < rowActions.count; index++) {
                
                UITableViewRowAction *rowAction = rowActions[index];
                
                [rowAction setValue:indexPath forKey:@"indexPath"];
                
                UIButton *rowActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                if (rowAction.backgroundColor) {
                    rowActionButton.backgroundColor = rowAction.backgroundColor;
                } else {
                    rowActionButton.backgroundColor = rowAction.style == UITableViewRowActionStyleDestructive ? deleteConfirmButton.backgroundColor : [UIColor colorWithRed:187.0 / 255.0 green:187.0 / 255.0 blue:193.0 / 255.0 alpha:1.0];
                }
                
                if (rowAction.enabled) {
                    [rowActionButton addTarget:rowAction action:NSSelectorFromString(@"actionTriggered:") forControlEvents:UIControlEventTouchUpInside];
                }
                
                rowActionButton.frame = CGRectMake((rowActions.count - 1 - index) * buttonWidth, 0, buttonWidth, buttonHeight);
                
                rowAction.image ? [rowActionButton setImage:rowAction.image forState:UIControlStateNormal]
                : [rowActionButton setTitle:rowAction.title forState:UIControlStateNormal];
                
                [deleteConfirmButton addSubview:rowActionButton];
            }
        });
    }
}

- (void)setRowActions:(NSArray *)rowActions
{
    objc_setAssociatedObject(self, @selector(rowActions), rowActions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)rowActions
{
    return objc_getAssociatedObject(self, _cmd);
}

/**
 *  @brief  加载同类名的nib
 *
 *  @return nib
 */
+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (UINib *)nibWithIdentifier:(NSString *)identifier
{
    return [UINib nibWithNibName:identifier bundle:nil];
}

+ (void)registerTable:(UITableView *)tableView
        nibIdentifier:(NSString *)identifier
{
    UINib *nib = [self nibWithIdentifier:identifier];
    if (nib)
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    else
        [tableView registerClass:NSClassFromString(identifier) forCellReuseIdentifier:identifier];
}

- (void)configure:(UITableViewCell *)tableViewCell
        customObj:(id)obj
        indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass !
}

- (void)cc_cellWillDisplayWithModel:(id)cModel
                          indexPath:(NSIndexPath *)cIndexPath
{
    self.cc_dataSources = cModel;
    self.cc_indexPath = cIndexPath;
    // Rewrite this func in SubClass !
}

+ (CGFloat)obtainCellHeightWithCustomObj:(id)obj
                               indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass if necessary
    if (!obj) {
        return 0.0f; // if obj is null .
    }
    return 44.0f; // default cell height
}


- (UIScrollView *)cc_scrollView
{
    id sv = self.contentView.superview;
    while (![sv isKindOfClass:[UIScrollView class]] && sv != self) {
        sv = [sv superview];
    }
    
    return sv == self ? nil : sv;
}

- (void)setCc_delaysContentTouches:(BOOL)delaysContentTouches
{
    [self willChangeValueForKey:@"cc_delaysContentTouches"];
    
    [[self cc_scrollView] setDelaysContentTouches:delaysContentTouches];
    
    [self didChangeValueForKey:@"cc_delaysContentTouches"];
}

- (BOOL)cc_delaysContentTouches
{
    return [[self cc_scrollView] delaysContentTouches];
}

- (void)setCc_dataSources:(id)cc_dataSources
{
    objc_setAssociatedObject(self, @selector(cc_dataSources), cc_dataSources, OBJC_ASSOCIATION_RETAIN);
}

- (id)cc_dataSources
{
    return objc_getAssociatedObject(self, @selector(cc_dataSources));
}

- (void)setCc_indexPath:(NSIndexPath *)cc_indexPath
{
    objc_setAssociatedObject(self, @selector(cc_indexPath), cc_indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)cc_indexPath
{
    return objc_getAssociatedObject(self, @selector(cc_indexPath));
}

@end
