//
//  TCEditWithAddRemindViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCRegularRemindersModel.h"

typedef NS_ENUM(NSInteger ,RemindType){
    AddRemind,
    EditRemind,
    BloodSugarRemind,// 血糖提醒
};
@interface TCEditAndAddRemindViewController : BaseViewController
/// 提醒类型
@property (nonatomic ,assign)  RemindType remindType;
/// 提醒数据
@property (nonatomic, strong) TCRegularRemindersModel  *reminderModel;
/// 多少分钟设定提醒（血糖提醒）
@property (nonatomic, assign) NSInteger  minutesLater;

@end
