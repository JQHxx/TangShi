//
//  TCMyMessageTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyMessageTableViewCell.h"
@interface TCMyMessageTableViewCell (){
    UILabel      *nickName;
    UIImageView  *headImg;
    UIImageView  *sexImg;
    UILabel      *timeLabel;
    UIButton     *acceptBtn;
    UIButton     *refuseBtn;
    UILabel      *resultLabel;
    
    NSInteger    apply_family_id;
}

@end

@implementation TCMyMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
        headImg.layer.cornerRadius = 24;
        headImg.clipsToBounds = YES;
        [self addSubview:headImg];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+5, headImg.top+5, 100, 20)];
        nickName.font =[UIFont systemFontOfSize:14];
        [self addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, nickName.top-10, 30, 30)];
        [self addSubview:sexImg];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, nickName.bottom+5, kScreenWidth-headImg.right-120, 20)];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:timeLabel];
        
        acceptBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-110, 19, 45, 30)];
        [acceptBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        acceptBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [acceptBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        acceptBtn.layer.cornerRadius = 2;
        [acceptBtn setBackgroundColor:[UIColor whiteColor]];
        [acceptBtn.layer setBorderWidth:1]; //设置边界宽度
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){5.0/256, 211.0/256, 128.0/256,1 });
        [acceptBtn.layer setBorderColor:colorref];//边框颜色
        CGColorSpaceRelease(colorSpace);
        CGColorRelease(colorref);
        acceptBtn.tag = 101;
        [acceptBtn addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:acceptBtn];

        refuseBtn = [[UIButton alloc] initWithFrame:CGRectMake(acceptBtn.right+10, 19, 45, 30)];
        [refuseBtn setTitle:@"接受" forState:UIControlStateNormal];
        refuseBtn.titleLabel.textColor = [UIColor whiteColor];
        refuseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        refuseBtn.layer.cornerRadius = 2;
        refuseBtn.tag = 100;
        [refuseBtn addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        [refuseBtn setBackgroundColor:kSystemColor];
        [self addSubview:refuseBtn];
        
        resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-60, 24, 50, 20)];
        resultLabel.font = [UIFont systemFontOfSize:14];
        resultLabel.textColor = [UIColor grayColor];
        [self addSubview:resultLabel];
    }
    return self;
}
- (void)cellMyMessageModel:(TCMyMessageModel *)model{

    apply_family_id = model.apply_family_id;
    
    [headImg sd_setImageWithURL:[NSURL URLWithString:[model.family objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nickName.text = [model.family objectForKey:@"nick_name"];
    CGSize size = [nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImg.right+5, headImg.top, size.width, 20);
    sexImg.frame = CGRectMake(nickName.right+5, nickName.top-5, 30, 30);
    if ([[model.family objectForKey:@"sex"] integerValue]!=3) {
        sexImg.image = [UIImage imageNamed:[[model.family objectForKey:@"sex"] integerValue]==1?@"ic_m_male":@"ic_m_famale"];
    }
    timeLabel.frame =CGRectMake(headImg.right+10, nickName.bottom+5, kScreenWidth-headImg.right-120, 20);
    timeLabel.text = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm:ss"];
    if (model.state==0) {
        acceptBtn.hidden=NO;
        refuseBtn.hidden =NO;
        resultLabel.hidden = YES;
    }else if (model.state==1){
        acceptBtn.hidden=YES;
        refuseBtn.hidden =YES;
        resultLabel.hidden = NO;
        resultLabel.text = @"已接受";
    }else if(model.state==2){
        acceptBtn.hidden=YES;
        refuseBtn.hidden =YES;
        resultLabel.hidden = NO;
        resultLabel.text = @"已拒绝";
    }

}
#pragma mark -- 添加好友
- (void)addFriend:(UIButton *)button{

    if ([_delegate respondsToSelector:@selector(MyMessageIndex:apply_family_id:)]) {
        [_delegate MyMessageIndex:button.tag apply_family_id:apply_family_id];
    }

}
@end
