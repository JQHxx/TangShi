//
//  TCReminderTypePickView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCReminderTimePickView.h"

@implementation TCReminderTimePickView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth, CGRectGetHeight(frame) - 10)];
        self.pickView.delegate = self;
        self.pickView.dataSource = self;
        self.pickView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.pickView];
    }
    return self;
}
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_proTitleList count];
}
// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_proTitleList[component] count];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_proTitleList[component] objectAtIndex:row];;
}
// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.frame.size.width/[self.proTitleList count] - 10;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 38;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:UIColorFromRGB(0x313131)];
    label.font = kBoldFontWithSize(18);
    
    if ([self.reminderDelegate respondsToSelector:@selector(didSelectedPickerView:didSelectRow:inComponent:RowText:)]) {
        [self.reminderDelegate didSelectedPickerView:self.pickView didSelectRow:row inComponent:component RowText:_proTitleList[component][row]];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        if (component == 0) {
            [pickerLabel setTextAlignment:NSTextAlignmentRight];
        }else if (component == 1){
            [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        }else{
            [pickerLabel setTextAlignment:NSTextAlignmentLeft];
        }
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

-(void)remove
{
    [self removeFromSuperview];
}

-(void)show:(UIView *)view
{
    [view addSubview:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
