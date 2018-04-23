//
//  TCImageButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/4/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCImageButton : UIButton
@property(nonatomic,strong)UILabel  *titleName;
@property(nonatomic,strong)UILabel  *contentLab;


-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict;
@end
