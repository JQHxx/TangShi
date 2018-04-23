//
//  TCFoodAddTool.m
//  TonzeCloud
//
//  Created by vision on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodAddTool.h"

@implementation TCFoodAddTool

singleton_implementation(TCFoodAddTool)

-(void)setSelectFoodArray:(NSMutableArray *)selectFoodArray{
    _selectFoodArray=selectFoodArray;
}

-(void)insertFood:(TCFoodAddModel *)food{
    if (_selectFoodArray==nil) {
        _selectFoodArray=[[NSMutableArray alloc] init];
    }
    [self.selectFoodArray addObject:food];
}

-(void)updateFood:(TCFoodAddModel *)food{
    for (NSInteger i=0; i<self.selectFoodArray.count; i++) {
        TCFoodAddModel *model=self.selectFoodArray[i];
        if (model.id==food.id) {
            [self.selectFoodArray replaceObjectAtIndex:i withObject:food];
        }
    }
}

-(void)deleteFood:(TCFoodAddModel *)food{
    [self.selectFoodArray removeObject:food];
}

-(void)removeAllFood{
    [self.selectFoodArray removeAllObjects];
}


@end
