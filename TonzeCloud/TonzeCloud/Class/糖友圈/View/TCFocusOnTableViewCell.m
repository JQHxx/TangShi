//
//  TCFocusOnTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFocusOnTableViewCell.h"
@interface TCFocusOnTableViewCell (){

    UIImageView     *headImgView;
    UILabel         *nickName;
    UIImageView     *sexImg;
    UILabel         *expertLabel;
    UILabel         *sugarType;
    UIButton        *isCare;
    
    TCFocusOnModel  *focusModel;
    TCNewFriendModel  *friendModel;
    NSInteger        type;
    NSInteger        focus;
    
    NSInteger        indexType;
}
@end

@implementation TCFocusOnTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14, 80-28, 80-28)];
        headImgView.clipsToBounds=YES;
        headImgView.layer.cornerRadius = (80-28)/2;
        [self addSubview:headImgView];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectZero];
        nickName.font = [UIFont systemFontOfSize:14];
        [self addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        sexImg.layer.cornerRadius =10;
        [self addSubview:sexImg];
        
        expertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        expertLabel.layer.cornerRadius = 4;
        expertLabel.clipsToBounds = YES;
        expertLabel.font = [UIFont systemFontOfSize:13];
        expertLabel.textAlignment = NSTextAlignmentCenter;
        expertLabel.textColor = [UIColor whiteColor];
        [self addSubview:expertLabel];
        
        sugarType = [[UILabel alloc] initWithFrame:CGRectZero];
        sugarType.font = [UIFont systemFontOfSize:14];
        sugarType.textColor = [UIColor grayColor];
        [self addSubview:sugarType];
        
        isCare = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-83, 27, 73, 25)];
        [isCare addTarget:self action:@selector(addCare:) forControlEvents:UIControlEventTouchUpInside];
        isCare.layer.cornerRadius = 2;
        [self addSubview:isCare];

    }
    return self;

}
#pragma mark -- 关注
- (void)cellFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index{
    type = 1;
    indexType = index;
    focusModel = model;
    isCare.tag = model.follow_user_id;
    
    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top-4, size.width, 20);
    sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    
    expertLabel.text = model.label;
    size = [expertLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    expertLabel.frame =CGRectMake(headImgView.right+15, nickName.bottom+2, size.width+10, 20);
    sugarType.frame = CGRectMake(headImgView.right+15, expertLabel.bottom+2, kScreenWidth/2, 20);
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        expertLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        expertLabel.backgroundColor = kSystemColor;
    }else{
        expertLabel.frame = CGRectMake(model.sex==3?nickName.right+10:sexImg.right, nickName.top, size.width+10, 0.01);
        sugarType.frame = CGRectMake(headImgView.right+15, nickName.bottom+2, kScreenWidth/2, 20);
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
    
    if (index==1) {
        [isCare setImage:[UIImage imageNamed:model.is_follow_tog==0?@"attention":@"each_attention"] forState:UIControlStateNormal];
    } else {
        if (model.is_self!=1) {
            if (model.is_follow_tog==2) {
                [isCare setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
            } else {
                [isCare setImage:[UIImage imageNamed:model.is_follow_tog==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
            }
        }
    }
}
#pragma mark -- 被关注
- (void)cellBeFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index{
    focusModel = model;
    type = 2;
    indexType = index;
    isCare.tag = model.follow_user_id;
    
    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top-4, size.width, 20);
    sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    expertLabel.text = model.label;
    size = [expertLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    expertLabel.frame =CGRectMake(headImgView.right+15, nickName.bottom+2, size.width+10, 20);
    sugarType.frame = CGRectMake(headImgView.right+15, expertLabel.bottom+2, kScreenWidth/2, 20);
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        expertLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        expertLabel.backgroundColor = kSystemColor;
    }else{
        expertLabel.frame = CGRectMake(model.sex==3?nickName.right+10:sexImg.right, nickName.top, size.width+10, 0.01);
        sugarType.frame = CGRectMake(headImgView.right+15, nickName.bottom+2, kScreenWidth/2, 20);
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
    if (index==1) {
        [isCare setImage:[UIImage imageNamed:model.is_follow_tog==0?@"add_attention":@"each_attention"] forState:UIControlStateNormal];
    } else {
        if (model.is_self!=1) {
            isCare.hidden = NO;
            if (model.is_follow_tog==2) {
                [isCare setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
            } else {
                [isCare setImage:[UIImage imageNamed:model.is_follow_tog==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
            }
        }else{
            isCare.hidden = YES;
        }
    }
}

#pragma mark -- 搜索更多糖友
- (void)cellMoreFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index{
    focusModel = model;
    type = 3;
    indexType = index;
    isCare.tag = model.follow_user_id;
    
    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top-4, size.width, 20);
    sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    expertLabel.text = model.label;
    size = [expertLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    expertLabel.frame =CGRectMake(headImgView.right+15, nickName.bottom+2, size.width+10, 20);
    sugarType.frame = CGRectMake(headImgView.right+15, expertLabel.bottom+2, kScreenWidth/2, 20);
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        expertLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        expertLabel.backgroundColor = kSystemColor;
    }else{
        expertLabel.frame = CGRectMake(model.sex==3?nickName.right+10:sexImg.right, nickName.top, size.width+10, 0.01);
        sugarType.frame = CGRectMake(headImgView.right+15, nickName.bottom+2, kScreenWidth/2, 20);
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
    if (index==1) {
        [isCare setImage:[UIImage imageNamed:model.focus_status==0?@"add_attention":@"each_attention"] forState:UIControlStateNormal];
    } else {
        if (model.is_self!=1) {
            isCare.hidden = NO;
            if (model.is_follow_tog==2) {
                [isCare setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
            } else {
                [isCare setImage:[UIImage imageNamed:model.focus_status==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
            }
        }else{
            isCare.hidden = YES;
        }
    }
}
- (void)cellNewFriendModel:(TCNewFriendModel *)model{
    friendModel = model;
    type = 4;
    isCare.tag = model.follow_user_id;
    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size =[nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top-4, size.width, 20);
    sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 30);
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
    }else{
        sexImg.frame =CGRectMake(nickName.right, nickName.top-5, 30, 0.1);
    }
    expertLabel.text = model.label;
    size = [expertLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    expertLabel.frame =CGRectMake(headImgView.right+15, nickName.bottom+2, size.width+10, 20);
    sugarType.frame = CGRectMake(headImgView.right+15, expertLabel.bottom+2, kScreenWidth/2, 20);
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        expertLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        expertLabel.backgroundColor = kSystemColor;
    }else{
        expertLabel.frame = CGRectMake(model.sex==3?nickName.right+10:sexImg.right, nickName.top, size.width+10, 0.01);
        sugarType.frame = CGRectMake(headImgView.right+15, nickName.bottom+2, kScreenWidth/2, 20);
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
- (void)addCare:(UIButton *)button{
    NSString *body = nil;
    if (type==1||type==2||type==3) {
        if (type==1) {
            if (indexType==1) {
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=2",focusModel.followed_user_id,focusModel.role_type_ed];
            } else {
                NSInteger focusID = 0;
                if (focusModel.is_follow_tog==2||focusModel.is_follow_tog==1) {
                    focusID = 2;
                } else {
                    focusID = 1;
                }
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%ld",focusModel.followed_user_id,focusModel.role_type_ed,focusID];
            }
        }else if (type==2){
            if (indexType==1) {
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%d",focusModel.follow_user_id,focusModel.role_type,focusModel.is_follow_tog==0?1:2];
            } else {
                NSInteger focusID = 0;
                if (focusModel.is_follow_tog==2||focusModel.is_follow_tog==1) {
                    focusID = 2;
                } else {
                    focusID = 1;
                }
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%ld",focusModel.follow_user_id,focusModel.role_type,focusID];
            }
        }else{
        
            if (indexType==1) {
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%d",focusModel.user_id,focusModel.role_type,focusModel.focus_status==0?1:2];
            } else {
                NSInteger focusID = 0;
                if (focusModel.focus_status==2||focusModel.focus_status==1) {
                    focusID = 2;
                } else {
                    focusID = 1;
                }
                body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%ld",focusModel.user_id,focusModel.role_type,focusID];
            }
        }
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFocusFriend body:body success:^(id json) {
            if ([_delegate respondsToSelector:@selector(returnFocusOnIndex:)]) {
                [_delegate returnFocusOnIndex:button.tag];
            }
            
        } failure:^(NSString *errorStr) {
            
        }];
    }else{
        NSString *body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%ld",friendModel.follow_user_id,friendModel.role_type,focus];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFocusFriend body:body success:^(id json) {
            if (focus==2) {
                focus=1;
                [isCare setImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
            }else{
                focus=2;
                [isCare setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];

            }
        } failure:^(NSString *errorStr) {
            
        }];
    }
}
@end
