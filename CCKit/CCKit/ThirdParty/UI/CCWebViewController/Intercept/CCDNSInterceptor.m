//
//  CCDNSInterceptor.m
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import "CCDNSInterceptor.h"
#import "CCHostFilterRule.h"
#import "CCHostMapper.h"

#define INVALID_STATUS_CODE 404
static CCInvalidIpHandle CCInvalidIPHandle;
static void (^CCURLSessionConfigure)(NSURLSessionConfiguration *configuration);

static NSString *const kCCNSURLProtocolKey = @"KCCNSURLProtocolKey";

@interface CCDNSInterceptor ()

@property (nonatomic, copy) NSURL *originUrl;
@property (nonatomic, copy) CCInvalidIpHandle invalidIpHandle;

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation CCDNSInterceptor

+ (void)registerInvalidIpHandle:(CCInvalidIpHandle)invalidIpHandle
{
    CCInvalidIPHandle = invalidIpHandle;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return ([NSURLProtocol propertyForKey:kCCNSURLProtocolKey inRequest:task.currentRequest] == nil);
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ([NSURLProtocol propertyForKey:kCCNSURLProtocolKey inRequest:request] == nil);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSString *host = request.URL.host;
    NSString *ip = [CCHostMapper parseHost:host];
    if (!ip)
        return request;
    
    if ([CCHostFilterRule isIpInvalid:ip])
        return request;
    
    NSString *absoluteURLString = request.URL.absoluteString;
    NSRange range = [absoluteURLString rangeOfString:host];
    if (range.location == NSNotFound)
        return request;
    
    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange:range withString:ip];
    NSMutableURLRequest *canonicalRequest = request.mutableCopy;
    canonicalRequest.URL = [NSURL URLWithString:absoluteURLString];
    return canonicalRequest;
}

- (void)startLoading
{
    NSMutableURLRequest *request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:kCCNSURLProtocolKey inRequest:request];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    [NSURLProtocol removePropertyForKey:kCCNSURLProtocolKey inRequest:self.connection.currentRequest.mutableCopy];
}

#pragma mark -
#pragma mark :. NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == INVALID_STATUS_CODE && CCInvalidIPHandle) {
            NSString *host = response.URL.host;
            if ([CCHostMapper validIp:host]) {
                [connection cancel];
                [CCHostFilterRule registerInvailIp:host];
                
                NSString *absoluteURLString = response.URL.absoluteString;
                NSRange range = [absoluteURLString rangeOfString:host];
                if (range.location != NSNotFound) {
                    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange:range withString:[CCHostFilterRule getHostFromIpAddress:host]];
                    CCInvalidIPHandle([NSURL URLWithString:absoluteURLString]);
                }
            }
        }
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

@end


@implementation CCDNSInterceptor (WKCustomProtocol)

static BOOL kCCEnableWKCustomProtocol = NO;

+ (void)setEnableWKCustomProtocol:(BOOL)enableWKCustomProtocol
{
    kCCEnableWKCustomProtocol = enableWKCustomProtocol;
    id contextController = NSClassFromString([NSString stringWithFormat:@"%@%@%@", @"WK", @"Browsing", @"ContextController"]);
    if (!contextController) {
        return;
    }
    SEL performSEL = nil;
    if (enableWKCustomProtocol) {
        performSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"register", @"SchemeForCustomProtocol:"]);
    } else {
        performSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"unregister", @"SchemeForCustomProtocol:"]);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([contextController respondsToSelector:performSEL]) {
        [contextController performSelector:performSEL withObject:@"http"];
        [contextController performSelector:performSEL withObject:@"https"];
    }
#pragma clang diagnostic pop
}

+ (BOOL)enableWKCustomProtocol
{
    return kCCEnableWKCustomProtocol;
}

@end
