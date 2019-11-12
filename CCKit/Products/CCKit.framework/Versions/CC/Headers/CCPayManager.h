//
//  CCPayManager.h
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

#import <Foundation/Foundation.h>

@interface CCPayManager : NSObject

/*  @author C C, 2015-10-18
 *
 *  @brief  单例模式
 *
 *  @return 返回当前对象
 */
+ (id)manager;

/**
 支付回调结果处理

 @param result 处理结果
 */
- (void)payCallbackHandler:(id)result;

#pragma mark -
#pragma mark :. 支付宝
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  设置链接秘钥
 *
 *  @param appScheme  回调APP名称
 *  @param partnerKey 作身份者ID
 *  @param sellerKey  支付宝收款账号,手机号码或邮箱格式。
 *  @param privateKey 商家私有秘钥
 */
- (void)setAliPaySchema:(NSString *)appScheme
             partnerKey:(NSString *)partnerKey
              sellerKey:(NSString *)sellerKey
             privateKey:(NSString *)privateKey;

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  支付订单
 *
 *  @param tradeNO            订单号
 *  @param productName        标题
 *  @param productDescription 描述
 *  @param amount             价格
 *  @param notifyURL          回调URL
 */
- (void)aliPayOrderForm:(NSString *)tradeNO
            productName:(NSString *)productName
     productDescription:(NSString *)productDescription
                 amount:(NSString *)amount
              notifyURL:(NSString *)notifyURL
                 itBPay:(NSString *)itbpay
               callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;

/**
 支付订单

 @param orderString 订单信息
 @param block 响应回调
 */
- (void)aliPayOrderForm:(NSString *)orderString
               callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;

/**
 *  处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
 *
 *  @param resultUrl 支付结果url，传入后由SDK解析，统一在上面的pay方法的callback中回调
 *  @param block 跳钱包支付结果回调，保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl
                      standbyCallback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;
/**
 *  处理授权信息Url
 *
 *  @param resultUrl 钱包返回的授权结果url
 *  @param block 跳授权结果回调，保证跳转钱包授权过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
- (void)processAuthResult:(NSURL *)resultUrl
          standbyCallback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;

#pragma mark -
#pragma mark :. 微信

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  基础设置
 *
 *  @param appid           公众账号ID (微信开发者ID)
 *  @param appSecret       appSecret (微信分配)
 *  @param partnerid       商户号
 *  @param partnerKey      商户API密钥
 *  @param withDescription 应用附加信息，长度不超过1024字节
 */
- (void)setWxPay:(NSString *)appid
          appSecret:(NSString *)appSecret
          partnerid:(NSString *)partnerid
         partnerKey:(NSString *)partnerKey
    withDescription:(NSString *)withDescription;


/**
 *  @author C C, 2015-12-04
 *
 *  @brief  设置获取服务器端支付数据地址（商户自定义）
 *          默认值：http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php
 *  @param url 自定义服务器地址
 */
- (void)setPayDataAddress:(NSString *)url;

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  统一提交订单
 *
 *  @param sendData 订单参数
 *  @param block    完成回调函数
 */
- (void)Unifiedorder:(NSDictionary *)sendData
            callback:(void (^)(NSDictionary *requestDic, NSError *error))block;

/**
 *  @author C C, 2015-12-06
 *
 *  @brief  支付订单
 *
 *  @param appid     由用户微信号和AppID组成的唯一标识
 *  @param partnerId 商家向财付通申请的商家id
 *  @param prepayId  预支付订单
 *  @param package   商家根据财付通文档填写的数据和签名
 *  @param noncestr  随机串
 *  @param timestamp 时间戳
 *  @param sign      签名
 */
- (void)wxPayOrderForm:(NSString *)appid
             partnerId:(NSString *)partnerId
              prepayId:(NSString *)prepayId
               package:(NSString *)package
              noncestr:(NSString *)noncestr
             timestamp:(NSString *)timestamp
                  sign:(NSString *)sign
              callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;

#pragma mark :. 微信小程序

/**
 小程序支付

 @param appletsUserName 拉起的小程序的username
 @param path 拉起小程序页面的路径，不填默认拉起小程序首页
 @param miniProgramType 拉起小程序的类型 (0:正式版 1:开发版 2:体验版)
 @param block 处理回调
 */
- (void)wxAppletsPayOrderForm:(NSString *)appletsUserName
                         path:(NSString *)path
              miniProgramType:(NSInteger)miniProgramType
                     callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block;

/**
 *  @author C C, 2015-12-06
 *
 *  @brief  设置回调
 *
 *  @param url url description
 */
-(BOOL)handleOpenURL:(NSURL *)url;



@end
