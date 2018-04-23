//
//  TCSportTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/28.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSportTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;  //运动
@property (weak, nonatomic) IBOutlet UILabel *sportType;    //运动类型
@property (weak, nonatomic) IBOutlet UILabel *consumeLab;   //运动消耗


@end
