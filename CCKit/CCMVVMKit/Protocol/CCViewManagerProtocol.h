//
//  CCViewManagerProtocol.h
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

/**
 *  @author CC, 16-04-20
 *
 *  @brief  将自己事件处理通过block方式交互ViewManager
 */
typedef void (^ViewEventsBlock)(NSString *info, NSDictionary *params);

/**
 *  @author CC, 16-04-20
 *
 *  @brief 将自己的信息返回给ViewModel的block
 */
typedef void (^ViewModelInfosBlock)(NSString *info, NSDictionary *params);

typedef void (^ViewEventHandle)(NSString *info, NSDictionary *eventDic);

typedef void (^ViewEventBlock)(id response);
typedef void (^ViewEventHandleBlock)(NSString *info, NSDictionary *eventDic, ViewEventBlock block);

@protocol CCViewManagerProtocol <NSObject>

@optional

/**
 *  @author CC, 16-04-20
 *
 *  @brief 中介者传值
 */
- (void)cc_notice;

/**
 *  设置Controller的子视图的管理者为self
 *
 *  @param superView 一般指subView所在控制器的view
 */

/**
 *  @author CC, 16-04-20
 *
 *  @brief 设置Controller的子视图的管理者为self
 *
 *  @param superView superView 一般指subView所在控制器的view
 */
- (void)cc_ViewManagerWithSuperView:(UIView *)superView;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 设置subView的管理者为self
 *
 *  @param subView 管理的subView
 */
- (void)cc_ViewManagerWithSubView:(UIView *)subView;

/**
 *  @author CC, 16-04-21
 *
 *  @brief View传递到ViewManager统一管理
 *
 *  @param viewDic View集合
 */
- (void)cc_ViewManagerWithView:(NSDictionary *)viewDic;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 设置添加subView的事件
 *
 *  @param subView 管理的subView
 *  @param info    附带信息，用于区分调用
 */
- (void)cc_ViewManagerWithHandleOfSubView:(UIView *)subView
                                    info:(NSString *)info;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 返回ViewManager所管理的视图
 *
 *  @return ViewManager所管理的视图
 */
- (__kindof UIView *)cc_ViewManagerOfSubView;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 得到其它ViewManager所管理的subView，用于自己内部
 *
 *  @param viewInfos 其它的subViews
 */
- (void)cc_ViewManagerWithOtherSubViews:(NSDictionary *)viewInfos;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 需要重新布局subView时，更改subView的frame或者约束
 *
 *  @param updateBlock 更新布局完成的block
 */
- (void)cc_ViewManagerWithLayoutSubViews:(void (^)())updateBlock;

/**
 *  @author CC, 16-04-20
 *
 *  @brief  使子视图更新到最新的布局约束或者frame
 */
- (void)cc_ViewManagerWithUpdateLayoutSubViews;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 将model数据传递给ViewManager
 */
- (void)cc_ViewManagerWithModel:(NSDictionary * (^)())dictBlock;

/**
 *  @author CC, 16-04-29
 *
 *  @brief ViewManager传递事件到ViewController
 */
- (void)cc_ViewManagerWithEventHandle:(ViewEventHandle)eventHandle;
- (void)cc_ViewManagerWithEventHandleBlock:(ViewEventHandleBlock)eventHandleBlock;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 处理viewBlock事件
 *
 *  @param infos 传递值
 */
- (ViewEventsBlock)cc_ViewManagerWithViewEventBlockOfInfos:(NSDictionary *)infos;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 处理ViewModelInfosBlock
 *
 *  @param infos 传递值
 */
- (ViewModelInfosBlock)cc_ViewManagerWithViewModelBlockOfInfos:(NSDictionary *)infos;

/**
 *  @author CC, 16-04-26
 *
 *  @brief 将（ViewManager的数据源）数据传递到ViewModel
 *
 *  @param info           附带信息，用于区分调用
 *  @param successHandler 响应数据
 */
- (void)cc_ViewManagerWithGetData:(NSString *)info
                  SuccessHandler:(void (^)(NSDictionary *parameter))successHandler;

/**
 *  @author CC, 16-04-20
 *
 *  @brief 将ViewManager中的信息通过代理传递给ViewModel
 *
 *  @param ViewManager ViewManager自己
 *  @param infos      描述信息
 */
- (void)cc_ViewManager:(id)ViewManager
            withInfos:(NSDictionary *)infos;

/**
 *  @author CC, 16-04-20
 *
 *  @brief ViewManager事件传递到ViewModel
 *
 *  @param info     描述信息
 *  @param eventDic 传递参数
 */
- (void)cc_ViewManagerEvent:(NSString *)info
                 withEvent:(NSDictionary *)eventDic;

/**
 *  @author CC, 16-04-26
 *
 *  @brief ViewManager事件传递到ViewModel 响应回调
 *
 *  @param info     描述信息
 *  @param eventDic 传递参数
 *  @param block    回调函数
 */
-(void)cc_ViewManagerEvent:(NSString *)info
                withEvent:(NSDictionary *)eventDic
            CallbackBlock:(void(^)(id response))block;

/**
 *  @author CC, 16-07-25
 *
 *  @brief ViewManager响应传递到调用类
 *
 *  @param block 传递值
 */
-(void)cc_ViewManagerWithModelBlcok:(void(^)(id model))block;

/**
 *  @author CC, 16-07-25
 *
 *  @brief 发送事件
 *
 *  @param eventName 事件名
 */
-(void)cc_ViewManagerSendEvents:(NSString *)eventName;

/**
 传递事件到Model处理Block回传结果
 
 @param info        描述信息
 @param parameters  传递参数
 @param handleBlock 回调BLock
 */
-(void)cc_viewManagerWithEventBlock:(NSString *)info 
                        Parameter:(NSDictionary *)parameters
                 EventHandleBlock:(void(^)(NSDictionary *handleResult))handleBlock;

@end