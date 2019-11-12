
//  UITableView+CCAdd.m
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

#import "UITableView+CCAdd.h"
#import "CCTableViewHelper.h"
#import "NSObject+CCAdd.h"
#import "UIView+Method.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

typedef NSMutableArray<NSMutableArray<NSNumber *> *> CCIndexPathHeightsBySection;

@interface CCIndexPathHeightCache ()

@property (nonatomic, strong) CCIndexPathHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) CCIndexPathHeightsBySection *heightsBySectionForLandscape;

@end

@implementation CCIndexPathHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (CCIndexPathHeightsBySection *)heightsBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait : self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(CCIndexPathHeightsBySection *heightsBySection))block
{
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ indexPath.section ][ indexPath.row ];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    self.heightsBySectionForCurrentOrientation[ indexPath.section ][ indexPath.row ] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ indexPath.section ][ indexPath.row ];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtSection:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        for (NSInteger targetSection = 0; targetSection <= section; ++targetSection) {
            if (targetSection < heightsBySection.count) {
                [heightsBySection[ targetSection ] removeAllObjects];
            }
        }
    }];
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[ indexPath ]];
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[ indexPath.section ];
        [heightsByRow removeObjectsInRange:NSMakeRange(indexPath.row, heightsByRow.count - indexPath.row)];
        heightsBySection[ indexPath.section ] = heightsByRow;
    }];
}

- (void)invalidateHeightLast:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeObjectsInRange:NSMakeRange(section, heightsBySection.count - section)];
    }];
}

- (void)invalidateAllHeightCache
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths
{
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[ section ] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCIndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[ section ];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[ row ] = @-1;
            }
        }
    }];
}

@end


typedef NSMutableArray<NSNumber *> CCSectionHeaderHeightsBySection;

@interface CCSectionHedaerHeightCache ()

@property (nonatomic, strong) CCSectionHeaderHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) CCSectionHeaderHeightsBySection *heightsBySectionForLandscape;

@end

@implementation CCSectionHedaerHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (CCSectionHeaderHeightsBySection *)heightsBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait : self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(CCSectionHeaderHeightsBySection *heightsBySection))block
{
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ section ];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height bySection:(NSInteger)section
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    self.heightsBySectionForCurrentOrientation[ section ] = @(height);
}

- (CGFloat)heightForSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ section ];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    [self enumerateAllOrientationsUsingBlock:^(CCSectionHeaderHeightsBySection *heightsBySection) {
        heightsBySection[ section ] = @-1;
    }];
}

- (void)invalidateHeightLast:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionHeaderHeightsBySection *heightsBySection) {
        [heightsBySection removeObjectsInRange:NSMakeRange(section, heightsBySection.count - section)];
    }];
}

- (void)invalidateAllHeightCache
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionHeaderHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)sections
{
    // Build every section array or row array which is smaller than given index path.
    [sections enumerateObjectsUsingBlock:^(id _Nonnull section, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:[section integerValue]];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionHeaderHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count)
                heightsBySection[ section ] = @-1;
        }
    }];
}

@end


typedef NSMutableArray<NSNumber *> CCSectionFooterHeightsBySection;

@interface CCSectionFooterHeightCache ()

@property (nonatomic, strong) CCSectionFooterHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) CCSectionFooterHeightsBySection *heightsBySectionForLandscape;

@end

@implementation CCSectionFooterHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (CCSectionFooterHeightsBySection *)heightsBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait : self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(CCSectionFooterHeightsBySection *heightsBySection))block
{
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ section ];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height bySection:(NSInteger)section
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    self.heightsBySectionForCurrentOrientation[ section ] = @(height);
}

- (CGFloat)heightForSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[ section ];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtSection:(NSInteger)section
{
    [self buildCachesAtIndexPathsIfNeeded:@[ @(section) ]];
    [self enumerateAllOrientationsUsingBlock:^(CCSectionFooterHeightsBySection *heightsBySection) {
        heightsBySection[ section ] = @-1;
    }];
}

- (void)invalidateHeightLast:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionFooterHeightsBySection *heightsBySection) {
        [heightsBySection removeObjectsInRange:NSMakeRange(section, heightsBySection.count - section)];
    }];
}

- (void)invalidateAllHeightCache
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionFooterHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)sections
{
    // Build every section array or row array which is smaller than given index path.
    [sections enumerateObjectsUsingBlock:^(id _Nonnull section, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:[section integerValue]];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection
{
    [self enumerateAllOrientationsUsingBlock:^(CCSectionFooterHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count)
                heightsBySection[ section ] = @-1;
        }
    }];
}

@end


#pragma mark -
#pragma mark :. CCAdd

@implementation UITableView (CCAdd)

- (CCTableViewHelper *)cc_tableViewHelper
{
    CCTableViewHelper *curTableHelper = [self associatedValueForKey:@selector(cc_tableViewHelper)];
    if (curTableHelper) return curTableHelper;

    curTableHelper = [CCTableViewHelper new];
    self.cc_tableViewHelper = curTableHelper;
    return curTableHelper;
}

- (void)setCc_tableViewHelper:(CCTableViewHelper *)cc_tableViewHelper
{
    [self associateValue:cc_tableViewHelper withKey:@selector(cc_tableViewHelper)];
    self.delegate = cc_tableViewHelper;
    self.dataSource = cc_tableViewHelper;
    cc_tableViewHelper.cc_tableView = self;
}

- (BOOL)cc_autoSizingCell
{
    return (BOOL)[self associatedValueForKey:@selector(cc_autoSizingCell)];
}

- (void)setCc_autoSizingCell:(BOOL)cc_autoSizingCell
{
    [self associateValue:@(cc_autoSizingCell) withKey:@selector(cc_autoSizingCell)];
}

- (BOOL)cc_autoSizingHeaderFooter
{
    return (BOOL)[self associatedValueForKey:@selector(cc_autoSizingHeaderFooter)];
}

- (void)setCc_autoSizingHeaderFooter:(BOOL)cc_autoSizingHeaderFooter
{
    [self associateValue:@(cc_autoSizingHeaderFooter) withKey:@selector(cc_autoSizingHeaderFooter)];
}

/** 隐藏TableView多余线 **/
- (void)extraCellLineHidden
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
}

- (void)applyiOS7SettingsStyleGrouping:(UITableViewCell *)cell
                     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass !
}

- (UIView *)tableViewSectionView:(NSString *)text
                   SectionHeight:(CGFloat)height
{
    // Rewrite this func in SubClass !
    return nil;
}

#pragma mark -
#pragma mark :. CCIndexPathHeightCache

- (CCIndexPathHeightCache *)cc_indexPathHeightCache
{
    CCIndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [CCIndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (CCSectionHedaerHeightCache *)cc_headerHeightCache
{
    CCSectionHedaerHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [CCSectionHedaerHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (CCSectionFooterHeightCache *)cc_footerHeightCache
{
    CCSectionFooterHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [CCSectionFooterHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

#pragma mark -
#pragma mark :. CCKeyedHeightCache

- (CCKeyedHeightCache *)cc_keyedHeightCache
{
    CCKeyedHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [CCKeyedHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

#pragma mark -
#pragma mark :. CCTemplateLayoutCell

- (CGFloat)cc_systemFittingHeightForConfiguratedHeaderFooter:(UITableViewHeaderFooterView *)templateHeaderFooterView
{
    CGFloat contentViewWidth = CGRectGetWidth(self.frame)?: [[UIScreen mainScreen] bounds].size.width;

    CGRect cellBounds = templateHeaderFooterView.bounds;
    cellBounds.size.width = contentViewWidth;
    templateHeaderFooterView.bounds = cellBounds;

    CGFloat rightSystemViewsWidth = 0.0;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
            rightSystemViewsWidth = CGRectGetWidth(view.frame);
            break;
        }
    }

    // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
    // This is the same height calculation passes used in iOS8 self-sizing cell's implementation.
    //
    // 1. Try "- systemLayoutSizeFittingSize:" first. (skip this step if 'cc_enforceFrameLayout' set to YES.)
    // 2. Warning once if step 1 still returns 0 when using AutoLayout
    // 3. Try "- sizeThatFits:" if step 1 returns 0
    // 4. Use a valid height or default row height (44) if not exist one
    CGFloat fittingHeight = 0;

    if (contentViewWidth > 0) {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];

        // [bug fix] after iOS 10.3, Auto Layout engine will add an additional 0 width constraint onto cell's content view, to avoid that, we add constraints to content view's left, right, top and bottom.
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });

        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            // To avoid confilicts, make width constraint softer than required (1000)
            widthFenceConstraint.priority = UILayoutPriorityRequired - 1;

            // Build edge constraintsb
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:templateHeaderFooterView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:templateHeaderFooterView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-rightSystemViewsWidth];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:templateHeaderFooterView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:templateHeaderFooterView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[ leftConstraint, rightConstraint, topConstraint, bottomConstraint ];
            [templateHeaderFooterView addConstraints:edgeConstraints];
        }

        [templateHeaderFooterView.contentView addConstraint:widthFenceConstraint];

        // Auto layout engine does its math
        fittingHeight = [templateHeaderFooterView.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [templateHeaderFooterView.contentView removeConstraint:widthFenceConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [templateHeaderFooterView removeConstraints:edgeConstraints];
        }
    }

    if (fittingHeight == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (templateHeaderFooterView.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[CCTemplateLayoutHeaderFooter] Warning once only: Cannot get a proper headerfooter height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in headerfooter, making it into 'self-sizing' headerfooter.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
    }

    // Still zero height after all above.
    if (fittingHeight == 0) {
        // Use default row height.
        fittingHeight = CGRectGetHeight(templateHeaderFooterView.frame);
    }

    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingHeight += 1.0 / [UIScreen mainScreen].scale;
    }

    return fittingHeight;
}

- (__kindof UITableViewHeaderFooterView *)cc_templateHeaderFooterForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);

    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFootersByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFootersByIdentifiers) {
        templateHeaderFootersByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFootersByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    UITableViewHeaderFooterView *templateHeaderFooter = templateHeaderFootersByIdentifiers[ identifier ];

    if (!templateHeaderFooter) {
        templateHeaderFooter = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooter != nil, @"headerORfooter must be registered to table view for identifier - %@", identifier);
        templateHeaderFooter.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFootersByIdentifiers[ identifier ] = templateHeaderFooter;
    }

    return templateHeaderFooter;
}

- (CGFloat)cc_heightForHeaderFooterWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration
{
    if (!identifier)
        return 0;

    UITableViewHeaderFooterView *templateLayoutHeader = [self cc_templateHeaderFooterForReuseIdentifier:identifier];

    // Manually calls to ensure consistent behavior with actual cells. (that are displayed on screen)
    [templateLayoutHeader prepareForReuse];

    // Customize and provide content for our template cell.
    if (configuration)
        configuration(templateLayoutHeader);

    return [self cc_systemFittingHeightForConfiguratedHeaderFooter:templateLayoutHeader];
}

- (CGFloat)cc_heightForHeaderFooterWithIdentifier:(NSString *)identifier headerORfooter:(BOOL)headerORfooter cacheBySection:(NSInteger)section configuration:(void (^)(id headerFooter))configuration
{
    if (!identifier)
        return 0;

    // Hit cache
    if (headerORfooter) {
        if ([self.cc_headerHeightCache existsHeightAtSection:section])
            return [self.cc_headerHeightCache heightForSection:section];
    } else {
        if ([self.cc_footerHeightCache existsHeightAtSection:section])
            return [self.cc_footerHeightCache heightForSection:section];
    }

    CGFloat height = [self cc_heightForHeaderFooterWithIdentifier:identifier configuration:configuration];
    if (headerORfooter)
        [self.cc_headerHeightCache cacheHeight:height bySection:section];
    else
        [self.cc_footerHeightCache cacheHeight:height bySection:section];

    return height;
}


- (CGFloat)cc_systemFittingHeightForConfiguratedCell:(UITableViewCell *)cell
{
    CGFloat contentViewWidth = CGRectGetWidth(self.frame) ?: [[UIScreen mainScreen] bounds].size.width;

    CGRect cellBounds = cell.bounds;
    cellBounds.size.width = contentViewWidth;
    cell.bounds = cellBounds;

    CGFloat rightSystemViewsWidth = 0.0;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
            rightSystemViewsWidth = CGRectGetWidth(view.frame);
            break;
        }
    }

    // If a cell has accessory view or system accessory type, its content view's width is smaller
    // than cell's by some fixed values.
    if (cell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
                [ UITableViewCellAccessoryNone ] = 0,
                [UITableViewCellAccessoryDisclosureIndicator] = 34,
                [UITableViewCellAccessoryDetailDisclosureButton] = 68,
                [UITableViewCellAccessoryCheckmark] = 40,
                [UITableViewCellAccessoryDetailButton] = 48};
        contentViewWidth -= systemAccessoryWidths[ cell.accessoryType ];
    }

    if ([UIScreen mainScreen].scale >= 3 && [UIScreen mainScreen].bounds.size.width >= 414) {
        rightSystemViewsWidth += 4;
    }

    contentViewWidth -= rightSystemViewsWidth;

    // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
    // This is the same height calculation passes used in iOS8 self-sizing cell's implementation.
    //
    // 1. Try "- systemLayoutSizeFittingSize:" first. (skip this step if 'cc_enforceFrameLayout' set to YES.)
    // 2. Warning once if step 1 still returns 0 when using AutoLayout
    // 3. Try "- sizeThatFits:" if step 1 returns 0
    // 4. Use a valid height or default row height (44) if not exist one

    CGFloat fittingHeight = 0;

    if (!cell.cc_enforceFrameLayout && contentViewWidth > 0) {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];

        // [bug fix] after iOS 10.3, Auto Layout engine will add an additional 0 width constraint onto cell's content view, to avoid that, we add constraints to content view's left, right, top and bottom.
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });

        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            // To avoid confilicts, make width constraint softer than required (1000)
            widthFenceConstraint.priority = UILayoutPriorityRequired - 1;

            // Build edge constraints
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:-rightSystemViewsWidth];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[ leftConstraint, rightConstraint, topConstraint, bottomConstraint ];
            [cell addConstraints:edgeConstraints];
        }

        [cell.contentView addConstraint:widthFenceConstraint];

        // Auto layout engine does its math
        fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [cell.contentView removeConstraint:widthFenceConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [cell removeConstraints:edgeConstraints];
        }
    }

    if (fittingHeight == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (cell.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[CCTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
    }

    // Still zero height after all above.
    if (fittingHeight == 0) {
        // Use default row height.
        fittingHeight = 44;
    }

    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingHeight += 1.0 / [UIScreen mainScreen].scale;
    }

    return fittingHeight;
}

- (__kindof UITableViewCell *)cc_templateCellForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);

    NSMutableDictionary<NSString *, UITableViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    UITableViewCell *templateCell = templateCellsByIdentifiers[ identifier ];

    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.cc_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[ identifier ] = templateCell;
    }

    return templateCell;
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(UITableViewCell *cell))configuration
{
    if (!identifier) {
        return 0;
    }

    UITableViewCell *templateLayoutCell = [self cc_templateCellForReuseIdentifier:identifier];

    // Manually calls to ensure consistent behavior with actual cells. (that are displayed on screen)
    [templateLayoutCell prepareForReuse];

    // Customize and provide content for our template cell.
    if (configuration) {
        configuration(templateLayoutCell);
    }

    return [self cc_systemFittingHeightForConfiguratedCell:templateLayoutCell];
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(UITableViewCell *cell))configuration
{
    if (!identifier || !indexPath) {
        return 0;
    }

    // Hit cache
    if ([self.cc_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.cc_indexPathHeightCache heightForIndexPath:indexPath];
    }

    CGFloat height = [self cc_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];

    return height;
}

- (CGFloat)cc_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(UITableViewCell *cell))configuration
{
    if (!identifier || !key) {
        return 0;
    }

    // Hit cache
    if ([self.cc_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.cc_keyedHeightCache heightForKey:key];
        return cachedHeight;
    }

    CGFloat height = [self cc_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cc_keyedHeightCache cacheHeight:height byKey:key];

    return height;
}


@end

@implementation UITableView (CCTemplateLayoutHeaderFooterView)

- (__kindof UITableViewHeaderFooterView *)cc_templateHeaderFooterViewForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);

    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFooterViews = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFooterViews) {
        templateHeaderFooterViews = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFooterViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    UITableViewHeaderFooterView *templateHeaderFooterView = templateHeaderFooterViews[ identifier ];

    if (!templateHeaderFooterView) {
        templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooterView != nil, @"HeaderFooterView must be registered to table view for identifier - %@", identifier);
        templateHeaderFooterView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFooterViews[ identifier ] = templateHeaderFooterView;
    }

    return templateHeaderFooterView;
}

- (CGFloat)cc_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configuration
{
    UITableViewHeaderFooterView *templateHeaderFooterView = [self cc_templateHeaderFooterViewForReuseIdentifier:identifier];

    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    [templateHeaderFooterView addConstraint:widthFenceConstraint];
    CGFloat fittingHeight = [templateHeaderFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [templateHeaderFooterView removeConstraint:widthFenceConstraint];

    if (fittingHeight == 0) {
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), 0)].height;
    }

    return fittingHeight;
}

@end

@implementation UITableViewCell (CCTemplateLayoutCell)

- (BOOL)cc_isTemplateLayoutCell
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCc_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell
{
    objc_setAssociatedObject(self, @selector(cc_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)cc_enforceFrameLayout
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCc_enforceFrameLayout:(BOOL)enforceFrameLayout
{
    objc_setAssociatedObject(self, @selector(cc_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end


#pragma mark -
#pragma mark :. CCKeyedHeightCache
@interface CCKeyedHeightCache ()

@property (nonatomic, strong) NSMutableDictionary *mutableHeightsByKeyForPortrait;
@property (nonatomic, strong) NSMutableDictionary *mutableHeightsByKeyForLandscape;

@end

@implementation CCKeyedHeightCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)mutableHeightsByKeyForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableHeightsByKeyForPortrait : self.mutableHeightsByKeyForLandscape;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key
{
    NSNumber *number = self.mutableHeightsByKeyForCurrentOrientation[ key ];
    return number && ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key
{
    self.mutableHeightsByKeyForCurrentOrientation[ key ] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key
{
#if CGFLOAT_IS_DOUBLE
    return [self.mutableHeightsByKeyForCurrentOrientation[ key ] doubleValue];
#else
    return [self.mutableHeightsByKeyForCurrentOrientation[ key ] floatValue];
#endif
}

- (void)invalidateHeightForKey:(id<NSCopying>)key
{
    [self.mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [self.mutableHeightsByKeyForLandscape removeObjectForKey:key];
}

- (void)invalidateAllHeightCache
{
    [self.mutableHeightsByKeyForPortrait removeAllObjects];
    [self.mutableHeightsByKeyForLandscape removeAllObjects];
}

@end
