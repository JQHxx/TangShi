//
//  TCDailyRecipesTableView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDailyRecipesTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSDictionary      *dataMenuDic;
@property (nonatomic,strong)NSArray           *headTitles;

@end
