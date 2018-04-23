//
//  TCMineButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCMineButton : UIButton
@property(nonatomic,strong)UILabel  *titleName;
@property(nonatomic,strong)UILabel  *contentLab;
@property(nonatomic,strong)UILabel  *phoneLab;
-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict;

@end
