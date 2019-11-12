//
//  CCPayManager.m
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

#import "CCPayManager.h"
#import "NSObject+CCAdd.h"
#import "NSString+CCAdd.h"

#import "AliOrderFormEntity.h"
#import "DataSigner.h"


@interface CCXML : NSObject <NSXMLParserDelegate>

@property (nonatomic, copy) NSMutableDictionary *dictionary;
@property (nonatomic, copy) NSMutableString *contentString;
@property (nonatomic, copy) NSMutableArray *xmlElements;
@property (nonatomic, copy) NSXMLParser *xmlParser;

@end

@implementation CCXML

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  开始解析
 *
 *  @param data 解析数据
 */
- (void)startParse:(NSData *)data
{
    _dictionary = [NSMutableDictionary dictionary];
    _contentString = [NSMutableString string];
    //Demo XML解析实例
    _xmlElements = [[NSMutableArray alloc] init];

    _xmlParser = [[NSXMLParser alloc] initWithData:data];
    [_xmlParser setDelegate:self];
    [_xmlParser parse];
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  转换位键值
 */
- (NSMutableDictionary *)changeDictionary
{
    return _dictionary;
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  解析文档开始
 *
 *  @param parser <#parser description#>
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //NSLog(@"解析文档开始");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"遇到启始标签:%@",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"遇到内容:%@",string);
    [_contentString setString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (![_contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"])
        [_dictionary setObject:[_contentString copy] forKey:elementName];
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  解析文档结束
 *
 *  @param parser <#parser description#>
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _xmlElements = nil;
    _xmlParser = nil;
}


@end


//支付结果回调页面
#define kWXNOTIFY_URL @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"

//统一提交订单地址
#define kWXUnifiedorderURL @"https://api.mch.weixin.qq.com/pay/unifiedorder"

/**
 回调响应

 @param resultStatus 状态码
 @param result 响应结果
 @param error 错误日志
 */
typedef void (^ResponseCallback)(NSInteger resultStatus, id result, NSError *error);

@interface CCPayManager ()

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  回调函数
 */
@property (nonatomic, copy) ResponseCallback responseCallback;

#pragma mark - 支付宝

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  回调APP名称
 */
@property (nonatomic, copy) NSString *appScheme;

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  合作身份者ID,以 2088 开头由 16 位纯数字组成的字符串
 */
@property (nonatomic, copy) NSString *aliPartnerKey;
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  支付宝收款账号,手机号码或邮箱格式。
 */
@property (nonatomic, copy) NSString *sellerKey;
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  商户方的私钥,pkcs8 格式。
 */
@property (nonatomic, copy) NSString *privateKey;

/**
 *  @author C C, 2015-11-16
 *
 *  @brief  初始化
 */
@property (nonatomic, strong) id AlipaySDK;

#pragma mark - 微信

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  微信分配的公众账号ID
 */
@property (nonatomic, copy) NSString *appid;

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  微信分配的appSecret
 */
@property (nonatomic, copy) NSString *appSecret;

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  商户号
 */
@property (nonatomic, copy) NSString *partnerid;

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  商户API密钥
 */
@property (nonatomic, copy) NSString *wxPartnerKey;

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  获取服务器端支付数据地址（商户自定义）
 */
@property (nonatomic, copy) NSString *payDataAddress;


@end

@implementation CCPayManager

/*  @author C C, 2015-10-18
 *
 *  @brief  单例模式
 *
 *  @return 返回当前对象
 */
+ (id)manager
{
    static id _sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

/**
 支付回调结果处理

 @param result 处理结果
 */
- (void)payCallbackHandler:(id)result
{
    if ([result isKindOfClass:NSClassFromString(@"BaseResp")]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSInteger errCode = [[result valueForKey:@"errCode"] integerValue];
        if (errCode == 0) {
            !_responseCallback ?: _responseCallback(errCode, result, nil);
        } else {
            !_responseCallback ?: _responseCallback(errCode, result, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"支付结果：失败！ errcode : %@", [result valueForKey:@"errStr"]] code:errCode userInfo:nil]);
        }
    } else if ([result isKindOfClass:[NSDictionary class]] && [[result allKeys] containsObject:@"aliPay"]) {
        NSInteger resultStatus = [[[result objectForKey:@"aliPay"] objectForKey:@"resultStatus"] integerValue];
        NSError *error;
        if (resultStatus != 9000) {
            NSString *message;
            switch (resultStatus) {
                case 8000:
                    message = @"订单处理中";
                    break;
                case 4000:
                    message = @"支付失败";
                    break;
                case 5000:
                    message = @"重复请求";
                    break;
                case 6001:
                    message = @"支付取消!";
                    break;
                case 6002:
                    message = @"网络连接出错!";
                    break;
                case 6004:
                    message = @"支付结果未知!";
                    break;
                default:
                    break;
            }
            error = [NSError errorWithDomain:message code:resultStatus userInfo:result];
        }
        !_responseCallback ?: _responseCallback(resultStatus, result, error);
    } else {
        NSString *message = @"支付回调自定义处理";
        if ([result objectForKey:@"message"])
            message = [result objectForKey:@"message"];
        !_responseCallback ?: _responseCallback(-1, result, [NSError errorWithDomain:message code:-1 userInfo:result]);
    }
}

#pragma mark -
#pragma mark :. 支付宝支付模块

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
             privateKey:(NSString *)privateKey
{
    _appScheme = appScheme;
    _aliPartnerKey = partnerKey;
    _sellerKey = sellerKey;
    _privateKey = privateKey;
}


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
               callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    if (_aliPartnerKey.length == 0 || _sellerKey.length == 0 ||
        _privateKey.length == 0 || _appScheme.length == 0) {
        NSString *errMessage;
        if (_aliPartnerKey.length == 0 || _sellerKey.length == 0)
            errMessage = @"partner或seller参数为空";

        if (_privateKey.length == 0 || _appScheme.length == 0)
            errMessage = @"privateKey或appScheme参数为空";

        NSError *err = [NSError errorWithDomain:errMessage code:-1 userInfo:nil];
        block(-1, nil, err);
    }

    AliOrderFormEntity *entity = [[AliOrderFormEntity alloc] init];
    entity.partner = _aliPartnerKey;
    entity.seller = _sellerKey;
    entity.productName = productName;
    entity.tradeNO = tradeNO;
    entity.productDescription = productDescription;
    entity.amount = amount;
    entity.notifyURL = notifyURL;

    NSString *orderSpec = [entity description];
    id<DataSigner> signer = CreateRSADataSigner(_privateKey);
    NSString *signedString = [signer signString:orderSpec];

    if (signedString) {
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        [self aliPayOrderForm:orderString callback:block];
    }
}

/**
 支付订单

 @param orderString 订单信息
 @param block 响应回调
 */
- (void)aliPayOrderForm:(NSString *)orderString
               callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    _responseCallback = [block copy];
    if (NSClassFromString(@"AlipaySDK")) {
        Class Alipay = NSClassFromString(@"AlipaySDK");
        if (!_AlipaySDK)
            _AlipaySDK = [Alipay initMethod:@"defaultService"];

        typeof(self) __weak weakSelf = self;
        void (^CompletionBlock)(NSDictionary *resultDic) = ^(NSDictionary *resultDic) {
            [weakSelf payCallbackHandler:@{ @"aliPay" : resultDic }];
        };
        [_AlipaySDK performSelectors:@"payOrder:fromScheme:callback:" withObject:orderString, _appScheme, CompletionBlock, nil];
    } else {
        NSLog(@"请在工程中导入AlipaySDK.framework文件");
    }
}

/**
 *  处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
 *
 *  @param resultUrl 支付结果url，传入后由SDK解析，统一在上面的pay方法的callback中回调
 *  @param completionBlock 跳钱包支付结果回调，保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl
                      standbyCallback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    if (NSClassFromString(@"AlipaySDK")) {
        if (_AlipaySDK) {
            typeof(self) __weak weakSelf = self;
            void (^CompletionBlock)(NSDictionary *resultDic) = ^(NSDictionary *resultDic) {
                weakSelf.responseCallback([[resultDic objectForKey:@"resultStatus"] integerValue], resultDic, nil);
                [weakSelf payCallbackHandler:@{ @"aliPay" : resultDic }];
                !block ?: block([[resultDic objectForKey:@"resultStatus"] integerValue], resultDic, nil);
            };

            [_AlipaySDK performSelectors:@"processOrderWithPaymentResult:standbyCallback:" withObject:resultUrl, CompletionBlock, nil];
        }
    } else {
        NSLog(@"请在工程中导入AlipaySDK.framework文件");
    }
}

/**
 *  处理授权信息Url
 *
 *  @param resultUrl 钱包返回的授权结果url
 *  @param completionBlock 跳授权结果回调，保证跳转钱包授权过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
- (void)processAuthResult:(NSURL *)resultUrl
          standbyCallback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    if (NSClassFromString(@"AlipaySDK")) {
        if (_AlipaySDK) {
            typeof(self) __weak weakSelf = self;
            void (^CompletionBlock)(NSDictionary *resultDic) = ^(NSDictionary *resultDic) {
                [weakSelf payCallbackHandler:@{ @"aliPay" : resultDic }];
                !block ?: block([[resultDic objectForKey:@"resultStatus"] integerValue], resultDic, nil);
            };

            [_AlipaySDK performSelectors:@"processAuthResult:standbyCallback:" withObject:resultUrl, CompletionBlock, nil];
        }
    } else {
        NSLog(@"请在工程中导入AlipaySDK.framework文件");
    }
}


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
    withDescription:(NSString *)withDescription
{
    _appid = appid;
    _appSecret = appSecret;
    _partnerid = partnerid;
    _wxPartnerKey = partnerKey;

    _payDataAddress = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php";

    Class clazz = NSClassFromString(@"WXApi");
    if (clazz) {
        id result = nil;
        result = [clazz performSelectors:@"registerApp:" withObject:appid, nil];
    } else {
        NSLog(@"请在工程中导入微信SDK文件");
    }
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  设置获取服务器端支付数据地址（商户自定义）
 *          http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php
 *
 *  @param url 自定义服务器地址
 */
- (void)setPayDataAddress:(NSString *)url
{
    _payDataAddress = url;
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  统一提交订单
 *
 *  @param sendData 订单参数
 *  @param block    完成回调函数
 */
- (void)Unifiedorder:(NSDictionary *)sendData
            callback:(void (^)(NSDictionary *requestDic, NSError *error))block
{
    __block NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];

    //清空未设置参数值
    [sendData enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if (obj) {
            if ([obj isKindOfClass:[NSString class]]) {
                if ([obj length])
                    [packageParams setObject:obj forKey:key];
            } else
                [packageParams setObject:obj forKey:key];
        }

    }];

    [packageParams setObject:_appid forKey:@"appid"];
    [packageParams setObject:_partnerid forKey:@"mch_id"];

    if (![packageParams objectForKey:@"notify_url"])
        [packageParams setObject:_payDataAddress forKey:@"notify_url"];

    //获取prepayId（预支付交易会话标识）
    NSString *prePayid = [self sendPrepay:packageParams];
    if (prePayid) {
        //获取到prepayid后进行第二次签名
        //设置支付参数
        time_t now;
        time(&now);

        NSString *time_stamp = [NSString stringWithFormat:@"%ld", now];
        NSString *nonce_str = [time_stamp MD532];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        NSString *package = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject:_appid forKey:@"appid"];
        [signParams setObject:_partnerid forKey:@"partnerid"];
        [signParams setObject:prePayid forKey:@"prepayid"];
        [signParams setObject:package forKey:@"package"];
        [signParams setObject:nonce_str forKey:@"noncestr"];
        [signParams setObject:time_stamp forKey:@"timestamp"];
        //生成签名
        NSString *sign = [self createMd5Sign:signParams];
        //添加签名
        [signParams setObject:sign forKey:@"sign"];
        if (block)
            block(signParams, nil);

    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"获取prepayid失败！" code:-1 userInfo:nil];
        if (block)
            block(nil, error);
    }
}

/**
 *  @author C C, 2015-12-06
 *
 *  @brief  支付订单
 *
 *  @param appid     由用户微信号和AppID组成的唯一标识
 *  @param prepayid  商家向财付通申请的商家id
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
              callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    _responseCallback = [block copy];

    Class payReqC = NSClassFromString(@"PayReq");

    id instance = [[payReqC alloc] init];
    [instance setValue:appid forKey:@"openID"];
    [instance setValue:partnerId forKey:@"partnerId"];
    [instance setValue:prepayId forKey:@"prepayId"];
    [instance setValue:package forKey:@"package"];
    [instance setValue:noncestr forKey:@"nonceStr"];
    [instance setValue:timestamp forKey:@"timeStamp"];
    [instance setValue:sign forKey:@"sign"];

    Class clazz = NSClassFromString(@"WXApi");
    if (clazz) {
        id result = nil;
        result = [clazz performSelectors:@"sendReq:" withObject:instance, nil];
    } else {
        NSLog(@"请在工程中导入微信SDK文件");
    }
}

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
                     callback:(void (^)(NSInteger resultStatus, id result, NSError *error))block
{
    _responseCallback = [block copy];

    Class payReq = NSClassFromString(@"WXLaunchMiniProgramReq");

    id instance = [payReq initMethod:@"object"];
    [instance setValue:appletsUserName forKey:@"userName"];
    [instance setValue:path forKey:@"path"];
    [instance setValue:@(miniProgramType) forKey:@"miniProgramType"];

    Class clazz = NSClassFromString(@"WXApi");
    if (clazz) {
        id result = nil;
        result = [clazz performSelectors:@"sendReq:" withObject:instance, nil];
    } else {
        NSLog(@"请在工程中导入微信SDK文件");
    }
}

/**
 *  @author C C, 2015-12-06
 *
 *  @brief  支付回调结果
 *
 *  @param resp 返回对象
 */
- (void)onResp:(id)resp
{
    [self payCallbackHandler:resp];
}

/**
 *  @author C C, 2015-12-06
 *
 *  @brief  设置回调
 *
 *  @param url url description
 */
- (BOOL)handleOpenURL:(NSURL *)url
{
    Class clazz = NSClassFromString(@"WXApi");
    BOOL bol = NO;
    if (clazz) {
        bol = (BOOL)[clazz performSelectors:@"handleOpenURL:delegate:" withObject:url, self, nil];
    } else {
        NSLog(@"请在工程中导入微信SDK文件");
    }
    return bol;
}

#pragma mark :. 生成预支付订单
/**
 *  @author C C, 2015-12-04
 *
 *  @brief  提交预支付订单
 *
 *  @param prePayParams 订单参数
 *
 *  @return 返回结果集
 */
- (NSString *)sendPrepay:(NSDictionary *)prePayParams
{
    NSString *prepayid = nil;

    //获取提交支付
    NSString *send = [self createPackage:prePayParams];

    //发送请求post xml数据
    NSData *res = [self sendPrePayHTTP:kWXUnifiedorderURL
                                method:@"POST"
                              SendData:send];

    CCXML *xml = [[CCXML alloc] init];
    //开始解析
    [xml startParse:res];

    NSMutableDictionary *resParams = [xml changeDictionary];

    //判断返回
    NSString *return_code = [resParams objectForKey:@"return_code"];
    NSString *result_code = [resParams objectForKey:@"result_code"];
    if ([return_code isEqualToString:@"SUCCESS"]) {
        //生成返回数据的签名
        NSString *sign = [[self createMd5Sign:resParams] lowercaseString];
        NSString *send_sign = [[resParams objectForKey:@"sign"] lowercaseString];

        //验证签名正确性
        if ([sign isEqualToString:send_sign]) { //获取预支付交易标示成功！
            if ([result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid = [resParams objectForKey:@"prepay_id"];
                //                return_code = 0;
            }
        } else { //服务器返回签名验证错误！！！
            //            last_errcode = 1;
        }
    } else { //接口返回错误！！！
        //        last_errcode = 2;
    }

    return prepayid;
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  发送预支付订单
 *
 *  @param requestURLString 请求地址
 *  @param method           请求类型
 *  @param sendData         发送数据
 *
 *  @return 返回请求结果
 */
- (NSData *)sendPrePayHTTP:(NSString *)requestURLString
                    method:(NSString *)method
                  SendData:(NSString *)sendData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURLString]
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:5];
    //设置提交方式
    [request setHTTPMethod:method];
    //设置数据类型
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    //设置编码
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    //如果是POST
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];

    NSError *error;
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil
                                                         error:&error];
    return response;
}

#pragma mark :. 生成签名
/**
 *  @author C C, 2015-12-04
 *
 *  @brief  生成package带参数的签名包
 *
 *  @param dict 请求参数
 *
 *  @return 返回签名
 */
- (NSString *)createPackage:(NSDictionary *)dict
{
    //生成package签名
    NSString *sign = [self createMd5Sign:dict];

    __block NSMutableString *reqPars = [NSMutableString string];
    //生成xml的package
    [reqPars appendString:@"<xml>\n"];

    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", key, obj, key];
    }];
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];

    return [NSString stringWithString:reqPars];
}

/**
 *  @author C C, 2015-12-04
 *
 *  @brief  生成package签名
 *
 *  @param dict 请求参数
 *
 *  @return 返回签名
 */
- (NSString *)createMd5Sign:(NSDictionary *)dict
{
    NSMutableString *contentString = [NSMutableString string];
    //按字母顺序排序
    NSArray *sortedArray = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (![categoryId isEqualToString:@"sign"] && ![categoryId isEqualToString:@"key"])
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", _wxPartnerKey];
    //得到MD5 sign签名
    NSString *md5Sign = [contentString MD5];

    return md5Sign;
}

@end
