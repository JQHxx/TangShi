//
//  TCArticleTableView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCArticleModel.h"

@protocol TCArticleTableViewDelegate <NSObject>

-(void)articleTableViewDidSelectedCellWithArticle:(TCArticleModel *)article;

@end
@interface TCArticleTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)NSInteger      type;
@property (nonatomic,strong)NSMutableArray *articlesArray;

@property (nonatomic,weak) id <TCArticleTableViewDelegate> articleDetagate;

@end

