//
//  CCTableViewHelper.m
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

#import "CCTableViewHelper.h"
#import "CCConfig.h"
#import "CCProperty.h"
#import "NSObject+CCAdd.h"
#import "NSString+CCAdd.h"
#import "UITableView+CCAdd.h"
#import "UITableViewCell+CCAdd.h"
#import "UIView+CCTransfer.h"
#import "UIView+Method.h"
#import "UIViewController+CCAdd.h"

#import "UITableViewHeaderFooterView+CCAdd.h"

#define CCAssert(condition, format, ...)                                                       \
do {                                                                                       \
_Pragma("clang diagnostic push")                                                       \
_Pragma("clang diagnostic ignored \"-Wformat-extra-args\"") if ((condition) == NO) \
NSLog(format, ##__VA_ARGS__);                                                  \
_Pragma("clang diagnostic pop")                                                        \
} while (0);

#define defaultInterval .5 //默认时间间隔

@interface CCTableViewHelper ()

@property (nonatomic, strong) NSArray *headerNibNames;
@property (nonatomic, strong) NSArray *footerNibNames;

@property (nonatomic, assign) NSInteger headerSection;
@property (nonatomic, assign) NSInteger footerSection;

@property (nonatomic, strong) NSArray *dataHeaderArr;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property (nonatomic, strong) NSArray *dataFooterArr;

@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@property (nonatomic, strong) UILocalizedIndexedCollation *theCollation;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign) BOOL isIgnoreEvent;

/**
 *  @author CC, 16-07-23
 *
 *  @brief 头部搜索
 */
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) CCTableHelperHeaderIdentifierBlock headerIdentifierBlock;
@property (nonatomic, copy) CCTableHelperCellIdentifierBlock cellIdentifierBlock;
@property (nonatomic, copy) CCTableHelperFooterIdentifierBlock footerIdentifierBlock;

@property (nonatomic, copy) CCTableHelperDidSelectBlock didSelectBlock;
@property (nonatomic, copy) CCTableHelperDidDeSelectBlock didDeSelectBlock;
@property (nonatomic, copy) CCTableHelperDidMoveToRowBlock didMoveToRowBlock;
@property (nonatomic, copy) CCTableHelperDidWillDisplayBlock didWillDisplayBlock;

@property (nonatomic, copy) CCTableHelperDidEditingBlock didEditingBlock;
@property (nonatomic, copy) CCTableHelperDidEditTitleBlock didEditTileBlock;

@property (nonatomic, copy) CCTableHelperEditingStyle didEditingStyle;
@property (nonatomic, copy) CCTableHelperDidEditActionsBlock didEditActionsBlock;

@property (nonatomic, copy) CCScrollViewWillBeginDragging scrollViewBdBlock;
@property (nonatomic, copy) CCScrollViewDidScroll scrollViewddBlock;
@property (nonatomic, copy) CCScrollViewDidEndDecelerating scrollViewDidEndDeceleratingBlock;
@property (nonatomic, copy) CCScrollViewDidEndDragging scrollViewDidEndDraggingBlock;

@property (nonatomic, copy) CCTableHelperHeaderBlock didHeaderWillDisplayBlock;
@property (nonatomic, copy) CCTableHelperTitleHeaderBlock headerTitleBlock;

@property (nonatomic, copy) CCTableHelperFooterBlock didFooterWillDisplayBlock;
@property (nonatomic, copy) CCTableHelperTitleFooterBlock footerTitleBlock;

@property (nonatomic, copy) CCTableHelperNumberOfSections numberOfSections;
@property (nonatomic, copy) CCTableHelperNumberRows numberRow;

@property (nonatomic, copy) CCTableHelperCellBlock cellViewEventsBlock;
@property (nonatomic, copy) CCTableHelperCurrentModelAtIndexPath currentModelAtIndexPath;
@property (nonatomic, copy) CCTableHelperScrollViewDidEndScrolling scrollViewDidEndScrolling;

@end

@implementation CCTableViewHelper

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    _titleHeaderHeight = 0;
    _titleFooterHeight = 0;
    if (@available(iOS 10.0, *)) {
        _titleHeaderHeight = 0.001;
        _titleFooterHeight = 0.001;
    }
}

#pragma mark -
#pragma mark :. getset

- (void)setCc_tableView:(UITableView *)cc_tableView
{
    _cc_tableView = cc_tableView;
    if (@available(iOS 11.0, *)) {
        _cc_tableView.estimatedRowHeight = 0;
        _cc_tableView.estimatedSectionFooterHeight = 0;
        _cc_tableView.estimatedSectionHeaderHeight = 0;
    }
}

- (NSString *)cellIdentifier
{
    if (!_cellIdentifier) {
        NSString *curVCIdentifier = [self cc_tableView_identifier];
        if (curVCIdentifier)
            _cellIdentifier = [NSString stringWithFormat:@"CC%@Cell", curVCIdentifier];
    }
    return _cellIdentifier;
}

- (NSString *)headerIdentifier
{
    if (!_headerIdentifier) {
        NSString *curVCIdentifier = [self cc_tableView_identifier];
        if (curVCIdentifier)
            _headerIdentifier = [NSString stringWithFormat:@"CC%@HeaderFooter", curVCIdentifier];
    }
    return _headerIdentifier;
}

- (NSString *)footerIdentifier
{
    if (!_footerIdentifier) {
        NSString *curVCIdentifier = [self cc_tableView_identifier];
        if (curVCIdentifier)
            _footerIdentifier = [NSString stringWithFormat:@"CC%@HeaderFooter", curVCIdentifier];
    }
    return _footerIdentifier;
}


- (void)registerNibs:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames.count > 0) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.cc_CellXIB && [self.cc_CellXIB containsObject:obj])
                [self.cc_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellReuseIdentifier:obj];
            else
                [self.cc_tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:obj];
        }];
        if (cellNibNames.count == 1) {
            self.cellIdentifier = cellNibNames[ 0 ];
        }
    }
}

- (void)registerHeaderNibs:(NSArray<NSString *> *)headerNibNames
{
    _headerNibNames = headerNibNames;
    if (headerNibNames.count) {
        [headerNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.cc_HeaderXIB && [self.cc_HeaderXIB containsObject:obj]) {
                [self.cc_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forHeaderFooterViewReuseIdentifier:obj];
            } else {
                [self.cc_tableView registerClass:NSClassFromString(obj) forHeaderFooterViewReuseIdentifier:obj];
            }
        }];
        
        if (headerNibNames.count == 1)
            self.headerIdentifier = headerNibNames[ 0 ];
    }
}

- (void)registerFooterNibs:(NSArray<NSString *> *)footerNibNames
{
    _footerNibNames = footerNibNames;
    if (footerNibNames.count) {
        [footerNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.cc_FooterXIB && [self.cc_FooterXIB containsObject:obj]) {
                [self.cc_tableView registerNib:[UINib nibWithNibName:obj bundle:nil] forHeaderFooterViewReuseIdentifier:obj];
            } else {
                [self.cc_tableView registerClass:NSClassFromString(obj) forHeaderFooterViewReuseIdentifier:obj];
            }
        }];
        
        if (footerNibNames.count == 1)
            self.footerIdentifier = footerNibNames[ 0 ];
    }
}


- (NSMutableArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.dataArray.count > 1)
        array = self.dataArray;
    else
        array = self.dataArray;
    
    return array;
}

- (NSArray *)dataHeaderSource
{
    return self.dataHeaderArr;
}

- (NSArray *)dataFooterSource
{
    return self.dataFooterArr;
}

- (NSArray *)sectionIndexTitles
{
    if (!_sectionIndexTitles) {
        NSMutableArray *sectionIndex = [NSMutableArray array];
        if (self.cc_tableView.tableHeaderView && [self.cc_tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
            self.searchBar = (UISearchBar *)self.cc_tableView.tableHeaderView;
            [sectionIndex addObject:UITableViewIndexSearch];
        }
        
        if (self.sectionIndexTitle)
            [sectionIndex addObjectsFromArray:self.sectionIndexTitle];
        else
            [sectionIndex addObjectsFromArray:[UILocalizedIndexedCollation.currentCollation sectionIndexTitles]];
        _sectionIndexTitles = sectionIndex;
    }
    return _sectionIndexTitles;
}

- (UILocalizedIndexedCollation *)theCollation
{
    if (!_theCollation) {
        _theCollation = [UILocalizedIndexedCollation currentCollation];
    }
    return _theCollation;
}

- (NSString *)cc_tableView_identifier
{
    NSString *curIdentifier = [self associatedValueForKey:_cmd];
    if (curIdentifier) return curIdentifier;
    
    NSString *curClassName = NSStringFromClass([self.cc_tableView.viewController class]);
    curIdentifier = [curClassName matchWithRegex:@"(?<=^CC)\\S+(?=VC$)" atIndex:0];
    if (!curIdentifier)
        NSLog(@"className should prefix with 'CC' and suffix with 'VC'");
    
    if (!cc_isNull_NilORNull(curClassName)) {
        [self copyAssociateValue:curClassName withKey:_cmd];
    }
    return curIdentifier;
}

#pragma mark -
#pragma mark :. Block事件
- (void)headerMultipleIdentifier:(CCTableHelperHeaderIdentifierBlock)cb
{
    self.headerIdentifierBlock = cb;
}

- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb
{
    self.cellIdentifierBlock = cb;
}

- (void)fotterMultipleIdentifier:(CCTableHelperFooterIdentifierBlock)cb
{
    self.footerIdentifierBlock = cb;
}

- (void)didSelect:(CCTableHelperDidSelectBlock)cb
{
    self.didSelectBlock = cb;
}

- (void)didDeSelect:(CCTableHelperDidDeSelectBlock)cb
{
    self.didDeSelectBlock = cb;
}

- (void)didEnditing:(CCTableHelperDidEditingBlock)cb
{
    self.didEditingBlock = cb;
}

- (void)didEnditTitle:(CCTableHelperDidEditTitleBlock)cb
{
    self.didEditTileBlock = cb;
}

- (void)didEditingStyle:(CCTableHelperEditingStyle)cb
{
    self.didEditingStyle = cb;
}

- (void)didEditActions:(CCTableHelperDidEditActionsBlock)cb
{
    self.didEditActionsBlock = cb;
}

- (void)didMoveToRowBlock:(CCTableHelperDidMoveToRowBlock)cb
{
    self.didMoveToRowBlock = cb;
}

- (void)cellWillDisplay:(CCTableHelperDidWillDisplayBlock)cb
{
    self.didWillDisplayBlock = cb;
}

- (void)didScrollViewWillBeginDragging:(CCScrollViewWillBeginDragging)block
{
    self.scrollViewBdBlock = block;
}

- (void)headerWillDisplay:(CCTableHelperHeaderBlock)cb
{
    self.didHeaderWillDisplayBlock = cb;
}

- (void)headerTitle:(CCTableHelperTitleHeaderBlock)cb
{
    self.headerTitleBlock = cb;
}

- (void)footerWillDisplay:(CCTableHelperFooterBlock)cb
{
    self.didFooterWillDisplayBlock = cb;
}

- (void)footerTitle:(CCTableHelperTitleFooterBlock)cb
{
    self.footerTitleBlock = cb;
}

- (void)numberOfSections:(CCTableHelperNumberOfSections)cb
{
    self.numberOfSections = cb;
}

- (void)numberOfRowsInSection:(CCTableHelperNumberRows)cb
{
    self.numberRow = cb;
}

- (void)cellViewEventBlock:(CCTableHelperCellBlock)cb
{
    self.cellViewEventsBlock = cb;
}

- (void)didScrollViewDidScroll:(CCScrollViewDidScroll)block
{
    self.scrollViewddBlock = block;
}

- (void)didScrollViewDidEndDecelerating:(CCScrollViewDidEndDecelerating)block
{
    self.scrollViewDidEndDeceleratingBlock = block;
}

- (void)didScrollViewDidEndDragging:(CCScrollViewDidEndDragging)block
{
    self.scrollViewDidEndDraggingBlock = block;
}

- (void)currentModelIndexPath:(CCTableHelperCurrentModelAtIndexPath)cb
{
    self.currentModelAtIndexPath = cb;
}

- (void)didScrollViewDidEndScrolling:(CCTableHelperScrollViewDidEndScrolling)cb
{
    self.scrollViewDidEndScrolling = cb;
}

#pragma mark -
#pragma mark :.TableView DataSource Delegate

#pragma mark :. TableView Gourps Count
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger curNumOfSections = self.dataArray.count;
    if (self.numberOfSections)
        curNumOfSections = self.numberOfSections(tableView, curNumOfSections);
    
    return curNumOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[ section ];
        if (self.numberRow)
            curNumOfRows = self.numberRow(tableView, section, subDataAry);
        else {
            curNumOfRows = subDataAry.count;
        }
    }
    
    return curNumOfRows;
}

#pragma mark :. GourpsView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return [self cc_heightForHeader:tableView section:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self cc_heightForHeader:tableView section:section];
}

- (CGFloat)cc_heightForHeader:(UITableView *)tableView section:(NSInteger)section
{
    CGFloat curHeight = self.titleHeaderHeight;
    if (tableView.cc_autoSizingHeaderFooter) {
        if ([self.cc_tableView.cc_headerHeightCache existsHeightAtSection:section])
            curHeight = [self.cc_tableView.cc_headerHeightCache heightForSection:section];
        else {
            id curModel = [self currentSectionModel:section];
            if (self.dataHeaderArr.count)
                curModel = [self currentHeaderModelAtSection:section];
            
            NSString *curHeaderIdentifier = [self headerIdentifierForRowSection:section model:curModel];
            if (![curHeaderIdentifier isEqualToString:@"CCHeaderFooter"] && curModel) {
                @weakify(self);
                curHeight = [tableView cc_heightForHeaderFooterWithIdentifier:curHeaderIdentifier
                                                               headerORfooter:YES
                                                               cacheBySection:section
                                                                configuration:^(UITableViewHeaderFooterView *headerFooter) {
                    @strongify(self);
                    if ([headerFooter respondsToSelector:@selector(cc_headerFooterWillDisplayWithModel:section:)]) {
                        headerFooter.cc_dataSources = curModel;
                        headerFooter.cc_Section = section;
                        headerFooter.cc_rowCount = [[self.dataArray objectAtIndex:section] count];
                        [headerFooter cc_headerFooterWillDisplayWithModel:curModel section:section];
                    }
                    
                    if (self.didHeaderWillDisplayBlock) {
                        self.didHeaderWillDisplayBlock(headerFooter, section, curModel);
                    }
                }];
            }
        }
    }
    
    if (@available(iOS 11.0, *))
        return curHeight;
    else
        return floor(curHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.headerSection = section;
    id curModel = [self currentSectionModel:section];
    if (self.dataHeaderArr.count)
        curModel = [self currentHeaderModelAtSection:section];
    
    UIView *hederView;
    if (self.headerNibNames.count) {
        NSString *curHeaderIdentifier = [self headerIdentifierForRowSection:section model:curModel];
        UITableViewHeaderFooterView *curHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:curHeaderIdentifier];
        
        CCAssert(curHeader, @"header is nil Identifier ⤭ %@ ⤪", curHeaderIdentifier);
        hederView = curHeader;
    }
    
    return hederView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.headerTitleBlock)
        title = self.headerTitleBlock(tableView, section);
    
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section
{
    id curModel = [self currentSectionModel:section];
    if (self.dataHeaderArr.count)
        curModel = [self currentHeaderModelAtSection:section];
    
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    
    if ([headerFooterView respondsToSelector:@selector(cc_headerFooterWillDisplayWithModel:section:)]) {
        headerFooterView.cc_dataSources = curModel;
        headerFooterView.cc_Section = section;
        headerFooterView.cc_rowCount = [[self.dataArray objectAtIndex:section] count];
        [headerFooterView cc_headerFooterWillDisplayWithModel:curModel section:section];
    }
    
    if (self.didHeaderWillDisplayBlock) {
        self.didHeaderWillDisplayBlock(headerFooterView, section, curModel);
    }
    
    if (self.headerFooterDelegate)
        headerFooterView.viewDelegate = self.headerFooterDelegate;
    
    if (!self.didHeaderWillDisplayBlock && !headerFooterView.backgroundColor)
        headerFooterView.tintColor = tableView.backgroundView ? tableView.backgroundView.backgroundColor : tableView.backgroundColor;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return [self cc_heightForFooter:tableView section:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self cc_heightForFooter:tableView section:section];
}

- (CGFloat)cc_heightForFooter:(UITableView *)tableView section:(NSInteger)section
{
    CGFloat curHeight = self.titleFooterHeight;
    if (tableView.cc_autoSizingHeaderFooter) {
        if ([self.cc_tableView.cc_footerHeightCache existsHeightAtSection:section])
            curHeight = [self.cc_tableView.cc_footerHeightCache heightForSection:section];
        else {
            id curModel = [self currentSectionModel:section];
            if (self.dataFooterArr.count)
                curModel = [self currentFooterModelAtSection:section];
            
            NSString *curFooterIdentifier = [self footerIdentifierForRowSection:section model:curModel];
            if (![curFooterIdentifier isEqualToString:@"CCHeaderFooter"] && curModel) {
                @weakify(self);
                curHeight = [tableView cc_heightForHeaderFooterWithIdentifier:curFooterIdentifier
                                                               headerORfooter:NO
                                                               cacheBySection:section
                                                                configuration:^(UITableViewHeaderFooterView *headerFooter) {
                    @strongify(self);
                    if ([headerFooter respondsToSelector:@selector(cc_headerFooterWillDisplayWithModel:section:)]) {
                        headerFooter.cc_dataSources = curModel;
                        headerFooter.cc_Section = section;
                        [headerFooter cc_headerFooterWillDisplayWithModel:curModel section:section];
                    }
                    
                    if (self.didFooterWillDisplayBlock) {
                        self.didFooterWillDisplayBlock(headerFooter, section, curModel);
                    }
                }];
            }
        }
    }
    
    if (@available(iOS 11.0, *))
        return curHeight;
    else
        return floor(curHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    self.footerSection = section;
    
    id curModel = [self currentSectionModel:section];
    if (self.dataFooterArr.count)
        curModel = [self currentFooterModelAtSection:section];
    
    UIView *footerView;
    if (self.footerNibNames.count) {
        NSString *curFooterIdentifier = [self footerIdentifierForRowSection:section model:curModel];
        UITableViewHeaderFooterView *curFooter = [tableView dequeueReusableHeaderFooterViewWithIdentifier:curFooterIdentifier];
        
        CCAssert(curFooter, @"header is nil Identifier ⤭ %@ ⤪", curFooterIdentifier);
        
        //        [curFooter cc_headerFooterWillDisplayWithModel:curModel section:section];
        footerView = curFooter;
    }
    
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.footerTitleBlock)
        title = self.footerTitleBlock(tableView, section);
    
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    id curModel = [self currentSectionModel:section];
    if (self.dataFooterArr.count)
        curModel = [self currentFooterModelAtSection:section];
    
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    
    if ([headerFooterView respondsToSelector:@selector(cc_headerFooterWillDisplayWithModel:section:)]) {
        headerFooterView.cc_dataSources = curModel;
        headerFooterView.cc_Section = section;
        [headerFooterView cc_headerFooterWillDisplayWithModel:curModel section:section];
    }
    
    if (self.didFooterWillDisplayBlock) {
        self.didFooterWillDisplayBlock(headerFooterView, section, curModel);
    }
    
    if (self.headerFooterDelegate)
        headerFooterView.viewDelegate = self.headerFooterDelegate;
    
    if (!self.didFooterWillDisplayBlock && !headerFooterView.backgroundColor)
        headerFooterView.tintColor = tableView.backgroundView ? tableView.backgroundView.backgroundColor : tableView.backgroundColor;
}

#pragma mark :. 侧边
/**
 *  @author CC, 16-07-23
 *
 *  @brief 侧边栏字母
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionArr = nil;
    if (self.isSection) {
        sectionArr = self.sectionIndexTitles;
    }
    return sectionArr;
}

/**
 *  @author CC, 16-07-23
 *
 *  @brief 侧边字母点击
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger indexs = self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? index : index - 1;
    if ([title isEqualToString:@"{search}"]) {
        [tableView scrollRectToVisible:_searchBar.frame animated:NO];
        indexs = -1;
    }
    
    return indexs;
}

#pragma mark :. delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (self.didEditingStyle)
        style = self.didEditingStyle(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    else if (self.didEditActionsBlock && !tableView.allowsMultipleSelectionDuringEditing)
        style = UITableViewCellEditingStyleDelete;
    
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didEditingBlock)
        self.didEditingBlock(tableView, editingStyle, indexPath, [self currentModelAtIndexPath:indexPath]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    if (self.didEditTileBlock)
        title = self.didEditTileBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    
    return title;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ary = [NSArray array];
    if (self.didEditActionsBlock)
        ary = self.didEditActionsBlock(tableView, indexPath, [self currentModelAtIndexPath:indexPath]);
    
    return ary;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cc_heightForCell:tableView IndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cc_heightForCell:tableView IndexPath:indexPath];
}

- (CGFloat)cc_heightForCell:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
{
    CGFloat curHeight = 44;
    if (tableView.cc_autoSizingCell) {
        if ([self.cc_tableView.cc_indexPathHeightCache existsHeightAtIndexPath:indexPath])
            curHeight = [self.cc_tableView.cc_indexPathHeightCache heightForIndexPath:indexPath];
        else {
            id curModel = [self currentModelAtIndexPath:indexPath];
            NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
            @weakify(self);
            curHeight = [tableView cc_heightForCellWithIdentifier:curCellIdentifier
                                                 cacheByIndexPath:indexPath
                                                    configuration:^(UITableViewCell *cell) {
                @strongify(self);
                if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
                    cell.cc_dataSources = curModel;
                    cell.cc_indexPath = indexPath;
                    [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
                }
                
                if (self.didWillDisplayBlock) {
                    self.didWillDisplayBlock(cell, indexPath, curModel, NO);
                }
            }];
        }
    } else {
        curHeight = tableView.rowHeight;
    }
    return curHeight;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isCanMoveRow;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.didMoveToRowBlock) {
        id sourceModel = [self currentModelAtIndexPath:sourceIndexPath];
        id destinationModel = [self currentModelAtIndexPath:destinationIndexPath];
        self.didMoveToRowBlock(tableView, sourceIndexPath, sourceModel, destinationIndexPath, destinationModel);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id curModel = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    UITableViewCell *curCell = [tableView dequeueReusableCellWithIdentifier:curCellIdentifier forIndexPath:indexPath];
    
    CCAssert(curCell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);
    
    if (self.cellDelegate)
        curCell.viewDelegate = self.cellDelegate;
    
    if (self.cellViewEventsBlock)
        curCell.viewEventsBlock = self.cellViewEventsBlock;
    
    return curCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.paddedSeparator) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
    id curModel = [self currentModelAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
        cell.cc_dataSources = curModel;
        cell.cc_indexPath = indexPath;
        [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
    }
    
    if (self.didWillDisplayBlock) {
        self.didWillDisplayBlock(cell, indexPath, curModel, YES);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cc_indexPath = indexPath;
    
    if (self.isAntiHurry) {
        self.timeInterval = self.timeInterval == 0 ? defaultInterval : self.timeInterval;
        if (self.isIgnoreEvent) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        } else if (self.timeInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
        
        self.isIgnoreEvent = YES;
    }
    if (self.didSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)resetState
{
    self.isIgnoreEvent = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cc_indexPath = indexPath;
    if (self.didDeSelectBlock) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didDeSelectBlock(tableView, indexPath, curModel);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollViewBdBlock)
        self.scrollViewBdBlock(scrollView);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewddBlock)
        self.scrollViewddBlock(scrollView);
    
    if (self.isHover) {
        CGFloat sectionHeaderHeight = 40;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView afterDelay:0.5];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:scrollView];
    if (self.scrollViewDidEndScrolling && scrollView)
        self.scrollViewDidEndScrolling(scrollView);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    !self.scrollViewDidEndDeceleratingBlock ?: self.scrollViewDidEndDeceleratingBlock(scrollView);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    !self.scrollViewDidEndDraggingBlock ?: self.scrollViewDidEndDraggingBlock(scrollView, decelerate);
}

#pragma mark :. handle

//section 头部,为了IOS6的美化
- (UIView *)tableViewSectionView:(UITableView *)tableView section:(NSInteger)section
{
    UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.cc_tableView.bounds), self.titleHeaderHeight)];
    UIColor *color = tableView.backgroundColor;
    if (!color) {
        color = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
    }
    customHeaderView.backgroundColor = color;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0, CGRectGetWidth(customHeaderView.bounds) - 15.0f, self.titleHeaderHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    headerLabel.textColor = [UIColor darkGrayColor];
    [customHeaderView addSubview:headerLabel];
    
    if (self.isSection) {
        BOOL showSection = NO;
        showSection = [tableView numberOfRowsInSection:section] != 0;
        headerLabel.text = (showSection) ? (self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? [_sectionIndexTitles objectAtIndex:section] : [_sectionIndexTitles objectAtIndex:section + 1]) : nil;
    }
    return customHeaderView;
}

#pragma mark -
#pragma mark :. ModelHandler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.cellIdentifierBlock) {
        curCellIdentifier = self.cellIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.cellIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentSectionModel:(NSInteger)section
{
    id currentModel = nil;
    if (section < self.dataArray.count) {
        NSArray *arr = [self.dataArray objectAtIndex:section];
        if (arr.count)
            currentModel = [arr objectAtIndex:0];
    }
    return currentModel;
}

#pragma mark :. header
- (NSString *)headerIdentifierForRowSection:(NSInteger)section model:(id)cModel
{
    NSString *curHeaderIdentifier = nil;
    if (self.headerIdentifierBlock) {
        curHeaderIdentifier = self.headerIdentifierBlock(section, cModel);
    } else {
        curHeaderIdentifier = self.headerIdentifier;
    }
    return curHeaderIdentifier;
}

- (id)currentHeaderModel
{
    return [self currentHeaderModelAtSection:self.headerSection];
}

- (id)currentHeaderModelAtSection:(NSInteger)section
{
    id currentModel = nil;
    if (section < self.dataHeaderArr.count)
        currentModel = [self.dataHeaderArr objectAtIndex:section];
    
    return currentModel;
}

#pragma mark :. cell
- (id)currentModel
{
    return [self currentModelAtIndexPath:self.cc_indexPath];
}

- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentModelAtIndexPath) {
        return self.currentModelAtIndexPath(self.dataArray, cIndexPath);
    } else if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[ cIndexPath.section ];
        if (subDataAry.count > cIndexPath.row) {
            id curModel = subDataAry[ cIndexPath.row ];
            return curModel;
        }
    }
    return nil;
}

#pragma mark :. footer
- (NSString *)footerIdentifierForRowSection:(NSInteger)section model:(id)cModel
{
    NSString *curFooterIdentifier = nil;
    if (self.footerIdentifierBlock) {
        curFooterIdentifier = self.footerIdentifierBlock(section, cModel);
    } else {
        curFooterIdentifier = self.footerIdentifier;
    }
    return curFooterIdentifier;
}


- (id)currentFooterModel
{
    return [self currentFooterModelAtSection:self.footerSection];
}

- (id)currentFooterModelAtSection:(NSInteger)section
{
    id currentModel = nil;
    if (section < self.dataFooterArr.count)
        currentModel = [self.dataFooterArr objectAtIndex:section];
    
    return currentModel;
}

#pragma mark -
#pragma mark :. data
- (void)cc_clearData
{
    [self.dataArray removeAllObjects];
    [self.cc_tableView reloadData];
}


- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
{
    [self.cc_tableView.cc_indexPathHeightCache invalidateAllHeightCache];
    [self.cc_tableView.cc_headerHeightCache invalidateAllHeightCache];
    [self.cc_tableView.cc_footerHeightCache invalidateAllHeightCache];
    [self.dataArray removeAllObjects];
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [self cc_makeUpDataAryForSection:i];
    
    for (int idx = 0; idx < self.dataArray.count; idx++) {
        NSMutableArray *subAry = self.dataArray[ idx ];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:idx];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_tableView reloadData];
}

- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightAtSection:cSection];
    
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

- (void)cc_addGroupDataAry:(NSArray *)newDataAry
{
    if (newDataAry.count == 0) return;
    [self.dataArray addObjectsFromArray:newDataAry];
    [self.cc_tableView reloadData];
}

- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightLast:cSection];
    
    NSRange range = NSMakeRange(cSection == -1 ? 0 : cSection, newDataAry.count);
    [self.dataArray insertObjects:newDataAry atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    [self.cc_tableView reloadData];
}

- (void)cc_insertMultiplGroupDataAry:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightLast:cSection];
    
    NSMutableArray *idxArray = [NSMutableArray array];
    if (cSection < 0) {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:0];
            [idxArray addObject:@(i)];
        }
    } else {
        for (NSInteger i = 0; i < newDataAry.count; i++) {
            [self.dataArray insertObject:[NSMutableArray array] atIndex:cSection + i];
            [idxArray addObject:@(cSection + i)];
        }
    }
    
    for (NSInteger i = 0; i < idxArray.count; i++) {
        NSInteger idx = [[idxArray objectAtIndex:i] integerValue];
        NSMutableArray *subAry = self.dataArray[ idx ];
        if (subAry.count) [subAry removeAllObjects];
        id data = [newDataAry objectAtIndex:i];
        if ([data isKindOfClass:[NSArray class]]) {
            [subAry addObjectsFromArray:data];
        } else {
            [subAry addObject:data];
        }
    }
    [self.cc_tableView reloadData];
}

- (void)cc_deleteGroupData:(NSInteger)cSection
{
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightLast:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightLast:cSection];
    
    [self.dataArray removeObjectAtIndex:cSection];
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView deleteSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

#pragma mark -
#pragma mark :. Plain

- (void)cc_resetHeaderAry:(NSArray *)newHeaderAry
{
    self.dataHeaderArr = newHeaderAry;
}

- (void)cc_resetFooterAry:(NSArray *)newFooterAry
{
    self.dataFooterArr = newFooterAry;
}

- (void)cc_resetDataAry:(NSArray *)newDataAry
{
    self.dataArray = nil;
    [self.cc_tableView.cc_indexPathHeightCache invalidateAllHeightCache];
    [self.cc_tableView.cc_headerHeightCache invalidateAllHeightCache];
    [self.cc_tableView.cc_footerHeightCache invalidateAllHeightCache];
    [self cc_resetDataAry:newDataAry forSection:0];
}

- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightAtSection:cSection];
    
    [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count) [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.cc_tableView reloadData];
}


- (void)cc_reloadDataAry:(NSArray *)newDataAry
{
    self.dataArray = nil;
    [self cc_reloadDataAry:newDataAry forSection:0];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_headerHeightCache invalidateHeightAtSection:cSection];
    [self.cc_tableView.cc_footerHeightCache invalidateHeightAtSection:cSection];
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];
    
    [self.cc_tableView beginUpdates];
    if (curIndexSet) {
        [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.cc_tableView reloadSections:[NSIndexSet indexSetWithIndex:cSection] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.cc_tableView endUpdates];
}

- (void)cc_addDataAry:(NSArray *)newDataAry
{
    [self cc_addDataAry:newDataAry forSection:0];
}

- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightLast:cSection];
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry;
    if (cSection < 0) {
        subAry = self.dataArray[ 0 ];
    } else
        subAry = self.dataArray[ cSection ];
    
    if (curIndexSet) {
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_tableView beginUpdates];
        [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationFade];
        [self.cc_tableView endUpdates];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
        [newDataAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count + idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_tableView beginUpdates];
        [self.cc_tableView insertRowsAtIndexPaths:curIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.cc_tableView endUpdates];
    }
}

- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
{
    if (!cModel) return;
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtIndexPath:cIndexPath];
    
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cIndexPath.section];
    NSMutableArray *subAry = self.dataArray[ cIndexPath.section ];
    if (subAry.count < cIndexPath.row) return;
    [subAry insertObject:cModel atIndex:cIndexPath.row];
    
    [self.cc_tableView beginUpdates];
    if (curIndexSet) {
        [self.cc_tableView insertSections:curIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.cc_tableView insertRowsAtIndexPaths:@[ cIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.cc_tableView endUpdates];
}

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath
{
    [self cc_deleteDataAtIndexs:@[ cIndexPath ]];
}

- (void)cc_deleteDataAtIndexs:(NSArray *)indexPaths
{
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSArray *arr in self.dataArray) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArray addObjectsFromArray:arr];
        [delArray addObject:sectionArray];
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (self.dataArray.count <= indexPath.section) continue;
        NSMutableArray *subAry = self.dataArray[ indexPath.section ];
        if (subAry.count <= indexPath.row) continue;
        
        [[delArray objectAtIndex:indexPath.section] removeObject:[subAry objectAtIndex:indexPath.row]];
        [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtIndexPath:indexPath];
    }
    self.dataArray = delArray;
    
    [self.cc_tableView beginUpdates];
    [self.cc_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.cc_tableView endUpdates];
}

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
{
    [self cc_replaceDataAtIndex:model IndexPath:cIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
             withRowAnimation:(UITableViewRowAnimation)animated
{
    [self.cc_tableView.cc_indexPathHeightCache invalidateHeightAtIndexPath:cIndexPath];
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[ cIndexPath.section ];
        if (subDataAry.count > cIndexPath.row) {
            [subDataAry replaceObjectAtIndex:cIndexPath.row withObject:model];
            [self.cc_tableView reloadRowsAtIndexPaths:@[ cIndexPath ] withRowAnimation:animated];
        }
    }
}

- (NSIndexSet *)cc_makeUpDataAryForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.dataArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.dataArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.dataArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.dataArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}


- (NSMutableArray<NSMutableArray *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

@end
