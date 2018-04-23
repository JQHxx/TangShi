//
//  TCServiceStateCell.h
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMineServiceModel.h"

@interface TCServiceStateCell : UITableViewCell

@property (nonatomic,strong)UIButton            *evaluateBtn;
@property (nonatomic,strong)TCMineServiceModel  *myService;

@end
