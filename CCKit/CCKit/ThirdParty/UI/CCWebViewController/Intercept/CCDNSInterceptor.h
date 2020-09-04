//
//  CCDNSInterceptor.h
//  CCKit
//
//  Created by CC on 2020/8/22.
//  Copyright © 2020 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CCInvalidIpHandle)(NSURL *originUrl);

@interface CCDNSInterceptor : NSURLProtocol

/**
 *  @brief 监听SDN
 *
 *  @param invalidIpHandle DNS回调
 */
+ (void)registerInvalidIpHandle:(CCInvalidIpHandle)invalidIpHandle;

@end

@interface CCDNSInterceptor (WKCustomProtocol)

@property (class, nonatomic) BOOL enableWKCustomProtocol;

@end
