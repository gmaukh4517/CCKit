//
//  CCDownloadStore.m
//  CCKit
//
// Copyright (c) 2015 CC
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

#import "CCDownloadStore.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#define PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

@implementation CCDownloadItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"id=%@, value=%@, timeStamp=%@", _uniqueId, _itemObject, _createdTime];
}

@end

@interface CCDownloadStore ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, copy) NSString *dbPath;

@end

static NSString *const DEFAULT_DB_NAME = @"CCDownloadDatabase.sqlite";

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

@implementation CCDownloadStore

+ (NSString *)createDirInDocument:(NSString *)pathName
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
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

+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        return NO;
    }
    return YES;
}

- (id)initDBWithName:(NSString *)dbName
{
    if (self = [super init]) {
        _dbPath = [[CCDownloadStore createDirInDocument:nil] stringByAppendingPathComponent:dbName];

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

- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

- (BOOL)checkTableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = '%@'", tableName];
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
    if ([CCDownloadStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
    }
}

- (void)clearTable:(NSString *)tableName
{
    if ([CCDownloadStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];

    if (!result) {
    }
}

- (void)putObject:(id)object
           withId:(NSString *)objectId
        intoTable:(NSString *)tableName
{
    if ([CCDownloadStore checkTableName:tableName] == NO)
        return;

    NSError *error;
    NSData *data = object;
    if (![data isKindOfClass:[NSData class]]) {
        data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    }
    if (error) {
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
    }
}

- (void)deleteObjectById:(NSString *)objectId
               fromTable:(NSString *)tableName
{
    if ([CCDownloadStore checkTableName:tableName] == NO)
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

- (id)getObjectById:(NSString *)objectId
          fromTable:(NSString *)tableName
{
    CCDownloadItem *item = [self getCCKeyValueItemById:objectId
                                             fromTable:tableName];
    if (item) {
        return item.itemObject;
    } else {
        return nil;
    }
}

- (NSArray *)getAllItemsWithTable:(NSString *)tableName
{
    if ([CCDownloadStore checkTableName:tableName] == NO)
        return nil;

    if (![self checkTableName:tableName]) {
        [self createTableWithName:tableName];
    }

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *SQL = [NSString stringWithFormat:@"select * from %@", tableName];
        FMResultSet *rs = [db executeQuery:SQL];

        while (rs.next) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [[[rs columnNameToIndexMap] allKeys] count]; i++) {
                dictM[ [rs columnNameForIndex:i] ] = [rs objectForColumnIndex:i];
            }
            [array addObject:[dictM objectForKey:@"json"]];
        }
        [rs close];
    }];
    return array;
}

- (CCDownloadItem *)getCCKeyValueItemById:(NSString *)objectId
                                fromTable:(NSString *)tableName
{
    if ([CCDownloadStore checkTableName:tableName] == NO)
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
            return nil;
        }

        CCDownloadItem *item = [[CCDownloadItem alloc] init];
        item.uniqueId = objectId;
        item.itemObject = result;
        item.createdTime = createdTime;
        return item;
    } else {
        return nil;
    }
}

@end
