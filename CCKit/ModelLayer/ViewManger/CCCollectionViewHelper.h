//
//  CCCollectionViewHelper.h
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

#import "CCViewProtocol.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSString * (^CCCollectionHelperCellIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);
typedef NSString * (^CCCollectionHelperHeaderIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);
typedef NSString * (^CCCollectionHelperFooterIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);

typedef NSInteger (^CCCollectionHelperNumberOfItemsInSection)(UICollectionView *collectionView, NSInteger section, id cModel);

typedef UICollectionReusableView * (^CCCollectionHelperHeaderView)(UICollectionView *collectionView, NSString *kind, NSIndexPath *cindexPath, id cModel);
typedef UICollectionReusableView * (^CCCollectionHelperFooterView)(UICollectionView *collectionView, NSString *kind, NSIndexPath *cindexPath, id cModel);

typedef void (^CCCollectionHelperDidSelectItemAtIndexPath)(UICollectionView *collectionView, NSIndexPath *cIndexPath, id cModel);
typedef void (^CCCollectionHelperCellForItemAtIndexPath)(UICollectionViewCell *Cell, NSIndexPath *cIndexPath, id cModel, BOOL IsCelldisplay);
typedef void (^CCCollectionHelperHeaderForItemAtIndexPath)(UICollectionReusableView *header, NSIndexPath *cIndexPath, id cModel, BOOL IsCelldisplay);
typedef void (^CCCollectionHelperFooterForItemAtIndexPath)(UICollectionReusableView *footer, NSIndexPath *cIndexPath, id cModel, BOOL IsCelldisplay);

typedef CGSize (^CCCollectionHelperCellForItemSize)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSIndexPath *cIndexPath, id cModel);
typedef CGSize (^CCCollectionHelperReferenceSize)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section, id cModel);

typedef UIEdgeInsets (^CCCollectionHelperCellItemMargin)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger *cSection, id cModel);
typedef CGFloat (^CCCollectionHelperMinimumInteritemSpacingForSection)(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger *cSection, id cModel);

typedef id (^CCCollectionHelperCurrentModelAtIndexPath)(id dataAry, NSIndexPath *cIndexPath);
typedef id (^CCCollectionHelperCurrentHeaderModelAtIndexPath)(id dataAry, NSIndexPath *cIndexPath);
typedef id (^CCCollectionHelperCurrentFooterModelAtIndexPath)(id dataAry, NSIndexPath *cIndexPath);

@interface CCCollectionViewHelper : NSObject <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak, readonly) NSMutableArray *dataSource;
@property (nonatomic, weak, readonly) NSMutableArray *headerSource;
@property (nonatomic, weak, readonly) NSMutableArray *footerSource;

@property (nonatomic, assign) CGSize titleHeaderSize;
@property (nonatomic, assign) CGSize titleFooterSize;

@property (nonatomic, weak) id<CCViewProtocol> cellDelegate;
@property (nonatomic, weak) id<CCViewProtocol> reusableDelegate;

/**
 Cell 是否加载XIB
 */
@property (nonatomic, strong) NSArray *cc_CellXIB;

/**
 Hader 是否加载XIB
 */
@property (nonatomic, strong) NSArray *cc_CellHeaderXIB;
/**
 Footer 是否加载XIB
 */
@property (nonatomic, strong) NSArray *cc_CellFooterXIB;
@property (nonatomic, weak) UICollectionView *cc_CollectionView;
@property (nonatomic, strong) NSIndexPath *cc_indexPath;

@property (nonatomic, assign) BOOL cc_autoSizingCell;

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *headerIdentifier;
@property (nonatomic, copy) NSString *footerIdentifier;

- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

/**
 Hader集合
 */
- (void)registerNibHeaders:(NSArray<NSString *> *)cellNibNames;

/**
 Footer集合
 */
- (void)registerNibFooters:(NSArray<NSString *> *)cellNibNames;


#pragma mark -
#pragma mark :. Handler

- (NSString *)cellIdentifierForRowAtIndexPath:(NSIndexPath *)cIndexPath model:(id)cModel;

- (id)currentSectionModel:(NSInteger)section;

- (id)currentModel;

- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;

#pragma mark :. Group
- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry;

- (void)cc_addGroupDataAry:(NSArray *)newDataAry;

- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection;

- (void)cc_insertMultiplGroupDataAry:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection;

#pragma mark :.

- (void)cc_resetDataAry:(NSArray *)newDataAry;

- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

- (void)cc_reloadDataAry:(NSArray *)newDataAry;
- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

- (void)cc_addDataAry:(NSArray *)newDataAry;

- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;
- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;

- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath;

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath;
#pragma mark -
#pragma mark :. Header

- (void)cc_reloadHeaderArr:(NSArray *)newDataAry;

- (void)cc_addHeaderArr:(NSArray *)newDataAry;

- (void)cc_insertHeaderArr:(NSArray *)newDataAry
                     forSection:(NSInteger)cSection;

- (void)cc_removerHeaderData:(NSInteger)cSection;

- (id)currentHeaderModelAtIndexPath:(NSIndexPath *)cIndexPath;

#pragma mark -
#pragma mark :. Footer

- (void)cc_reloadFooterArr:(NSArray *)newDataAry;

- (void)cc_addFooterArr:(NSArray *)newDataAry;

- (void)cc_insertFooterArr:(NSArray *)newDataAry
                     forSection:(NSInteger)cSection;

- (void)cc_removerFooterData:(NSInteger)cSection;

- (id)currentFooterModelAtIndexPath:(NSIndexPath *)cIndexPath;

#pragma mark -
#pragma mark :. Block事件

- (void)cellMultipleIdentifier:(CCCollectionHelperCellIdentifierBlock)block;
- (void)headerMultipleIdentifier:(CCCollectionHelperHeaderIdentifierBlock)block;
- (void)footerMultipleIdentifier:(CCCollectionHelperFooterIdentifierBlock)block;

- (void)currentModelIndexPath:(CCCollectionHelperCurrentModelAtIndexPath)block;

- (void)didNumberOfItemsInSection:(CCCollectionHelperNumberOfItemsInSection)block;

- (void)didHeaderView:(CCCollectionHelperHeaderView)block;
- (void)didCurrentHeaderModel:(CCCollectionHelperCurrentHeaderModelAtIndexPath)block;
- (void)didFooterView:(CCCollectionHelperFooterView)block;
- (void)didCurrentFooterModel:(CCCollectionHelperCurrentFooterModelAtIndexPath)block;

- (void)didCellForItemAtIndexPath:(CCCollectionHelperCellForItemAtIndexPath)block;
- (void)didHeaderForItemAtIndexPah:(CCCollectionHelperHeaderForItemAtIndexPath)block;
- (void)didFooterForItemAtIndexPah:(CCCollectionHelperFooterForItemAtIndexPath)block;

- (void)didSizeForItemAtIndexPath:(CCCollectionHelperCellForItemSize)block;
- (void)didReferenceSize:(CCCollectionHelperReferenceSize)block;

- (void)didSelectItemAtIndexPath:(CCCollectionHelperDidSelectItemAtIndexPath)block;

- (void)didCellItemMargin:(CCCollectionHelperCellItemMargin)block;

- (void)didMinimumInteritemSpacingForSection:(CCCollectionHelperMinimumInteritemSpacingForSection)blcok;

@end
