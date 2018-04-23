//
//  TCFileModel.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCFileModel : NSObject

@property(nonatomic,strong)NSString *typeString;       //糖尿病类型
@property(nonatomic,strong)NSString *dateString;       //确认日期
@property(nonatomic,strong)NSString *treatMethodString;//治疗方法
@property(nonatomic,strong)NSString *bloodString;      //最近一次血压
@property(nonatomic,assign)BOOL      smoke;            //是否吸烟
@property(nonatomic,assign)BOOL      alcohol;          //是否喝酒
@end
