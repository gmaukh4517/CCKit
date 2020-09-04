//
//  CCHTTPProtocol.h
//  CCKit
//
//  Created by CC on 2020/6/29.
//  Copyright © 2020 CC. All rights reserved.
//

#ifndef CCHTTPProtocol_h
#define CCHTTPProtocol_h

@class CCResponseObject;

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求成功Block
 */
typedef void (^requestSuccessBlock)(CCResponseObject *responseObject);

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求失败Block
 */
typedef void (^requestFailureBlock)(id response, NSError *error);

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求进度Block
 */
typedef void (^requestProgressBlock)(NSProgress *progress);

/**
 *  @author C C, 16-03-10
 *
 *  @brief  请求响应结果
 *
 *  @param data  下载数据
 *  @param error 错误信息
 */
typedef void (^requestDownloadBacktrack)(NSData *data, NSError *error);

/**
 *  @author CC, 16-03-10
 *
 *  @brief 请求下载文件回调
 *
 *  @param response 响应结果
 *  @param error    错误信息
 */
typedef void (^requestDownloadsuccess)(id response, NSError *error);

#endif /* CCHTTPProtocol_h */
