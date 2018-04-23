//
//  TCSetSugarView.m
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSetSugarView.h"
#import "TCArcSlider.h"

#define kSuagrValueMax   35.0

@interface TCSetSugarView ()<TCArcSliderDelegate,UITextFieldDelegate>{
    UITextField      *valueLabel;    //血糖值
    UILabel          *rangeLabel;    //正常范围
    TCArcSlider      *slider;
    UILabel          *lineLabel;
    double           value;
    
    double           normalMinValue;
    double           normalMaxValue;
}

@end

@implementation TCSetSugarView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        self.isbool = NO;
        slider=[[TCArcSlider alloc] initWithFrame:CGRectMake(60, 10, kScreenWidth-120, (kScreenWidth-120)/2+10)];
        slider.slideDelegate=self;
        [self addSubview:slider];
        
        UIButton *lessBtn=[[UIButton alloc] initWithFrame:CGRectMake(20, 120, 35, 35)];
        lessBtn.tag=100;
        [lessBtn setImage:[UIImage imageNamed:@"pub_ic_reduce"] forState:UIControlStateNormal];
        [lessBtn addTarget:self action:@selector(changeBloodSugarValueAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lessBtn];
        
        UIButton *addBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-55, 120, 35, 35)];
        addBtn.tag=101;
        [addBtn setImage:[UIImage imageNamed:@"pub_ic_add"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(changeBloodSugarValueAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
        
        valueLabel = [[UITextField alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 60, 100, 30)];
        valueLabel.text = @"0.0";
        valueLabel.keyboardType = UIKeyboardTypeDecimalPad;
        valueLabel.delegate = self;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.textColor = kSystemColor;
        valueLabel.font = [UIFont systemFontOfSize:30.0f];
        [self addSubview:valueLabel];
        
        CGSize width = [valueLabel.text sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2)];
        lineLabel.backgroundColor =valueLabel.textColor;
        [self addSubview:lineLabel];
        
        UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, valueLabel.bottom+10, 100, 20)];
        unitLabel.font=[UIFont systemFontOfSize:12.0];
        unitLabel.textAlignment=NSTextAlignmentCenter;
        unitLabel.text=@"mmol/L";
        unitLabel.textColor=[UIColor lightGrayColor];
        [self addSubview:unitLabel];
        
        rangeLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-160)/2, unitLabel.bottom+20, 160, 20)];
        rangeLabel.font=[UIFont boldSystemFontOfSize:12.0];
        rangeLabel.textAlignment=NSTextAlignmentCenter;
        rangeLabel.text=@"";
        rangeLabel.textColor=[UIColor lightGrayColor];
        [self addSubview:rangeLabel];
    }
    return self;
}

-(void)setIsHomeIn:(BOOL)isHomeIn{
    _isHomeIn=isHomeIn;
    slider.isHomeIn=isHomeIn;
}

#pragma mark --UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    MyLog(@"textFieldDidBeginEditing,event:%@",self.isHomeIn?@"101_002007":@"102_002007");
    
#if !DEBUG
    if (self.isHomeIn) {
        [MobClick event:@"101_002007"];
    }else{
        [MobClick event:@"102_002007"];
    }
#endif
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    slider.minValueAngle=180-(normalMinValue/kSuagrValueMax)*180+0.1;
    slider.maxValueAngle=180-(normalMaxValue/kSuagrValueMax)*180-0.1;
    if (1 == range.length) {//按下回格键
        if (textField.text.length==1) {
            if ([textField.text isEqualToString:@"0"]) {
                return NO;
            } else {
                textField.text = @"0";
                NSString *title = [textField.text substringToIndex:textField.text.length-1];
                [self setValueColor:title];
                CGFloat angle=180-([title floatValue]/kSuagrValueMax)*180;
                [slider moveArcSliderWithAngle:angle];
                
                __weak typeof(self) weakSelf = self;
                weakSelf.sugarValue((double)([title floatValue]));
                weakSelf.isbool = YES;
            }
        } else {
            NSString *title = [textField.text substringToIndex:textField.text.length-1];
            [self setValueColor:title];
            CGFloat angle=180-([title floatValue]/kSuagrValueMax)*180;
            [slider moveArcSliderWithAngle:angle];
            
            __weak typeof(self) weakSelf = self;
            weakSelf.sugarValue((double)([title floatValue]));
            weakSelf.isbool = YES;
            return YES;
        }
    }else{
        if ([textField.text isEqualToString:@"0.0"]||[textField.text isEqualToString:@"0"]) {
            textField.text = @"";
            
            [self setValueColor:string];
            CGFloat angle=180-([string floatValue]/kSuagrValueMax)*180;
            [slider moveArcSliderWithAngle:angle];
            
            __weak typeof(self) weakSelf = self;
            weakSelf.sugarValue((double)([string floatValue]));
            weakSelf.isbool = YES;

            return YES;
        }
        //如果输入的是“.”  判断之前已经有"."或者字符串为空
        if ([string isEqualToString:@"."] && ([textField.text rangeOfString:@"."].location != NSNotFound || [textField.text isEqualToString:@""])) {
            return NO;
        }
        NSString *title = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if ([title floatValue]<=35.0) {
            if ([title floatValue]>0.0&&title.length<5) {
                //只能有一位小数
                if (title.length >= [title rangeOfString:@"."].location+3){
                    return NO;
                }
                [self setValueColor:title];
                
                CGFloat angle=180-([title floatValue]/kSuagrValueMax)*180;
                [slider moveArcSliderWithAngle:angle];
                
                __weak typeof(self) weakSelf = self;
                weakSelf.sugarValue((double)([title floatValue]));
                weakSelf.isbool = YES;
                
                return YES;
            }
           
        }else{
            [self makeToast:@"血糖值超出最大范围" duration:1.0 position:CSToastPositionCenter];

        }
    }
    return NO;
}

#pragma mark -- Event Response
-(void)changeBloodSugarValueAction:(UIButton*)sender{
    self.isbool = YES;
    
    if (sender.tag==100) {
        value-=0.1;
        if (value<0.0) {
            value=0.0;
        }
    }else{
        value+=0.1;
        if (value>kSuagrValueMax) {
            value=kSuagrValueMax;
        }
    }
    valueLabel.text =[NSString stringWithFormat:@"%.1f",(double)value];
    CGSize width = [valueLabel.text sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
    lineLabel.frame =CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2);
    lineLabel.backgroundColor =valueLabel.textColor;
    [self addSubview:lineLabel];
    
    self.sugarValue((double)(value));
    [self setValueLabelColor];
    CGFloat angle=180-(value/kSuagrValueMax)*180;
    [slider moveArcSliderWithAngle:angle];
}
#pragma mark -- 根据血糖值改变颜色
- (void)setValueColor:(NSString *)title{

    if ([title floatValue]<normalMinValue) {
        valueLabel.textColor =[UIColor colorWithHexString:@"0xffd657"];
        
    }else if ([title floatValue]>=normalMinValue&&[title floatValue]<=normalMaxValue){
        valueLabel.textColor =kSystemColor;
    }else{
        valueLabel.textColor =[UIColor colorWithHexString:@"0xfa7574"];
    }

    CGSize width = [title sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
    lineLabel.frame =CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2);
    lineLabel.backgroundColor =valueLabel.textColor;
}
#pragma mark -- TCArcSliderDelegate
-(void)arcSliderSetSugarValueWithAngle:(CGFloat)angle{
    self.isbool = self.way==1?NO:YES;
    slider.minValueAngle=180-(normalMinValue/kSuagrValueMax)*180+0.1;
    slider.maxValueAngle=180-(normalMaxValue/kSuagrValueMax)*180-0.1;
    
    NSInteger index=((180-angle)/180)*kSuagrValueMax*10+0.5;
    value=(double)(index*0.1);
    valueLabel.text =[NSString stringWithFormat:@"%.1f",(double)(index*0.1)];
    CGSize width = [valueLabel.text sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
    lineLabel.frame =CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2);
    lineLabel.backgroundColor =valueLabel.textColor;
    
    [self setValueLabelColor];
    
    __weak typeof(self) weakSelf = self;
    weakSelf.sugarValue((double)(index*0.1));
    weakSelf.isbool = self.way==1?NO:YES;
    
}

#pragma mark -- Setters and Getters
-(void)setPeriodStr:(NSString *)periodStr{
    
    _periodStr=periodStr;
    NSDictionary *normalRangeDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:_periodStr];
    normalMinValue=[normalRangeDict[@"min"] doubleValue];
    normalMaxValue=[normalRangeDict[@"max"] doubleValue];
    
    rangeLabel.text=[NSString stringWithFormat:@"正常范围：%.1f-%.1fmmol/L",normalMinValue,normalMaxValue];
    
    slider.minValueAngle=180-(normalMinValue/kSuagrValueMax)*180+0.1;
    slider.maxValueAngle=180-(normalMaxValue/kSuagrValueMax)*180-0.1;
}

-(void)setInitValue:(double)initValue{
    _initValue=initValue;
    value=initValue;
    valueLabel.text =initValue>0.01?[NSString stringWithFormat:@"%.1f",initValue]:@"0.0";
    CGSize width = [valueLabel.text sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
    lineLabel.frame =CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2);
    lineLabel.backgroundColor =valueLabel.textColor;
    
    [self setValueLabelColor];

    slider.initAngle=180-(initValue/kSuagrValueMax)*180;
    
}

#pragma mark -- 设置lable字体颜色
-(void)setValueLabelColor{

    NSDictionary *normalRangeDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:_periodStr];
    normalMinValue=[normalRangeDict[@"min"] doubleValue];
    normalMaxValue=[normalRangeDict[@"max"] doubleValue];
    if ([valueLabel.text floatValue]<normalMinValue) {
        valueLabel.textColor =[UIColor colorWithHexString:@"0xffd657"];

    }else if ([valueLabel.text floatValue]>=normalMinValue&&[valueLabel.text floatValue]<=normalMaxValue){
        valueLabel.textColor =kSystemColor;
    }else{
        valueLabel.textColor =[UIColor colorWithHexString:@"0xfa7574"];

    }
    CGSize width = [valueLabel.text sizeWithLabelWidth:100 font:[UIFont systemFontOfSize:30]];
    lineLabel.frame =CGRectMake((kScreenWidth-width.width)/2-5, valueLabel.bottom, width.width+10, 2);
    lineLabel.backgroundColor =valueLabel.textColor;
}


@end
