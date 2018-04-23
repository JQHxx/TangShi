//
//  NSDictionary+Extend.m
//  SRZNetworkDemo
//
//  Created by vision on 16/7/21.
//  Copyright © 2016年 shuruzhi. All rights reserved.
//

#import "NSDictionary+Extend.h"

@implementation NSDictionary (Extend)

- (id)srz_objectForKey:(id<NSCopying>)key{
    if(key==nil){
        return nil;
    }
    return [self objectForKey:key];
}

- (NSInteger)srz_integerForKey:(id)key{
    if(key==nil){
        return 0;
    }
    NSNumber *number=[self srz_numberForKey:key];
    return [number integerValue];
}

- (double)srz_doubleForKey:(id)key {
    if (key == nil) {
        return 0;
    }
    
    NSNumber *number = [self srz_numberForKey:key];
    return [number doubleValue];
}

- (NSString *)srz_stringForKey:(id)key{
    if (key==nil) {
        return nil;
    }
    id obj=[self srz_objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    }else if ([obj isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",obj];
    }
    return nil;
}

- (NSNumber *)srz_numberForKey:(id)key{
    if (key==nil) {
        return 0;
    }
    id obj=[self srz_objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)obj;
    }
    return nil;
}

- (NSDictionary *)srz_dictionaryForKey:(id)key {
    if (key == nil) {
        return 0;
    }
    id obj = [self srz_objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    }
    return nil;
}

- (NSArray *)srz_arrayForKey:(id)key {
    if (key == nil) {
        return 0;
    }
    id obj = [self srz_objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    }
    return nil;
}

- (BOOL)srz_boolForKey:(id)key {
    if (key == nil) {
        return NO;
    }
    id number = [self srz_objectForKey:key];
    if ([number respondsToSelector:@selector(boolValue)]) {
        return [number boolValue];
    }
    return NO;
}

@end
