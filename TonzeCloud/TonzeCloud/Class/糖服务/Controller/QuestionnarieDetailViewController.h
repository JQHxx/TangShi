//
//  QuestionnarieDetailViewController.h
//  TangShiService
//
//  Created by vision on 17/12/13.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^QuestionnarieSaveBlock)(NSString *questionnarieTitle);

@interface QuestionnarieDetailViewController : BaseViewController

@property (nonatomic,assign)NSInteger id;

@property (nonatomic,strong)NSString *titleStr;

@property (nonatomic, copy )QuestionnarieSaveBlock saveBlock;

@end
