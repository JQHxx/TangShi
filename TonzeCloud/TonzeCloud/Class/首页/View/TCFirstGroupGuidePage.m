//
//  TCFriendGroupGuidePage.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/9/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFirstGroupGuidePage.h"

@interface TCFirstGroupGuidePage ()
/// 进入页
@property (nonatomic, strong) UIView *loginView;
/// 开启页
@property (nonatomic ,strong) UIView *openView;

@end

@implementation TCFirstGroupGuidePage

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"hasShowFriendGroup"];
        [userDefaults synchronize];
        
        [self addSubview:self.loginView];
    }
    return self;
}
#pragma mark ====== 跳过 =======

- (void)skipBtnClick{
   [self removeFromSuperview];
}
#pragma mark ====== 跳转糖友圈 =======

- (void)nextBtnClick{
    if (self.nextClickBlock) {
        self.nextClickBlock();
    }
    
    self.loginView.alpha = 0;
    [self.loginView removeFromSuperview];
    [self addSubview:self.openView];
}
#pragma mark ====== 关闭遮罩 =======

- (void)openBtnClick{
    [self removeFromSuperview];
}
#pragma mark ====== Setter =======

- (UIView *)loginView{
    if (!_loginView) {
        _loginView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _loginView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
        skipBtn.titleLabel.textColor = [UIColor whiteColor];
        skipBtn.titleLabel.font = kFontWithSize(18);
        skipBtn.frame = CGRectMake(kScreenWidth - 80,KStatusHeight + 4, 80, 40);
        [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:skipBtn];
        
        UIImageView *onlineImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 580/2)/2, kScreenHeight/3, 580/2, 169/2)];
        onlineImg.image = [UIImage imageNamed:@"cover_tips_h_01"];
        [_loginView addSubview:onlineImg];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBtn setImage:[UIImage imageNamed:@"cover_tips_h_02"] forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.frame = CGRectMake((kScreenWidth - 380/2 - 13 *kScreenWidth/320), kScreenHeight - KTabbarSafeBottomMargin - 262/2 , 380/2, 262/2);
        [_loginView addSubview:nextBtn];
    }
    return _loginView;
}
- (UIView *)openView{
    if (!_openView) {
        _openView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _openView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        UIImageView *shareImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 450/2)/2, 290  * kScreenWidth/375 , 450/2, 172/2)];
        shareImg.image = [UIImage imageNamed:@"cover_tips_m_01"];
        [_openView addSubview:shareImg];
        
        UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        openBtn.frame = CGRectMake((kScreenWidth - 450/2)/2, kScreenHeight -KTabbarSafeBottomMargin - 120/2 - 60 , 450/2, 120/2);
        [openBtn setImage:[UIImage imageNamed:@"cover_tips_m_02"] forState:UIControlStateNormal];
        [openBtn addTarget:self action:@selector(openBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_openView addSubview:openBtn];
    }
    return _openView;
}
#pragma mark ====== show =======

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
