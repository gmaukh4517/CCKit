//
//  CCKeyValueStore.m
//  CCKit
//
// Copyright (c) 2015 CC ( https://github.com/gmaukh4517/CCKit )
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

#import "CCKeyValueStore.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#define PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

@implementation CCKeyValueItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"id=%@, value=%@, timeStamp=%@", _itemId, _itemObject, _createdTime];
}

@end

@interface CCKeyValueStore ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, copy) NSString *dbPath;

@end

static NSString *const DEFAULT_DB_NAME = @"CCDatabase.sqlite";

static NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT NOT NULL, \
createdTime TEXT NOT NULL, \
PRIMARY KEY(id)) \
";

static NSString *const UPDATE_ITEM_SQL = @"REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)";

static NSString *const QUERY_ITEM_SQL = @"SELECT json, createdTime from %@ where id = ? Limit 1";

static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";

static NSString *const CLEAR_ALL_SQL = @"DELETE from %@";

static NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where id = ?";

static NSString *const DELETE_ITEMS_SQL = @"DELETE from %@ where id in ( %@ )";

static NSString *const DELETE_ITEMS_WITH_PREFIX_SQL = @"DELETE from %@ where id like ? ";

@implementation CCKeyValueStore


+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        //        CCNSLogger(@"ERROR, table name: %@ format error.", tableName);
        return NO;
    }
    return YES;
}

- (id)initDBWithName:(NSString *)dbName
{
    if (self = [super init]) {
        _dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
        
        if (_dbQueue)
            [self close];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    }
    return self;
}

- (id)initWithDBWithPath:(NSString *)dbPath
{
    if (self = [super init]) {
        _dbPath = dbPath;
        if (_dbQueue)
            [self close];
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (BOOL)checkTableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = %@", tableName];
    __block BOOL isCkeck = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count) {
                isCkeck = NO;
            } else {
                isCkeck = YES;
            }
        }
    }];
    return isCkeck;
}

- (void)createTableWithName:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to create table: %@", tableName);
    }
}

- (void)clearTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to clear table: %@", tableName);
    }
}

- (void)putObject:(id)object
           withId:(NSString *)objectId
        intoTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return;
    
    NSError *error;
    NSData *data = object;
    if (![data isKindOfClass:[NSData class]]) {
        data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    }
    if (error) {
        //        CCNSLogger(@"ERROR, faild to get json data");
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    NSDate *createdTime = [NSDate date];
    NSString *sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId, jsonString, createdTime];
    }];
    
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to insert/replace into table: %@", tableName);
    }
}

- (id)getObjectById:(NSString *)objectId
          fromTable:(NSString *)tableName
{
    CCKeyValueItem *item = [self getCCKeyValueItemById:objectId
                                             fromTable:tableName];
    if (item) {
        return item.itemObject;
    } else {
        return nil;
    }
}

- (CCKeyValueItem *)getCCKeyValueItemById:(NSString *)objectId
                                fromTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return nil;
    
    if (![self checkTableName:tableName]) {
        [self createTableWithName:tableName];
    }
    
    NSString *sql = [NSString stringWithFormat:QUERY_ITEM_SQL, tableName];
    __block NSString *json = nil;
    __block NSDate *createdTime = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql, objectId];
        if ([rs next]) {
            json = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    
    if (json) {
        NSError *error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments)
                                                      error:&error];
        if (error) {
            //            CCNSLogger(@"ERROR, faild to prase to json");
            return nil;
        }
        
        CCKeyValueItem *item = [[CCKeyValueItem alloc] init];
        item.itemId = objectId;
        item.itemObject = result;
        item.createdTime = createdTime;
        return item;
    } else {
        return nil;
    }
}

- (void)putString:(NSString *)string
           withId:(NSString *)stringId
        intoTable:(NSString *)tableName
{
    if (!string) {
        //        CCNSLogger(@"error, string is nil");
        return;
    }
    
    [self putObject:@[ string ]
             withId:stringId
          intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId
                  fromTable:(NSString *)tableName
{
    NSArray *array = [self getObjectById:stringId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]])
        return array[0];
    
    return nil;
}

- (void)putNumber:(NSNumber *)number
           withId:(NSString *)numberId
        intoTable:(NSString *)tableName
{
    if (!number) {
        //        CCNSLogger(@"error, number is nil");
        return;
    }
    
    [self putObject:@[ number ]
             withId:numberId
          intoTable:tableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId
                  fromTable:(NSString *)tableName
{
    NSArray *array = [self getObjectById:numberId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (NSArray *)getAllItemsFromTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return nil;
    
    NSString *sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray *result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            CCKeyValueItem *item = [[CCKeyValueItem alloc] init];
            item.itemId = [rs stringForColumn:@"id"];
            item.itemObject = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    // parse json string to object
    NSError *error;
    for (CCKeyValueItem *item in result) {
        error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments)
                                                      error:&error];
        if (error) {
            //            CCNSLogger(@"ERROR, faild to prase to json.");
        } else
            item.itemObject = object;
    }
    
    return result;
}

- (void)deleteObjectById:(NSString *)objectId
               fromTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return;
    
    NSString *sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId];
    }];
    
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to delete item from table: %@", tableName);
    }
}

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray
                     fromTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return;
    
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to delete items by ids from table: %@", tableName);
    }
}

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix
                      fromTable:(NSString *)tableName
{
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return;
    
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_WITH_PREFIX_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", objectIdPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    
    if (!result) {
        //        CCNSLogger(@"ERROR, failed to delete items by id prefix from table: %@", tableName);
    }
}

- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

- (NSArray *)getItemsFromTable:(NSString *)tableName
                     withRange:(NSRange)range
{
    
    if ([CCKeyValueStore checkTableName:tableName] == NO)
        return nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT %zd, %zd", tableName, range.location, range.length];
    __block NSMutableArray *result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            CCKeyValueItem *item = [[CCKeyValueItem alloc] init];
            item.itemId = [rs stringForColumn:@"id"];
            item.itemObject = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    
    // parse json string to object
    NSError *error;
    for (CCKeyValueItem *item in result) {
        error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments)
                                                      error:&error];
        if (error) {
            //            CCNSLogger(@"ERROR, faild to prase to json.");
        } else
            item.itemObject = object;
    }
    return result;
}

- (BOOL)isExistTableWithName:(NSString *)tableName
{
    __block BOOL result;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next]) {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count) {
                result = NO;
            } else {
                result = YES;
            }
        }
        
    }];
    return result;
}

// 删除表
- (BOOL)deleteTable:(NSString *)tableName
{
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
        if (![db executeUpdate:sqlstr]) {
            //            CCNSLogger(@"Delete table error!");
            result = NO;
        }
        result = YES;
    }];
    return result;
}

// 删除数据库
- (void)deleteDatabseWithDBName:(NSString *)DBName
{
    __block BOOL success;
    __block NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // delete the old db.
    if ([fileManager fileExistsAtPath:DBName]) {
        [_dbQueue inDatabase:^(FMDatabase *db) {
            [db close];
            success = [fileManager removeItemAtPath:DBName error:&error];
            if (!success) {
                NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
            }
        }];
    }
}

- (NSString *)getDBPath
{
    return _dbPath;
}

@end
