//
//  CCHTTPRequest.m
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

#import "CCHTTPRequest.h"
#import "CCHTTPManager.h"

@implementation CCHTTPRequest


#pragma mark - 参数设置


/**
 全局设置请求HTTP Header头

 @param headerField 参数
 */
+ (void)setAppendingServerHTTPHeaderField:(NSDictionary *)headerField
{
    return [CCHTTPManager setHTTPheaderField:headerField];
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  设定固定请求参数
 *
 *  @param postData 请求参数
 */
+ (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:postData];
    return dic;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief 追加网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       CFSTR("!*'();@+$,%#[]"),
                                                                                       NULL,
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  追加扩展网络请求地址
 *
 *  @param MethodName API地址
 */
+ (NSString *)appendingExpandServerURLWithString:(NSString *)MethodName
{
    MethodName = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)MethodName,
                                                                                       NULL,
                                                                                       CFSTR("!*'();@+$,%#[]"),
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return MethodName;
}

/**
 *  @author CC, 2016-3-10
 *
 *  @brief  拼接请求网络地址
 *
 *  @param serviceAddres 服务器地址
 *  @param methodName    API地址
 */
+ (NSString *)appendingServerURLWithString:(NSString *)serviceAddres
                                MethodName:(NSString *)methodName
{
    return [[NSString stringWithFormat:@"%@%@", serviceAddres, methodName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

/**
 请求地址拼接
 格式: /xxxx?type=1&content=xxxx
 @param url API
 @param parameter 参数
 */
+ (NSString *)appendingUrlParameter:(NSString *)url
                          Parameter:(NSDictionary *)parameter
{
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@?", url];
    for (NSString *key in parameter.allKeys)
        [urlStr appendFormat:@"%@=%@&", key, [parameter objectForKey:key]];

    return [urlStr substringToIndex:urlStr.length - 1];
}

#pragma mark -
#pragma mark :. 网络请求并解析 异步

static id dataObj;


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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager GET:api
            parameters:parameter
           cachePolicy:2
               success:response
               failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager GET:requestURLString
            parameters:parameter
           cachePolicy:cachePolicy
               success:^(CCResponseObject *responseObject) {

                   dataObj = [self modelTransformationWithResponseObj:responseObject
                                                           modelClass:modelClass];

                   if ([dataObj isKindOfClass:modelClass]) {
                       if (response)
                           response(dataObj, nil);
                   } else {
                       if (failure)
                           failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                   }
               }
               failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager POST:api
             parameters:parameter
            cachePolicy:2
                success:response
                failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager POST:requestURLString
             parameters:parameter
            cachePolicy:cachePolicy
                success:^(CCResponseObject *responseObject) {
                    dataObj = [self modelTransformationWithResponseObj:responseObject
                                                            modelClass:modelClass];

                    if ([dataObj isKindOfClass:modelClass]) {
                        if (response)
                            response(dataObj, nil);
                    } else {
                        if (failure)
                            failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                    }
                }
                failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager DELETE:api
               parameters:parameter
              cachePolicy:2
                  success:response
                  failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager DELETE:requestURLString
               parameters:parameter
              cachePolicy:cachePolicy
                  success:^(CCResponseObject *responseObject) {
                      dataObj = [self modelTransformationWithResponseObj:responseObject
                                                              modelClass:modelClass];

                      if ([dataObj isKindOfClass:modelClass]) {
                          if (response)
                              response(dataObj, nil);
                      } else {
                          if (failure)
                              failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                      }
                  }
                  failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager HEAD:api
             parameters:parameter
            cachePolicy:2
                success:response
                failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager HEAD:requestURLString
             parameters:parameter
            cachePolicy:cachePolicy
                success:^(CCResponseObject *responseObject) {
                    if (response)
                        response(responseObject, nil);
                }
                failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager PUT:api
            parameters:parameter
           cachePolicy:2
               success:response
               failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager PUT:requestURLString
            parameters:parameter
           cachePolicy:cachePolicy
               success:^(CCResponseObject *responseObject) {
                   dataObj = [self modelTransformationWithResponseObj:responseObject
                                                           modelClass:modelClass];

                   if ([dataObj isKindOfClass:modelClass]) {
                       if (response)
                           response(dataObj, nil);
                   } else {
                       if (failure)
                           failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                   }
               }
               failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager PATCH:api
              parameters:parameter
             cachePolicy:2
                 success:response
                 failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager PATCH:requestURLString
              parameters:parameter
             cachePolicy:cachePolicy
                 success:^(CCResponseObject *responseObject) {
                     dataObj = [self modelTransformationWithResponseObj:responseObject
                                                             modelClass:modelClass];

                     if ([dataObj isKindOfClass:modelClass]) {
                         if (response)
                             response(dataObj, nil);
                     } else {
                         if (failure)
                             failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                     }
                 }
                 failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncGET:requestURLString
                parameters:parameter
               cachePolicy:cachePolicy
                   success:^(CCResponseObject *responseObject) {

                       dataObj = [self modelTransformationWithResponseObj:responseObject
                                                               modelClass:modelClass];

                       if ([dataObj isKindOfClass:modelClass]) {
                           if (response)
                               response(dataObj, nil);
                       } else {
                           if (failure)
                               failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                       }
                   }
                   failure:failure];
}

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
         failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncPOST:requestURLString
                 parameters:parameter
                cachePolicy:cachePolicy
                    success:^(CCResponseObject *responseObject) {
                        dataObj = [self modelTransformationWithResponseObj:responseObject
                                                                modelClass:modelClass];

                        if ([dataObj isKindOfClass:modelClass]) {
                            if (response)
                                response(dataObj, nil);
                        } else {
                            if (failure)
                                failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                        }
                    }
                    failure:failure];
}

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
           failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncDELETE:requestURLString
                   parameters:parameter
                  cachePolicy:cachePolicy
                      success:^(CCResponseObject *responseObject) {
                          dataObj = [self modelTransformationWithResponseObj:responseObject
                                                                  modelClass:modelClass];

                          if ([dataObj isKindOfClass:modelClass]) {
                              if (response)
                                  response(dataObj, nil);
                          } else {
                              if (failure)
                                  failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                          }
                      }
                      failure:failure];
}

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
         failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncHEAD:requestURLString
                 parameters:parameter
                cachePolicy:cachePolicy
                    success:^(CCResponseObject *responseObject) {
                        if (response)
                            response(responseObject, nil);
                    }
                    failure:failure];
}

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
        failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncPUT:requestURLString
                parameters:parameter
               cachePolicy:cachePolicy
                   success:^(CCResponseObject *responseObject) {
                       dataObj = [self modelTransformationWithResponseObj:responseObject
                                                               modelClass:modelClass];

                       if ([dataObj isKindOfClass:modelClass]) {
                           if (response)
                               response(dataObj, nil);
                       } else {
                           if (failure)
                               failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                       }
                   }
                   failure:failure];
}

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
          failure:(requestFailureBlock)failure
{
    [CCHTTPManager syncPATCH:requestURLString
                  parameters:parameter
                 cachePolicy:cachePolicy
                     success:^(CCResponseObject *responseObject) {
                         dataObj = [self modelTransformationWithResponseObj:responseObject
                                                                 modelClass:modelClass];

                         if ([dataObj isKindOfClass:modelClass]) {
                             if (response)
                                 response(dataObj, nil);
                         } else {
                             if (failure)
                                 failure(responseObject.userInfo, [NSError errorWithDomain:dataObj code:0 userInfo:@{ @"NSDebugDescription" : @"解析对象错误" }]);
                         }
                     }
                     failure:failure];
}

#pragma mark :. 上下传文件

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager Upload:requestURLString
               parameters:parameter
               fileConfig:fileConfig
                  success:success
                  failure:failure];
}

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
       failure:(requestFailureBlock)failure
{
    [CCHTTPManager Upload:requestURLString
                 filePath:filePath
                 progress:progress
                  success:success
                  failure:failure];
}

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
                  failure:(requestFailureBlock)failure
{
    [CCHTTPManager Download:requestURLString
                     fileName:fileName
        downloadProgressBlock:downloadProgressBlock
                      success:success
                      failure:failure];
}

/**
 *  @author CC, 16-03-10
 *
 *  @brief 下载文件缓存
 *
 *  @param requestURLString 请求地址
 *  @param success          完成回调
 */
+ (void)Download:(NSString *)requestURLString
         success:(CCRequestBacktrack)success
{
    [CCHTTPManager Download:requestURLString
                    success:success];
}

#pragma mark -
#pragma mark :. 网络请求解析处理

/**
 数组、字典转化为模型
 */
+ (id)modelTransformationWithResponseObj:(CCResponseObject *)responseObject modelClass:(Class)modelClass
{
    return nil;
}

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
    responseBlock:(CCRequestBacktrack)responseBlock
{
}

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
     responseBlock:(CCRequestBacktrack)responseBlock
{
}

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
       responseBlock:(CCRequestBacktrack)responseBlock
{
}

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
     responseBlock:(CCRequestBacktrack)responseBlock
{

}

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
    responseBlock:(CCRequestBacktrack)responseBlock
{

}

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
      responseBlock:(CCRequestBacktrack)responseBlock
{

}

@end
