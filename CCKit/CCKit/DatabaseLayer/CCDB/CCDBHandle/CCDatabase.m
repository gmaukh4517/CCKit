//
//  CCDatabase.m
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

#import "CCDatabase.h"
#import "CCDBTool.h"
#import "FMDB.h"

#define CCDBEnterLog(log)                \
    do {                                 \
        if (self.debug) {                \
            NSLog(@"CCDB = >: %@", log); \
        }                                \
    } while (0)

#define MaxQueryPageNum 50

static NSString *const kPRIMARYKEY = @"ccdb_identifier";
static NSString *const kCREATETIMEKEY = @"ccdb_createTime";
static NSString *const kUPDSTETIMEKEY = @"ccdb_updateTime";

static NSString *const kSQLITENAME = @"CCDBSqlite";

/** keyPath查询用的关系 **/
static NSString *const kSQLEQUAL = @"Relation_Equal";       //等于的关系；
static NSString *const kSQLCONTAINS = @"Relation_Contains"; //包含的关系.

@interface CCDatabase ()

@property (nonatomic, strong) NSString *dbPath;

@property (nonatomic, strong) FMDatabaseQueue *fmdbQueue;
@property (nonatomic, strong) FMDatabase *fmdb;
/** 事物 **/
@property (nonatomic, assign) BOOL inTransaction;
/** 记录注册监听数据变化的block **/
@property (nonatomic, strong) NSMutableDictionary *changeBlocks;
/** 信号量 **/
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

static CCDatabase *database = nil;

@implementation CCDatabase

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        database = [[CCDatabase alloc] init];
    });
    return database;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.changeBlocks = [NSMutableDictionary dictionary];
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)dealloc
{
    [self destroy];
}

#pragma mark -
#pragma mark :. private

- (NSString *)dbPath
{
    if (!_dbPath) {
        NSString *dbsPath = [CCDatabase createDirInDocument:@"CCDataBases"];
        NSString *sqlName = kSQLITENAME;
        if (self.sqliteName)
            sqlName = self.sqliteName;

        _dbPath = [dbsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", sqlName]];
    }
    return _dbPath;
}

+ (NSString *)createDirInDocument:(NSString *)pathName
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    if (!pathName || pathName.length == 0)
        documentPath = [documentPath stringByAppendingPathComponent:@"CCDataBases"];
    else
        documentPath = [documentPath stringByAppendingPathComponent:pathName];

    BOOL isDir = NO;
    BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:documentPath isDirectory:&isDir];
    if (!isCreated || !isDir) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (success == NO)
            NSLog(@"create dir error: %@", error.debugDescription);
    }
    return documentPath;
}

/** 销毁数据库 **/
- (void)destroy
{
    if (_changeBlocks) {
        [_changeBlocks removeAllObjects]; //清除所有注册列表.
        _changeBlocks = nil;
    }
    if (_semaphore) {
        _semaphore = 0x00;
    }
    [self closeDB];
    if (database) {
        database = nil;
    }
}

#pragma mark -
#pragma mark :. public

/** 关闭数据库 **/
- (void)closeDB
{
    if (_disableCloseDB) {
        return;
    }

    if (!_inTransaction && _fmdbQueue) { //没有事务的情况下就关闭数据库.
        [_fmdbQueue close];              //关闭数据库.
        _fmdbQueue = nil;
    }
}

/**
 删除数据库文件

 @param sqliteName 数据库名
 */
+ (BOOL)deleteSqlite:(NSString *)sqliteName
{
    NSString *dbsPath = [CCDatabase createDirInDocument:@"CCDataBases"];

    NSString *filePath = [dbsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", sqliteName]];
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSError *error;
    if ([file_manager fileExistsAtPath:filePath]) {
        [file_manager removeItemAtPath:filePath error:&error];
    }
    return error == nil;
}

/** 事务操作 **/
- (void)inTransaction:(BOOL (^)(void))block
{
    NSAssert(block, @"block is nil!");
    [self executeDB:^(FMDatabase *db) {
        self.inTransaction = db.inTransaction;
        if (!self.inTransaction) {
            self.inTransaction = [db beginTransaction];
        }
        BOOL isCommit = NO;
        isCommit = block();
        if (self.inTransaction) {
            if (isCommit) {
                [db commit];
            } else {
                [db rollback];
            }
            self.inTransaction = NO;
        }
    }];
}

/** 为了对象层的事物操作而封装的函数 **/
- (void)executeDB:(void (^)(FMDatabase *db))block
{
    NSAssert(block, @"block is nil!");
    if (_fmdb) { //为了事务操作防止死锁而设置.
        block(_fmdb);
        return;
    }
    __weak typeof(self) WeakSelf = self;
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        WeakSelf.fmdb = db;
        block(db);
        WeakSelf.fmdb = nil;
    }];

    //[self.threadLock unlock];//解锁
}

/**
 数据库中是否存在表

 @param tablename 表面
 @param complete 回调
 */
- (void)existTableName:(NSString *)tableName
              complete:(void (^)(BOOL exist))complete
{
    NSAssert(tableName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    !complete ?: complete(result);
}

/**
 判断对象数据是否有改变，智能刷星

 @param object 对象
 */
- (void)ifIvarChangeForClass:(id)object
{
    @autoreleasepool {
        NSString *tableName = NSStringFromClass([object class]);
        NSMutableArray *newKeys = [NSMutableArray array];
        NSMutableArray *sqlKeys = [NSMutableArray array];

        NSDictionary *properties = [CCDBTool objectProperties:[object class]];
        NSArray *propertyNameArr = [properties objectForKey:@"propertyName"];       //属性名称
        NSArray *propertySQLTypeArr = [properties objectForKey:@"propertySQLType"]; //属性类型

        [self executeDB:^(FMDatabase *db) {
            NSString *SQL = [NSString stringWithFormat:@"select * from %@ limit 0,1;", tableName];
            FMResultSet *rs = [db executeQuery:SQL];
            // 2.遍历结果集
            if (rs.next) {
                NSArray *columNames = [rs columnNames]; //获取表中字段
                for (NSInteger i = 0; i < propertyNameArr.count; i++) {
                    NSString *key = [propertyNameArr objectAtIndex:i];
                    if (![columNames containsObject:key]) {
                        [newKeys addObject:@{key : [propertySQLTypeArr objectAtIndex:i]}];
                    }
                }

                [columNames enumerateObjectsUsingBlock:^(NSString *columName, NSUInteger idx, BOOL *stop) {
                    if (![propertyNameArr containsObject:columName])
                        [sqlKeys addObject:columName];
                }];
            }
            //查询完后要关闭rs，不然会报@"Warning: there is at least one open result set around after performing
            !rs ?: [rs close];
        }];

        if ((sqlKeys.count == 0) && (newKeys.count > 0)) {
            for (NSDictionary *dic in newKeys) { //此处只是增加了新的列.
                NSString *key = dic.allKeys.firstObject;
                [self tableAddColumn:tableName columnName:key columnType:[dic objectForKey:key] complete:nil]; //添加新字段
            }
        } else if (sqlKeys.count > 0) { //字段发生改变,减少或名称变化,实行刷新数据库.
            [self refreshQueueTable:tableName columnNames:properties complete:nil];
        }
    }
}

#pragma mark :.... tableHandle

/**
 清空表数据

 @param tableName 表名
 @param complete 完成回调
 */
- (void)clearTable:(NSString *)tableName complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"delete from %@", tableName];
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateDelete];
    !complete ?: complete(result);
}

/**
 删除表

 @param tableName 表名
 @param complete 完成回调
 */
- (void)deleteTable:(NSString *)tableName complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"drop table %@", tableName];
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateDrop];
    !complete ?: complete(result);
}

/**
 删除表(同步线程处理)

 @param tableName 表名
 @param complete 完成回调
 */
- (void)deleteSafeTable:(NSString *)tableName
               complete:(void (^)(BOOL isSuccess))complete
{
    [self deleteTable:tableName complete:complete];
}

/**
 判断数据库中表是否存在

 @param tableName 表名
 @param complete 处理回调
 */
- (void)isExistWithTableName:(NSString *)tableName
                    complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    !complete ?: complete(result);
}

/** 判断表是否存在,不存在创建 **/
- (BOOL)ifNotExistWillCreateTableWithObject:(id)object
{
    //检查是否建立了跟对象相对应的数据表
    NSString *tableName = NSStringFromClass([object class]);
    //获取"唯一约束"字段名
    NSString *uniqueKey = [CCDBTool isRespondsToSelector:NSSelectorFromString(kPRIMARYKEY) class:[object class]]; //获取"唯一约束"字段名
    __block BOOL isExistTable;
    [self isExistWithTableName:tableName
                      complete:^(BOOL isExist) {
                          if (!isExist) { //如果不存在就新建
                              NSDictionary *createKeys = [CCDBTool objectProperties:[object class]];

                              [self createTableWithTableName:tableName
                                                        keys:createKeys
                                                   uniqueKey:uniqueKey
                                                    complete:^(BOOL isSuccess) {
                                                        isExistTable = isSuccess;
                                                    }];
                          }
                      }];

    if (!isExistTable) { // 无需创建判断是否需要刷新表结构
        [self ifIvarChangeForClass:object];
    }

    return isExistTable;
}

/**
 表添加列

 @param tableName 表面
 @param columnName 列名
 @param columnType 列类型
 @param complete 处理回调
 */
- (void)tableAddColumn:(NSString *)tableName
            columnName:(NSString *)columnName
            columnType:(NSString *)columnType
              complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(columnName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"alter table %@ add %@;", columnName, columnType];
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];
    !complete ?: complete(result);
}

/**
 刷新表结构

 @param tablename 表名
 @param columnNames 字段
 @param complete 完成回调
 */
- (void)refreshQueueTable:(NSString *)tablename
              columnNames:(NSDictionary *)columnNames
                 complete:(void (^)(CCDBDealState state))complete
{
    NSAssert(tablename, @"表名不能为空!");
    NSAssert(columnNames, @"字段数组不能为空!");
    [self isExistWithTableName:tablename
                      complete:^(BOOL isSuccess) {
                          if (!isSuccess) {
                              CCDBEnterLog(@"没有数据存在,数据库更新失败!");
                              !complete ?: complete(CCDBDealStateError);
                              return;
                          }
                      }];

    NSString *CCTempTable = @"CCTempTable";
    //事务操作.
    __block int recordFailCount = 0;
    [self inTransaction:^BOOL {
        [self copyTableName:tablename
                toTableName:CCTempTable
                columnNames:columnNames
                   complete:^(CCDBDealState state) {
                       if (state == CCDBDealStateComplete)
                           recordFailCount++;
                   }];
        [self deleteTable:tablename
                 complete:^(BOOL isSuccess) {
                     if (isSuccess) recordFailCount++;
                 }];

        [self copyTableName:CCTempTable
                toTableName:tablename
                columnNames:columnNames
                   complete:^(CCDBDealState state) {
                       if (state == CCDBDealStateComplete) {
                           recordFailCount++;
                       }
                   }];

        [self deleteTable:CCTempTable
                 complete:^(BOOL isSuccess) {
                     if (isSuccess) recordFailCount++;
                 }];

        if (recordFailCount != 4) {
            CCDBEnterLog(@"发生错误，更新数据库失败!");
        }
        return recordFailCount == 4;
    }];

    //回调结果.
    if (recordFailCount == 0) {
        !complete ?: complete(CCDBDealStateError);
    } else if (recordFailCount > 0 && recordFailCount < 4) {
        !complete ?: complete(CCDBDealStateIncomplete);
    } else {
        !complete ?: complete(CCDBDealStateComplete);
    }
}

/**
 表迁移

 @param tableName 表名
 @param toTablename 迁移表名
 @param columnNames 迁移字段
 @param complete 处理回调
 */
- (void)copyTableName:(NSString *)tableName
          toTableName:(NSString *)toTablename
          columnNames:(NSDictionary *)columnNames
             complete:(void (^)(CCDBDealState state))complete
{
    Class tableClass = NSClassFromString(tableName);
    NSString *uniqueKey = [CCDBTool isRespondsToSelector:NSSelectorFromString(kPRIMARYKEY) class:tableClass]; //获取"唯一约束"字段名
    //建立一张临时表
    __block BOOL createFlag;
    [self createTableWithTableName:toTablename
                              keys:columnNames
                         uniqueKey:uniqueKey
                          complete:^(BOOL isSuccess) {
                              createFlag = isSuccess;
                          }];
    if (!createFlag) {
        CCDBEnterLog(@"数据库更新失败!");
        !complete ?: complete(CCDBDealStateError);
        return;
    }

    __block CCDBDealState refreshstate = CCDBDealStateError;
    __block BOOL recordError = NO;
    __block BOOL recordSuccess = NO;
    __weak typeof(self) WeakSelf = self;
    __block NSArray *propertyNameArr = [columnNames objectForKey:@"propertyName"]; //属性名称
    NSInteger count = [self selectTableHasCount:tableName where:nil];
    for (NSInteger i = 0; i < count; i += MaxQueryPageNum) {
        @autoreleasepool { //由于查询出来的数据量可能巨大,所以加入自动释放池.
            NSString *param = [NSString stringWithFormat:@"limit %@,%@", @(i), @(MaxQueryPageNum)];
            [self selectTableParamWhereObject:tableName
                                        where:nil
                                        param:param
                                     complete:^(NSArray *array) {
                                         for (NSDictionary *oldDict in array) {
                                             NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                                             for (NSString *key in propertyNameArr) {
                                                 if (oldDict[ key ])
                                                     newDict[ key ] = oldDict[ key ];
                                             }
                                             //将旧表的数据插入到新表
                                             [WeakSelf insertTableObject:toTablename
                                                                  object:newDict
                                                                complete:^(BOOL isSuccess) {
                                                                    if (isSuccess) {
                                                                        if (!recordSuccess) {
                                                                            recordSuccess = YES;
                                                                        }
                                                                    } else {
                                                                        if (!recordError) {
                                                                            recordError = YES;
                                                                        }
                                                                    }

                                                                }];
                                         }
                                     }];
        }
    }

    if (complete) {
        if (recordError && recordSuccess) {
            refreshstate = CCDBDealStateIncomplete;
        } else if (recordError && !recordSuccess) {
            refreshstate = CCDBDealStateError;
        } else if (recordSuccess && !recordError) {
            refreshstate = CCDBDealStateComplete;
        }
        complete(refreshstate);
    }
}

#pragma mark :.... sql Handle

/**
 like语句拼接

 @param keyPathValues 键值数组
 @param where 是否Where
 */
+ (NSString *)likeSQLKeyAndValueSplice:(NSArray *)keyPathValues where:(BOOL)where
{
    NSAssert(keyPathValues, @"集合不能为空!");
    NSAssert(!(keyPathValues.count % 3), @"集合格式错误!");
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *relations = [NSMutableArray array];
    for (int i = 0; i < keyPathValues.count; i += 3) {
        [keys addObject:keyPathValues[ i ]];
        [relations addObject:keyPathValues[ i + 1 ]];
        [values addObject:keyPathValues[ i + 2 ]];
    }
    NSMutableString *likeM = [NSMutableString string];
    !where ?: [likeM appendString:@" where "];
    for (int i = 0; i < keys.count; i++) {
        NSString *keyPath = keys[ i ];
        id value = values[ i ];
        NSAssert([keyPath containsString:@"."], @"keyPath错误,正确形式如: user.stident.name");
        NSArray *keypaths = [keyPath componentsSeparatedByString:@"."];
        NSMutableString *keyPathParam = [NSMutableString string];
        for (int i = 1; i < keypaths.count; i++) {
            i != 1 ?: [keyPathParam appendString:@"%"];
            [keyPathParam appendFormat:@"%@", keypaths[ i ]];
            [keyPathParam appendString:@"%"];
        }
        [keyPathParam appendFormat:@"%@", value];
        if ([relations[ i ] isEqualToString:kSQLCONTAINS]) { //包含关系
            [keyPathParam appendString:@"%"];
        } else {
            if (keypaths.count <= 2) {
                if ([values[ i ] isKindOfClass:[NSString class]]) {
                    [keyPathParam appendString:@"\"%"];
                } else {
                    [keyPathParam appendString:@",%"];
                }
            } else {
                [keyPathParam appendString:@"\\%"];
            }
        }
        [likeM appendFormat:@"%@ like '%@'", keypaths[ 0 ], keyPathParam];
        if (i != (keys.count - 1))
            [likeM appendString:@" and "];
    }
    return likeM;
}

/**
 where语句处理

 @param keyValues 键值数组
 */
+ (NSArray *)whereSQLKeyAndValueHandle:(NSArray *)keyValues
{
    NSMutableArray *results = [NSMutableArray array];
    NSMutableString *SQL = [NSMutableString string];
    if (!(keyValues.count % 3)) {
        [SQL appendString:@" where "];
        for (int i = 0; i < keyValues.count; i += 3) {
            [SQL appendFormat:@"%@%@?", keyValues[ i ], keyValues[ i + 1 ]];
            if (i != (keyValues.count - 3)) {
                [SQL appendString:@" and "];
            }
        }
    } else {
        NSAssert(NO, @"条件数组错误!");
    }
    NSMutableArray *wheres = [NSMutableArray array];
    for (int i = 0; i < keyValues.count; i += 3) {
        [wheres addObject:keyValues[ i + 2 ]];
    }
    [results addObject:SQL];
    [results addObject:wheres];

    return results;
}

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
                        complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(keys, @"字段数组不能为空!");
    //创表
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *header = [NSString stringWithFormat:@"create table if not exists %@ (", tableName];
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:header];

        NSArray *propertyNameArr = [keys objectForKey:@"propertyName"];       //属性名称
        NSArray *propertySQLTypeArr = [keys objectForKey:@"propertySQLType"]; //属性类型
        BOOL uniqueKeyFlag = NO;
        for (int i = 0; i < propertyNameArr.count; i++) {
            NSString *key = [propertyNameArr objectAtIndex:i];
            NSString *sqlType = [propertySQLTypeArr objectAtIndex:i];

            NSString *columns = [NSString stringWithFormat:@"%@ %@", key, sqlType];
            if (uniqueKey) {
                if ([key isEqualToString:uniqueKey]) {
                    uniqueKeyFlag = YES;
                    [sql appendFormat:@"%@ unique", columns];
                } else if ([key isEqualToString:kPRIMARYKEY]) {
                    [sql appendFormat:@"%@ primary key autoincrement", columns];
                } else {
                    [sql appendString:columns];
                }
            } else {
                if ([key isEqualToString:kPRIMARYKEY]) {
                    [sql appendFormat:@"%@ primary key autoincrement", columns];
                } else {
                    [sql appendString:columns];
                }
            }

            if (i == (propertyNameArr.count - 1)) {
                [sql appendString:@");"];
            } else {
                [sql appendString:@","];
            }
        }

        if (uniqueKey) {
            NSAssert(uniqueKeyFlag, @"没有找到设置的主键,请检查primarykey返回值是否正确!");
        }
        CCDBEnterLog(sql);
        result = [db executeUpdate:sql];
    }];
    !complete ?: complete(result);
}

#pragma mark :.... insert

/**
 插入数据处理

 @param tableName 表名
 @param begin 开始回调
 @param handle 处理回调
 @param complete 完成回调
 */
- (void)insertTableHandle:(NSString *)tableName
                   handle:(void (^)(NSInteger sqlCount))handle
                 complete:(void (^)(void))complete
{
    __weak typeof(self) WeakSelf = self;
    [self isExistWithTableName:tableName
                      complete:^(BOOL isSuccess) {
                          if (!isSuccess) {
                              Class cls = NSClassFromString(tableName);
                              NSString *uniqueKey = [CCDBTool isRespondsToSelector:NSSelectorFromString(kPRIMARYKEY) class:cls]; //获取"唯一约束"字段名
                              NSDictionary *createKeys = [CCDBTool objectProperties:cls];
                              [WeakSelf createTableWithTableName:tableName keys:createKeys uniqueKey:uniqueKey complete:nil];
                          }
                      }];

    NSInteger sqlCount = [self selectTableMaxID:tableName];
    [self inTransaction:^BOOL {
        !handle ?: handle(sqlCount);
        return YES;
    }];
    !complete ?: complete();
}

/**
 批量插入数据

 @param tableName 表名
 @param objeects 对象集合
 @param complete 完成回调
 */
- (void)insertBatchTableHandle:(NSString *)tableName
                       objects:(NSArray *)objeects
                      complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(objeects && objeects.count, @"数组不能为空!");
    __block NSInteger num = 0;
    __weak typeof(self) WeakSelf = self;
    [self insertTableHandle:tableName
        handle:^(NSInteger sqlCount) {
            for (id obj in objeects) {
                sqlCount++;
                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:obj];
                [dicM setObject:@(sqlCount) forKey:kPRIMARYKEY];
                [WeakSelf insertTableObject:tableName
                                     object:dicM
                                   complete:^(BOOL isSuccess) {
                                       if (isSuccess)
                                           num++;
                                   }];
            }
        }
        complete:^{
            !complete ?: complete(objeects.count == num);
        }];
}

/**
 插入表数据对象

 @param tableName 表名
 @param objDic 对象数据
 @param complete 完成回调
 */
- (void)insertTableObject:(NSString *)tableName
                   object:(NSDictionary *)objDic
                 complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(objDic, @"插入值字典不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSArray *keys = objDic.allKeys;
        NSArray *values = objDic.allValues;
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendFormat:@"insert into %@(", tableName];
        for (int i = 0; i < keys.count; i++) {
            [SQL appendFormat:@"%@", keys[ i ]];
            if (i == (keys.count - 1)) {
                [SQL appendString:@") "];
            } else {
                [SQL appendString:@","];
            }
        }
        [SQL appendString:@"values("];
        for (int i = 0; i < values.count; i++) {
            [SQL appendString:@"?"];
            if (i == (keys.count - 1)) {
                [SQL appendString:@");"];
            } else {
                [SQL appendString:@","];
            }
        }

        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL withArgumentsInArray:values];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateInsert];
    !complete ?: complete(result);
}

/**
 插入数据(对象形式)

 @param object 对象集合
 @param complete 完成回调
 */
- (void)inserQueueTableObject:(id)object
                     complete:(void (^)(BOOL isSuccess))complete
{
    [self ifNotExistWillCreateTableWithObject:object];
    Class cls = [object class];
    NSString *tableName = NSStringFromClass(cls);
    __block NSInteger num = 0;
    __weak typeof(self) WeakSelf = self;
    [self insertTableHandle:tableName
        handle:^(NSInteger sqlCount) {
            sqlCount++;
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[CCDBTool objectSqlProperties:object]];
            [dicM setObject:@(sqlCount) forKey:kPRIMARYKEY];
            [WeakSelf insertTableObject:tableName
                                 object:dicM
                               complete:^(BOOL isSuccess) {
                                   if (isSuccess)
                                       num++;
                               }];
        }
        complete:^{
            !complete ?: complete(1 == num);
        }];
}

/**
 批量插入表数据对象

 @param tableName 表名
 @param objArr 对象集合
 @param complete 完成回调
 */
- (void)insertBatchTableObject:(NSString *)tableName
                   batchObject:(NSArray<NSDictionary *> *)objArr
                      complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        [db beginTransaction];
        [objArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSArray *keys = dict.allKeys;
                NSArray *values = dict.allValues;
                NSMutableString *SQL = [[NSMutableString alloc] init];
                [SQL appendFormat:@"insert into %@(", tableName];
                for (int i = 0; i < keys.count; i++) {
                    [SQL appendFormat:@"%@", keys[ i ]];
                    if (i == (keys.count - 1)) {
                        [SQL appendString:@") "];
                    } else {
                        [SQL appendString:@","];
                    }
                }
                [SQL appendString:@"values("];
                for (int i = 0; i < values.count; i++) {
                    [SQL appendString:@"?"];
                    if (i == (keys.count - 1)) {
                        [SQL appendString:@");"];
                    } else {
                        [SQL appendString:@","];
                    }
                }
                CCDBEnterLog(SQL);
                result = [db executeUpdate:SQL withArgumentsInArray:values];
                if (!result) *stop = YES;
            }
        }];
        [db commit];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateInsert];
    !complete ?: complete(result);
}

/**
 批量插入表数据(对象形式)

 @param arr 对象集合
 @param complete 完成回调
 */
- (void)insertQueueBatchTableObject:(NSArray *)arr
                           complete:(void (^)(BOOL isSuccess))complete
{
    // 对象归类 用于区分数组中不同对象
    NSMutableDictionary *classifyM = [NSMutableDictionary dictionary];
    for (id obj in arr) {
        Class cls = [obj class];
        NSString *className = NSStringFromClass(cls);

        NSMutableArray *array = [NSMutableArray arrayWithArray:[classifyM objectForKey:className]];
        [array addObject:[CCDBTool objectSqlProperties:obj]];

        [classifyM setObject:array forKey:className];
    }

    for (NSString *tableName in classifyM.allKeys) {
        NSArray *arr = [classifyM objectForKey:tableName];

        [self ifNotExistWillCreateTableWithObject:arr.firstObject];
        [self insertBatchTableHandle:tableName objects:arr complete:complete];
    }
}

#pragma mark :.... delete

/**
 删除表数据

 @param tableName 表名
 @param where 语句对象
 @param complete 完成回调
 */
- (void)deleteTableObject:(NSString *)tableName
                    where:(NSArray *)where
                 complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(where, @"条件数组错误! 不能为空");
    __block BOOL result;
    NSMutableArray *arguments = [NSMutableArray array];
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendFormat:@"delete from %@", tableName];

        if (where && (where.count > 0)) {
            NSArray *results = [CCDatabase whereSQLKeyAndValueHandle:where];
            [SQL appendString:results[ 0 ]];
            [arguments addObjectsFromArray:results[ 1 ]];
        }

        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL withArgumentsInArray:arguments];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateDelete];
    !complete ?: complete(result);
}

/**
 删除表数据(SQL)

 @param tableName 表名
 @param conditions sql
 @param complete 完成回调
 */
- (void)deleteSQLTableObject:(NSString *)tableName
                  conditions:(NSString *)conditions
                    complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(conditions && conditions.length, @"查询条件不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"delete from %@ %@", tableName, conditions];
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateDelete];
    !complete ?: complete(result);
}

/**
 模糊删除表数据

 @param tableName 表名
 @param keyPathValues 查询字段键值
 @param complete 完成回调
 */
- (void)deleteLikeTableObjec:(NSString *)tableName
         forKeyPathAndValues:(NSArray *)keyPathValues
                    complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSString *like = [CCDatabase likeSQLKeyAndValueSplice:keyPathValues where:YES];
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendFormat:@"delete from %@%@", tableName, like];
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateDelete];
    !complete ?: complete(result);
}

#pragma mark :.... update

/**
 更新数据（事物执行）

 @param object 更新对象
 @param where 条件
 *      条件数组，形式@[@"name",@"=",@"CC哥",@"age",@"=>",@(25)],即更新name=CC哥,age=>25的数据. 可以为nil,nil时更新所有数据;
 *      不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 */
- (BOOL)updateTableObjecTransaction:(id)object
                              where:(NSArray *)where
{
    NSString *tableName = NSStringFromClass([object class]);
    __block BOOL result = NO;
    [self isExistWithTableName:tableName
                      complete:^(BOOL isExist) {
                          result = isExist;
                      }];

    if (result) {
        [self executeDB:^(FMDatabase *db) {
            [db beginTransaction];

            NSDictionary *sqlDic = [CCDBTool objectSqlProperties:object];
            [self ifIvarChangeForClass:object];
            [self updateTableObject:tableName
                           KeyValue:sqlDic
                              where:where
                           complete:^(BOOL isSuccess) {
                               result = isSuccess;
                           }];
            [db commit];
        }];
    }
    return result;
}

/**
 更新数据

 @param object 更新对象
 @param where 条件
 *      条件数组，形式@[@"name",@"=",@"CC哥",@"age",@"=>",@(25)],即更新name=CC哥,age=>25的数据. 可以为nil,nil时更新所有数据;
 *      不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 */
- (BOOL)updateTableObjec:(id)object
                   where:(NSArray *)where
{
    NSString *tableName = NSStringFromClass([object class]);
    __block BOOL result = NO;
    [self isExistWithTableName:tableName
                      complete:^(BOOL isExist) {
                          result = isExist;
                      }];

    if (result) {
        NSDictionary *sqlDic = [CCDBTool objectSqlProperties:object];
        [self ifIvarChangeForClass:object];
        [self updateTableObject:tableName
                       KeyValue:sqlDic
                          where:where
                       complete:^(BOOL isSuccess) {
                           result = isSuccess;
                       }];
    }
    return result;
}

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
                 complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(keyValue, @"更新数据集合不能为空!");
    __block BOOL result;
    NSMutableArray *arguments = [NSMutableArray array];
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendFormat:@"update %@ set ", tableName];
        for (int i = 0; i < keyValue.allKeys.count; i++) {
            [SQL appendFormat:@"%@=?", keyValue.allKeys[ i ]];
            [arguments addObject:keyValue[ keyValue.allKeys[ i ] ]];
            if (i != (keyValue.allKeys.count - 1)) {
                [SQL appendString:@","];
            }
        }

        if (where && (where.count > 0)) {
            NSArray *results = [CCDatabase whereSQLKeyAndValueHandle:where];
            [SQL appendString:results[ 0 ]];
            [arguments addObjectsFromArray:results[ 1 ]];
        }

        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL withArgumentsInArray:arguments];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
}

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
                    complete:(void (^)(BOOL isSuccess))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(conditions && conditions.length, @"查询条件不能为空!");
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL;
        if (!keyValue || !keyValue.count) {
            SQL = [NSString stringWithFormat:@"update %@ %@", tableName, conditions];
        } else {
            NSMutableString *param = [NSMutableString stringWithFormat:@"update %@ set ", tableName];
            for (int i = 0; i < keyValue.allKeys.count; i++) {
                NSString *key = keyValue.allKeys[ i ];
                id value = keyValue[ key ];
                if ([value isKindOfClass:[NSString class]]) {
                    [param appendFormat:@"%@='%@'", key, value];
                } else {
                    [param appendFormat:@"%@=%@", key, value];
                }
                if (i != (keyValue.allKeys.count - 1)) {
                    [param appendString:@","];
                }
            }
            [param appendFormat:@" %@", conditions];
            SQL = param;
        }
        CCDBEnterLog(SQL);
        result = [db executeUpdate:SQL];
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
}

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
                         complete:(void (^)(BOOL isSuccess))complete
{
    //自动判断是否有字段改变,自动刷新数据库.
    [self ifIvarChangeForClass:NSClassFromString(tableName)];
    [self updateSQLTableObject:tableName keyValue:keyValue conditions:conditions complete:complete];
}

/**
 更新数据(对象方式并检查数据结构)

 @param object 对象
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)updateSQLQueueTableObject:(id)object
                       conditions:(NSString *)conditions
                         complete:(void (^)(BOOL isSuccess))complete
{
    NSString *tableName = NSStringFromClass([object class]);
    [self ifIvarChangeForClass:NSClassFromString(tableName)]; //自动判断是否有字段改变,自动刷新数据库.
    NSDictionary *keyValue = [CCDBTool objectSqlProperties:object];
    [self updateSQLTableObject:tableName keyValue:keyValue conditions:conditions complete:complete];
}

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
                     complete:(void (^)(BOOL isSuccess))complete
{
    NSString *like = [CCDatabase likeSQLKeyAndValueSplice:keyPathValues where:YES];
    NSMutableArray *arguments = [NSMutableArray array];
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendFormat:@"update %@ set ", tableName];
        for (int i = 0; i < keyValue.allKeys.count; i++) {
            [SQL appendFormat:@"%@=?", keyValue.allKeys[ i ]];
            [arguments addObject:keyValue[ keyValue.allKeys[ i ] ]];
            if (i != (keyValue.allKeys.count - 1)) {
                [SQL appendString:@","];
            }
        }
        [SQL appendString:like];
        result = [db executeUpdate:SQL withArgumentsInArray:arguments];
        CCDBEnterLog(SQL);
    }];

    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
}

/**
 批量更新数据

 @param tableName 表名
 @param uniqueKey 关键字段
 @param objArr 更行数据集合
 @param complete 完成回调
 */
- (void)updateBatchTableObject:(NSString *)tableName
                     uniqueKey:(NSString *)uniqueKey
                   batchObject:(NSArray<NSDictionary *> *)objArr
                      complete:(void (^)(BOOL isSuccess))complete
{
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        [db beginTransaction];
        [objArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSMutableArray *arguments = [NSMutableArray array];
                NSString *where = nil;
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                if (uniqueKey) {
                    id uniqueValue = dict[ uniqueKey ];
                    where = [NSString stringWithFormat:@" where %@=%@", uniqueKey, uniqueValue];
                    if ([uniqueValue isKindOfClass:[NSString class]])
                        where = [NSString stringWithFormat:@" where %@='%@'", uniqueKey, uniqueValue];

                    [tempDict removeObjectForKey:uniqueKey];
                }
                dict = tempDict;
                NSMutableString *SQL = [[NSMutableString alloc] init];
                [SQL appendFormat:@"update %@ set ", tableName];
                [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [SQL appendFormat:@"%@=?,", key];
                    [arguments addObject:obj];
                }];
                SQL = [NSMutableString stringWithString:[SQL substringToIndex:SQL.length - 1]];
                if (where) {
                    [SQL appendString:where];
                }
                CCDBEnterLog(SQL);
                result = [db executeUpdate:SQL withArgumentsInArray:arguments];
            }
        }];
        [db commit];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
    [self closeDB];
}

- (void)updateBatchTableObject:(NSString *)tableName
                   batchObject:(NSArray<NSDictionary *> *)objArr
                    conditions:(NSString *)conditions
                      complete:(void (^)(BOOL isSuccess))complete
{
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        [db beginTransaction];
        [objArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSMutableArray *arguments = [NSMutableArray array];
                NSMutableString *SQL = [[NSMutableString alloc] init];
                [SQL appendFormat:@"update %@ set ", tableName];
                [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [SQL appendFormat:@"%@=?,", key];
                    [arguments addObject:obj];
                }];
                SQL = [NSMutableString stringWithString:[SQL substringToIndex:SQL.length - 1]];
                if (conditions) {
                    [SQL appendString:conditions];
                }
                CCDBEnterLog(SQL);
                result = [db executeUpdate:SQL withArgumentsInArray:arguments];
            }
        }];
        [db commit];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
    [self closeDB];
}

/**
 批量更新数据

 @param tableName 表名
 @param objArr 更行数据集合
 @param complete 完成回调
 */
- (void)updateBatchTableObject:(NSString *)tableName
                   batchObject:(NSArray<NSDictionary *> *)objArr
                      complete:(void (^)(BOOL isSuccess))complete
{
    __block BOOL result;
    [self executeDB:^(FMDatabase *db) {
        [db beginTransaction];
        [objArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSMutableArray *arguments = [NSMutableArray array];
                NSString *uniqueKey = [CCDBTool isRespondsToSelector:NSSelectorFromString(kPRIMARYKEY) class:NSClassFromString(tableName)]; //获取"唯一约束"字段名
                NSString *where = nil;
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                if (uniqueKey) {
                    where = [NSString stringWithFormat:@" where %@=%@", uniqueKey, dict[ uniqueKey ]];
                    [tempDict removeObjectForKey:uniqueKey];
                }
                dict = tempDict;
                NSMutableString *SQL = [[NSMutableString alloc] init];
                [SQL appendFormat:@"update %@ set ", tableName];
                [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [SQL appendFormat:@"%@=?,", key];
                    [arguments addObject:obj];
                }];
                SQL = [NSMutableString stringWithString:[SQL substringToIndex:SQL.length - 1]];
                if (where) {
                    [SQL appendString:where];
                }
                CCDBEnterLog(SQL);
                result = [db executeUpdate:SQL withArgumentsInArray:arguments];
            }
        }];
        [db commit];
    }];
    //数据监听执行函数
    [self dbDataChangeWithName:tableName flag:result state:CCDBChangeStateUpdate];
    !complete ?: complete(result);
    [self closeDB];
}

/**
 批量更行数据(对象)

 @param objects 对象集合
 @param complete 完成回调
 */
- (void)updateBatchTableObject:(NSArray *)objects
                      complete:(void (^)(BOOL isSuccess))complete
{
    // 对象归类 用于区分数组中不同对象
    NSMutableDictionary *classifyM = [NSMutableDictionary dictionary];
    for (id obj in objects) {
        NSString *className = NSStringFromClass([obj class]);

        NSMutableArray *array = [NSMutableArray arrayWithArray:[classifyM objectForKey:className]];
        [array addObject:[CCDBTool objectSqlProperties:[obj class]]];

        [classifyM setObject:array forKey:className];
    }

    for (NSString *tableName in classifyM.allKeys) {
        NSArray *arr = [classifyM objectForKey:tableName];

        [self ifNotExistWillCreateTableWithObject:arr.firstObject];
        [self updateBatchTableObject:tableName batchObject:arr complete:complete];
    }
}

#pragma mark :.... select

- (NSInteger)selectTableMaxID:(NSString *)tableName
{
    NSAssert(tableName, @"表名不能为空!");
    __block NSUInteger count = 0;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select max(ccdb_identifier) from %@", tableName];
        CCDBEnterLog(SQL);
        [db executeStatements:SQL
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  count = 0;
                  if (![resultsDictionary.allValues.lastObject isKindOfClass:[NSNull class]]) {
                      count = [[resultsDictionary.allValues lastObject] integerValue];
                  }
                  return 0;
              }];
    }];
    return count;
}

/**
 查询表中有多少条数据

 @param tableName 表名
 @param where 查询条件
 */
- (NSInteger)selectTableHasCount:(NSString *)tableName
                           where:(NSArray *)where
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(!(where.count % 3), @"条件数组错误!");
    NSMutableString *strM = [NSMutableString string];
    !where ?: [strM appendString:@" where "];
    for (int i = 0; i < where.count; i += 3) {
        if ([where[ i + 2 ] isKindOfClass:[NSString class]]) {
            [strM appendFormat:@"%@%@'%@'", where[ i ], where[ i + 1 ], where[ i + 2 ]];
        } else {
            [strM appendFormat:@"%@%@%@", where[ i ], where[ i + 1 ], where[ i + 2 ]];
        }

        if (i != (where.count - 3)) {
            [strM appendString:@" and "];
        }
    }
    __block NSUInteger count = 0;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select count(*) from %@%@", tableName, strM];
        CCDBEnterLog(SQL);
        [db executeStatements:SQL
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  count = [[resultsDictionary.allValues lastObject] integerValue];
                  return 0;
              }];
    }];
    return count;
}

/**
 查询表中有多少条数据(同步队列查询)

 @param tableName 表名
 @param where 查询条件
 */
- (NSInteger)selectQueueTableHasCount:(NSString *)tableName
                                where:(NSArray *)where
{
    NSInteger count = 0;
    count = [self selectTableHasCount:tableName where:where];
    return count;
}

/**
 查询表中有多少条数据(sql)

 @param tableName 表名
 @param conditions sql查询条件
 */
- (NSInteger)selectTableHasCount:(NSString *)tableName
                      conditions:(NSString *)conditions
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(conditions && conditions.length, @"查询条件不能为空!");
    __block NSUInteger count = 0;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select count(*) from %@ %@", tableName, conditions];
        CCDBEnterLog(SQL);
        [db executeStatements:SQL
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  count = [[resultsDictionary.allValues lastObject] integerValue];
                  return 0;
              }];
    }];
    return count;
}

/**
 查询表中有多少条数据(sql同步队列查询)

 @param tableName 表名
 @param conditions sql查询条件
 */
- (NSInteger)selectQueueTableHasCount:(NSString *)tableName
                           conditions:(NSString *)conditions
{
    NSInteger count = 0;
    count = [self selectTableHasCount:tableName conditions:conditions];
    return count;
}

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
                              where:(NSString *_Nullable)where
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(key, @"属性名不能为空!");
    __block NSUInteger num = 0;
    NSString *method;
    switch (methodType) {
        case CCDBSqliteMethodTypeMin:
            method = [NSString stringWithFormat:@"min(%@)", key];
            break;
        case CCDBSqliteMethodTypeMax:
            method = [NSString stringWithFormat:@"max(%@)", key];
            break;
        case CCDBSqliteMethodTypeSum:
            method = [NSString stringWithFormat:@"sum(%@)", key];
            break;
        case CCDBSqliteMethodTypeAvg:
            method = [NSString stringWithFormat:@"avg(%@)", key];
            break;
        default:
            NSAssert(NO, @"请传入方法类型!");
            break;
    }

    [self executeDB:^(FMDatabase *db) {
        NSString *SQL;
        if (where) {
            SQL = [NSString stringWithFormat:@"select %@ from %@ %@", method, tableName, where];
        } else {
            SQL = [NSString stringWithFormat:@"select %@ from %@", method, tableName];
        }
        CCDBEnterLog(SQL);
        [db executeStatements:SQL
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  id dbResult = [resultsDictionary.allValues lastObject];
                  if (dbResult && ![dbResult isKindOfClass:[NSNull class]]) {
                      num = [dbResult integerValue];
                  } else {
                      num = 0;
                  }
                  return 0;
              }];
    }];
    return num;
}

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
                                   where:(NSString *_Nullable)where
{
    NSInteger num = 0;
    num = [self selectTableMethodCount:tableName type:methodType key:key where:where];
    return num;
}

/**
 like查询（keyPath方式）数量

 @param tableName 表名
 @param keyPathValues 键值
 */
- (NSInteger)selectTableLikeCount:(NSString *)tableName forKeyPathAndValues:(NSArray *)keyPathValues
{
    NSString *like = [CCDatabase likeSQLKeyAndValueSplice:keyPathValues where:YES];
    __block NSUInteger count = 0;
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select count(*) from %@%@", tableName, like];
        CCDBEnterLog(SQL);
        [db executeStatements:SQL
              withResultBlock:^int(NSDictionary *resultsDictionary) {
                  count = [[resultsDictionary.allValues lastObject] integerValue];
                  return 0;
              }];
    }];
    return count;
}

/**
 like查询（keyPath方式）数量 (同步队列查询)

 @param tableName 表名
 @param keyPathValues 键值
 */
- (NSInteger)selectQueueTableLinkeCount:(NSString *)tableName forKeyPathAndValues:(NSArray *)keyPathValues
{
    NSInteger count = 0;
    count = [self selectTableLikeCount:tableName forKeyPathAndValues:keyPathValues];
    return count;
}

/**
 查询表(sql语句)

 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)selectTableObject:(NSString *)tableName conditions:(NSString *)conditions complete:(void (^)(NSArray *array))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSAssert(conditions && conditions.length, @"查询条件不能为空!");
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select * from %@ %@", tableName, conditions];
        CCDBEnterLog(SQL);
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL];
        if (rs == nil) {
            CCDBEnterLog(@"查询错误,可能是'类变量名'发生了改变或'字段','表格'不存在!,请存储后再读取!");
        }
        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [[[rs columnNameToIndexMap] allKeys] count]; i++) {
                dictM[ [rs columnNameForIndex:i] ] = [rs objectForColumnIndex:i];
            }
            [arrM addObject:dictM];
        }
        //查询完后要关闭rs，不然会报@"Warning: there is at least one open result set around after performing
        [rs close];
    }];
    !complete ?: complete(arrM);
}

/**
 查询表(sql语句)同步队列查询

 @param tableName 表名
 @param conditions sql语句
 @param complete 完成回调
 */
- (void)selectQueueTableObjec:(NSString *)tableName
                   conditions:(NSString *)conditions
                     complete:(void (^)(NSArray *array))complete
{
    [self selectTableObject:tableName conditions:conditions complete:complete];
}

/**
 查询表键值语句

 @param tableName 表名
 @param keys 条件
 @param where 查询条件
 @param complete 完成回调
 */
- (void)selectTableKeyValuesWithWhereObject:(NSString *)tableName
                                       keys:(NSArray *)keys
                                      where:(NSArray *)where
                                   complete:(void (^)(NSArray *array))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    __block NSArray *arguments;
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [[NSMutableString alloc] init];
        [SQL appendString:@"select"];
        if ((keys != nil) && (keys.count > 0)) {
            [SQL appendString:@" "];
            for (int i = 0; i < keys.count; i++) {
                [SQL appendFormat:@"%@", keys[ i ]];
                if (i != (keys.count - 1)) {
                    [SQL appendString:@","];
                }
            }
        } else {
            [SQL appendString:@" *"];
        }
        [SQL appendFormat:@" from %@", tableName];

        if (where && (where.count > 0)) {
            NSArray *results = [CCDatabase whereSQLKeyAndValueHandle:where];
            [SQL appendString:results[ 0 ]];
            arguments = results[ 1 ];
        }

        CCDBEnterLog(SQL);
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL withArgumentsInArray:arguments];
        if (!rs)
            CCDBEnterLog(@"查询错误,可能是'类变量名'发生了改变或'字段','表格'不存在!,请存储后再读取,或检查条件数组'字段名称'是否正确");

        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [[[rs columnNameToIndexMap] allKeys] count]; i++) {
                dictM[ [rs columnNameForIndex:i] ] = [rs objectForColumnIndex:i];
            }
            [arrM addObject:dictM];
        }
        //查询完后要关闭rs，不然会报@"Warning: there is at least one open result set around after performing
        [rs close];
    }];
    !complete ?: complete(arrM);
}

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
                                        complete:(void (^)(NSArray *array))complete
{
    [self selectTableKeyValuesWithWhereObject:tableName keys:keys where:where complete:complete];
}

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
                           complete:(void (^)(NSArray *array))complete
{
    NSAssert(tableName, @"表名不能为空!");
    NSMutableArray *arrM = [[NSMutableArray alloc] init];
    __block NSArray *arguments;
    [self executeDB:^(FMDatabase *db) {
        NSMutableString *SQL = [NSMutableString string];
        [SQL appendFormat:@"select * from %@", tableName];

        if (where && (where.count > 0)) {
            NSArray *results = [CCDatabase whereSQLKeyAndValueHandle:where];
            [SQL appendString:results[ 0 ]];
            arguments = results[ 1 ];
        }

        !param ?: [SQL appendFormat:@" %@", param];
        CCDBEnterLog(SQL);
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL withArgumentsInArray:arguments];
        if (!rs)
            CCDBEnterLog(@"查询错误,'表格'不存在!,请存储后再读取!");

        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [[[rs columnNameToIndexMap] allKeys] count]; i++) {
                dictM[ [rs columnNameForIndex:i] ] = [rs objectForColumnIndex:i];
            }
            [arrM addObject:dictM];
        }
        //查询完后要关闭rs，不然会报@"Warning: there is at least one open result set around after performing
        [rs close];
    }];

    !complete ?: complete(arrM);
}

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
                                complete:(void (^)(NSArray *array))complete
{
    [self selectTableParamWhereObject:tableName where:where param:param complete:complete];
}

/**
 查询表like

 @param tableName 表名
 @param keyPathValues 条件
 @param complete 完成回调
 */
- (void)selectTableKeyValuesObject:(NSString *)tableName
               forKeyPathAndValues:(NSArray *)keyPathValues
                          complete:(void (^)(NSArray *array))complete
{
    NSMutableArray *arrM = [NSMutableArray array];
    NSString *like = [CCDatabase likeSQLKeyAndValueSplice:keyPathValues where:YES];
    [self executeDB:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select * from %@%@", tableName, like];
        CCDBEnterLog(SQL);
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL];
        if (!rs)
            CCDBEnterLog(@"查询错误,数据不存在,请存储后再读取!");

        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [[[rs columnNameToIndexMap] allKeys] count]; i++) {
                dictM[[rs columnNameForIndex:i]] = [rs objectForColumnIndex:i];
            }
            [arrM addObject:dictM];
        }
        //查询完后要关闭rs，不然会报@"Warning: there is at least one open result set around after performing
        [rs close];
    }];

    !complete ?: complete(arrM);
}

/**
 同步查询表like

 @param tableName 表名
 @param keyPathValues 条件
 @param complete 完成回调
 */
-(void)selectQueueTableKeyValuesObject:(NSString *)tableName
                   forKeyPathAndValues:(NSArray *)keyPathValues
                              complete:(void (^)(NSArray *array))complete
{
    [self selectTableKeyValuesObject:tableName forKeyPathAndValues:keyPathValues complete:complete];
}


#pragma mark -
#pragma mark :. monitorHandel
/** 注册数据变化监听 **/
- (BOOL)registerChangeWithName:(NSString *)tableName
                   changeBlock:(void (^)(CCDBChangeState result))block
{
    if ([_changeBlocks.allKeys containsObject:tableName]) {
        NSString *reason = [NSString stringWithFormat:@"%@类重复注册监听,注册监听失败!", tableName];
        CCDBEnterLog(reason);
        return NO;
    } else {
        [_changeBlocks setObject:block forKey:tableName];
        return YES;
    }
}

/** 移除数据变化监听 **/
- (BOOL)removeChangeWithName:(NSString *)tableName
{
    if ([_changeBlocks.allKeys containsObject:tableName]) {
        [_changeBlocks removeObjectForKey:tableName];
        return YES;
    } else {
        NSString *reason = [NSString stringWithFormat:@"没有找到%@监听,移除监听失败!", tableName];
        CCDBEnterLog(reason);
        return NO;
    }
}

/** 数据库数据变化处理 **/
- (void)dbDataChangeWithName:(NSString *)tableName flag:(BOOL)flag state:(CCDBChangeState)state
{
    if (flag && _changeBlocks.count > 0) {
        //开一个子线程去执行block,防止死锁.
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.changeBlocks enumerateKeysAndObjectsUsingBlock:^(id  key, id  obj, BOOL * stop) {
                if ([tableName isEqualToString:key]) {
                    void (^block)(CCDBChangeState) = obj;
                    //返回主线程回调.
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        block(state);
                    });
                }
            }];
        });
    }
}

#pragma mark -
#pragma mark :. getter/setter

- (FMDatabaseQueue *)fmdbQueue
{
    if (!_fmdbQueue) {
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:[self dbPath]];
    }
    return _fmdbQueue;
}

@end

