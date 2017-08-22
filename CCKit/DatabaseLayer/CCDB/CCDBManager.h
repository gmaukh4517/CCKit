//
//  CCDBManager.h
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

@interface CCDBManager : NSObject

#pragma mark :. tableHandle

/**
 清空表数据
 
 @param tableName 表名
 */
+ (BOOL)ccdb_clear:(NSString *)tableName;

/**
 异步清空表数据
 
 @param tableName 表名
 @param complete 完成回调
 */
+ (void)ccdb_claerAsync:(NSString *)tableName
               complete:(void (^)(BOOL isSuccess))complete;

/**
 删除表
 
 @param tableName 表名
 */
+ (BOOL)ccdb_deleteTable:(NSString *)tableName;

/**
 异步删除表
 
 @param tableName 表名
 @param complete 完成回调
 */
+ (void)ccdb_deleteAsyncTable:(NSString *)tableName
                     complete:(void (^)(BOOL isSuccess))complete;

#pragma mark -
#pragma mark :. insert (sync/async)
/** 插入数据 **/
+ (BOOL)ccdb_insertObject:(id)object;

/** 异步插入数据 **/
+ (void)ccdb_insertAsyncObject:(id)object
                      complete:(void (^)(BOOL isSuccess))complete;

/** 批量插入数据 **/
+ (BOOL)ccdb_insertArray:(NSArray *)arr;

/** 异步批量插入数据 **/
+ (void)ccdb_insertAsyncArr:(NSArray *)arr
                   complete:(void (^)(BOOL isSuccess))complete;

#pragma mark -
#pragma mark :. delete (sync/async)
/**
 删除表数据
 
 @param tableName 表名
 @param where 条件数组
 *      形式@[@"user.student.name",cc_equal,@"小芳",@"user.student.conten",cc_contains,@"书"]
 *      即更新user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象.
 */
+ (BOOL)ccdb_deleteWhere:(NSString *)tableName
                   where:(NSArray *)where;

/**
 异步删除表数据
 
 @param tableName 表名
 @param where 条件数组
 *      形式@[@"user.student.name",cc_equal,@"小芳",@"user.student.conten",cc_contains,@"书"]
 *      即更新user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象.
 @param complete 完成回调
 */
+ (void)ccdb_deleteAsyncWhere:(NSString *)tableName
                        where:(NSArray *)where
                     complete:(void (^)(BOOL isSuccess))complete;

/**
 删除数据(sql)
 
 @param tableName 表名
 @param conditions sql语句
 */
+ (BOOL)ccdb_deleteSqlConditions:(NSString *)tableName
                      conditions:(NSString *)conditions;

/**
 删除数据(根据KeyPath)
 
 @param tableName 表名
 @param keyPathValues keyPathValues
 */
+ (BOOL)ccdb_deleteKeyPathValue:(NSString *)tableName
                  keyPathValues:(NSArray *)keyPathValues;

/**
 异步删除数据(根据KeyPath)
 
 @param tableName 表名
 @param keyPathValues keyPathValues
 @param complete 完成回调
 */
+ (void)ccdb_deleteAsyncKeyPathValue:(NSString *)tableName
                       keyPathValues:(NSArray *)keyPathValues
                            complete:(void (^)(BOOL isSuccess))complete;

#pragma mark -
#pragma mark :. update (sync/async)

/**
 更新数据
 
 @param object 更新对象
 @param where  匹配条件
 *      条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即更新name=标哥,age=>25的数据. 可以为nil,nil时更新所有数据;
 *      不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 */
+ (BOOL)ccdb_updateTableObject:(id)object
                         where:(NSArray *)where;

/**
 更新表数据(字段)
 
 @param tableName 表名
 @param keyValue 更新字段键值
 @param where 语句条件
 *      条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即更新name=标哥,age=>25的数据. 可以为nil,nil时更新所有数据;
 *      不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 @param complete 完成回调
 */
+ (void)ccdb_updateTableObject:(NSString *)tableName
                      KeyValue:(NSDictionary *)keyValue
                         where:(NSArray *)where
                      complete:(void (^)(BOOL isSuccess))complete;

/**
 更新表数据(Sql)
 
 @param tableName 表名
 @param keyValue 更新字段键值
 @param conditions Sql
 @param complete 完成回调
 */
+ (void)ccdb_updateSQLTableObject:(NSString *)tableName
                         keyValue:(NSDictionary *)keyValue
                       conditions:(NSString *)conditions
                         complete:(void (^)(BOOL isSuccess))complete;

/**
 更新数据(对象方式并检查数据结构)
 
 @param object 对象
 @param conditions sql语句
 @param complete 完成回调
 */
+ (void)ccdb_updateSQLQueueTableObject:(id)object
                            conditions:(NSString *)conditions
                              complete:(void (^)(BOOL isSuccess))complete;

/**
 模糊更新数据
 
 @param tableName 表名
 @param keyPathValues 模糊条件
 @param keyValue 更行字段键值
 @param complete 完成回调
 */
+ (void)ccdb_updateTableLikeObject:(NSString *)tableName
               forKeyPathAndValues:(NSArray *)keyPathValues
                          keyValue:(NSDictionary *)keyValue
                          complete:(void (^)(BOOL isSuccess))complete;


/**
 批量更新数据
 
 @param tableName 表名
 @param objArr 更行数据集合
 @param complete 完成回调
 */
+ (void)ccdb_updateBatchTableObject:(NSString *)tableName
                        batchObject:(NSArray<NSDictionary *> *)objArr
                           complete:(void (^)(BOOL isSuccess))complete;

/**
 批量更新数据
 
 @param objects 对象集合
 @param complete 完成回调
 */
+ (void)ccdb_updateBatchTableObject:(NSArray *)objects
                           complete:(void (^)(BOOL isSuccess))complete;


#pragma mark -
#pragma mark :. select

/**
 查询表中有多少条数据
 
 @param tableName 表名
 @param where 查询条件
 */
+ (NSInteger)ccdb_selectTableHasCount:(NSString *)tableName
                                where:(NSArray *)where;

/**
 查询表中有多少条数据(sql)
 
 @param tableName 表名
 @param conditions sql查询条件
 */
+ (NSInteger)ccdb_selectTableHasCount:(NSString *)tableName
                           conditions:(NSString *)conditions;

/**
 函数查询表数据
 
 @param tableName 表名
 @param methodType 函数类型
 *                 求最小值 = 0
 *                 求最大值 = 1
 *                 求总和值 = 2
 *                 求平均值 = 3
 @param key 字段名
 @param where 查询语句(sql)
 */
+ (NSInteger)ccdb_selectTableMethodCount:(NSString *)tableName
                                    type:(NSInteger)methodType
                                     key:(NSString *)key
                                   where:(NSString *)where;


/**
 like查询（keyPath方式）数量
 
 @param tableName 表名
 @param keyPathValues 数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 即查询user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象的条数.
 */
+ (NSInteger)ccdb_selectTableLikeCount:(NSString *)tableName
                   forKeyPathAndValues:(NSArray *)keyPathValues;

/**
 查询表(sql语句)
 
 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
+ (NSArray *)ccdb_selectTableObject:(NSString *)tableName
                         conditions:(NSString *)conditions;

/**
 查询表键值语句
 
 @param tableName 表名
 @param keys 键值
 @param where 语句
 @param complete 完成回调
 */
+ (NSArray *)ccdb_selectTableKeyValuesWithWhereObject:(NSString *)tableName
                                                 keys:(NSArray *)keys
                                                where:(NSArray *)where;

/**
 查询表跟随语句
 
 @param tableName 表名
 @param param 跟随局域
 @param where 查询条件
 @param complete 完成回调函数
 */
+ (NSArray *)ccdb_selectTableParamWhereObject:(NSString *)tableName
                                        where:(NSArray *)where
                                        param:(NSString *)param;

/**
 查询表like
 
 @param tableName 表名
 @param keyPathValues 键值
 @param complete 完成回调
 */
+ (NSArray *)ccdb_selectTableKeyValuesObject:(NSString *)tableName
                         forKeyPathAndValues:(NSArray *)keyPathValues;

/**
 查询表所有数据
 
 @param tableName 表名
 */
+ (NSArray *)ccdb_selectTableAll:(NSString *)tableName;

/**
 条件查询表数据
 
 @param tableName 表名
 @param where 查询条件
 */
+ (NSArray *)ccdb_selectTableWhere:(NSString *)tableName
                             where:(NSArray *)where;

/**
 分段排序查询数据
 
 @param tableName 表名
 @param limit 每次查询限制的条数,0则无限制.
 @param orderBy 排序字段
 @param desc  YES:降序，NO:升序.
 */
+ (NSArray *)ccdb_selectTableAllWithLimit:(NSString *)tableName
                                    limit:(NSInteger)limit
                                  orderBy:(NSString *)orderBy
                                     desc:(BOOL)desc;

/**
 分页查询
 
 @param tableName 表名
 @param limit 查询范围 开始位置
 @param offset 查询范围 条数
 @param where 查询条件
 */
+ (NSArray *)ccdb_selectTablePage:(NSString *)tableName
                            limit:(int)limit
                           offset:(int)offset
                            where:(NSArray *)where;

/**
 分页排序查询数据
 
 @param tableName 表名
 @param limit 查询范围 开始位置
 @param offset 查询范围 条数
 @param orderBy 排序字段
 @param desc YES:降序，NO:升序.
 @param where 查询条件
 */
+ (NSArray *)ccdb_selectTablePage:(NSString *)tableName
                            limit:(int)limit
                           offset:(int)offset
                          orderBy:(NSString *)orderBy
                             desc:(BOOL)desc
                            where:(NSArray *)where;

/**
 分组查询数据
 
 @param tableName 表名
 @param groupBy 分组字段
 @param where 查询条件
 */
+ (NSArray *)ccdb_selectTableGroup:(NSString *)tableName
                           groupBy:(NSString *)groupBy
                             where:(NSArray *)where;

#pragma mark -
#pragma mark :. monitorHandel
/**
 注册数据变化监听
 
 @param tableName 注册数据变化监听
 @param block 监听回调
 *            插入数据 = 0
 *            更新数据 = 1
 *            删除数据 = 2
 *            删表数据 = 3
 */
+ (BOOL)registerChangeWithName:(NSString *)tableName
                   changeBlock:(void (^)(NSInteger result))block;

/** 移除数据变化监听 **/
+ (BOOL)removeChangeWithName:(NSString *)tableName;

@end
