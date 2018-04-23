//
//  UICityPicker.h
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PickerStyle) {
    PickerStyle_type,         //糖尿病类型
    PickerStyle_Waist,        //腰围
    PickerStyle_Weight,       //体重
    PickerStyle_Height,       //身高
    PickerStyle_Age,          //年龄
    PickerStyle_Sex,          //性别
    PickerStyle_sportTime,    //运动时间
    PickerStyle_Place,        //所在地区
    PickerStyle_DietTime,     //饮食时间段
    PickerStyle_Blood,         //血压
    PickerStyle_Step,          //步数
    PickerStyle_SugarPeriod,   //血糖时间段
    PickerStyle_Relationship,  //亲友关系
    PickerStyle_ReminderType, //定时提醒类型
    PickerStyle_Time,         //烹饪时间
    PickerStyle_OrderTime,    //预约启动时间
    PickerStyle_Integral,     //积分
};


@interface TimePickerView : UIActionSheet<UIPickerViewDelegate, UIPickerViewDataSource,UIApplicationDelegate> {
@private
    BOOL isReloadComponent;
    NSInteger rowNum;
}
@property (nonatomic)PickerStyle pickerStyle;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic, assign) NSInteger maxHours;//最大的小时值
@property (nonatomic, assign) NSInteger minHours;//最小的小时值
@property (nonatomic, assign) NSInteger minMinutes;//最小的分钟值

@property(strong,nonatomic)  UIView *backgroudView;;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate;

@property (nonatomic,strong)NSArray *valuesArray;   //选择值（饮食时间段）

- (void)showInView:(UIView *)view;

@end
