//
//  TCTreatTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCTreatTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *highlightImage;
-(void)cellDisplayWithDict:(NSDictionary *)dict;
@end
