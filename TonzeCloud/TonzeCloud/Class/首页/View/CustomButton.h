//
//  CustomButton.h
//  TonzeCloud
//
//  Created by vision on 17/6/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton

@property (nonatomic ,strong)NSString *iconImage;

@property (nonatomic ,strong)NSString *titleStr;

-(instancetype)initWithFrame:(CGRect)frame;

@end
