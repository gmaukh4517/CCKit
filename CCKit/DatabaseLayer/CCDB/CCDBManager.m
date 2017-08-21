//
//  CCDBManager.m
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

#import "CCDBManager.h"
#import "CCDBTool.h"
#import "CCDatabase.h"

static NSString *const kPRIMARYKEY = @"cc_identifier";

/** 在主队列上提交用于异步执行的块 **/
static inline void ccdb_dispatch_async_on_global_queue(void (^block)())
{
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

@implementation CCDBManager

/** 自定义数据库名 **/
void CCDBSqliteName(NSString *sqliteName)
{
    if (![sqliteName isEqualToString:[CCDatabase shareManager].sqliteName])
        [CCDatabase shareManager].sqliteName = sqliteName;
}

/** 删除数据库 **/
BOOL CCDBDeleteSqlite(NSString *sqliteName)
{
    return [CCDatabase deleteSqlite:sqliteName];
}
/** 是否输入日志 **/
void CCDBEnterLog(BOOL debug)
{
    if ([CCDatabase shareManager].debug != debug) //防止重复设置.
        [CCDatabase shareManager].debug = debug;
}

#pragma mark :. tableHandle


/**
 清空表数据
 
 @param tableName 表名
 */
+ (BOOL)ccdb_clear:(NSString *)tableName
{
    __block BOOL result;
    [[CCDatabase shareManager] clearTable:tableName
                                 complete:^(BOOL isSuccess) {
                                     result = isSuccess;
                                 }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/**
 异步清空表数据
 
 @param tableName 表名
 @param complete 完成回调
 */
+ (void)ccdb_claerAsync:(NSString *)tableName complete:(void (^)(BOOL isSuccess))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL flag = [self ccdb_clear:tableName];
        !complete ?: complete(flag);
    });
}


/**
 删除表
 
 @param tableName 表名
 @param complete 完成回调
 */
+ (BOOL)ccdb_deleteTable:(NSString *)tableName
{
    __block BOOL result;
    [[CCDatabase shareManager] isExistWithTableName:tableName
                                           complete:^(BOOL isSuccess) { //判断表是否存在
                                               if (isSuccess) {
                                                   [[CCDatabase shareManager] deleteTable:tableName
                                                                                 complete:^(BOOL dSuccess) { //存在删除表
                                                                                     result = dSuccess;
                                                                                 }];
                                               }
                                           }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/**
 异步删除表
 
 @param tableName 表名
 @param complete 完成回调
 */
+ (void)ccdb_deleteAsyncTable:(NSString *)tableName
                     complete:(void (^)(BOOL isSuccess))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL flag = [self ccdb_deleteTable:tableName];
        !complete ?: complete(flag);
    });
}

#pragma mark -
#pragma mark :. insert (sync/async)
/** 插入数据 **/
+ (BOOL)ccdb_insertObject:(id)object
{
    __block BOOL result;
    [[CCDatabase shareManager] inserQueueTableObject:object
                                            complete:^(BOOL isSuccess) {
                                                result = isSuccess;
                                            }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/** 异步插入数据 **/
+ (void)ccdb_insertAsyncObject:(id)object
                      complete:(void (^)(BOOL isSuccess))complete
{
    ccdb_dispatch_async_on_global_queue(^{
        BOOL flag = [self ccdb_insertObject:object];
        !complete ?: complete(flag);
    });
}

/** 批量插入数据 **/
+ (BOOL)ccdb_insertArray:(NSArray *)arr
{
    NSAssert(arr || arr.count, @"数组没有元素!");
    __block BOOL result = YES;
    [[CCDatabase shareManager] insertQueueBatchTableObject:arr
                                                  complete:^(BOOL isSuccess) {
                                                      result = isSuccess;
                                                  }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/** 异步批量插入数据 **/
+ (void)ccdb_insertAsyncArr:(NSArray *)arr
                   complete:(void (^)(BOOL isSuccess))complete
{
    ccdb_dispatch_async_on_global_queue(^{
        BOOL flag = [self ccdb_insertArray:arr];
        !complete ?: complete(flag);
    });
}

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
                   where:(NSArray *)where
{
    __block BOOL result;
    [[CCDatabase shareManager] deleteTableObject:tableName
                                           where:where
                                        complete:^(BOOL isSuccess) {
                                            result = isSuccess;
                                        }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

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
                     complete:(void (^)(BOOL isSuccess))complete
{
    ccdb_dispatch_async_on_global_queue(^{
        BOOL flag = [self ccdb_deleteWhere:tableName
                                     where:where];
        !complete ?: complete(flag);
    });
}

/**
 删除数据(sql)
 
 @param tableName 表名
 @param conditions sql语句
 */
+ (BOOL)ccdb_deleteSqlConditions:(NSString *)tableName
                      conditions:(NSString *)conditions
{
    __block BOOL result;
    [[CCDatabase shareManager] deleteSQLTableObject:tableName
                                         conditions:conditions
                                           complete:^(BOOL isSuccess) {
                                               result = isSuccess;
                                           }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/**
 删除数据(根据KeyPath)
 
 @param tableName 表名
 @param keyPathValues keyPathValues
 */
+ (BOOL)ccdb_deleteKeyPathValue:(NSString *)tableName
                  keyPathValues:(NSArray *)keyPathValues
{
    __block BOOL result;
    [[CCDatabase shareManager] deleteLikeTableObjec:tableName
                                forKeyPathAndValues:keyPathValues
                                           complete:^(BOOL isSuccess) {
                                               result = isSuccess;
                                           }];
    //关闭数据库
    [[CCDatabase shareManager] closeDB];
    return result;
}

/**
 异步删除数据(根据KeyPath)
 
 @param tableName 表名
 @param keyPathValues keyPathValues
 @param complete 完成回调
 */
+ (void)ccdb_deleteAsyncKeyPathValue:(NSString *)tableName
                       keyPathValues:(NSArray *)keyPathValues
                            complete:(void (^)(BOOL isSuccess))complete
{
    ccdb_dispatch_async_on_global_queue(^{
        BOOL flag = [self ccdb_deleteKeyPathValue:tableName keyPathValues:keyPathValues];
        !complete ?: complete(flag);
    });
}

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
                         where:(NSArray *)where
{
    BOOL result = [[CCDatabase shareManager] updateTableObjec:object where:where];
    [[CCDatabase shareManager] closeDB];
    return result;
}

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
                      complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateTableObject:tableName
                                        KeyValue:keyValue
                                           where:where
                                        complete:^(BOOL isSuccess) {
                                            [[CCDatabase shareManager] closeDB];
                                            !complete ?: complete(isSuccess);
                                        }];
}

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
                         complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateSQLTableObject:tableName
                                           keyValue:keyValue
                                         conditions:conditions
                                           complete:^(BOOL isSuccess) {
                                               [[CCDatabase shareManager] closeDB];
                                               !complete ?: complete(isSuccess);
                                           }];
}

/**
 更新数据(对象方式并检查数据结构)
 
 @param object 对象
 @param conditions sql语句
 @param complete 完成回调
 */
+ (void)ccdb_updateSQLQueueTableObject:(id)object
                            conditions:(NSString *)conditions
                              complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateSQLQueueTableObject:object
                                              conditions:conditions
                                                complete:^(BOOL isSuccess) {
                                                    [[CCDatabase shareManager] closeDB];
                                                    !complete ?: complete(isSuccess);
                                                }];
}

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
                          complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateTableLikeObject:tableName
                                 forKeyPathAndValues:keyPathValues
                                            keyValue:keyValue
                                            complete:^(BOOL isSuccess) {
                                                [[CCDatabase shareManager] closeDB];
                                                !complete ?: complete(isSuccess);
                                            }];
}


/**
 批量更新数据
 
 @param tableName 表名
 @param objArr 更行数据集合
 @param complete 完成回调
 */
+ (void)ccdb_updateBatchTableObject:(NSString *)tableName
                        batchObject:(NSArray<NSDictionary *> *)objArr
                           complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateBatchTableObject:tableName
                                          batchObject:objArr
                                             complete:^(BOOL isSuccess) {
                                                 [[CCDatabase shareManager] closeDB];
                                                 !complete ?: complete(isSuccess);
                                             }];
}

/**
 批量更新数据
 
 @param objects 对象集合
 @param complete 完成回调
 */
+ (void)ccdb_updateBatchTableObject:(NSArray *)objects
                           complete:(void (^)(BOOL isSuccess))complete
{
    [[CCDatabase shareManager] updateBatchTableObject:objects
                                             complete:^(BOOL isSuccess) {
                                                 [[CCDatabase shareManager] closeDB];
                                                 !complete ?: complete(isSuccess);
                                             }];
}


#pragma mark -
#pragma mark :. select

/**
 查询表中有多少条数据
 
 @param tableName 表名
 @param where 查询条件
 */
+ (NSInteger)ccdb_selectTableHasCount:(NSString *)tableName
                                where:(NSArray *)where
{
    NSInteger count = [[CCDatabase shareManager] selectTableHasCount:tableName where:where];
    [[CCDatabase shareManager] closeDB];
    return count;
}

/**
 查询表中有多少条数据(sql)
 
 @param tableName 表名
 @param conditions sql查询条件
 */
+ (NSInteger)ccdb_selectTableHasCount:(NSString *)tableName
                           conditions:(NSString *)conditions
{
    NSInteger count = [[CCDatabase shareManager] selectTableHasCount:tableName conditions:conditions];
    [[CCDatabase shareManager] closeDB];
    return count;
}

/**
 函数查询表数据
 
 @param tableName 表名
 @param methodType 函数类型
 @param key 字段名
 @param where 查询语句(sql)
 */
+ (NSInteger)ccdb_selectTableMethodCount:(NSString *)tableName
                                    type:(CCDBSqliteMethodType)methodType
                                     key:(NSString *)key
                                   where:(NSString *)where
{
    NSInteger count = [[CCDatabase shareManager] selectTableMethodCount:tableName type:methodType key:key where:where];
    [[CCDatabase shareManager] closeDB];
    return count;
}


/**
 like查询（keyPath方式）数量
 
 @param tableName 表名
 @param keyPathValues 数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 即查询user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象的条数.
 */
+ (NSInteger)ccdb_selectTableLikeCount:(NSString *)tableName
                   forKeyPathAndValues:(NSArray *)keyPathValues
{
    NSInteger count = [[CCDatabase shareManager] selectQueueTableLinkeCount:tableName forKeyPathAndValues:keyPathValues];
    [[CCDatabase shareManager] closeDB];
    return count;
}

/**
 查询表(sql语句)
 
 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
+ (void)ccdb_selectTableObject:(NSString *)tableName
                    conditions:(NSString *)conditions
                      complete:(void (^)(NSArray *array))complete
{
    [[CCDatabase shareManager] selectTableObject:tableName
                                      conditions:conditions
                                        complete:^(NSArray *array) {
                                            [[CCDatabase shareManager] closeDB];
                                            !complete ?: complete(array);
                                        }];
}

/**
 查询表键值语句
 
 @param tableName 表名
 @param keys 键值
 @param where 语句
 @param complete 完成回调
 */
+ (void)ccdb_selectTableKeyValuesWithWhereObject:(NSString *)tableName
                                            keys:(NSArray *)keys
                                           where:(NSArray *)where
                                        complete:(void (^)(NSArray *array))complete
{
    [[CCDatabase shareManager] selectTableKeyValuesWithWhereObject:tableName
                                                              keys:keys
                                                             where:where
                                                          complete:^(NSArray *array) {
                                                              [[CCDatabase shareManager] closeDB];
                                                              !complete ?: complete(array);
                                                          }];
}

/**
 查询表跟随语句
 
 @param tableName 表名
 @param param 跟随局域
 @param where 查询条件
 @param complete 完成回调函数
 */
+ (void)ccdb_selectTableParamWhereObject:(NSString *)tableName
                                   param:(NSString *)param
                                   where:(NSArray *)where
                                complete:(void (^)(NSArray *array))complete
{
    [[CCDatabase shareManager] selectTableParamWhereObject:tableName
                                                     param:param
                                                     where:where
                                                  complete:^(NSArray *array) {
                                                      [[CCDatabase shareManager] closeDB];
                                                      !complete ?: complete(array);
                                                      
                                                  }];
}

/**
 查询表like
 
 @param tableName 表名
 @param keyPathValues 键值
 @param complete 完成回调
 */
+ (void)ccdb_selectTableKeyValuesObject:(NSString *)tableName
                    forKeyPathAndValues:(NSArray *)keyPathValues
                               complete:(void (^)(NSArray *array))complete
{
    [[CCDatabase shareManager] selectTableKeyValuesObject:tableName
                                      forKeyPathAndValues:keyPathValues complete:^(NSArray *array) {
                                          [[CCDatabase shareManager] closeDB];
                                          !complete ?: complete(array);
                                      }];
}

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
- (BOOL)registerChangeWithName:(NSString *)tableName
                   changeBlock:(void (^)(NSInteger result))block
{
    return [[CCDatabase shareManager] registerChangeWithName:tableName changeBlock:block];
}

/** 移除数据变化监听 **/
- (BOOL)removeChangeWithName:(NSString *)tableName
{
    return [[CCDatabase shareManager] removeChangeWithName:tableName];
}

@end
