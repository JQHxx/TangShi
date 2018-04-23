//
//  TCSugarFriendsRankView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarFriendsRankView.h"
#import "TCToolButton.h"
#import "TCSugarFriendsRankModel.h"

@implementation TCSugarFriendsRankView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(18, 7, 4, 20)];
        colorView.backgroundColor = kbgBtnColor;
        [self addSubview:colorView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(colorView.right+5, colorView.top+2, kScreenWidth/2-colorView.right, 15)];
        titleLabel.text = @"上周控糖之星";
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:titleLabel];
        
        UIButton *lookRankBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lookRankBtn.backgroundColor = [UIColor whiteColor];
        lookRankBtn.frame = CGRectMake(kScreenWidth-90, 2, 80 , 30);
        [lookRankBtn setTitleColor:UIColorFromRGB(0x939393) forState:UIControlStateNormal];
        lookRankBtn.titleLabel.font = kFontWithSize(15);
        lookRankBtn.tag = 105;
        [lookRankBtn setTitle:@"查看榜单" forState:UIControlStateNormal];
        [lookRankBtn setImage:[UIImage imageNamed:@"pub_ic_arrow"] forState:UIControlStateNormal];
        [lookRankBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        [lookRankBtn addTarget:self action:@selector(lookRangButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lookRankBtn];
        
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(0, colorView.bottom+6, kScreenWidth, 0.5);
        line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"].CGColor;
        [self.layer addSublayer:line];
    }
    return self;
}
- (void)lookSugarFriendData:(NSArray *)dataArray{
    
    for (UIView *view in self.subviews) {   //删除子视图
        if ([view isKindOfClass:[TCToolButton class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i=0; i<dataArray.count; i++) {
        TCSugarFriendsRankModel *model = dataArray[i];
        TCToolButton *friendButton = [[TCToolButton alloc] initWithFriendRankListFrame:CGRectMake(i*kScreenWidth/4, 34, kScreenWidth/4, 95)];
        friendButton.tag = 100+i;
        friendButton.titleLab.text = model.nick_name;
        [friendButton.headImage sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
        [friendButton addTarget:self action:@selector(lookRangButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:friendButton];
    }

}
- (void)lookRangButton:(UIButton *)sender{
    if (self.lookRankBlock) {
        self.lookRankBlock(sender.tag);
    }
}
@end
