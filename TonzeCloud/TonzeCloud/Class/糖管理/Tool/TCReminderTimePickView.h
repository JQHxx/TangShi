//
//  TCReminderTypePickView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReminderTimePickViewDelegate <NSObject>

-(void)didSelectedPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component RowText:(NSString *)text;
@end

@interface TCReminderTimePickView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

///
@property (nonatomic ,strong) UIPickerView *pickView;

@property (nonatomic, weak) id reminderDelegate;

@property (nonatomic, strong) NSArray *proTitleList;

-(void)remove;
-(void)show:(UIView *)view;

@end
