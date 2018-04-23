//
//  TCArcSlider.h
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCArcSliderDelegate <NSObject>

-(void)arcSliderSetSugarValueWithAngle:(CGFloat)angle;

@end

@interface TCArcSlider : UIControl

@property (nonatomic,weak)id<TCArcSliderDelegate>slideDelegate;

@property (nonatomic,assign)CGFloat initAngle; //初始角度

@property (nonatomic,assign)CGFloat minValueAngle;
@property (nonatomic,assign)CGFloat maxValueAngle;
@property (nonatomic,assign)BOOL isbool;

@property (nonatomic,assign)BOOL isHomeIn;

-(void)moveArcSliderWithAngle:(CGFloat)newAngle;

@end
