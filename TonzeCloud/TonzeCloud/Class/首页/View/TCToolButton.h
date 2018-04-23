//
//  TCToolButton.h
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCToolButton : UIButton

@property (nonatomic,strong)UILabel *titleLab;

@property (nonatomic,strong)UIView *bgView;

@property (nonatomic,strong)UIImageView *headImage;

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict bgColor:(UIColor *)color;

-(instancetype)initWithFriendRankListFrame:(CGRect)frame;

@end
