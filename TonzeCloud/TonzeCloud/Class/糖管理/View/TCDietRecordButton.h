//
//  TCDietRecordButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDietRecordButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict;

@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,assign)NSInteger num;

@end
