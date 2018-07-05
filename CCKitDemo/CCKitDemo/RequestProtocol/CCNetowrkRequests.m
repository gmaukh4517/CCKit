//
//  CCNetowrkRequests.m
//  CCKitDemo
//
//  Created by CC on 2018/4/8.
//  Copyright © 2018年 CC. All rights reserved.
//

#import "CCNetowrkRequests.h"

@implementation CCNetowrkRequests

+ (NSMutableDictionary *)fixedParameters:(NSDictionary *)postData
{
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithDictionary:postData];

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
    [CCHTTPManager POST:urlString
        parameters:[CCNetowrkRequests fixedParameters:parameter]
        success:^(CCResponseObject *responseObject) {
            if (responseObject.Code) {
                responseBlock(responseObject.Data, nil);
            } else {
                responseBlock(nil, [CCNetowrkRequests httpErrorAnalysis:responseObject.Code errorContent:responseObject.Msg]);
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
    [CCHTTPManager GET:urlString
        parameters:parameter
        success:^(CCResponseObject *responseObject) {
            if (responseObject.Code) {
                responseBlock(responseObject.Data, nil);
            } else {
                responseBlock(nil, [CCNetowrkRequests httpErrorAnalysis:responseObject.Code errorContent:responseObject.Msg]);
            }
        }
        failure:^(id response, NSError *error) {
            responseBlock(nil, error);
        }];
}

+ (NSError *)httpErrorAnalysis:(NSInteger)code
                  errorContent:(NSString *)content
{
    NSString *errorContent = content ?: @"请求服务器失败";

    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];


    if ([errorInfo.allKeys containsObject:@(code)])
        errorContent = [errorInfo objectForKey:@(code)];

    return [NSError errorWithDomain:errorContent code:code userInfo:nil];
}

#pragma mark -
#pragma mark :. 请求地址

NSString *const API_DEMO = @"api/demo";

@end
