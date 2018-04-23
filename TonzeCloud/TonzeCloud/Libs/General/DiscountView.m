//
//  DiscountView.m
//  TonzeCloud
//
//  Created by vision on 18/4/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "DiscountView.h"
#import "TimePickerView.h"

@interface DiscountView()<UIActionSheetDelegate>{
    UILabel       *couponLabel;
    UILabel       *integralLabel;
    UISwitch      *integralSwitch;
    UILabel       *intLineLab;
    UILabel       *discountLabel;
    UIImageView   *integArrowImageView;
    TimePickerView *integralPickerView;
}

@end

@implementation DiscountView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        NSArray *titleArr=@[@"优惠券",@"积分抵扣"];
        for (NSInteger i=0; i<titleArr.count; i++) {
            UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 10+48*i, 70, 28)];
            titleLabel.font=[UIFont systemFontOfSize:16];
            titleLabel.textColor=[UIColor blackColor];
            titleLabel.text=titleArr[i];
            [self addSubview:titleLabel];
        }
        
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(0,49, kScreenWidth, 0.5);
        line.backgroundColor = kLineColor.CGColor;
        [self.layer addSublayer:line];
        
        UIButton *showDetailsBtn=[[UIButton alloc] initWithFrame:CGRectMake(85, 58, 28, 28)];
        [showDetailsBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [showDetailsBtn addTarget:self action:@selector(showIntegralUseRulesAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showDetailsBtn];
        
        //选择优惠券
        couponLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-150, 10, 120, 28)];
        couponLabel.textAlignment=NSTextAlignmentRight;
        couponLabel.text=@"暂无可用";
        couponLabel.font=[UIFont systemFontOfSize:14];
        couponLabel.textColor=[UIColor lightGrayColor];
        [self addSubview:couponLabel];
        
        UIImageView *arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(couponLabel.right, 14, 20, 20)];
        arrowImageView.image=[UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self addSubview:arrowImageView];
        
        UIButton *couponBtn=[[UIButton alloc] initWithFrame:CGRectMake(couponLabel.left, 0, 150, 48)];
        [couponBtn addTarget:self action:@selector(selectCouponAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:couponBtn];
        
        //积分抵扣
        integralLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        integralLabel.text=@"共200积分，满1000积分可用";
        integralLabel.font=[UIFont systemFontOfSize:14];
        integralLabel.textColor=[UIColor lightGrayColor];
        integralLabel.textAlignment=NSTextAlignmentRight;
        CGFloat labWidth=[integralLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-90, 28) withTextFont:integralLabel.font].width;
        integralLabel.frame=CGRectMake(kScreenWidth-labWidth-10, 48+10, labWidth, 28);
        [self addSubview:integralLabel];
        
        integralSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 48+9, 60, 30)];
        [integralSwitch addTarget:self action:@selector(setIntegralSelectedAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:integralSwitch];
        integralSwitch.hidden=YES;
        
        intLineLab=[[UILabel alloc] initWithFrame:CGRectMake(0,integralLabel.bottom+10, kScreenWidth, 0.5)];
        intLineLab.backgroundColor=kLineColor;
        [self addSubview:intLineLab];
        
        discountLabel=[[UILabel alloc] initWithFrame:CGRectMake(40, integralLabel.bottom+20, kScreenWidth-70, 28)];
        discountLabel.textAlignment=NSTextAlignmentRight;
        discountLabel.text=@"抵¥10，使用1000积分";
        discountLabel.font=[UIFont systemFontOfSize:14];
        discountLabel.textColor=[UIColor lightGrayColor];
        [self addSubview:discountLabel];
        
        integArrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(discountLabel.right, integralLabel.bottom+24, 20, 20)];
        integArrowImageView.image=[UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self addSubview:integArrowImageView];
        
        UIButton *chooseIntegralBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, intLineLab.bottom, kScreenWidth-60, 48)];
        [chooseIntegralBtn addTarget:self action:@selector(chooseIntegralAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chooseIntegralBtn];
        intLineLab.hidden=discountLabel.hidden=integArrowImageView.hidden=YES;
        
    }
    return self;
}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSInteger count=([integralPickerView.locatePicker selectedRowInComponent:0]+1)*500;
        if ([self.delegate respondsToSelector:@selector(discountViewChooseIntegralCount:)]) {
            [self.delegate discountViewChooseIntegralCount:count];
        }
    }
}

#pragma mark -- Event Response
#pragma mark  显示积分抵扣规则
- (void)showIntegralUseRulesAction{
    if ([self.delegate respondsToSelector:@selector(discountViewShowInteralRules)]) {
        [self.delegate discountViewShowInteralRules];
    }
}

#pragma mark 选择优惠券
- (void)selectCouponAction{
    if ([self.delegate respondsToSelector:@selector(discountViewSelectCoupon)]) {
        [self.delegate discountViewSelectCoupon];
    }
}

#pragma mark 开启积分抵扣设置
- (void)setIntegralSelectedAction:(UISwitch *)sender{
    if ([self.delegate respondsToSelector:@selector(discountViewSetIntegralSelected:)]) {
        [self.delegate discountViewSetIntegralSelected:sender.isOn];
    }
    intLineLab.hidden=discountLabel.hidden=integArrowImageView.hidden=!sender.isOn;
}

#pragma mark 选择积分
- (void)chooseIntegralAction{
    integralPickerView =[[TimePickerView alloc]initWithTitle:@"使用积分" delegate:self];
    integralPickerView.pickerStyle=PickerStyle_Integral;
    [integralPickerView.locatePicker selectRow:0 inComponent:0 animated:YES];
    [integralPickerView showInView:kKeyWindow];
    [integralPickerView pickerView:integralPickerView.locatePicker didSelectRow:0 inComponent:0];
}

#pragma mark -- Setters
-(void)setIntegralCount:(NSInteger)integralCount{
    _integralCount=integralCount;
}

-(void)setHasavailableIntegral:(BOOL)hasavailableIntegral{
    _hasavailableIntegral=hasavailableIntegral;
    integralSwitch.hidden=!hasavailableIntegral;
    if (hasavailableIntegral) {
        integralLabel.text=[NSString stringWithFormat:@"共%ld积分",self.integralCount];
        CGFloat labWidth=[integralLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-90, 28) withTextFont:integralLabel.font].width;
        integralLabel.frame=CGRectMake(kScreenWidth-labWidth-80, 48+10, labWidth, 28);
    }else{
        integralLabel.text=@"共200积分，满1000积分可用";
        CGFloat labWidth=[integralLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-90, 28) withTextFont:integralLabel.font].width;
        integralLabel.frame=CGRectMake(kScreenWidth-labWidth-10, 48+10, labWidth, 28);
    }
}

@end
