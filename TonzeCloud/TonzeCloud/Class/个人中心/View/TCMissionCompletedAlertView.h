//
//  TCMissionCompletedAlertView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResultBlcok)(NSInteger index);

@interface TCMissionCompletedAlertView : UIView

/**
*   taskSuccessStr  任务完成名
*   points          积分
*   rewardIntegralStr  奖励积分提示语
*   isHideBonusPoints  是否隐藏奖励积分
*
*   isHideRedeemBtn    是否隐藏“积分兑换”按钮
*
*/

- (instancetype)initWithTaskSuccessStr:(NSString *)taskSuccessStr points:(NSInteger )points rewardIntegralStr:(NSString *)rewardIntegralStr isHideBonusPoints:(BOOL)isHideBonusPoints isHideRedeemBtn:(BOOL)isHideRedeemBtn;

#pragma mark －－展示alertview
-(void)show;

///
@property (nonatomic, copy)  AlertResultBlcok alertResultBlcok;


@end
