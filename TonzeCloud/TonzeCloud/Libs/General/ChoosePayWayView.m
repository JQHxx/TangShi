//
//  ChoosePayWayView.m
//  TonzeCloud
//
//  Created by vision on 18/4/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "ChoosePayWayView.h"
#import "PayWayTool.h"

@interface ChoosePayWayView (){
    PayWayTool   *weiPayTool;  //微信支付
    PayWayTool   *alipayTool;  //微信支付
}

@end

@implementation ChoosePayWayView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        UILabel *payTitleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 90, 20)];
        payTitleLab.text=@"支付方式";
        payTitleLab.font=[UIFont systemFontOfSize:14];
        payTitleLab.textColor=[UIColor lightGrayColor];
        [self addSubview:payTitleLab];
        
        //支付宝支付
        alipayTool=[[PayWayTool alloc] initWithFrame:CGRectMake(0, payTitleLab.bottom+10, kScreenWidth, 50) iconName:@"pub_ic_zhifubao" title:@"支付宝支付"];
        alipayTool.isWaySelected=YES;
        alipayTool.tag=100;
        alipayTool.backgroundColor=[UIColor whiteColor];
        [alipayTool addTarget:self action:@selector(didSelectPayWayActionForSender:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:alipayTool];
        
        //微信支付
        weiPayTool=[[PayWayTool alloc] initWithFrame:CGRectMake(0, alipayTool.bottom, kScreenWidth, 50) iconName:@"pub_ic_weichat" title:@"微信支付"];
        weiPayTool.isWaySelected=NO;
        weiPayTool.tag=101;
        weiPayTool.backgroundColor=[UIColor whiteColor];
        [weiPayTool addTarget:self action:@selector(didSelectPayWayActionForSender:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weiPayTool];
        
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, payTitleLab.bottom+9+50, kScreenWidth, 0.5)];
        lineLab.backgroundColor=kLineColor;
        [self addSubview:lineLab];

    }
    return self;
}

#pragma mark 选择支付方式
-(void)didSelectPayWayActionForSender:(UIButton *)sender{
    if (sender.tag==100) {
        alipayTool.isWaySelected=YES;
        weiPayTool.isWaySelected=NO;
    }else{
        alipayTool.isWaySelected=NO;
        weiPayTool.isWaySelected=YES;
    }
    if ([self.delegate respondsToSelector:@selector(didSelectedPayWay:)]) {
        [self.delegate didSelectedPayWay:sender.tag-100];
    }
}

@end
