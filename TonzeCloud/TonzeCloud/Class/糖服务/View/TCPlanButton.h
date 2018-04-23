//
//  TCPlanButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPlanButton : UIButton
@property(nonatomic,strong)UIImageView   *headImage;
@property(nonatomic,strong)UILabel       *expertName;
@property(nonatomic,strong)UILabel       *workRank;
-(instancetype)initWithFrame:(CGRect)frame;
@end
