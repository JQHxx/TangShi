//
//  TCConsultTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCConsultModel.h"

@interface TCConsultTableViewCell : UITableViewCell
-(void)cellConsultWithDict:(TCConsultModel *)consultModel;

@end
