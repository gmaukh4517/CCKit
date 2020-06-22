//
//  UITableViewHeaderFooterView+CCAdd.h
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

#import <UIKit/UIKit.h>

@interface UITableViewHeaderFooterView (CCAdd)

/**
 *  @author CC, 16-09-08
 *
 *  @brief  当前Cell数据源
 */
@property (nonatomic, copy) id cc_dataSources;

/**
 *  @author C C, 16-09-08
 *
 *  @brief  HeaderFooterView 获取下标
 */
@property (nonatomic, assign) NSInteger cc_Section;

/**
 *  @author C C, 16-09-08
 *
 *  @brief  HeaderFooterView 获取RowCount
 */
@property (nonatomic, assign) NSInteger cc_rowCount;

/**
 *  @author CC, 16-09-08
 *
 *  @brief  背景线图片
 */
@property (nonatomic, copy) UIImage *backgroundImage;

/**
 *  @author CC, 16-09-08
 *
 *  @brief 设置背景颜色
 */
@property (nonatomic, copy) UIColor *backgroundViewColor;

- (void)cc_headerFooterWillDisplayWithModel:(id)cModel
                                    section:(NSInteger)section;

@end
