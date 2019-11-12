//
//  CCTableViewHelper.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nullable (^CCTableHelperHeaderIdentifierBlock)(NSInteger section, id cModel);
typedef NSString * _Nullable (^CCTableHelperFooterIdentifierBlock)(NSInteger section, id cModel);
typedef NSString * _Nullable (^CCTableHelperCellIdentifierBlock)(NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidSelectBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);
typedef void (^CCTableHelperDidDeSelectBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);

typedef void (^CCTableHelperDidMoveToRowBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, id sourceModel, NSIndexPath *destinationIndexPath, id destinationModel);

typedef void (^CCTableHelperDidWillDisplayBlock)(UITableViewCell *Cell, NSIndexPath *cIndexPath, id cModel, BOOL IsCelldisplay);

typedef void (^CCTableHelperDidEditingBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *cIndexPath, id cModel);
typedef NSString * _Nullable (^CCTableHelperDidEditTitleBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);

typedef UITableViewCellEditingStyle (^CCTableHelperEditingStyle)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);
typedef NSArray<UITableViewRowAction *> * _Nullable (^CCTableHelperDidEditActionsBlock)(UITableView *tableView, NSIndexPath *cIndexPath, id cModel);

typedef void (^CCScrollViewWillBeginDragging)(UIScrollView *scrollView);
typedef void (^CCScrollViewDidScroll)(UIScrollView *scrollView);
typedef void (^CCTableHelperCellBlock)(NSString *info, id event);


typedef void (^CCTableHelperHeaderBlock)(UITableViewHeaderFooterView *headerView, NSInteger section, id cModel);
typedef void (^CCTableHelperFooterBlock)(UITableViewHeaderFooterView *footerView, NSInteger section, id cModel);

typedef NSString * _Nullable (^CCTableHelperTitleHeaderBlock)(UITableView *tableView, NSInteger section);
typedef NSString * _Nullable (^CCTableHelperTitleFooterBlock)(UITableView *tableView, NSInteger section);

typedef NSInteger (^CCTableHelperNumberOfSections)(UITableView *tableView, NSInteger count);
typedef NSInteger (^CCTableHelperNumberRows)(UITableView *tableView, NSInteger section, NSArray *cModels);
typedef id _Nullable (^CCTableHelperCurrentModelAtIndexPath)(id dataAry, NSIndexPath *cIndexPath);

typedef void (^CCTableHelperScrollViewDidEndScrolling)(UIScrollView *scrollView);

@interface CCTableViewHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 *  @author CC, 16-07-23
 *
 *  @brief 获取当前数据源
 */
@property (nonatomic, weak, readonly) NSMutableArray *dataSource;
@property (nonatomic, weak, readonly) NSArray *dataHeaderSource;
@property (nonatomic, weak, readonly) NSArray *dataFooterSource;
@property (nonatomic, copy) NSArray *sectionIndexTitle;

/**
 *  @author CC, 16-07-23
 *
 *  @brief 分组顶部高度 默认：0.001
 */
@property (nonatomic, assign) CGFloat titleHeaderHeight;

/**
 *  @author CC, 16-07-23
 *
 *  @brief 分组底部高度 默认：0.001
 */
@property (nonatomic, assign) CGFloat titleFooterHeight;

/**
 *  @author CC, 16-03-19
 *
 *  @brief 是否补齐线(默认不补齐)
 */
@property (nonatomic, assign) BOOL paddedSeparator;

/**
 *  @author CC, 16-07-23
 *
 *  @brief 是否显示侧边字母
 */
@property (nonatomic, assign) BOOL isSection;

/**
 是否移动行
 */
@property (nonatomic, assign) BOOL isCanMoveRow;

/**
 是否防快速点击 (默认：NO 不防止)
 */
@property (nonatomic, assign) BOOL isAntiHurry;

/**  **/

/**
 * @brief section HeaderView 是否悬停 (默认悬停) YES: 不悬停
 *  UITableViewStylePlain 模式下
 */
@property (nonatomic, assign) BOOL isHover;

/**
 *  When using the storyboard and a single cell, set the property inspector same identifier
 */
@property (nullable, nonatomic, copy) NSString *cellIdentifier;

/**
 *  When using the storyboard and a single headerFooter, set the property inspector same identifier
 */
@property (nullable, nonatomic, copy) NSString *headerIdentifier;
@property (nullable, nonatomic, copy) NSString *footerIdentifier;


/**
 指定注册Cell中那些加载Xib
 */
@property (nonatomic, strong) NSArray *cc_CellXIB;
@property (nonatomic, copy) NSArray *cc_HeaderXIB;
@property (nonatomic, copy) NSArray *cc_FooterXIB;

@property (nonatomic, weak) UITableView *cc_tableView;
@property (nonatomic, strong, readonly) NSIndexPath *cc_indexPath;

/**
 *  @author CC, 16-04-07
 *
 *  @brief Cell委托
 */
@property (nonatomic, weak) id<CCViewProtocol> cellDelegate;

@property (nonatomic, weak) id<CCViewProtocol> headerFooterDelegate;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerNibs:(NSArray<NSString *> *)cellNibNames;

/**
 *  When using xib, all incoming nib names
 */
- (void)registerHeaderNibs:(NSArray<NSString *> *)headerNibNames;
- (void)registerFooterNibs:(NSArray<NSString *> *)footerNibNames;

#pragma mark -
#pragma mark :. Block事件

/**
 *  When there are multiple header, returned identifier in block
 */
- (void)headerMultipleIdentifier:(CCTableHelperHeaderIdentifierBlock)cb;

/**
 *  When there are multiple cell, returned identifier in block
 */
- (void)cellMultipleIdentifier:(CCTableHelperCellIdentifierBlock)cb;

/**
 *  When there are multiple footer, returned identifier in block
 */
- (void)fotterMultipleIdentifier:(CCTableHelperFooterIdentifierBlock)cb;

/**
 *  If you override tableView:didSelectRowAtIndexPath: method, it will be invalid
 */
- (void)didSelect:(CCTableHelperDidSelectBlock)cb;

/**
 *  If you override tableView:didDeselectRowAtIndexPath: method, it will be invalid
 */
- (void)didDeSelect:(CCTableHelperDidDeSelectBlock)cb;

/**
 *  @author CC, 16-07-27
 *
 *  @brief 编辑样式
 */
- (void)didEditingStyle:(CCTableHelperEditingStyle)cb;

/**
 *  @author CC, 16-06-20
 *
 *  @brief  cell侧滑编辑事件
 */
- (void)didEnditing:(CCTableHelperDidEditingBlock)cb;
/**
 *  @author CC, 16-06-20
 *
 *  @brief  cell侧滑标题
 */
- (void)didEnditTitle:(CCTableHelperDidEditTitleBlock)cb;

/**
 *  @author CC, 16-06-20
 *
 *  @brief  cell侧滑菜单
 */
- (void)didEditActions:(CCTableHelperDidEditActionsBlock)cb;

/**
 移动Cell
 */
- (void)didMoveToRowBlock:(CCTableHelperDidMoveToRowBlock)cb;

/**
 *  @author CC, 16-03-19
 *
 *  @brief 设置Cell显示
 */
- (void)cellWillDisplay:(CCTableHelperDidWillDisplayBlock)cb;

- (void)didScrollViewWillBeginDragging:(CCScrollViewWillBeginDragging)block;
- (void)didScrollViewDidScroll:(CCScrollViewDidScroll)block;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  Header视图
 */
- (void)headerWillDisplay:(CCTableHelperHeaderBlock)cb;
- (void)headerTitle:(CCTableHelperTitleHeaderBlock)cb;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  Footer视图
 */
- (void)footerWillDisplay:(CCTableHelperFooterBlock)cb;
- (void)footerTitle:(CCTableHelperTitleFooterBlock)cb;

- (void)numberOfSections:(CCTableHelperNumberOfSections)cb;
/**
 *  @author CC, 16-05-23
 *
 *  @brief  NumberOfRowsInSection
 */
- (void)numberOfRowsInSection:(CCTableHelperNumberRows)cb;

/**
 *  @author CC, 16-04-22
 *
 *  @brief 设置Cell回调Block
 */
- (void)cellViewEventBlock:(CCTableHelperCellBlock)cb;

/**
 *  @author CC, 16-05-23
 *
 *  @brief  处理获取当前模型
 */
- (void)currentModelIndexPath:(CCTableHelperCurrentModelAtIndexPath)cb;

/**
 滚动结束回调
 */
- (void)didScrollViewDidEndScrolling:(CCTableHelperScrollViewDidEndScrolling)cb;

#pragma mark -
#pragma mark :. Handler

-(void)cc_clearData;

/**
 *  @author CC, 16-07-02
 *
 *  @brief 显示分组数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry;

/**
 重新加载该分组数据

 @param newDataAry 分组数据
 @param cSection 分组下标
 */
- (void)cc_reloadGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection;

/**
 *  @author C C, 2016-09-29
 *
 *  @brief  添加分组数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_addGroupDataAry:(NSArray *)newDataAry;

/**
 *  @author C C, 2016-09-29
 *
 *  @brief  插入分组数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   下标
 *                    如下标为-1 是往前插入
 */
- (void)cc_insertGroupDataAry:(NSArray *)newDataAry
                   forSection:(NSInteger)cSection;

/**
 *  @author C C, 2016-09-29
 *
 *  @brief  插入多条分组数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   下标
 *                    如下标为-1 是往前插入
 */
- (void)cc_insertMultiplGroupDataAry:(NSArray *)newDataAry
                          forSection:(NSInteger)cSection;

/**
 删除分组数据

 @param cSection 分组下标
 */
- (void)cc_deleteGroupData:(NSInteger)cSection;

#pragma mark -
#pragma mark :. Plain

/**
 设置Section Header 数据

 @param newHeaderAry 数据源
 */
- (void)cc_resetHeaderAry:(NSArray *)newHeaderAry;

/**
 设置section Footer 数据

 @param newFooterAry 数据源
 */
- (void)cc_resetFooterAry:(NSArray *)newFooterAry;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_resetDataAry:(NSArray *)newDataAry;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  显示数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_resetDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_reloadDataAry:(NSArray *)newDataAry;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  刷新并加入新数据
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_reloadDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  批量添加数据
 *
 *  @param newDataAry 数据源
 */
- (void)cc_addDataAry:(NSArray *)newDataAry;
/**
 *  @author CC, 16-05-18
 *
 *  @brief  批量添加
 *
 *  @param newDataAry 数据源
 *  @param cSection   分组数
 */
- (void)cc_addDataAry:(NSArray *)newDataAry forSection:(NSInteger)cSection;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  单个添加
 *
 *  @param cModel     数据模型
 *  @param cIndexPath 下标位置
 */
- (void)cc_insertData:(id)cModel AtIndex:(NSIndexPath *)cIndexPath;

/**
 *  @author CC, 16-09-06
 *
 *  @brief 替换数据对象
 *
 *  @param model      对象
 *  @param cIndexPath 下标位置
 */
- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath;

- (void)cc_replaceDataAtIndex:(id)model
                    IndexPath:(NSIndexPath *)cIndexPath
             withRowAnimation:(UITableViewRowAnimation)animated;

/**
 *  @author CC, 16-05-18
 *
 *  @brief  根据下标删除数据
 *
 *  @param cIndexPath 下标位置
 */
- (void)cc_deleteDataAtIndex:(NSIndexPath *)cIndexPath;
- (void)cc_deleteDataAtIndexs:(NSArray *)indexPaths;


/**
 获取当前Header模型数据
 */
-(id)currentHeaderModel;
-(id)currentHeaderModelAtSection:(NSInteger)section;

/**
 获取当前Cell模型数据
 */
- (id)currentModel;
- (id)currentModelAtIndexPath:(NSIndexPath *)cIndexPath;

/**
 获取当前Footer模型数据
 */
-(id)currentFooterModel;
-(id)currentFooterModelAtSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
