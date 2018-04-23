//
//  TCArticleLibraryViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ArticleLibraryBackBlock)(NSInteger id,NSInteger readNum);

@interface TCArticleLibraryViewController : BaseViewController

@property (nonatomic,assign)NSInteger cateID;

@property (nonatomic,assign)NSInteger articleIndex;
/// 是否为任务列表进入
@property (nonatomic, assign) BOOL  isTaskListLogin;

@property (nonatomic,copy)ArticleLibraryBackBlock articleBackBlock;

@end
