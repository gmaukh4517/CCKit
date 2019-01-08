//
//  CCDBTool.m
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

#import "CCDBTool.h"
#import <UIKit/UIImage.h>
#import <objc/runtime.h>

/** SQLite五种数据类型 */
#define SQLTEXT @"TEXT"       //字符串，以数据库编码方式存储（UTF-8, UTF-16BE 或者 UTF-16-LE）。
#define SQLINTEGER @"INTEGER" //有符号整数，按大小被存储成1,2,3,4,6或8字节。
#define SQLREAL @"REAL"       //浮点数，以8字节指数形式存储。
#define SQLBLOB @"BLOB"       //BLOB数据不做任何转换，以输入形式存储。
#define SQLNULL @"NULL"       //该值为空
#define PrimaryKey @"primary key"

//100M大小限制.
#define MaxData @(838860800)

typedef void (^CCClassesEnumeration)(Class c, BOOL *stop);
static NSSet *foundationClasses_;

@implementation CCDBTool

#pragma mark -
#pragma mark :. CCDB Class

+ (id)isRespondsToSelector:(SEL)selector class:(Class)classs
{
    id obj = nil;
    if ([classs respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [classs performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

+ (NSSet *)foundationClasses
{
    if (foundationClasses_ == nil) {
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses_ = [NSSet setWithObjects:
                              [NSURL class],
                              [NSDate class],
                              [NSValue class],
                              [NSData class],
                              [NSError class],
                              [NSArray class],
                              [NSDictionary class],
                              [NSString class],
                              [NSAttributedString class], nil];
    }
    return foundationClasses_;
}

+ (void)cc_enumerateClasses:(Class)classs complete:(CCClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    // 2.停止遍历的标记
    BOOL stop = NO;
    // 3.当前正在遍历的类
    Class c = classs;
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        // 4.2.获得父类
        c = class_getSuperclass(c);
        if ([self isClassFromFoundation:c]) break;
    }
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    if (c == [NSObject class]) return YES;
    __block BOOL result = NO;
    [[CCDBTool foundationClasses] enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

#pragma mark -
#pragma mark :. CCDBProperty

/** 类中有不需要创建数据库字段 **/
+ (NSArray *)filterColumns:(Class)classs
{
    NSMutableArray *columnArray = [NSMutableArray array];
    SEL columnsSEL = NSSelectorFromString([NSString stringWithFormat:@"%@filterColumns", @""]);
    
    NSArray *arr = [CCDBTool isRespondsToSelector:columnsSEL class:classs];
    if (arr)
        [columnArray addObjectsFromArray:arr];
    
    return columnArray;
}

/** 类中array model class 配置 **/
+ (NSDictionary *)objectClassInArray:(Class)classs
{
    NSMutableDictionary *classArrayDic = [NSMutableDictionary dictionary];
    SEL classArraySEL = NSSelectorFromString([NSString stringWithFormat:@"%@setupObjectClassInArray", @"ccdb_"]);
    NSDictionary *dic = [CCDBTool isRespondsToSelector:classArraySEL class:classs];
    if (dic) {
        [classArrayDic setDictionary:dic];
    }
    return classArrayDic;
}

/**
 获取对象属性与属性类型
 
 @param class 对象
 @param filterColumns 忽略属性
 */
+ (NSDictionary *)objectProperties:(Class)classs
{
    NSMutableArray *propertyNames = [NSMutableArray array];
    NSMutableArray *propertyTypes = [NSMutableArray array];
    NSMutableArray *propertySQLTypes = [NSMutableArray array];
    NSArray *filterColumns = [CCDBTool filterColumns:classs];
    
    [propertyNames addObject:@"ccdb_identifier"]; //主键
    [propertyTypes addObject:@"i"];
    [propertySQLTypes addObject:SQLINTEGER];
    
    [CCDBTool cc_enumerateClasses:classs
                         complete:^(__unsafe_unretained Class c, BOOL *stop) {
                             unsigned int numIvars; //成员变量个数
                             Ivar *vars = class_copyIvarList(classs, &numIvars);
                             for (int i = 0; i < numIvars; i++) {
                                 Ivar thisIvar = vars[i];
                                 //获取成员变量的名
                                 NSString *propertyName = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                                 if ([propertyName containsString:@"_"])
                                     propertyName = [propertyName substringFromIndex:1];
                                 
                                 //过滤不需要创建属性
                                 if ([filterColumns containsObject:propertyName])
                                     continue;
                                 [propertyNames addObject:propertyName];
                                 
                                 NSString *propertyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
                                 [propertyTypes addObject:propertyType]; //对象属性类型
                                 
                                 propertyType = [CCDBTool sqlTypeAnalysis:propertyType];
                                 if ([SQLTEXT isEqualToString:propertyType]) {
                                     propertyType = SQLTEXT;
                                 } else if ([SQLREAL isEqualToString:propertyType]) {
                                     propertyType = SQLREAL;
                                 } else if ([SQLINTEGER isEqualToString:propertyType]) {
                                     propertyType = SQLINTEGER;
                                 } else if ([SQLBLOB isEqualToString:propertyType]) {
                                     propertyType = SQLBLOB;
                                 } else {
                                     NSAssert(NO, @"没有找到匹配的类型!");
                                 }
                                 [propertySQLTypes addObject:propertyType]; //对象数据库类型
                             }
                             free(vars); //释放资源
                         }];
			 
    return [NSDictionary dictionaryWithObjectsAndKeys:propertyNames, @"propertyName", propertyTypes, @"propertyType", propertySQLTypes, @"propertySQLType", nil];
}

/**
 获取对象属性与值
 
 @param class 对象
 @param filterColumns 忽略属性
 */
+ (NSDictionary *)objectSqlProperties:(id)object
{
    Class classs = [object class];
    NSMutableDictionary *propertyM = [NSMutableDictionary dictionary];
    NSArray *filterColumns = [CCDBTool filterColumns:classs];
    
    [CCDBTool cc_enumerateClasses:classs
                         complete:^(__unsafe_unretained Class c, BOOL *stop) {
                             unsigned int numIvars; //成员变量个数
                             Ivar *vars = class_copyIvarList(classs, &numIvars);
                             for (int i = 0; i < numIvars; i++) {
                                 Ivar thisIvar = vars[i];
                                 //获取成员变量的名
                                 NSString *propertyName = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                                 if ([propertyName containsString:@"_"])
                                     propertyName = [propertyName substringFromIndex:1];
                                 
                                 //过滤不需要创建属性
                                 if ([filterColumns containsObject:propertyName])
                                     continue;
                                 
                                 id propertyValue = [object valueForKey:propertyName];
                                 if (propertyValue) {
                                     NSString *propertyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
                                     propertyValue = [CCDBTool valueAnalysisHandle:propertyValue level:0 valueType:propertyType encode:YES];
                                     [propertyM setObject:propertyValue forKey:propertyName];
                                 }
                             }
                             free(vars); //释放资源
                         }];
    return propertyM;
}

#pragma mark -
#pragma mark :. CCDB SQLite

/**
 属性类型处理 (返回SQLite字段类型)
 @param type 属相类型
 */
+ (NSString *)sqlTypeAnalysis:(NSString *)valueType
{
    if ([valueType isEqualToString:@"i"] || [valueType isEqualToString:@"I"] ||
        [valueType isEqualToString:@"s"] || [valueType isEqualToString:@"S"] ||
        [valueType isEqualToString:@"q"] || [valueType isEqualToString:@"Q"] ||
        [valueType isEqualToString:@"b"] || [valueType isEqualToString:@"B"] ||
        [valueType isEqualToString:@"c"] || [valueType isEqualToString:@"C"] ||
        [valueType isEqualToString:@"l"] || [valueType isEqualToString:@"L"]) {
        return SQLINTEGER;
    } else if ([valueType isEqualToString:@"f"] || [valueType isEqualToString:@"F"] ||
               [valueType isEqualToString:@"d"] || [valueType isEqualToString:@"D"]) {
        return SQLREAL;
    } else if ([valueType isEqualToString:@"@\"NSString\""] || [valueType isEqualToString:@"NSMutableString"] ||
               [valueType containsString:@"NSRange"] || [valueType containsString:@"CGRect"] ||
               [valueType containsString:@"CGPoint"] || [valueType containsString:@"CGSize"]) {
        return SQLTEXT;
    } else {
        return SQLBLOB;
    }
}

/**
 值分析处理
 
 @param value 值
 @param level 级别 0 级 用于存储需要编码 大于0级都不是存储对象不要编码
 @param valueType 值类型
 @param isEncode 是否编解码
 */
+ (id)valueAnalysisHandle:(id)value
                    level:(NSInteger)level
                valueType:(NSString *)valueType
                   encode:(BOOL)isEncode
{
    if (!value || [value isKindOfClass:[NSNull class]]) return nil;
    
    if ([valueType isEqualToString:@"@\"NSString\""] || [valueType isEqualToString:@"@\"NSMutableString\""]) {
        return value;
    } else if ([valueType containsString:@"Number"]) {
        if (isEncode) {
            return [NSString stringWithFormat:@"%@", value];
        } else {
            return [[NSNumberFormatter new] numberFromString:value];
        }
    } else if ([valueType isEqualToString:@"@\"NSData\""] || [valueType isEqualToString:@"@\"NSMutableData\""] ||
               [valueType isEqualToString:@"@\"NSDate\""] || [valueType isEqualToString:@"@\"NSURL\""] ||
               [valueType isEqualToString:@"@\"UIImage\""] || [valueType isEqualToString:@"@\"UIColor\""] ||
               [valueType isEqualToString:@"@\"NSAttributedString\""] || [valueType isEqualToString:@"@\"NSMutableAttributedString\""]) {
        if (isEncode) {
            if ([valueType containsString:@"@\"UIImage\""]) {
                NSData *data = UIImageJPEGRepresentation(value, 1);
                NSNumber *maxLength = MaxData;
                NSAssert(data.length < maxLength.integerValue, @"最大存储限制为100M");
                return data;
            }
            
            return [[NSKeyedArchiver archivedDataWithRootObject:value] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        } else {
            if ([valueType containsString:@"@\"UIImage\""])
                return [UIImage imageWithData:value];
            
            NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    } else if ([valueType isEqualToString:@"@\"NSArray\""] || [valueType isEqualToString:@"@\"NSMutableArray\""] ||
               [valueType isEqualToString:@"@\"NSSet\""] || [valueType isEqualToString:@"@\"NSMutableSet\""]) {
        if (level == 0) {
            if (isEncode) {
                NSArray *arr = [self arrayToSqlObject:value];
                return [[NSKeyedArchiver archivedDataWithRootObject:arr] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            } else {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        } else {
            return [self arrayToSqlObject:value];
        }
    } else if ([valueType isEqualToString:@"@\"NSDictionary\""] || [valueType isEqualToString:@"@\"NSMutableDictionary\""]) {
        if (level == 0) {
            if (isEncode) {
                NSDictionary *dic = [self dictionaryToSqlObject:value];
                return [[NSKeyedArchiver archivedDataWithRootObject:dic] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            } else {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        return [self dictionaryToSqlObject:value];
    } else if ([valueType isEqualToString:@"@\"NSHashTable\""]) {
        if (level == 0) {
            if (isEncode) {
                NSArray *arr = [self hashTableToSqlObject:value];
                return [[NSKeyedArchiver archivedDataWithRootObject:arr] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            } else {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        return [self hashTableToSqlObject:value];
    } else if ([valueType isEqualToString:@"@\"NSMapTable\""]) {
        if (level == 0) {
            if (isEncode) {
                NSDictionary *dic = [self mapTableToSqlObject:value];
                return [[NSKeyedArchiver archivedDataWithRootObject:dic] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            } else {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        return [self mapTableToSqlObject:value];
    } else if ([valueType containsString:@"NSRange"]) {
        if (isEncode) {
            return NSStringFromRange([value rangeValue]);
        } else {
            return [NSValue valueWithRange:NSRangeFromString(value)];
        }
    } else if ([valueType containsString:@"CGRect"] && [valueType containsString:@"CGPoint"] && [valueType containsString:@"CGSize"]) {
        if (isEncode) {
            return NSStringFromCGRect([value CGRectValue]);
        } else {
            return [NSValue valueWithCGRect:CGRectFromString(value)];
        }
    } else if (![valueType containsString:@"CGRect"] && [valueType containsString:@"CGPoint"] && ![valueType containsString:@"CGSize"]) {
        if (isEncode) {
            return NSStringFromCGPoint([value CGPointValue]);
        } else {
            return [NSValue valueWithCGPoint:CGPointFromString(value)];
        }
    } else if (![valueType containsString:@"CGRect"] && ![valueType containsString:@"CGPoint"] && [valueType containsString:@"CGSize"]) {
        if (isEncode) {
            return NSStringFromCGSize([value CGSizeValue]);
        } else {
            return [NSValue valueWithCGSize:CGSizeFromString(value)];
        }
    } else if ([valueType isEqualToString:@"i"] || [valueType isEqualToString:@"I"] ||
               [valueType isEqualToString:@"s"] || [valueType isEqualToString:@"S"] ||
               [valueType isEqualToString:@"q"] || [valueType isEqualToString:@"Q"] ||
               [valueType isEqualToString:@"b"] || [valueType isEqualToString:@"B"] ||
               [valueType isEqualToString:@"c"] || [valueType isEqualToString:@"C"] ||
               [valueType isEqualToString:@"l"] || [valueType isEqualToString:@"L"]) {
        return value;
    } else if ([valueType isEqualToString:@"f"] || [valueType isEqualToString:@"F"] ||
               [valueType isEqualToString:@"d"] || [valueType isEqualToString:@"D"]) {
        return value;
    } else {
        if (level == 0) {
            if (isEncode) {
                NSDictionary *dic = [self objectToSqlObject:value];
                return [[NSKeyedArchiver archivedDataWithRootObject:dic] base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
                ;
            } else {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                NSString *objeType = [valueType stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                objeType = [objeType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                return [self jsonToObjectWithClassName:objeType keyValue:value level:level + 1];
            }
        }
        return [self objectToSqlObject:value];
    }
}

#pragma mark -
#pragma mark :. CCDB Object Conversion
/** JOSN字符串转化为字典 **/
+ (NSDictionary *)jsonToObject:(NSString *)json
{
    NSAssert(json, @"数据不能为空!");
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:NSJSONReadingMutableContainers
                                               error:&err];
    
    NSAssert(!err, @"json解析失败");
    return dic;
}

/** data转化为JSON字符串 **/
+ (NSString *)dataToJSON:(id)data
{
    NSAssert(data, @"数据不能为空!");
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)valueToSqlObject:(id)value
{
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
        return [self arrayToSqlObject:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        return [self dictionaryToSqlObject:value];
    } else if ([value isKindOfClass:[NSMapTable class]]) {
        return [self dictionaryToSqlObject:value];
    } else if ([value isKindOfClass:[NSHashTable class]]) {
        return [self hashTableToSqlObject:value];
    } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSData class]]) {
        return value;
    } else if ([value isKindOfClass:[UIImage class]]) {
        NSData *data = UIImageJPEGRepresentation(value, 1);
        NSNumber *maxLength = MaxData;
        NSAssert(data.length < maxLength.integerValue, @"最大存储限制为100M");
        return data;
    } else {
        return [self objectToSqlObject:value];
    }
}

/** 数组转化为数据可存储对象 **/
+ (NSArray *)arrayToSqlObject:(id)arr
{
    if ([NSJSONSerialization isValidJSONObject:arr]) {
        return arr;
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (id value in arr)
            [array addObject:[self valueToSqlObject:value]];
        
        return array;
    }
}

/** 字典转化为数据可存储对象 **/
+ (NSDictionary *)dictionaryToSqlObject:(NSDictionary *)dictionary
{
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        return dictionary;
    } else {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        for (NSString *key in dictionary.allKeys)
            dicM[key] = [self valueToSqlObject:[dictionary objectForKey:key]];
        
        return dicM;
    }
}

/** NSMapTable转化为数据可存储对象 **/
+ (NSDictionary *)mapTableToSqlObject:(NSMapTable *)mapTable
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    NSArray *objects = mapTable.keyEnumerator.allObjects;
    NSArray *keys = mapTable.objectEnumerator.allObjects;
    for (int i = 0; i < objects.count; i++) {
        dictM[keys[i]] = [self valueToSqlObject:objects[i]];
    }
    return dictM;
}

/** NSHashTable转化为数据可存储对象 **/
+ (NSArray *)hashTableToSqlObject:(NSHashTable *)hashTable
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *values = hashTable.objectEnumerator.allObjects;
    for (id value in values)
        [array addObject:[self valueToSqlObject:value]];
    
    return array;
}

/** 对象转化为数据可存储对象 **/
+ (id)objectToSqlObject:(NSObject *)object
{
    NSMutableDictionary *keyValueDict = [NSMutableDictionary dictionary];
    Class class = [object class];
    NSDictionary *keys = [CCDBTool objectProperties:class];	 // 获取对象属性与属性类型
    NSArray *propertyNameArr = [keys objectForKey:@"propertyName"]; //属性名称
    NSArray *propertyTypeArr = [keys objectForKey:@"propertyType"]; //属性名称
    
    for (NSInteger i = 0; i < propertyNameArr.count; i++) {
        NSString *propertyName = [propertyNameArr objectAtIndex:i];
        NSString *propertyType = [propertyTypeArr objectAtIndex:i];
        id propertyValue = [object valueForKey:propertyName];
        if (propertyValue) {
            propertyValue = [self valueAnalysisHandle:propertyValue level:1 valueType:propertyType encode:YES];
            [keyValueDict setObject:propertyValue forKey:propertyName];
        }
    }
    return keyValueDict;
}

/** 字典转化为对象 **/
+ (id)jsonToObjectWithClassName:(NSString *)className
                       keyValue:(NSDictionary *)keyValue
                          level:(NSInteger)level
{
    id object = [NSClassFromString(className) new];
    NSDictionary *objectClassInArray = [CCDBTool objectClassInArray:[object class]]; // 模型中嵌套模型解析
    
    NSDictionary *propertys = [CCDBTool objectProperties:[object class]];
    NSArray *propertyNames = [propertys objectForKey:@"propertyName"];
    NSArray *propertyTypes = [propertys objectForKey:@"propertyType"];
    
    [keyValue.allKeys enumerateObjectsUsingBlock:^(id _Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
        id remoteValue = [keyValue objectForKey:key];
        if (remoteValue) {
            if ([propertyNames containsObject:key]) {
                NSInteger index = [propertyNames indexOfObject:key];
                
                remoteValue = [CCDBTool valueAnalysisHandle:remoteValue level:level valueType:[propertyTypes objectAtIndex:index] encode:NO];
                if ([objectClassInArray.allKeys containsObject:key]) //解析嵌套模型
                    remoteValue = [CCDBTool jsonToObjectWithClassName:[objectClassInArray objectForKey:key] keyValue:remoteValue level:level];
                
                [object setValue:remoteValue forKey:key];
            }
        }
    }];
    return object;
}

+(id)sqlObjectToWithClass:(NSString *)className keyValue:(NSDictionary *)keyValue
{
    return [CCDBTool jsonToObjectWithClassName:className keyValue:keyValue level:0];
}

@end

