//
//  TCScaleView.h
//  TonzeCloud
//
//  Created by vision on 17/3/3.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodAddModel.h"

@class TCScaleView;
@protocol TCScaleViewDelegate <NSObject>

-(void)scaleView:(TCScaleView *)scaleView didSelectFood:(TCFoodAddModel *)food;

@end

@interface TCScaleView : UIView

@property (nonatomic,weak)id<TCScaleViewDelegate>scaleDelegate;

-(instancetype)initWithFrame:(CGRect)frame model:(TCFoodAddModel *)model;

-(void)scaleViewShowInView:(UIView *)view;

@end
