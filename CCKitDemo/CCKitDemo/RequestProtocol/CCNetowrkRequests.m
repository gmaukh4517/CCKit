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
    [super POST:urlString parameters:[CCNetowrkRequests fixedParameters:parameter] response:^(CCResponseObject *responseObject) {
       if ([responseObject.status isEqualToString:@"0"]) {
            responseBlock(responseObject.data, nil);
        } else {
            responseBlock(responseObject ? responseObject.data : nil, [CCNetowrkRequests httpErrorAnalysis:responseObject.status errorContent:responseObject.msg]);
        }
    } failure:^(id response, NSError *error) {
          responseBlock(nil, error);
    }];
}

+ (void)handleGET:(NSString *)api
       parameters:(NSDictionary *)parameter
    responseBlock:(CCRequestBacktrack)responseBlock
{
    NSString *urlString = [CCNetowrkRequests appendingServerURLWithString:api];
    [super GET:urlString parameters:parameter response:^(CCResponseObject *responseObject) {
         if ([responseObject.status isEqualToString:@"0"]) {
            responseBlock(responseObject.data, nil);
        } else {
            responseBlock(responseObject ? responseObject.data : nil, [CCNetowrkRequests httpErrorAnalysis:responseObject.status errorContent:responseObject.msg]);
        }
    } failure:^(id response, NSError *error) {
         responseBlock(nil, error);
    }];
}

+ (NSError *)httpErrorAnalysis:(NSString *)code
                  errorContent:(NSString *)content
{
    NSString *errorContent = content.length ? content : @"请求服务器失败";

    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];

    if ([errorInfo.allKeys containsObject:code])
        errorContent = [errorInfo objectForKey:code];

    return [NSError errorWithDomain:errorContent code:[code integerValue] > 0 ? [code integerValue] : -1 userInfo:@{ @"errorCode" : code ?: @"0" }];
}

#pragma mark -
#pragma mark :. 请求地址

NSString *const API_DEMO = @"api/demo";

@end
