//
//  TCRuleAlertView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSInteger titleBtnTag,NSInteger alertViewTag);

@interface TCRuleAlertView : UIView

-(instancetype)initWithTitle:(NSString*)title andWithMassage:(NSString*)massage andWithTag:(NSInteger)tag andWithButtonTitle:(NSString*)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark －－展示alertview
-(void)show;

#pragma mark －－设置标题文字颜色
-(void)setTitleTextColorr:(UIColor *)textColor;

#pragma mark －－设置信息文字颜色
-(void)setMassageTextColor:(UIColor *)textColor;

#pragma mark －－设置背景颜色
-(void)setAlertViewBgColor:(UIColor*)bgColor;

#pragma mark －－设置按钮背景颜色－－设置按钮文字颜色
-(void)setTitleBtnWithBgColor:(UIColor *)bgColor andWithtitleColor:(UIColor *)titleColor atBtnTag:(NSInteger)tag;

@property(nonatomic,copy)AlertResult resultIndex;

@end
