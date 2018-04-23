//
//  TCDetailButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDetailButton : UIButton
@property(nonatomic,strong)UIImageView   *headImage;
@property(nonatomic,strong)UILabel       *expertName;

-(instancetype)initWithFrame:(CGRect)frame;

@end
