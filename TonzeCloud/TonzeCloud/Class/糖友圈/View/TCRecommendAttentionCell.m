//
//  TCRecommendAttentionCell.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/12/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRecommendAttentionCell.h"

@interface TCRecommendAttentionCell (){
    UIImageView     *headImgView;
    UILabel         *nickName;
    UIImageView     *sexImg;
    UILabel         *expertLabel;
    UILabel         *sugarType;
    UIButton        *isCare;
    TCNewFriendModel  *friendModel;
    NSInteger        type;
    NSInteger        focus;
}
@end
@implementation TCRecommendAttentionCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14, 80-28, 80-28)];
        headImgView.clipsToBounds=YES;
        headImgView.layer.cornerRadius = (80-28)/2;
        [self.contentView addSubview:headImgView];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImgView.right+15, headImgView.top, 60, 20)];
        nickName.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, headImgView.top, 20, 20)];
        sexImg.layer.cornerRadius =10;
        [self.contentView addSubview:sexImg];
        
        expertLabel = [[UILabel alloc] initWithFrame:CGRectMake(sexImg.right, nickName.top, 40, 20)];
        expertLabel.layer.cornerRadius = 3;
        expertLabel.font = [UIFont systemFontOfSize:13];
        expertLabel.textAlignment = NSTextAlignmentCenter;
        expertLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:expertLabel];
        
        sugarType = [[UILabel alloc] initWithFrame:CGRectMake(headImgView.right+15, nickName.bottom+10, kScreenWidth/2, 20)];
        sugarType.font = [UIFont systemFontOfSize:14];
        sugarType.textColor = [UIColor grayColor];
        [self.contentView addSubview:sugarType];
        
        isCare = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, (80 - 24)/2, 70, 24)];
        [isCare addTarget:self action:@selector(addCare:) forControlEvents:UIControlEventTouchUpInside];
        isCare.layer.cornerRadius = 2;
        [self.contentView addSubview:isCare];
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(10, 80 - 0.5,kScreenWidth  - 10, 0.5)];
        len.backgroundColor = UIColorFromRGB(0xe5e5e5);
        [self.contentView addSubview:len];
    }
    return self;
}
- (void)cellWithNewFriendModel:(TCNewFriendModel *)model{
    friendModel = model;
    type = 4;
    isCare.tag = model.follow_user_id;
    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top, size.width, 20);
    sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    expertLabel.text = model.label;
    size = [expertLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    expertLabel.frame =CGRectMake(model.sex==3?nickName.right+10:sexImg.right, nickName.top, size.width+10, 20);
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        expertLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        expertLabel.backgroundColor = kSystemColor;
    }else{
        expertLabel.hidden = YES;
    }
    if (model.diabetes_type.length > 0) {
        // 用户类型 、 治疗时间
        if ([model.diabetes_type isEqualToString:@"其他"]||[model.diabetes_type isEqualToString:@"正常"]) {
            sugarType.text = [NSString stringWithFormat:@"%@",model.diabetes_type];
        } else {
            sugarType.text = [NSString stringWithFormat:@"%@ %@",model.diabetes_type,model.diagnosis_time];
        }
    }else{
        sugarType.text = @"未知";
    }
    [isCare setImage:[UIImage imageNamed:model.is_follow_tog==0?@"add_attention":@"each_attention"] forState:UIControlStateNormal];
    focus =model.is_follow_tog==0?1:2;
}
#pragma mark ====== 关注 =======
- (void)addCare:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(recommendAttentionToClick:withFriendMode:)]) {
        [_delegate recommendAttentionToClick:self withFriendMode:friendModel];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
