//
//  TCGroupedData.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGroupedData : NSObject

//@[[@"11",@"32"],@[@"big",@"Boy"],...@[@"zoom",@"zune"]]
+(NSArray *)getGroupedArray:(NSArray *)array;

//@[@"title1",@"title2",...@"titlen"]
+(NSArray *)getIndexArray:(NSArray *)array;

//@[{@"indexKey":@"A",@"arrayKey":@[@"abandon",@"About",@"All"]},
//                    ............                              ,
//@{@"indexKey":@"Z",@"arrayKey":@[@"bean",@"Big",@"boy"]}
+(NSArray *)getGroupedDictionaryArray:(NSArray *)array
                             indexKey:(NSString *)indexKey
                             arrayKey:(NSString *)arrayKey;

//@[{@"A":@[@"abandon",@"About",@"All"]},
//    ......................     ,
//  {@"Z":@[@"bean",@"Big",@"boy"]}]
+(NSArray *)getGroupedDictionaryArray:(NSArray *)array;

@end

@interface NSString (TCGroupedData)

-(BOOL)startWithChinese;
-(BOOL)startWithEnglish;
-(BOOL)startWithNumber;

-(NSString *)changeToEnglishOrChinese;

-(NSString *)transformToPinyin;

-(NSString *)getFirstLetter;

@end
