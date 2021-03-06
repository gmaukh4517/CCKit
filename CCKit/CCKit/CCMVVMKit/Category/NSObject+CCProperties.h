//
//  NSObject+CCProperties.h
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

#import "CCMediator.h"
#import "CCViewManagerProtocol.h"
#import "CCViewModelProtocol.h"
#import "CCViewProtocol.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  ViewModelBlock
 */
typedef _Nonnull id (^ViewModelBlock)(void);
/**
 *  ViewManagerInfosBlock
 */
typedef void (^ViewManagerInfosBlock)(NSString *info, NSDictionary *params);
/**
 *  ViewModelInfosBlock
 */
typedef void (^ViewModelInfosBlock)(NSString *info, NSDictionary *params);


@interface NSObject (CCProperties)

/**
 *  viewModelBlock
 */
@property (nonatomic, copy, nonnull) ViewModelBlock viewModelBlock;

/**
 *  获取一个对象的所有属性
 */
- (nullable NSDictionary *)cc_allProperties;

/**
 *  ViewManagerDelegate
 */
@property (nullable, nonatomic, weak) id<CCViewManagerProtocol> viewManagerDelegate;

/**
 *  ViewManagerInfosBlock
 */
@property (nonatomic, copy) ViewManagerInfosBlock viewManagerInfosBlock;

/**
 *  viewModelDelegate
 */
@property (nullable, nonatomic, weak) id<CCViewModelProtocol> viewModelDelegate;

/**
 *  ViewModelInfosBlock
 */
@property (nonatomic, copy) ViewModelInfosBlock viewModelInfosBlock;

/**
 *  mediator
 */
@property (nonatomic, strong) CCMediator *cc_mediator;

/**
 *  cc_ViewManagerInfos
 */
@property (nonatomic, copy) NSDictionary *cc_viewManagerInfos;

/**
 *  cc_viewModelInfos
 */
@property (nonatomic, copy) NSDictionary *cc_viewModelInfos;

- (void)didViewManagerInfosBlock:(ViewManagerInfosBlock)block;
- (void)didViewModelInfosBlock:(ViewModelInfosBlock)block;
- (void)didViewModelBlock:(ViewModelBlock)block;

@end

NS_ASSUME_NONNULL_END
