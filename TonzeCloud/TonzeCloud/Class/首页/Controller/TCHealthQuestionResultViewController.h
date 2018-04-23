//
//  TCHealthQuestionResultViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCHealthQuestionResultViewController : BaseViewController

@property(nonatomic ,assign)NSInteger index;

@property(nonatomic ,assign)NSInteger num;

@property(nonatomic ,strong)NSString  *titleStr;

@property(nonatomic ,strong)NSString  *brief;

@property(nonatomic ,strong)NSString  *imgUrl;

@property(nonatomic ,strong)NSString  *shareUrl;

@property (nonatomic ,assign)NSInteger assess_id;

@end
