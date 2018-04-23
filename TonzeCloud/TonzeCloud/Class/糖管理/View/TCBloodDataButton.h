//
//  TCBloodDataButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCBloodDataButton : UIButton

@property(nonatomic,strong)UILabel *timeLabel;
-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict;

@end
