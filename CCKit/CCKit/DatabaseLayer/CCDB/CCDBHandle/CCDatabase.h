//
//  CCDatabase.h
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

typedef NS_ENUM(NSInteger, CCDBChangeState) {
    /** 插入数据 **/
    CCDBChangeStateInsert = 0,
    /** 更新数据 **/
    CCDBChangeStateUpdate = 1,
    /** 删除数据 **/
    CCDBChangeStateDelete = 2,
    /** 删表数据 **/
    CCDBChangeStateDrop = 3,
};

typedef NS_ENUM(NSInteger, CCDBDealState) { //处理状态
    /** 处理失败 **/
    CCDBDealStateError = -1,
    /** 处理不完整 **/
    CCDBDealStateIncomplete = 0,
    /** 处理完整 **/
    CCDBDealStateComplete = 1,
};

typedef NS_ENUM(NSInteger, CCDBSqliteMethodType) { //sqlite数据库原生方法枚举
    /** 求最小值 **/
    CCDBSqliteMethodTypeMin = 0,
    /** 求最大值 **/
    CCDBSqliteMethodTypeMax = 1,
    /** 求总和值 **/
    CCDBSqliteMethodTypeSum = 2,
    /** 求平均值 **/
    CCDBSqliteMethodTypeAvg = 3,
};

typedef NS_ENUM(NSInteger, CCDBDataTimeType) {
    /** 存储时间 **/
    CCDBDataTimeTypeCreateTime = 0,
    /** 更新时间 **/
    CCDBDataTimeTypeUpdateTime = 1,
};

@interface CCDatabase : NSObject

/** 数据库名 **/
@property (nonatomic, copy) NSString *sqliteName;
/** 是否开启日志 **/
@property (nonatomic, assign) BOOL debug;
/** 设置操作过程中不可关闭数据库(即closeDB函数无效). **/
@property (nonatomic, assign) BOOL disableCloseDB;

+ (instancetype)shareManager;

/** 关闭数据库 **/
- (void)closeDB;

/**
 删除数据库文件
 
 @param sqliteName 数据库名
 */
+ (BOOL)deleteSqlite:(NSString *)sqliteName;

/** 事务操作 **/
- (void)inTransaction:(BOOL (^)(void))block;

/**
 数据库中是否存在表
 
 @param tablename 表面
 @param complete 回调
 */
- (void)existTableName:(NSString *)tableName
              complete:(void (^)(BOOL exist))complete;

/**
 判断对象数据是否有改变，智能刷星
 
 @param object 对象
 */
- (void)ifIvarChangeForClass:(id)object;

#pragma mark :.... tableHandle

/**
 清空表数据
 
 @param tableName 表名
 @param complete 完成回调
 */
- (void)clearTable:(NSString *)tableName
          complete:(void (^)(BOOL isSuccess))complete;

/**
 删除表
 
 @param tableName 表名
 @param complete 完成回调
 */
- (void)deleteTable:(NSString *)tableName
           complete:(void (^)(BOOL isSuccess))complete;

/**
 删除表(同步线程处理)
 
 @param tableName 表名
 @param complete 完成回调
 */
- (void)deleteSafeTable:(NSString *)tableName
               complete:(void (^)(BOOL isSuccess))complete;

/**
 判断数据库中表是否存在
 
 @param tableName 表名
 @param complete 处理回调
 */
- (void)isExistWithTableName:(NSString *)tableName
                    complete:(void (^)(BOOL isSuccess))complete;

#pragma mark :.... create


/**
 创建表
 
 @param tableName 表面
 @param keys 字段名
 @param uniqueKey "唯一约束"字段名
 @param complete 处理结果回调
 */
- (void)createTableWithTableName:(NSString *)tableName
                            keys:(NSDictionary *)keys
                       uniqueKey:(NSString *)uniqueKey
                        complete:(void (^)(BOOL isSuccess))complete;

#pragma mark :.... insert

/**
 插入表数据对象
 
 @param tableName 表名
 @param objDic 对象数据
 @param complete 完成回调
 */
- (void)insertTableObject:(NSString *)tableName
                   object:(NSDictionary *)objDic
                 complete:(void (^)(BOOL isSuccess))complete;

/**
 插入数据(对象形式)
 
 @param object 对象集合
 @param complete 完成回调
 */
- (void)inserQueueTableObject:(id)object
                     complete:(void (^)(BOOL isSuccess))complete;

/**
 批量插入表数据
 
 @param tableName 表名
 @param objArr 对象集合
 @param complete 完成回调
 */
- (void)insertBatchTableObject:(NSString *)tableName
                   batchObject:(NSArray<NSDictionary *> *)objArr
                      complete:(void (^)(BOOL isSuccess))complete;

/**
 批量插入表数据(对象形式)
 
 @param arr 对象集合
 @param complete 完成回调
 */
- (void)insertQueueBatchTableObject:(NSArray *)arr
                           complete:(void (^)(BOOL isSuccess))complete;

#pragma mark :.... delete

/**
 删除表数据
 
 @param tableName 表名
 @param where 语句对象
 @param complete 完成回调
 */
- (void)deleteTableObject:(NSString *)tableName
                    where:(NSArray *)where
                 complete:(void (^)(BOOL isSuccess))complete;

/**
 删除表数据(SQL)
 
 @param tableName 表名
 @param conditions sql
 @param complete 完成回调
 */
- (void)deleteSQLTableObject:(NSString *)tableName
                  conditions:(NSString *)conditions
                    complete:(void (^)(BOOL isSuccess))complete;

/**
 模糊删除表数据
 
 @param tableName 表名
 @param keyPathValues 查询字段键值
 @param complete 完成回调
 */
- (void)deleteLikeTableObjec:(NSString *)tableName
         forKeyPathAndValues:(NSArray *)keyPathValues
                    complete:(void (^)(BOOL isSuccess))complete;

#pragma mark :.... update
/**
 更新数据
 
 @param object 更新对象
 @param where 条件
 *      条件数组，形式@[@"name",@"=",@"CC哥",@"age",@"=>",@(25)],即更新name=CC哥,age=>25的数据. 可以为nil,nil时更新所有数据;
 *      不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 */
- (BOOL)updateTableObjec:(id)object
                   where:(NSArray *)where;

/**
 更新表数据(字段)
 
 @param tableName 表名
 @param keyValue 更新字段键值
 @param where 语句条件
 @param complete 完成回调
 */
- (void)updateTableObject:(NSString *)tableName
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
- (void)updateSQLTableObject:(NSString *)tableName
                    keyValue:(NSDictionary *)keyValue
                  conditions:(NSString *)conditions
                    complete:(void (^)(BOOL isSuccess))complete;

/**
 更新数据(检查数据结构)
 
 @param tableName 表名
 @param keyValue 更新字段键值
 @param conditions sql
 @param complete 完成回调
 */
- (void)updateSQLQueueTableObject:(NSString *)tableName
                         keyValue:(NSDictionary *)keyValue
                       conditions:(NSString *)conditions
                         complete:(void (^)(BOOL isSuccess))complete;

/**
 更新数据(对象方式并检查数据结构)
 
 @param object 对象
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)updateSQLQueueTableObject:(id)object
                       conditions:(NSString *)conditions
                         complete:(void (^)(BOOL isSuccess))complete;

/**
 模糊更新数据
 
 @param tableName 表名
 @param keyPathValues 模糊条件
 @param keyValue 更行字段键值
 @param complete 完成回调
 */
- (void)updateTableLikeObject:(NSString *)tableName
          forKeyPathAndValues:(NSArray *)keyPathValues
                     keyValue:(NSDictionary *)keyValue
                     complete:(void (^)(BOOL isSuccess))complete;


/**
 批量更新数据
 
 @param tableName 表名
 @param objArr 更行数据集合
 @param complete 完成回调
 */
- (void)updateBatchTableObject:(NSString *)tableName
                   batchObject:(NSArray<NSDictionary *> *)objArr
                      complete:(void (^)(BOOL isSuccess))complete;

/**
 批量更行数据(对象)
 
 @param objects 对象集合
 @param complete 完成回调
 */
- (void)updateBatchTableObject:(NSArray *)objects
                      complete:(void (^)(BOOL isSuccess))complete;

#pragma mark :.... select

/**
 查询表中有多少条数据
 
 @param tableName 表名
 @param where 查询条件
 */
- (NSInteger)selectTableHasCount:(NSString *)tableName
                           where:(NSArray *)where;

/**
 查询表中有多少条数据(同步队列查询)
 
 @param tableName 表名
 @param where 查询条件
 */
- (NSInteger)selectQueueTableHasCount:(NSString *)tableName
                                where:(NSArray *)where;

/**
 查询表中有多少条数据(sql)
 
 @param tableName 表名
 @param conditions sql查询条件
 */
- (NSInteger)selectTableHasCount:(NSString *)tableName
                      conditions:(NSString *)conditions;

/**
 查询表中有多少条数据(sql同步队列查询)
 
 @param tableName 表名
 @param conditions sql查询条件
 */
- (NSInteger)selectQueueTableHasCount:(NSString *)tableName
                           conditions:(NSString *)conditions;

/**
 函数查询表数据
 
 @param tableName 表名
 @param methodType 函数类型
 @param key 字段名
 @param where 查询语句(sql)
 */
- (NSInteger)selectTableMethodCount:(NSString *)tableName
                               type:(CCDBSqliteMethodType)methodType
                                key:(NSString *)key
                              where:(NSString *)where;

/**
 函数查询表数据(线程)
 
 @param tableName 表名
 @param methodType 函数类型
 @param key 字段名
 @param where 查询语句(sql)
 */
- (NSInteger)selectQueueTableMethodCount:(NSString *)tableName
                                    type:(CCDBSqliteMethodType)methodType
                                     key:(NSString *)key
                                   where:(NSString *)where;

/**
 like查询（keyPath方式）数量
 
 @param tableName 表名
 @param keyPathValues 键值
 */
- (NSInteger)selectTableLikeCount:(NSString *)tableName
              forKeyPathAndValues:(NSArray *)keyPathValues;

/**
 like查询（keyPath方式）数量 (同步队列查询)
 
 @param tableName 表名
 @param keyPathValues 键值
 */
- (NSInteger)selectQueueTableLinkeCount:(NSString *)tableName
                    forKeyPathAndValues:(NSArray *)keyPathValues;

/**
 查询表(sql语句)
 
 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)selectTableObject:(NSString *)tableName
               conditions:(NSString *)conditions
                 complete:(void (^)(NSArray *array))complete;

/**
 查询表(sql语句)同步队列查询
 
 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)selectQueueTableObjec:(NSString *)tableName
                   conditions:(NSString *)conditions
                     complete:(void (^)(NSArray *array))complete;

/**
 查询表键值语句
 
 @param tableName 表名
 @param keys 键值
 @param where 语句
 @param complete 完成回调
 */
- (void)selectTableKeyValuesWithWhereObject:(NSString *)tableName
                                       keys:(NSArray *)keys
                                      where:(NSArray *)where
                                   complete:(void (^)(NSArray *array))complete;

/**
 队列查询表键值语句
 
 @param tableName 表名
 @param keys 条件
 @param where 查询条件
 @param complete 完成回调
 */
- (void)selectQueueTableKeyValuesWithWhereObject:(NSString *)tableName
                                            keys:(NSArray *)keys
                                           where:(NSArray *)where
                                        complete:(void (^)(NSArray *array))complete;

/**
 查询表跟随语句
 
 @param tableName 表名
 @param param 跟随局域
 @param where 查询条件
 @param complete 完成回调函数
 */
- (void)selectTableParamWhereObject:(NSString *)tableName
                              where:(NSArray *)where
                              param:(NSString *)param
                           complete:(void (^)(NSArray *array))complete;

/**
 同步队列查询表
 
 @param tableName 表名
 @param param 跟随条件
 @param where 查询条件
 @param complete 完成回调
 */
- (void)selectQueueTableParamWhereObject:(NSString *)tableName
                                   where:(NSArray *)where
                                   param:(NSString *)param
                                complete:(void (^)(NSArray *array))complete;

/**
 查询表like
 
 @param tableName 表名
 @param keyPathValues 键值
 @param complete 完成回调
 */
- (void)selectTableKeyValuesObject:(NSString *)tableName
               forKeyPathAndValues:(NSArray *)keyPathValues
                          complete:(void (^)(NSArray *array))complete;

/**
 同步查询表like
 
 @param tableName 表名
 @param keyPathValues 条件
 @param complete 完成回调
 */
-(void)selectQueueTableKeyValuesObject:(NSString *)tableName
                   forKeyPathAndValues:(NSArray *)keyPathValues
                              complete:(void (^)(NSArray *array))complete;

#pragma mark -
#pragma mark :. monitorHandel
/** 注册数据变化监听 **/
- (BOOL)registerChangeWithName:(NSString *)tableName
                   changeBlock:(void (^)(CCDBChangeState result))block;

/** 移除数据变化监听 **/
- (BOOL)removeChangeWithName:(NSString *)tableName;

@end
