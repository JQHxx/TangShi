//
//  TJYMenuDetailIntroductionView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuDetailIntroductionView.h"

@interface TJYMenuDetailIntroductionView ()

@end

@implementation TJYMenuDetailIntroductionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        // 菜谱相关信息
        _menuNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20, 200, 20)];
        _menuNameLabel.font = [UIFont systemFontOfSize:18];
        _menuNameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self addSubview:_menuNameLabel];
        
        // 菜谱图标
        _menuImg = [[UIImageView alloc] initWithFrame:CGRectMake(_menuNameLabel.right, _menuNameLabel.top, 35/2, 23/2)];
        _menuImg.image = [UIImage imageNamed:@"ic_lite_yun"];
        [self addSubview:_menuImg];
        /// 卡路里
        _energyLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, _menuImg.bottom +10, kScreenWidth, 20)];
        _energyLabel.textAlignment=NSTextAlignmentCenter;
        _energyLabel.font=kFontWithSize(14);
        _energyLabel.textColor=[UIColor colorWithHexString:@"999999"];
        [self addSubview:_energyLabel];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(15,100 - 0.5, kScreenWidth - 15, 0.5)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
    }
    return self;
}
@end
