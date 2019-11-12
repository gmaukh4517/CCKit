//
//  NSObject+CCDBAdd.h
//  CCKit
//
// Copyright (c) 2017 CC ( https://github.com/gmaukh4517/CCKit )
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

#import <Foundation/Foundation.h>

/** 数组中需要转换的模型类 */
typedef NSDictionary * (^CCDBObjectClassInArray)(void);

@interface NSObject (CCDBAdd)

/** 本库自带的自动增长主键. **/
@property (nonatomic, strong) NSNumber *ccdb_identifier;
/** 数据创建时间(即存入数据库的时间) **/
@property (nonatomic, copy) NSString *ccdb_createTime;
/** 数据最后那次更新的时间. **/
@property (nonatomic, copy) NSString *ccdb_updateTime;

+(void)ccdb_setupObjectClassInArray:(CCDBObjectClassInArray)objectClassInArray;

@end
