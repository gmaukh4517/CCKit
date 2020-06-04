//
//  CCHTTPRequest.h
//  CCKit
//
// Copyright (c) 2015 CC
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

#import "CCResponseObject.h"
#import "HttpFileConfig.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCHTTPRequestCachePolicy) {
    /** 不作任何处理，只请求数据 */
    CCHTTPReturnDefault = 0,
    /** 有缓存就先返回缓存，同步请求数据 */
    CCHTTPReturnCacheDataThenLoad,
    /** 忽略缓存，重新请求 */
    CCHTTPReloadIgnoringLocalCacheData,
    /** 有缓存就用缓存，没有缓存就重新请求(用于数据不变时) */
    CCHTTPReturnCacheDataElseLoad,
    /** 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）*/
    CCHTTPReturnCacheDataDontLoad
};

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求响应结果
 */
typedef void (^responseBlock)(id responseObj, NSError *error);
typedef void (^CCRequestBacktrack)(id responseObject, NSError *error);
/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求失败Block
 */
typedef void (^requestFailureBlock)(id response, NSError *error);
/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求成功Block
 */
typedef void (^requestSuccessBlock)(CCResponseObject *responseObject);

@interface CCHTTPRequest : NSObject

/**
 全局设置请求HTTP Header头
 
 @param headerField 参数
 */
+ (void)setAppendingServerHTTPHeaderField:(NSDictionary *)headerField;

/**
 全局设置请求 传递参数UserInfo
 
 @param userInfo 参数
 */
+ (void)setAppendingServerHTTPUserInfo:(NSDictionary *)userInfo;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 */
+ (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief 追加网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)MethodName;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  追加扩展网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName;

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  拼接请求网络地址
 *
 *  @param serviceAddres 服务器地址
 *  @param methodName    API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)serviceAddres
                                MethodName:(NSString *)methodName;

/**
 请求地址拼接
 格式: /xxxx?type=1&content=xxxx
 @param url API
 @param parameter 参数
 */
+ (NSString *)appendingUrlParameter:(NSString *)url
                          Parameter:(NSDictionary *)parameter;

#pragma mark -
#pragma mark :. 网络请求并解析 异步

/**
 *  @author CC, 16-04-06
 *
 *  @brief GET请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)GET:(NSString *)api
 parameters:(NSDictionary *)parameter
   response:(requestSuccessBlock)response
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief GET请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)GET:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
 modelClass:(Class)modelClass
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
   response:(responseBlock)response
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-04-06
 *
 *  @brief POST请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)POST:(NSString *)api
  parameters:(NSDictionary *)parameter
    response:(requestSuccessBlock)response
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief POST请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)POST:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
  modelClass:(Class)modelClass
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    response:(responseBlock)response
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-04-06
 *
 *  @brief ELETE请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)DELETE:(NSString *)api
    parameters:(NSDictionary *)parameter
      response:(requestSuccessBlock)response
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief DELETE请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)DELETE:(NSString *)requestURLString
    parameters:(NSDictionary *)parameter
    modelClass:(Class)modelClass
   cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
      response:(responseBlock)response
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-04-06
 *
 *  @brief HEAD请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)HEAD:(NSString *)api
  parameters:(NSDictionary *)parameter
    response:(requestSuccessBlock)response
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief HEAD请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)HEAD:(NSString *)requestURLString
  parameters:(NSDictionary *)parameter
  modelClass:(Class)modelClass
 cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
    response:(responseBlock)response
     failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-04-06
 *
 *  @brief PUT请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)PUT:(NSString *)api
 parameters:(NSDictionary *)parameter
   response:(requestSuccessBlock)response
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief PUT请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)PUT:(NSString *)requestURLString
 parameters:(NSDictionary *)parameter
 modelClass:(Class)modelClass
cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
   response:(responseBlock)response
    failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-04-06
 *
 *  @brief PATCH请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param response      请求响应结果
 *  @param failure       故障处理回调
 */
+ (void)PATCH:(NSString *)api
   parameters:(NSDictionary *)parameter
     response:(requestSuccessBlock)response
      failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief PATCH请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)PATCH:(NSString *)requestURLString
   parameters:(NSDictionary *)parameter
   modelClass:(Class)modelClass
  cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
     response:(responseBlock)response
      failure:(requestFailureBlock)failure;

#pragma mark :. 网络请求并解析 同步
/**
 *  @author CC, 16-03-10
 *
 *  @brief GET请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncGET:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
     modelClass:(Class)modelClass
    cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
       response:(responseBlock)response
        failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief POST请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncPOST:(NSString *)requestURLString
      parameters:(NSDictionary *)parameter
      modelClass:(Class)modelClass
     cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
        response:(responseBlock)response
         failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief DELETE请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncDELETE:(NSString *)requestURLString
        parameters:(NSDictionary *)parameter
        modelClass:(Class)modelClass
       cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
          response:(responseBlock)response
           failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief HEAD请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncHEAD:(NSString *)requestURLString
      parameters:(NSDictionary *)parameter
      modelClass:(Class)modelClass
     cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
        response:(responseBlock)response
         failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief PUT请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncPUT:(NSString *)requestURLString
     parameters:(NSDictionary *)parameter
     modelClass:(Class)modelClass
    cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
       response:(responseBlock)response
        failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief PATCH请求
 *
 *  @param requestURLString 请求地址
 *  @param parameter        请求参数
 *  @param modelClass       模型Class
 *  @param cachePolicy      缓存类型
 *  @param response         请求响应结果
 *  @param failure          故障处理回调
 */
+ (void)syncPATCH:(NSString *)requestURLString
       parameters:(NSDictionary *)parameter
       modelClass:(Class)modelClass
      cachePolicy:(CCHTTPRequestCachePolicy)cachePolicy
         response:(responseBlock)response
          failure:(requestFailureBlock)failure;

#pragma mar -
#pragma mar :.上下传文件

/**
 *  @author CC, 16-03-10
 *
 *  @brief 上传文件(表单提交)
 *
 *  @param requestURLString 请求地址
 *  @param parameter        发送阐述
 *  @param fileConfig       文件对象
 *  @param success          完成回调
 *  @param failure          故障回调
 */
+ (void)Upload:(NSString *)requestURLString
    parameters:(id)parameter
    fileConfig:(HttpFileConfig *)fileConfig
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief 上传文件（流）
 *
 *  @param requestURLString 请求地址
 *  @param filePath         文件地址
 *  @param progress         进度
 *  @param success          完成回调
 *  @param failure          故障回调
 */
+ (void)Upload:(NSString *)requestURLString
      filePath:(NSString *)filePath
      progress:(NSProgress *__autoreleasing *)progress
       success:(requestSuccessBlock)success
       failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief 下载文件
 *
 *  @param requestURLString      请求地址
 *  @param fileName              文件名
 *  @param downloadProgressBlock 进度回调
 *  @param success               完成回调
 *  @param failure               故障回调
 */
+ (void)Download:(NSString *)requestURLString
        fileName:(NSString *)fileName
downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock
         success:(CCRequestBacktrack)success
         failure:(requestFailureBlock)failure;

/**
 *  @author CC, 16-03-10
 *
 *  @brief 下载文件缓存
 *
 *  @param requestURLString 请求地址
 *  @param success          完成回调
 */
+ (void)Download:(NSString *)requestURLString
         success:(CCRequestBacktrack)success;

#pragma mark -
#pragma mark :. 网络请求解析处理   PS:如需使用必须在子类实现该函数

/**
 *  @author CC, 16-03-10
 *
 *  @brief 数组、字典转模型，提供给子类的接口
 *
 *  @param responseObject 响应结果
 *  @param modelClass     模型对象
 */
+ (id)modelTransformationWithResponseObj:(CCResponseObject *)responseObject
                              modelClass:(Class)modelClass;

/**
 *  @author CC, 16-04-06
 *
 *  @brief GET请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleGET:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock;

/**
 *  @author CC, 16-04-06
 *
 *  @brief POST请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePOST:(NSString *)api
        parameters:(NSDictionary *)parameter
     responseBlock:(CCRequestBacktrack)responseBlock;

/**
 *  @author CC, 16-04-06
 *
 *  @brief ELETE请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleDELETE:(NSString *)api
          parameters:(NSDictionary *)parameter
       responseBlock:(CCRequestBacktrack)responseBlock;

/**
 *  @author CC, 16-04-06
 *
 *  @brief HEAD请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handleHEAD:(NSString *)api
        parameters:(NSDictionary *)parameter
     responseBlock:(CCRequestBacktrack)responseBlock;

/**
 *  @author CC, 16-04-06
 *
 *  @brief PUT请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePUT:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock;

/**
 *  @author CC, 16-04-06
 *
 *  @brief PATCH请求处理
 *
 *  @param api           API地址
 *  @param parameter     发送参数
 *  @param responseBlock 回调函数
 */
+ (void)handlePATCH:(NSString *)api
         parameters:(NSDictionary *)parameter
      responseBlock:(CCRequestBacktrack)responseBlock;

@end
