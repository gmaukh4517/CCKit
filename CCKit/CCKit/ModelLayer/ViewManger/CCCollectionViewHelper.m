//
//  CCCollectionViewHelper.m
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

#import "CCCollectionViewHelper.h"
#import "CCConfig.h"
#import "UICollectionReusableView+CCAdd.h"
#import "UICollectionView+CCAdd.h"
#import "UICollectionViewCell+CCAdd.h"
#import "UIView+CCTransfer.h"
#import "UIView+Method.h"
#import "UIViewController+CCAdd.h"
#import "NSObject+CCAdd.h"
#import "NSString+CCAdd.h"
#define CCAssert(condition, format, ...)                                                       \
do {                                                                                       \
_Pragma("clang diagnostic push")                                                       \
_Pragma("clang diagnostic ignored \"-Wformat-extra-args\"") if ((condition) == NO) \
NSLog(format, ##__VA_ARGS__);                                                  \
_Pragma("clang diagnostic pop")                                                        \
} while (0);

@interface CCCollectionViewHelper ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *headerArray;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *footerArray;

@property (nonatomic, copy) CCCollectionHelperHeaderView headerView;
@property (nonatomic, copy) CCCollectionHelperFooterView footerView;

@property (nonatomic, copy) CCCollectionHelperCellIdentifierBlock cellIdentifierBlock;
@property (nonatomic, copy) CCCollectionHelperHeaderIdentifierBlock headerIdentifierBlock;
@property (nonatomic, copy) CCCollectionHelperFooterIdentifierBlock footerIdentifierBlock;


@property (nonatomic, copy) CCCollectionHelperNumberOfItemsInSection numberOfItemsInSection;

@property (nonatomic, copy) CCCollectionHelperCellForItemAtIndexPath cellForItemAtIndexPath;
@property (nonatomic, copy) CCCollectionHelperHeaderForItemAtIndexPath headerForItemAtIndexPath;
@property (nonatomic, copy) CCCollectionHelperFooterForItemAtIndexPath footerForItemAtIndexPath;

@property (nonatomic, copy) CCCollectionHelperCellForItemSize sizeForItemAtIndexPath;
@property (nonatomic, copy) CCCollectionHelperReferenceHeaderSize referenceHeaderSize;
@property (nonatomic, copy) CCCollectionHelperReferenceFooterSize referenceFooterSize;


@property (nonatomic, copy) CCCollectionHelperDidSelectItemAtIndexPath didSelectItemAtIndexPath;

@property (nonatomic, copy) CCCollectionHelperCurrentModelAtIndexPath currentModelAtIndexPath;
@property (nonatomic, copy) CCCollectionHelperCurrentHeaderModelAtIndexPath currentHeaderModelAtIndexPath;
@property (nonatomic, copy) CCCollectionHelperCurrentFooterModelAtIndexPath currentFooterModelAtIndexPath;

@property (nonatomic, copy) CCCollectionHelperCellItemMargin cellItemMargin;
@property (nonatomic, copy) CCCollectionHelperMinimumInteritemSpacingForSection minimumInteritemSpacingForSection;

@property (nonatomic, copy) CCScrollViewDidScroll scrollViewDidScroll;

@end

@implementation CCCollectionViewHelper

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames.count > 0) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (!self.cc_CellXIB && [[self.cc_CellXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forCellWithReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forCellWithReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1)
            self.cellIdentifier = cellNibNames[ 0 ];
    }
}

- (void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (self.cc_CellHeaderXIB && [[self.cc_CellHeaderXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1) {
            self.headerIdentifier = cellNibNames[ 0 ];
        }
    }
}

- (void)registerNibFooters:(NSArray<NSString *> *)cellNibNames
{
    if (cellNibNames) {
        [cellNibNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([[self.cc_CellFooterXIB objectAtIndex:idx] boolValue])
                [self.cc_CollectionView registerNib:[UINib nibWithNibName:obj bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
            else
                [self.cc_CollectionView registerClass:NSClassFromString(obj) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:obj];
        }];

        if (cellNibNames.count == 1)
            self.footerIdentifier = cellNibNames[ 0 ];
    }
}

- (NSMutableArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.dataArray.count > 1)
        array = self.dataArray;
    else
        array = self.dataArray.firstObject;

    return array;
}

#pragma mark--UICollectionViewDelegateFlowLayout
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize = self.titleHeaderSize;
    if (self.referenceHeaderSize) {
        id curModel = [self currentHeaderModelAtIndexPath:indexPath];
        contentSize = self.referenceHeaderSize(collectionView, collectionViewLayout, section, curModel);
    } else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))) {
        if (iOS9Later)
            contentSize = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].LayoutSizeFittingSize;
    }
    return contentSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    CGSize contentSize = self.titleFooterSize;
    if (self.referenceFooterSize) {
        id curModel = [self currentFooterModelAtIndexPath:indexPath];
        contentSize = self.referenceFooterSize(collectionView, collectionViewLayout, section, curModel);
    } else if (CGSizeEqualToSize(contentSize, CGSizeMake(0, 0))) {
        if (iOS9Later)
            contentSize = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath].LayoutSizeFittingSize;
    }
    return contentSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize curSize = CGSizeMake(SCREEN_WIDTH, 0);
    if (self.cc_autoSizingCell) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
        @weakify(self);
        curSize = [collectionView cc_SizeForCellWithIdentifier:curCellIdentifier
                                              cacheByIndexPath:indexPath
                                                 configuration:^(id cell) {
                                                     @strongify(self);
                                                     if (self.cellForItemAtIndexPath) {
                                                         self.cellForItemAtIndexPath(cell, indexPath, curModel, NO);
                                                     } else if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
                                                         [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
                                                     }
                                                 }];
    } else if (self.sizeForItemAtIndexPath) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        curSize = self.sizeForItemAtIndexPath(collectionView, collectionViewLayout, indexPath, curModel);
    }
    return curSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (self.cellItemMargin) {
        id curModel = [self currentSectionModel:section];
        edgeInsets = self.cellItemMargin(collectionView, collectionViewLayout, section, curModel);
    }

    return edgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat minimum = 0;
    if (self.minimumInteritemSpacingForSection) {
        id curModel = [self currentSectionModel:section];
        minimum = self.minimumInteritemSpacingForSection(collectionView, collectionViewLayout, section, curModel);
    }
    return minimum;
}


#pragma mark--UICollectionViewDelegate && UICollectionViewDataSourse

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger curNumOfSections = self.dataArray.count;
    return curNumOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger curNumOfRows = 0;
    if (self.dataArray.count > section) {
        NSMutableArray *subDataAry = self.dataArray[ section ];
        if (self.numberOfItemsInSection)
            curNumOfRows = self.numberOfItemsInSection(collectionView, section, subDataAry);
        else
            curNumOfRows = subDataAry.count;
    }
    return curNumOfRows;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    if (kind == UICollectionElementKindSectionHeader) {
        id curModel = [self currentHeaderModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self headerIdentifierForRowAtIndexPath:indexPath model:curModel];
        if (self.headerView)
            reusableView = self.headerView(collectionView, kind, curCellIdentifier, indexPath, curModel);

        if (!reusableView && !self.headerView)
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];

        if (self.reusableDelegate && !reusableView.viewDelegate)
            reusableView.viewDelegate = self.reusableDelegate;

        if (self.headerForItemAtIndexPath) {
            self.headerForItemAtIndexPath(reusableView, indexPath, curModel, YES);
        } else if ([reusableView respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
            [reusableView cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
        id curModel = [self currentFooterModelAtIndexPath:indexPath];
        NSString *curCellIdentifier = [self footerIdentifierForRowAtIndexPath:indexPath model:curModel];
        if (self.footerView)
            reusableView = self.footerView(collectionView, kind, curCellIdentifier, indexPath, curModel);

        if (!reusableView && !self.footerView)
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:curCellIdentifier forIndexPath:indexPath];

        if (self.reusableDelegate && !reusableView.viewDelegate)
            reusableView.viewDelegate = self.reusableDelegate;

        if (self.footerForItemAtIndexPath) {
            self.footerForItemAtIndexPath(reusableView, indexPath, curModel, YES);
        } else if ([reusableView respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
            [reusableView cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
        }
    }
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *curCell = nil;
    id curModel = [self currentModelAtIndexPath:indexPath];
    NSString *curCellIdentifier = [self cellIdentifierForRowAtIndexPath:indexPath model:curModel];
    curCell = [collectionView dequeueReusableCellWithReuseIdentifier:curCellIdentifier forIndexPath:indexPath];
    CCAssert(curCell, @"cell is nil Identifier ⤭ %@ ⤪", curCellIdentifier);
    if (self.cellDelegate)
        curCell.viewDelegate = self.cellDelegate;

    return curCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    id curModel = [self currentModelAtIndexPath:indexPath];
    if (self.cellForItemAtIndexPath) {
        self.cellForItemAtIndexPath(cell, indexPath, curModel, YES);
    } else if ([cell respondsToSelector:@selector(cc_cellWillDisplayWithModel:indexPath:)]) {
        [cell cc_cellWillDisplayWithModel:curModel indexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.cc_indexPath = indexPath;
    if (self.didSelectItemAtIndexPath) {
        id curModel = [self currentModelAtIndexPath:indexPath];
        self.didSelectItemAtIndexPath(collectionView, indexPath, curModel);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(scrollView);
    }
}

#pragma mark -
#pragma mark :. Handler

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
    NSArray *arr = [self.dataArray objectAtIndex:section];
    if (arr.count)
        currentModel = [arr objectAtIndex:0];

    return currentModel;
}

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

#pragma mark :. Group
- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
{
    self.dataArray = nil;
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
    [self.cc_CollectionView reloadData];
}

- (void)cc_addGroupDataAry:(NSArray *)newDataAry
{
    [self.dataArray addObject:[NSMutableArray arrayWithArray:newDataAry]];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection
{
    [self.dataArray insertObject:[NSMutableArray arrayWithArray:newDataAry] atIndex:cSection == -1 ? 0 : cSection];
    [self.cc_CollectionView reloadData];
}

- (void)cc_insertMultiplGroupDataAry:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection
{
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
    [self.cc_CollectionView reloadData];
}

#pragma mark :.

- (void)cc_resetDataAry:(NSArray *)newDataAry
{
    self.dataArray = nil;
    [self cc_resetDataAry:newDataAry forSection:0];
}

- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count) [subAry removeAllObjects];
    if (newDataAry.count) {
        [subAry addObjectsFromArray:newDataAry];
    }
    [self.cc_CollectionView reloadData];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry
{
    [self cc_reloadDataAry:newDataAry forSection:0];
}

- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;

    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry = self.dataArray[ cSection ];
    if (subAry.count) [subAry removeAllObjects];
    [subAry addObjectsFromArray:newDataAry];

    if (curIndexSet) {
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        [self.cc_CollectionView reloadSections:[NSIndexSet indexSetWithIndex:cSection]];
    }
}

- (void)cc_addDataAry:(NSArray *)newDataAry
{
    [self cc_addDataAry:newDataAry forSection:0];
}

- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection
{
    if (newDataAry.count == 0) return;

    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cSection];
    NSMutableArray *subAry;
    if (cSection < 0) {
        subAry = self.dataArray[ 0 ];
    } else
        subAry = self.dataArray[ cSection ];

    if (curIndexSet) {
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        __block NSMutableArray *curIndexPaths = [NSMutableArray arrayWithCapacity:newDataAry.count];
        [newDataAry enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [curIndexPaths addObject:[NSIndexPath indexPathForRow:subAry.count + idx inSection:cSection]];
        }];
        [subAry addObjectsFromArray:newDataAry];
        [self.cc_CollectionView insertItemsAtIndexPaths:curIndexPaths];
    }
}

- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;
{
    NSIndexSet *curIndexSet = [self cc_makeUpDataAryForSection:cIndexPath.section];
    NSMutableArray *subAry = self.dataArray[ cIndexPath.section ];
    if (subAry.count < cIndexPath.row) return;
    [subAry insertObject:cModel atIndex:cIndexPath.row];
    if (curIndexSet) {
        [self.cc_CollectionView insertSections:curIndexSet];
    } else {
        [subAry insertObject:cModel atIndex:cIndexPath.row];
        [self.cc_CollectionView insertItemsAtIndexPaths:@[ cIndexPath ]];
    }
}

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath
{
    if (self.dataArray.count <= cIndexPath.section) return;
    NSMutableArray *subAry = self.dataArray[ cIndexPath.section ];
    if (subAry.count <= cIndexPath.row) return;

    [subAry removeObjectAtIndex:cIndexPath.row];
    [self.cc_CollectionView insertItemsAtIndexPaths:@[ cIndexPath ]];
}

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
{
    if (self.dataArray.count > cIndexPath.section) {
        NSMutableArray *subDataAry = self.dataArray[ cIndexPath.section ];
        if (subDataAry.count > cIndexPath.row) {
            [subDataAry replaceObjectAtIndex:cIndexPath.row withObject:model];
            [self.cc_CollectionView reloadData];
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

#pragma mark -
#pragma mark :. Header

- (void)cc_reloadHeaderArr:(NSArray *)newDataAry
{
    self.headerArray = [NSMutableArray arrayWithArray:newDataAry];
}

- (void)cc_addHeaderArr:(NSArray *)newDataAry
{
    [self.headerArray addObjectsFromArray:newDataAry];
}

- (void)cc_insertHeaderArr:(NSArray *)newDataAry
                forSection:(NSInteger)cSection
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [set addIndex:cSection + i];

    [self.headerArray insertObjects:newDataAry atIndexes:set];
}

- (void)cc_removerHeaderData:(NSInteger)cSection
{
    [self.headerArray removeObjectAtIndex:cSection];
}

- (NSString *)headerIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.headerIdentifierBlock) {
        curCellIdentifier = self.headerIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.headerIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentHeaderModelAtIndexPath) {
        return self.currentHeaderModelAtIndexPath(self.headerArray, cIndexPath);
    } else if (self.headerArray.count > cIndexPath.section) {
        id curModel = self.headerArray[ cIndexPath.section ];
        return curModel;
    }
    return nil;
}

- (NSMutableArray<NSMutableArray *> *)headerArray
{
    if (!_headerArray) {
        _headerArray = [NSMutableArray new];
    }
    return _headerArray;
}

#pragma mark -
#pragma mark :. Footer

- (void)cc_reloadFooterArr:(NSArray *)newDataAry
{
    self.footerArray = [NSMutableArray arrayWithArray:newDataAry];
}

- (void)cc_addFooterArr:(NSArray *)newDataAry
{
    [self.footerArray addObjectsFromArray:newDataAry];
}

- (void)cc_insertFooterArr:(NSArray *)newDataAry
                forSection:(NSInteger)cSection
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < newDataAry.count; i++)
        [set addIndex:cSection + i];

    [self.footerArray insertObjects:newDataAry atIndexes:set];
}

- (void)cc_removerFooterData:(NSInteger)cSection
{
    [self.footerArray removeObjectAtIndex:cSection];
}

- (NSString *)footerIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel
{
    NSString *curCellIdentifier = nil;
    if (self.footerIdentifierBlock) {
        curCellIdentifier = self.footerIdentifierBlock(cIndexPath, cModel);
    } else {
        curCellIdentifier = self.footerIdentifier;
    }
    return curCellIdentifier;
}

- (id)currentFooterModelAtIndexPath:(NSIndexPath *)cIndexPath
{
    if (self.currentFooterModelAtIndexPath) {
        return self.currentFooterModelAtIndexPath(self.footerArray, cIndexPath);
    } else if (self.footerArray.count > cIndexPath.section) {
        id curModel = self.footerArray[ cIndexPath.section ];
        return curModel;
    }
    return nil;
}

- (NSIndexSet *)cc_makeUpFooterArrForSection:(NSInteger)cSection
{
    NSMutableIndexSet *curIndexSet = nil;
    if (self.footerArray.count <= cSection) {
        curIndexSet = [NSMutableIndexSet indexSet];
        for (NSInteger idx = 0; idx < (cSection - self.footerArray.count + 1); idx++) {
            NSMutableArray *subAry = [NSMutableArray array];
            if (cSection < 0) {
                [self.footerArray insertObject:subAry atIndex:0];
                [curIndexSet addIndex:0];
                break;
            } else {
                [self.footerArray addObject:subAry];
                [curIndexSet addIndex:cSection - idx];
            }
        }
    }
    return curIndexSet;
}


- (NSMutableArray<NSMutableArray *> *)footerArray
{
    if (!_footerArray) {
        _footerArray = [NSMutableArray new];
    }
    return _footerArray;
}

#pragma mark -
#pragma mark :. getset

- (NSString *)cellIdentifier
{
    if (_cellIdentifier == nil) {
        NSString *curVCIdentifier =  [self cc_collectionView_identifier];
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"CC%@Cell", curVCIdentifier];
            _cellIdentifier = curCellIdentifier;
        }
    }
    return _cellIdentifier;
}

- (NSString *)headerIdentifier
{
    if (_headerIdentifier == nil) {
        NSString *curVCIdentifier =  [self cc_collectionView_identifier];
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"CC%@Header", curVCIdentifier];
            _headerIdentifier = curCellIdentifier;
        }
    }
    return _headerIdentifier;
}

- (NSString *)footerIdentifier
{
    if (_footerIdentifier == nil) {
        NSString *curVCIdentifier = [self cc_collectionView_identifier];
        if (curVCIdentifier) {
            NSString *curCellIdentifier = [NSString stringWithFormat:@"CC%@Header", curVCIdentifier];
            _footerIdentifier = curCellIdentifier;
        }
    }
    return _footerIdentifier;
}

-(NSString *)cc_collectionView_identifier
{
    NSString *curIdentifier = [self associatedValueForKey:_cmd];
    if (curIdentifier) return curIdentifier;

    NSString *curClassName = NSStringFromClass([self.cc_CollectionView.viewController class]);
    curIdentifier = [curClassName matchWithRegex:@"(?<=^CC)\\S+(?=VC$)" atIndex:0];
    if (!curIdentifier)
        NSLog(@"className should prefix with 'CC' and suffix with 'VC'");

    if (!cc_isNull_NilORNull(curClassName)) {
        [self copyAssociateValue:curClassName withKey:_cmd];
    }
    return curIdentifier;
}

- (void)cellMultipleIdentifier:(CCCollectionHelperCellIdentifierBlock)block
{
    self.cellIdentifierBlock = block;
}

- (void)headerMultipleIdentifier:(CCCollectionHelperHeaderIdentifierBlock)block
{
    self.headerIdentifierBlock = block;
}

- (void)footerMultipleIdentifier:(CCCollectionHelperFooterIdentifierBlock)block
{
    self.footerIdentifierBlock = block;
}

- (void)currentModelIndexPath:(CCCollectionHelperCurrentModelAtIndexPath)block
{
    self.currentModelAtIndexPath = block;
}

- (void)didNumberOfItemsInSection:(CCCollectionHelperNumberOfItemsInSection)block
{
    self.numberOfItemsInSection = block;
}

- (void)didHeaderView:(CCCollectionHelperHeaderView)block
{
    self.headerView = block;
}

- (void)didCurrentHeaderModel:(CCCollectionHelperCurrentHeaderModelAtIndexPath)block
{
    self.currentHeaderModelAtIndexPath = block;
}

- (void)didFooterView:(CCCollectionHelperFooterView)block
{
    self.footerView = block;
}

- (void)didCurrentFooterModel:(CCCollectionHelperCurrentFooterModelAtIndexPath)block
{
    self.currentFooterModelAtIndexPath = block;
}

- (void)didCellForItemAtIndexPath:(CCCollectionHelperCellForItemAtIndexPath)block
{
    self.cellForItemAtIndexPath = block;
}

- (void)didHeaderForItemAtIndexPah:(CCCollectionHelperHeaderForItemAtIndexPath)block
{
    self.headerForItemAtIndexPath = block;
}

- (void)didFooterForItemAtIndexPah:(CCCollectionHelperFooterForItemAtIndexPath)block
{
    self.footerForItemAtIndexPath = block;
}

- (void)didSizeForItemAtIndexPath:(CCCollectionHelperCellForItemSize)block
{
    self.sizeForItemAtIndexPath = block;
}

- (void)didReferenceHeaderSize:(CCCollectionHelperReferenceHeaderSize)block
{
    self.referenceHeaderSize = block;
}

- (void)didReferenceFooterSize:(CCCollectionHelperReferenceFooterSize)block
{
    self.referenceFooterSize = block;
}

- (void)didSelectItemAtIndexPath:(CCCollectionHelperDidSelectItemAtIndexPath)block
{
    self.didSelectItemAtIndexPath = block;
}

- (void)didCellItemMargin:(CCCollectionHelperCellItemMargin)block
{
    self.cellItemMargin = block;
}

- (void)didMinimumInteritemSpacingForSection:(CCCollectionHelperMinimumInteritemSpacingForSection)blcok
{
    self.minimumInteritemSpacingForSection = blcok;
}

- (void)didScrollViewDidScroll:(CCScrollViewDidScroll)block
{
    self.scrollViewDidScroll = block;
}

@end


@implementation CCCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //UICollectionViewLayoutAttributes：我称它为collectionView中的item（包括cell和header、footer这些）的《结构信息》
    //截取到父类所返回的数组（里面放的是当前屏幕所能展示的item的结构信息），并转化成不可变数组
    NSMutableArray *superArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    //创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
    NSMutableIndexSet *noneHeaderSections = [NSMutableIndexSet indexSet];
    //遍历superArray，得到一个当前屏幕中所有的section数组
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [noneHeaderSections addIndex:attributes.indexPath.section];
        }
    }

    //遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
    //正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前的元素是一个header，将header所在的section从数组中移除
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [noneHeaderSections removeIndex:attributes.indexPath.section];
        }
    }

    //遍历当前屏幕中没有header的section数组
    [noneHeaderSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {

        //取到当前section中第一个item的indexPath
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        //获取当前section在正常情况下已经离开屏幕的header结构信息
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];

        //如果当前分区确实有因为离开屏幕而被系统回收的header
        if (attributes) {
            //将该header结构信息重新加入到superArray中去
            [superArray addObject:attributes];
        }
    }];

    //遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        //如果当前item是header
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            //得到当前header所在分区的cell的数量
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:attributes.indexPath.section];
            //得到第一个item的indexPath
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section];
            //得到最后一个item的indexPath
            NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection - 1) inSection:attributes.indexPath.section];
            //得到第一个item和最后一个item的结构信息
            UICollectionViewLayoutAttributes *firstItemAttributes, *lastItemAttributes;
            if (numberOfItemsInSection > 0) {
                //cell有值，则获取第一个cell和最后一个cell的结构信息
                firstItemAttributes = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
                lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItemIndexPath];
            } else {
                //cell没值,就新建一个UICollectionViewLayoutAttributes
                firstItemAttributes = [UICollectionViewLayoutAttributes new];
                //然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                CGFloat y = CGRectGetMaxY(attributes.frame) + self.sectionInset.top;
                firstItemAttributes.frame = CGRectMake(0, y, 0, 0);
                //因为只有一个cell，所以最后一个cell等于第一个cell
                lastItemAttributes = firstItemAttributes;
            }

            //获取当前header的frame
            CGRect rect = attributes.frame;

            //当前的滑动距离 + 因为导航栏产生的偏移量，默认为64（如果app需求不同，需自己设置）
            CGFloat offset = self.collectionView.contentOffset.y + _naviHeight;
            //第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
            CGFloat headerY = firstItemAttributes.frame.origin.y - rect.size.height - self.sectionInset.top;

            //哪个大取哪个，保证header悬停
            //针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
            CGFloat maxY = MAX(offset,headerY);

            //最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
            //当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
            CGFloat headerMissingY = CGRectGetMaxY(lastItemAttributes.frame) + self.sectionInset.bottom - rect.size.height;

            //给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
            rect.origin.y = MIN(maxY,headerMissingY);
            //给header的结构信息的frame重新赋值
            attributes.frame = rect;

            //如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
            //通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大，这里随便填了个7
            attributes.zIndex = 7;
        }
    }

    //转换回不可变数组，并返回
    return [superArray copy];

}

//return YES;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}
@end
