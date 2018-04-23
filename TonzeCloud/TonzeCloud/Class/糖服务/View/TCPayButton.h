//
//  TCPayButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPayButton : UIButton

@property(nonatomic,strong)UIImageView   *headImage;
@property(nonatomic,strong)UIImageView   *Image;
@property(nonatomic,strong)UILabel       *expertName;
-(instancetype)initWithFrame:(CGRect)frame;

@end
