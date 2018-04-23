//
//  TCFoodSelectView.h
//  TonzeCloud
//
//  Created by vision on 17/3/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodAddModel.h"

@protocol TCFoodSelectViewDelegate <NSObject>

//已选食物视图关闭
-(void)foodSelectViewDismissAction;
//删除食物
-(void)foodSelectViewDeleteFood:(TCFoodAddModel *)food;
//选择食物
-(void)foodSelectViewDidSelectFood:(TCFoodAddModel *)food;

@end

@interface TCFoodSelectView : UIView

@property (nonatomic,weak)id<TCFoodSelectViewDelegate>delegate;

@property (nonatomic,strong)UITableView     *tableView;
@property (nonatomic,strong)NSMutableArray  *foodSelectArray;


@end
