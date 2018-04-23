//
//  TCRankListTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRankListTableViewCell.h"
@interface TCRankListTableViewCell(){

    UIImageView *rankImage;
    UILabel     *rankLabel;
    UIImageView *headImage;
    UILabel     *nickName;
    UIImageView *sexImage;
    UILabel     *typeLabel;
    UIButton    *focusBtn;
    
    TCSugarFriendsRankModel *rankListModel;
}
@end
@implementation TCRankListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        rankImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 40, 40)];
        [self addSubview:rankImage];
        
        rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 19, 40, 20)];
        rankLabel.font = [UIFont systemFontOfSize:22];
        rankLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:rankLabel];
        
        headImage = [[UIImageView alloc] initWithFrame:CGRectMake(rankImage.right+9, 9, 40, 40)];
        headImage.clipsToBounds=YES;
        headImage.layer.cornerRadius = 20;
        [self addSubview:headImage];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+9, headImage.top, 60, 20)];
        nickName.font = [UIFont systemFontOfSize:14];
        [self addSubview:nickName];
        
        sexImage = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, headImage.top, 20, 20)];
        sexImage.layer.cornerRadius =10;
        [self addSubview:sexImage];
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+9, nickName.bottom+5, kScreenWidth/2, 15)];
        typeLabel.font = [UIFont systemFontOfSize:14];
        typeLabel.textColor = [UIColor grayColor];
        [self addSubview:typeLabel];
        
        focusBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-83, (58-25)/2, 73, 25)];
        [focusBtn addTarget:self action:@selector(addCare:) forControlEvents:UIControlEventTouchUpInside];
        focusBtn.layer.cornerRadius = 2;
        [self addSubview:focusBtn];
    }
    return self;
}
- (void)cellRankListModel:(TCSugarFriendsRankModel *)rankModel rank:(NSInteger)rank{
    rankListModel = rankModel;
    
    if (rank<=2) {
        rankImage.hidden = NO;
        rankImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pub_ranking_0%ld",rank+1]];
        rankLabel.hidden = YES;
    } else {
        rankImage.hidden = YES;
        rankLabel.hidden = NO;
        rankLabel.text = [NSString stringWithFormat:@"%ld",rank+1];
    }
    
    [headImage sd_setImageWithURL:[NSURL URLWithString:rankModel.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = rankModel.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImage.right+9, headImage.top, size.width, 20);
    sexImage.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (rankModel.sex!=3) {
        sexImage.image = [UIImage imageNamed:rankModel.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImage.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    if (rankModel.diabetes_type.length > 0) {
        // 用户类型 、 治疗时间
        if ([rankModel.diabetes_type isEqualToString:@"其他"]||[rankModel.diabetes_type isEqualToString:@"正常"]) {
            typeLabel.text = [NSString stringWithFormat:@"%@",rankModel.diabetes_type];
        } else {
            typeLabel.text = [NSString stringWithFormat:@"%@ %@",rankModel.diabetes_type,rankModel.diagnosis_time];
        }
    }else{
        typeLabel.text = @"未知";
    }
    if (rankModel.is_self!=1) {
        if (rankModel.focus_status==2) {
            [focusBtn setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
        } else {
            [focusBtn setImage:[UIImage imageNamed:rankModel.focus_status==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
        }
    }
}
- (void)addCare:(UIButton *)button{
    NSString *body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%d",rankListModel.user_id,rankListModel.role_type,rankListModel.focus_status==0?1:2];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFocusFriend body:body success:^(id json) {
        if ([self.rankListDelegate respondsToSelector:@selector(returnFocusOnRankList)]) {
            [self.rankListDelegate returnFocusOnRankList];
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
@end
