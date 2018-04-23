//
//  TCRuleAlertView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRuleAlertView.h"

#define kButtonHei 44
#define kAlertW 530/2

#define kTitleFont 16
#define kMassageFont 13
#define kBtnTitleFont  16

@interface TCRuleAlertView ()
{
    UIView *_backgraoudView; //蒙板背景
    UILabel *_titleLabel;
    UILabel *_massageLabel;
    UIView *_downView;
    UIView *_aletView;
    NSMutableArray *_titleBtnArray;
}
@end

@implementation TCRuleAlertView
-(instancetype)initWithTitle:(NSString *)title andWithMassage:(NSString *)massage andWithTag:(NSInteger)tag andWithButtonTitle:(NSString *)otherButtonTitles, ...{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0,kScreenWidth, kScreenHeight);
        self.tag=tag;
        _titleBtnArray = [NSMutableArray array];
        //蒙板
        [_backgraoudView removeFromSuperview];
        _backgraoudView = nil;
        _backgraoudView = [[UIView alloc]init];
        _backgraoudView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _backgraoudView.backgroundColor = [UIColor blackColor];
        _backgraoudView.alpha = 0;
        [self addSubview:_backgraoudView];
        
        [UIView animateWithDuration:0.2 animations:^{
            _backgraoudView.alpha = 0.7;
        }];
        
        
        UIView *alertView = [[UIView alloc]init];
        alertView.backgroundColor = [UIColor whiteColor];
        alertView.frame = CGRectMake((kScreenWidth - kAlertW)/2, 0, kAlertW, 1000);
        alertView.layer.masksToBounds = YES; //没这句话它圆不起来
        alertView.layer.cornerRadius =5; //设置图片圆角的尺度
        [self addSubview:alertView];
        
        UIImageView *titleImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAlertW, 380/2)];
        titleImg.image = [UIImage imageNamed:@"ic_sign_ rule"];
        [alertView addSubview:titleImg];
        
        //获取标题文字大小
        CGRect titleLabelRect = [self getStrimgRect:title andWithStringFontSize:kTitleFont andWithCurrentProlWitch:kAlertW - 20];
        
        //标题
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(0, titleImg.bottom , kAlertW, titleLabelRect.size.height);
        titleLabel.textColor = UIColorFromRGB(0x313131);
        titleLabel.text = title;
        titleLabel.numberOfLines = 0;
        titleLabel.font = kFontWithSize(16);
        [alertView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        //获取信息文字大小
        CGRect massageLabelRect = [self getStrimgRect:massage andWithStringFontSize:kMassageFont andWithCurrentProlWitch:kAlertW - 30];
        
        //信息内容
        UILabel *massageLabel = [[UILabel alloc]init];
        massageLabel.backgroundColor = [UIColor whiteColor];
//        massageLabel.text = massage;
        massageLabel.numberOfLines = 0;
        massageLabel.font = [UIFont systemFontOfSize:kMassageFont];
        massageLabel.textAlignment = NSTextAlignmentLeft;
        
        massageLabel.frame =
        CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 18, kAlertW - 20, massageLabelRect.size.height);
        if (massage == nil||[massage isEqualToString:@""]) {
            massageLabel.frame =
            CGRectMake(0, CGRectGetMaxY(titleLabel.frame), kAlertW - 10, 1);
        }
        NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:massage];
        //获取要调整颜色的文字位置,调整颜色
        NSRange range1=[[attributedString string]rangeOfString:@"2积分"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:range1];
        
        NSRange range2=[[attributedString string]rangeOfString:@"10积分"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:range2];
        
        NSRange range3=[[attributedString string]rangeOfString:@"30积分"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:range3];
        NSRange range4=[[attributedString string]rangeOfString:@"80积分"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xf9c92b) range:range4];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [massage length])];
        
        massageLabel.attributedText = attributedString;
        
        [alertView addSubview:massageLabel];
        _massageLabel = massageLabel;
        
        //添加按钮
        va_list args;
        va_start(args, otherButtonTitles);
        NSMutableArray *buttonTitleArray = [NSMutableArray array];
        NSMutableString *allStr = [[NSMutableString alloc] initWithCapacity:16];
        for (NSString *str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
            [allStr appendFormat:@"%@,",str];
            [buttonTitleArray addObject:str];
        }
        
        //创建按钮
        //判断按钮是一个的时候
        if (buttonTitleArray.count == 1) {
            [_titleBtnArray removeAllObjects];
            UIButton *oneBtn = [[UIButton alloc]init];
            oneBtn.frame = CGRectMake((alertView.width - 274/2)/2, CGRectGetMaxY(massageLabel.frame)+ 57/2, 274/2 ,64/2);
            [oneBtn setTitle:buttonTitleArray[0] forState:(UIControlStateNormal)];
            [oneBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
            oneBtn.titleLabel.font = [UIFont systemFontOfSize:kBtnTitleFont];
            [oneBtn.titleLabel setFont:kFontWithSize(16)];
            oneBtn.tag = 0;
            [oneBtn setBackgroundImage:[UIImage imageNamed:@"ic_green_btn"] forState:UIControlStateNormal];
            [oneBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
            [alertView addSubview:oneBtn];
//            [oneBtn addSubview:[self getLineView:CGRectMake(0, 0, titleLabel.frame.size.width, 0.5)]];
            alertView.frame = CGRectMake((kScreenWidth - kAlertW)/2, 0, kAlertW, CGRectGetMaxY(oneBtn.frame) + 25);
            
            [_titleBtnArray addObject:oneBtn];
        }
        _aletView = alertView;
    }
    return self;
}
#pragma mark －－显示在控制器中
-(void)show{
    [UIView animateWithDuration:0.5 animations:^{
        _aletView.frame = CGRectMake((kScreenWidth - kAlertW)/2, kScreenHeight/2-_aletView.frame.size.height/2, _aletView.frame.size.width, _aletView.frame.size.height);
    }];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self];
}
#pragma mark －－获取文字方法
-(CGRect)getStrimgRect:(NSString *)str andWithStringFontSize:(NSInteger)font andWithCurrentProlWitch:(CGFloat)witch{
    CGSize  maxSize;
    maxSize = CGSizeMake(witch,MAXFLOAT);
    CGRect rect=
    [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName,nil]context:nil];
    return rect;
}
#pragma mark －－创建灰色线
-(UIView*)getLineView:(CGRect)rect{
    UIView *lineView = [[UIView alloc]init];
    lineView.frame = rect;
    lineView.backgroundColor = kLineColor;
    return lineView;
}
#pragma mark  －－按钮点击方法
-(void)titleBtnClick:(UIButton*)btn{
    [UIView animateWithDuration:0.5 animations:^{
        _aletView.frame = CGRectMake((kScreenWidth - kAlertW)/2, kScreenHeight, _aletView.frame.size.width, _aletView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    self.resultIndex(btn.tag,self.tag);
}
#pragma mark －－设置按钮背景颜色－－设置按钮文字颜色
-(void)setTitleBtnWithBgColor:(UIColor *)bgColor andWithtitleColor:(UIColor *)titleColor atBtnTag:(NSInteger)tag{
    if (tag <_titleBtnArray.count) {
        UIButton *btn = _titleBtnArray[tag];
        
        if (bgColor != nil) {
            btn.backgroundColor = bgColor;
        }
        if (titleColor != nil) {
            [btn setTitleColor:titleColor forState:(UIControlStateNormal)];
        }
    }else{
        NSLog(@"并没有创建tag相对应的btn");
    }
}
#pragma mark －－设置标题文字颜色
-(void)setTitleTextColorr:(UIColor *)textColor{
    if (textColor != nil) {
        _titleLabel.textColor = textColor;
    }
}
#pragma mark －－设置信息文字颜色
-(void)setMassageTextColor:(UIColor *)textColor {
    if (textColor != nil) {
        _massageLabel.textColor = textColor;
    }
}
#pragma mark －－设置背景颜色
-(void)setAlertViewBgColor:(UIColor*)bgColor{
    if (bgColor != nil) {
        _aletView.backgroundColor = bgColor;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
