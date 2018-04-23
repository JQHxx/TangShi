//
//  TCDatePickerView.h
//  TonzeCloud
//
//  Created by vision on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DatePickerViewTypeDate =0,
    DatePickerViewTypeDateTime = 1 << 0
} DatePickerViewType;

@class TCDatePickerView;

@protocol TCDatePickerViewDelegate <NSObject>

-(void)datePickerView:(TCDatePickerView *)pickerView didSelectDate:(NSString *)dateStr;

@end

@interface TCDatePickerView : UIView<CAAnimationDelegate>

@property (nonatomic,weak)id<TCDatePickerViewDelegate>pickerDelegate;

-(instancetype)initWithFrame:(CGRect)frame value:(NSString *)dateValue pickerType:(DatePickerViewType)type;

-(instancetype)initWithFrame:(CGRect)frame birthdayValue:(NSString *)dateValue pickerType:(DatePickerViewType)type title:(NSString *)title;

-(instancetype)initWithFrame:(CGRect)frame ageValue:(NSString *)dateValue pickerAgeType:(DatePickerViewType)type;

-(void)datePickerViewShowInView:(UIView *)view;


@end
