//
//  NSDictionary+Extend.h
//  SRZNetworkDemo
//
//  Created by vision on 16/7/21.
//  Copyright © 2016年 shuruzhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extend)

/**
 *  通过key从字典中获取对象
 *
 *  @param key key
 *
 *  @return 返回对象
 */
- (id)srz_objectForKey:(id<NSCopying>)key;

/**
 *  取出整型数据
 *
 *  @param key 键
 *
 *  @return 整型数据
 */
- (NSInteger)srz_integerForKey:(id)key;

/**
 *  取出浮点型数据
 *
 *  @param key 键
 *
 *  @return 浮点数据
 */
- (double)srz_doubleForKey:(id)key;

/**
 *  取出字符串数据
 *
 *  @param key 键
 *
 *  @return 字符串
 */
- (NSString *)srz_stringForKey:(id)key;

/**
 *  取出基本数据类型的数据
 *
 *  @param key 键
 *
 *  @return NSNumber对象
 */
- (NSNumber *)srz_numberForKey:(id)key;

/**
 *  取出字典
 *
 *  @param key 键
 *
 *  @return 字典对象
 */
- (NSDictionary *)srz_dictionaryForKey:(id)key;

/**
 *  取出数组
 *
 *  @param key 键
 *
 *  @return 数组对象
 */
- (NSArray *)srz_arrayForKey:(id)key;

/**
 *  取出bool型数据
 *
 *  @param key 键
 *
 *  @return bool值
 */
- (BOOL)srz_boolForKey:(id)key;

@end
