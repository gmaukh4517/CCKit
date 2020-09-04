//
//  CCDownloadMultiProxy.h
//  CCKit
//
//  Created by CC on 2020/8/19.
//  Copyright © 2020 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDownloadMultiProxy : NSObject

+ (CCDownloadMultiProxy *)proxy;

- (void)addDelegate:(id)delegate;

- (void)removeDelete:(id)delegate;

- (void)removeAllDelegates;

@end
