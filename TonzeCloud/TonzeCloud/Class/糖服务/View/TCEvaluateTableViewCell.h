//
//  TCEvaluateTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/6/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCEvaluateModel.h"


@interface TCEvaluateTableViewCell : UITableViewCell

@property (nonatomic,strong)TCEvaluateModel *evaluateModel;

+(CGFloat)getEvaluateCellHeightWithModel:(TCEvaluateModel *)model;

@end
