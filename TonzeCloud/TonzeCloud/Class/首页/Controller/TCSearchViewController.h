//
//  TCSearchViewController.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    FoodSearchType=0,
    KnowledgeSearchType=1,
    FoodAddSearchType  =2
} SearchType;

@interface TCSearchViewController : BaseViewController

@property (nonatomic,assign)SearchType type;

@end
