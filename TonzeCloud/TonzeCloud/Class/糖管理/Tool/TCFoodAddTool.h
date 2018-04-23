//
//  TCFoodAddTool.h
//  TonzeCloud
//
//  Created by vision on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCFoodAddModel.h"

@interface TCFoodAddTool : NSObject

singleton_interface(TCFoodAddTool)

@property (nonatomic,strong)NSMutableArray *selectFoodArray;   //已选食物数组

/*
 *@bref 添加食物
 */
-(void)insertFood:(TCFoodAddModel *)food;

/*
 *@bref 更新食物
 */
-(void)updateFood:(TCFoodAddModel *)food;

/*
 *@bref 删除食物
 */
-(void)deleteFood:(TCFoodAddModel *)food;

/*
 *@bref 删除所有事物
 */
-(void)removeAllFood;




@end
