//
//  TCManagerRecordButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/26.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCManagerRecordButton : UIButton

@property (nonatomic,strong)UILabel *titleLab;

@property (nonatomic,strong)UIImageView *image;
-(instancetype)initWithFrame:(CGRect)frame dictManager:(NSDictionary *)dict bgColor:(UIColor *)color;

@end
