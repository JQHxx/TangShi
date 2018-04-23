//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TimePickerView.h"

#define kDuration 0.3

@interface TimePickerView ()<CAAnimationDelegate>{
    
}

@end

@implementation TimePickerView

@synthesize titleLabel;
@synthesize locatePicker;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TimePickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.titleLabel.text = title;
        self.descLabel.hidden=YES;
        
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        NSString* phoneModel = [UIDevice getDeviceVersion];//获取设备型号
        float version=[[phoneModel substringFromIndex:6] floatValue];
        if (version>7.2) {
            //6s要加这几句pickerview才能正常显示
            CGRect rect=self.locatePicker.frame;
            rect.size.width=[ UIScreen mainScreen ].bounds.size.width;
            self.locatePicker.frame=rect;
        }
    
        self.backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
        [self.backgroudView setBackgroundColor:[UIColor blackColor]];
        [self.backgroudView setAlpha:0.3f];
        
    }
    return self;
}

- (void)showInView:(UIView *) view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"DDLocateView"];
    
    self.frame = CGRectMake(0,view.height - self.height,kScreenWidth, self.height);
    [view addSubview:self.backgroudView];
    [view addSubview:self];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (self.pickerStyle==PickerStyle_Place){
        return 3;
    }else if (self.pickerStyle == PickerStyle_Blood){
        return 4;
    }else if(self.pickerStyle==PickerStyle_Weight){
        return 4;
    }else if(self.pickerStyle==PickerStyle_Time){
        return 2;
    }else if(self.pickerStyle==PickerStyle_OrderTime){
        return 3;
    }else{
        return 1;
    }
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.pickerStyle==PickerStyle_Place){
  
    }else if (self.pickerStyle==PickerStyle_Height){
        return 201;
    }else if (self.pickerStyle==PickerStyle_Waist){
        return 291;
    }else if (self.pickerStyle==PickerStyle_sportTime){
        return 300;
    }else if (self.pickerStyle==PickerStyle_Sex){
        return 2;
    }else if (self.pickerStyle==PickerStyle_Blood){
        if (component==0||component==2) {
            return 1;
        }else{
           return 231;
        }
    }else if (self.pickerStyle==PickerStyle_Weight){
        if (component==0) {
            return 241;
        }else if(component==1){
            return 1;
        }else if (component==2){
            NSString *str = [NSString stringWithFormat:@"%ld",(long)[self.locatePicker selectedRowInComponent:0]];
            if ([str isEqualToString:@"240"]) {
                return 1;
            }else{
                return 10;
            }
        }else{
            return 1;
        }
    }else if (self.pickerStyle==PickerStyle_type){
        return 7;
    }else if (self.pickerStyle==PickerStyle_Relationship){
        return 15;
    }else if(self.pickerStyle==PickerStyle_Age){
        return 100;
    }else if(self.pickerStyle==PickerStyle_DietTime){
        return self.valuesArray.count;
    }else if(self.pickerStyle==PickerStyle_Step){
        return 99;
    }else if(self.pickerStyle==PickerStyle_SugarPeriod){
        return [[TCHelper sharedTCHelper].sugarPeriodArr count];
    }else if (self.pickerStyle == PickerStyle_ReminderType){
        return [[TCHelper sharedTCHelper].reminderTypeArr count];
    }else if(self.pickerStyle == PickerStyle_Time){
        NSInteger row=0;
        if (component==0) {
            row = self.maxHours + 1-self.minHours;
        }else{
            if (isReloadComponent){
                row=rowNum;
            }else{
                row = 60;
            }
        }
        return row;
    }else if(self.pickerStyle==PickerStyle_OrderTime){
        NSInteger row=0;
        if (component==0) {
            row = 8;
        }else if(component==1){
            row=1;
        }else{
            if (isReloadComponent){
                row=rowNum;
            }else{
                row = 60;
            }
        }
        return row;
    }else if(self.pickerStyle==PickerStyle_Integral){
        return 2;
    }else{
        return 0;
    }
    return 0;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 0.0f, 120.0f, 30.0f)];
    if (self.pickerStyle==PickerStyle_DietTime) {
        myView.frame = CGRectMake(50.0f, 0.0f, 180.0f, 30.0f);
    }
    if (self.pickerStyle==PickerStyle_Place){
       
    }else if (self.pickerStyle==PickerStyle_Sex){
         myView.text=row==0?@"男":@"女";
    }else if (self.pickerStyle==PickerStyle_Height){
        myView.text=[NSString stringWithFormat:@"%li",(long)row+50];
    }else if (self.pickerStyle==PickerStyle_Waist){
        myView.text=[NSString stringWithFormat:@"%li",(long)row+10];
    }else if (self.pickerStyle==PickerStyle_sportTime){
        myView.text=[NSString stringWithFormat:@"%li",(long)row+1];
    }else if (self.pickerStyle==PickerStyle_Blood){
        if (component==0) {
            myView.text=@"收缩压：";
        }else if (component==2){
            myView.text=@"舒张压：";
        }else{
           myView.text=[NSString stringWithFormat:@"%li",(long)row+20];
        }
    }else if (self.pickerStyle==PickerStyle_Weight){
        if (component==0) {
            myView.text=[NSString stringWithFormat:@"%ld",(long)row+10];
        }else if(component==1){
            myView.text=@".";
        }else if (component==2){
            myView.text=[NSString stringWithFormat:@"%ld",(long)row];
        }else{
            myView.text=@"kg";
        }
    }else if (self.pickerStyle==PickerStyle_Age){
        myView.text=[NSString stringWithFormat:@"%li",(long)row];
    } else if (self.pickerStyle==PickerStyle_type){
        switch (row) {
            case 0:
                myView.text=@"正常";
                break;
            case 1:
                myView.text=@"1型糖尿病";
                break;
            case 2:
                myView.text=@"2型糖尿病";
                break;
            case 3:
                myView.text=@"妊娠型糖尿病";
                break;
            case 4:
                myView.text=@"特殊型糖尿病";
                break;
            case 5:
                myView.text=@"糖尿病前期";
                break;
            case 6:
                myView.text=@"其他";
                break;
            default:
                break;
        }
    } else if (self.pickerStyle==PickerStyle_Relationship){
        myView.text=[[TCHelper sharedTCHelper].relationshipArr objectAtIndex:row];
    }else if (self.pickerStyle==PickerStyle_SugarPeriod){
        myView.text=[[TCHelper sharedTCHelper].sugarPeriodArr objectAtIndex:row];
    }else if (self.pickerStyle==PickerStyle_DietTime){
        myView.text=self.valuesArray[row];
    }else if (self.pickerStyle==PickerStyle_Step){
        myView.text=[NSString stringWithFormat:@"%ld",(long)(row+1)*1000];
    }else if (self.pickerStyle == PickerStyle_ReminderType){
        myView.text =[[TCHelper sharedTCHelper].reminderTypeArr objectAtIndex:row];
    }else if (self.pickerStyle == PickerStyle_Time){
        if (component == 0) {
            myView.text = [NSString stringWithFormat:@"%02ld小时", (long)row+self.minHours];
        } else if (component == 1) {
            if (self.minMinutes>0&&[self.locatePicker selectedRowInComponent:0]==0) {
                myView.text = [NSString stringWithFormat:@"%02ld分钟",(long)(row+self.minMinutes)];
            }else{
                myView.text = [NSString stringWithFormat:@"%02ld分钟", (long)row];
            }
        }
    }else if (self.pickerStyle==PickerStyle_OrderTime){
        if (component==0) {
            if (self.minHours>16) {
                NSInteger minValue=self.minHours;
                NSArray *values=[[NSArray alloc] init];
                switch (minValue) {
                    case 17:
                        values=@[@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"00"];
                        break;
                    case 18:
                        values=@[@"18",@"19",@"20",@"21",@"22",@"23",@"00",@"01"];
                        break;
                    case 19:
                        values=@[@"19",@"20",@"21",@"22",@"23",@"00",@"01",@"02"];
                        break;
                    case 20:
                        values=@[@"20",@"21",@"22",@"23",@"00",@"01",@"02",@"03"];
                        break;
                    case 21:
                        values=@[@"21",@"22",@"23",@"00",@"01",@"02",@"03",@"04"];
                        break;
                    case 22:
                        values=@[@"22",@"23",@"00",@"01",@"02",@"03",@"04",@"05"];
                        break;
                    case 23:
                        values=@[@"23",@"00",@"01",@"02",@"03",@"04",@"05",@"06"];
                        break;
                        
                    default:
                        break;
                }
                myView.text=values[row];
            }else{
                myView.text=[NSString stringWithFormat:@"%02ld",(long)row+self.minHours];
            }
        }else if (component==1){
            myView.text=@":";
        }else{
            if (self.minMinutes>0&&[self.locatePicker selectedRowInComponent:0]==0) {
                myView.text=[NSString stringWithFormat:@"%02ld",(long)row+self.minMinutes];
            }else{
                myView.text = [NSString stringWithFormat:@"%02ld", (long)row];
            }
        }
        
    }else if (self.pickerStyle==PickerStyle_Integral){
        myView.text=[NSString stringWithFormat:@"%ld",500*(row+1)];
    }
    
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = [UIFont fontWithName:@"EurostileExtended-Roman-DTC" size:22.0];
    myView.backgroundColor = [UIColor clearColor];
    return myView;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickerStyle==PickerStyle_Place) {
        if (component == 0) {
            [self.locatePicker reloadComponent:1];
            [self.locatePicker reloadComponent:2];
        }else if (component == 1){
            [self.locatePicker reloadComponent:2];
        }
    }else if (self.pickerStyle==PickerStyle_Time){
        if (component==0) {
            if ([self.locatePicker selectedRowInComponent:0]+self.minHours ==self.minHours) {
                isReloadComponent=YES;
                rowNum=60-self.minMinutes;
            }else if ([self.locatePicker selectedRowInComponent:0]+self.minHours == self.maxHours) {
                isReloadComponent=YES;
                rowNum=1;
            }
             [self.locatePicker reloadComponent:1];
        }
    }else if (self.pickerStyle==PickerStyle_OrderTime){
        if (component==0) {
            NSInteger hour=[self.locatePicker selectedRowInComponent:0];
            if (hour+self.minHours==self.minHours) {
                isReloadComponent=YES;
                rowNum=60-self.minMinutes;
            }else if (hour+self.minHours==self.maxHours){
                isReloadComponent=YES;
                rowNum=self.minMinutes;
            }else{
                isReloadComponent=NO;
            }
            [self.locatePicker reloadComponent:2];
        }
    }
    
    
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:kbgBtnColor];
    
    if (self.pickerStyle==PickerStyle_Height){
        label.text=[NSString stringWithFormat:@"%licm",(long)label.text.integerValue];
    }else if (self.pickerStyle==PickerStyle_Waist){
        label.text=[NSString stringWithFormat:@"%licm",(long)label.text.integerValue];
    }else if (self.pickerStyle==PickerStyle_sportTime){
        label.text=[NSString stringWithFormat:@"%li分钟",(long)label.text.integerValue];
    }else if (self.pickerStyle==PickerStyle_Blood){
        label.font = [UIFont systemFontOfSize:15];
        if (component ==1) {
            [label setTextColor:kSystemColor];
            label.text=[NSString stringWithFormat:@"%li",(long)label.text.integerValue];
        } else if(component==3){
            [label setTextColor:kSystemColor];
            label.text=[NSString stringWithFormat:@"%li",(long)label.text.integerValue];
        }
    }else if (self.pickerStyle==PickerStyle_Weight){
        if (component==0) {
            label.text=[NSString stringWithFormat:@"%ld",(long)[label.text integerValue]];
            [label setTextColor:kSystemColor];
            
            if ([label.text integerValue]==250) {
                [self.locatePicker reloadComponent:2];
            }else{
                [self.locatePicker reloadComponent:2];
            }
        }else if(component==1){
            label.text=@".";
        }else if (component==2){
            label.text=[NSString stringWithFormat:@"%ld",(long)[label.text integerValue]];
            [label setTextColor:kSystemColor];
        }else{
            label.text=@"kg";
        }
    }else if (self.pickerStyle==PickerStyle_DietTime){
        label.frame=CGRectMake(20, 0, kScreenWidth-40, 30);
        label.textAlignment=NSTextAlignmentCenter;
    }else if (self.pickerStyle == PickerStyle_Time){
        if (component==0) {
            label.text=[NSString stringWithFormat:@"%02li小时",(long)label.text.integerValue];
        }else{
            label.text=[NSString stringWithFormat:@"%02li分钟",(long)label.text.integerValue];
        }
    }else if (self.pickerStyle==PickerStyle_OrderTime){
        if (component==1) {
            label.text=@":";
        }else{
           label.text=[NSString stringWithFormat:@"%02li",(long)label.text.integerValue];
        }
        
    }else if (self.pickerStyle==PickerStyle_Integral){
        label.text=[NSString stringWithFormat:@"%ld",(long)label.text.integerValue];
    }
}

- (void)changeLabelStateWithRow:(NSInteger)row component:(NSInteger)component pockerView:(UIPickerView *)pickerView{
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:UIColorFromRGB(0xff8314)];
    if (component==0) {
        label.text=[NSString stringWithFormat:@"%li小时",(long)label.text.integerValue];
    }else{
        label.text=[NSString stringWithFormat:@"%li分钟",(long)label.text.integerValue];
    }
}


#pragma mark -- Setters and Getters
-(void)setValuesArray:(NSArray *)valuesArray{
    _valuesArray=valuesArray;
}


#pragma mark - Button lifecycle

- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
            [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
}



-(void)viewRemoveFromSuperview{
    [self.backgroudView removeFromSuperview];
    [self removeFromSuperview];
}




@end
