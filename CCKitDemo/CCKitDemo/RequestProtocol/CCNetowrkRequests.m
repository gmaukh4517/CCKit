//
//  CCNetowrkRequests.m
//  CCKitDemo
//
//  Created by CC on 2018/4/8.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCNetowrkRequests.h"

@implementation CCNetowrkRequests

+ (NSMutableDictionary *)appendingServerHTTPHeaderField
{
    NSMutableDictionary *headerField = [NSMutableDictionary dictionary];
    
    return headerField;
}


+ (NSMutableDictionary *)appendingServerParameters:(NSDictionary *)postParams
{
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithDictionary:postParams];
    
    return parameter;
}

+ (NSString *)appendingServerURLWithString:(NSString *)MethodName
{
    return [super appendingServerURLWithString:[NSString stringWithFormat:@"%@%@", ServiceAddress, MethodName]];
}


+ (void)handlePOST:(NSString *)api
        parameters:(NSDictionary *)parameter
     responseBlock:(CCRequestBacktrack)responseBlock
{
    NSString *urlString = [CCNetowrkRequests appendingServerURLWithString:api];
    [super POST:urlString
     parameters:[CCNetowrkRequests appendingServerParameters:parameter]
       response:^(CCResponseObject *responseObject) {
        if (!responseObject.error) {
            id responseData = [responseObject.result objectForKey:@"data"];
            if (responseData) {
                responseBlock(responseData, nil);
            } else {
                responseBlock(responseObject ? responseObject.result : nil, [CCNetowrkRequests httpErrorAnalysis:-1 errorContent:[responseObject.error objectForKey:@"msg"]]);
            }
        } else {
            responseBlock(responseObject ? responseObject.result : nil, [CCNetowrkRequests httpErrorAnalysis:[[responseObject.error objectForKey:@"code"] integerValue] errorContent:[responseObject.error objectForKey:@"msg"]]);
        }
    }
        failure:^(id response, NSError *error) {
        responseBlock(nil, error);
    }];
}

+ (void)handleGET:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock
{
    NSString *urlString = [CCNetowrkRequests appendingServerURLWithString:api];
    [super GET:urlString
    parameters:parameter
      response:^(CCResponseObject *responseObject) {
        if (!responseObject.error) {
            id responseData = [responseObject.result objectForKey:@"data"];
            if (responseData) {
                responseBlock(responseData, nil);
            } else {
                responseBlock(responseObject ? responseObject.result : nil, [CCNetowrkRequests httpErrorAnalysis:-1 errorContent:[responseObject.error objectForKey:@"msg"]]);
            }
        } else {
            responseBlock(responseObject ? responseObject.result : nil, [CCNetowrkRequests httpErrorAnalysis:[[responseObject.error objectForKey:@"code"] integerValue] errorContent:[responseObject.error objectForKey:@"msg"]]);
        }
    }
       failure:^(id response, NSError *error) {
        responseBlock(nil, error);
    }];
}

+ (NSError *)httpErrorAnalysis:(NSInteger)code
                  errorContent:(NSString *)content
{
    NSString *errorContent = content.length ? content : @"请求服务器失败";
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    
    if ([errorInfo.allKeys containsObject:@(code)])
        errorContent = [errorInfo objectForKey:@(code)];
    
    return [NSError errorWithDomain:errorContent code:code > 0 ? code : -1 userInfo:@{ @"errorCode" : @(code) ?: @"0" }];
}

#pragma mark -
#pragma mark :. 请求地址

NSString *const API_DEMO = @"api/demo";

@end
