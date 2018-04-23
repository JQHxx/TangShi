//
//  TCMyResponseView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyResponseView.h"
@interface TCMyResponseView (){
    
    UIButton        *headImgViewBtn;
    UIButton        *nickNameBtn;
    UIImageView     *sexImg;
    UIButton        *roleType;      // 用户类型
    UIButton        *careButton;
    UILabel         *sugarType;     // 糖尿病类型
    UIImageView     *positionImg;
    UILabel         *positionLabel;
    UIButton          *lookAllButton;   // 查看全文
    UIButton          *deleteButton;    // 删除动态
    
    
    TCMyDynamicModel  *dynamicModel;
}
@end
@implementation TCMyResponseView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        headImgViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, 7, 40, 40)];
        headImgViewBtn.layer.cornerRadius = 20;
        headImgViewBtn.clipsToBounds = YES;
        [headImgViewBtn addTarget:self action:@selector(myDynamic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:headImgViewBtn];
        
        nickNameBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        nickNameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [nickNameBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        [nickNameBtn addTarget:self action:@selector(myDynamic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nickNameBtn];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        sexImg.layer.cornerRadius =10;
        [self addSubview:sexImg];
        
        roleType = [UIButton buttonWithType:UIButtonTypeCustom];
        roleType.titleLabel.font = kFontWithSize(12);
        [roleType setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        roleType.hidden = YES;
        roleType.layer.cornerRadius = 3;
        [self addSubview:roleType];
        
        careButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-83, (60-25)/2, 73, 25)];
        [careButton addTarget:self action:@selector(addCareButton) forControlEvents:UIControlEventTouchUpInside];
        careButton.layer.cornerRadius = 2;
        careButton.hidden = YES;
        [self addSubview:careButton];
        
        sugarType = [[UILabel alloc] initWithFrame:CGRectZero];
        sugarType.font = [UIFont systemFontOfSize:13];
        sugarType.textAlignment = NSTextAlignmentLeft;
        sugarType.textColor = [UIColor colorWithHexString:@"0x959595"];

        [self addSubview:sugarType];
        
        positionImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        positionImg.image = [UIImage imageNamed:@"where"];
        [self addSubview:positionImg];
        positionImg.hidden=YES;
        
        positionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        positionLabel.font = [UIFont systemFontOfSize:13];
        positionLabel.textColor = [UIColor grayColor];
        [self addSubview:positionLabel];
        positionLabel.hidden=YES;
    }
    return self;
}
- (void)myResponseModel:(TCMyDynamicModel *)model type:(NSInteger)type{
    //头像
    dynamicModel = model;
    if (type==1) {
        if (model.is_self!=1) {
            careButton.hidden = NO;
            if (model.focus_status==2) {
                [careButton setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
            }else{
                [careButton setImage:[UIImage imageNamed:model.focus_status==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
            }
            [careButton addTarget:self action:@selector(addCareButton) forControlEvents:UIControlEventTouchUpInside];
            careButton.tag = 101;
            careButton.layer.cornerRadius = 2;
        }
    }else{
        careButton.hidden = YES;
    }
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:model.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    [nickNameBtn setTitle:model.nick_name forState:UIControlStateNormal];
    
    // 用户名
    CGSize nickNameSize = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickNameBtn.frame = CGRectMake(headImgViewBtn.right+6,10, nickNameSize.width+5, 18);
    
    // 性别
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
        sexImg.frame =CGRectMake(nickNameBtn.right, 10, 20, 20);
    }else{
        sexImg.frame =CGRectMake(nickNameBtn.right, nickNameBtn.top- 5, 0.1, 0.1);
    }
    
    //用户类型
    CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(12)];
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        roleType.hidden = NO;
        roleType.frame = CGRectMake(sexImg.right + 10, nickNameBtn.top , labelSize.width + 10 , 16);
        [roleType setTitle:model.label forState:UIControlStateNormal];
        roleType.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        roleType.hidden = NO;
        roleType.frame = CGRectMake(sexImg.right + 10, nickNameBtn.top , labelSize.width + 10, 16);
        [roleType setTitle:model.label forState:UIControlStateNormal];
        roleType.backgroundColor = kSystemColor;
    }else{
        roleType.hidden = YES;
    }
    
    // 糖尿病类型 、 治疗时间
    NSString *roleTypeAndDiagnosisTimeStr = [NSString stringWithFormat:@"%@ %@",model.diabetes_type,model.diagnosis_time];
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
    CGSize roleSize = [sugarType.text boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontWithSize(13)];
    sugarType.frame =CGRectMake(headImgViewBtn.right + 8, nickNameBtn.bottom + 3,roleSize.width, roleSize.height);
    
    // 地址信息
    if (!kIsEmptyString(model.pro) && ![model.pro isEqualToString:@"(null)"]) {
        positionImg.hidden = NO;
        positionLabel.hidden = NO;
        positionLabel.text = [NSString stringWithFormat:@"%@%@",model.pro,model.city];
        if (kIsEmptyString(roleTypeAndDiagnosisTimeStr)) {
            positionImg.frame =CGRectMake(sugarType.right, sugarType.bottom - 15, 12, 15);
        }else{
            positionImg.frame =CGRectMake(sugarType.right+10, sugarType.bottom - 15, 12, 15);
        }
        positionLabel.frame =CGRectMake(positionImg.right + 3, sugarType.top, kScreenWidth/2, roleSize.height);
    }else{
        positionLabel.text=[NSString stringWithFormat:@"%@%@",model.pro,model.city];
        positionImg.hidden = YES;
        positionLabel.hidden = YES;
    }
}


- (void)myLookForMyModel:(TCLookFoMyModel *)model{
    
    //头部
    [headImgViewBtn sd_setImageWithURL:[NSURL URLWithString:model.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    [nickNameBtn setTitle:model.nick_name forState:UIControlStateNormal];
    
    CGSize size = [nickNameBtn.titleLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nickNameBtn.frame = CGRectMake(headImgViewBtn.right+8,10, size.width, 20);
    
    if (model.sex!=3) {
        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
        sexImg.frame =CGRectMake(nickNameBtn.right, nickNameBtn.top-5, 30, 30);
    }else{
        sexImg.frame =CGRectMake(nickNameBtn.right, nickNameBtn.top-5, 0.1, 0.1);
    }
    //用户类型
    CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(12)];
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        roleType.hidden = NO;
        roleType.frame = CGRectMake(sexImg.right + 10, nickNameBtn.top , labelSize.width + 10 , 16);
        [roleType setTitle:model.label forState:UIControlStateNormal];
        roleType.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        roleType.hidden = NO;
        roleType.frame = CGRectMake(sexImg.right + 10, nickNameBtn.top , labelSize.width + 10, 16);
        [roleType setTitle:model.label forState:UIControlStateNormal];
        roleType.backgroundColor = kSystemColor;
    }else{
        roleType.hidden = YES;
    }
    if (model.diabetes_type.length>0) {
        if ([model.diabetes_type isEqualToString:@"其他"]||[model.diabetes_type isEqualToString:@"正常"]) {
            sugarType.text = [NSString stringWithFormat:@"%@",model.diabetes_type];
        } else {
            sugarType.text = [NSString stringWithFormat:@"%@ %@",model.diabetes_type,model.diagnosis_time];
        }
    }else{
        sugarType.text = @"未知";
    }
    size = [sugarType.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    sugarType.frame =CGRectMake(headImgViewBtn.right+8, nickNameBtn.bottom + 3,size.width, 15);
    positionImg.hidden = YES;


}
#pragma mark -- 个人信息
- (void)myDynamic{
    if ([_delegate respondsToSelector:@selector(myRespondView)]) {
        [_delegate myRespondView];
    }
}

#pragma mark -- 添加关注
- (void)addCareButton{
    [MobClick event:@"105_002028"];
    [[TCHelper sharedTCHelper] loginClick:@"008-06-03"];
    NSString *body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%d",dynamicModel.user_id,dynamicModel.role_type,dynamicModel.focus_status==0?1:2];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFocusFriend body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            dynamicModel.focus_status =[[result objectForKey:@"focus_status"] integerValue];
            if ([[result objectForKey:@"focus_status"] integerValue]==2) {
                [careButton setImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
            }else{
                [careButton setImage:[UIImage imageNamed:[[result objectForKey:@"focus_status"] integerValue]==0?@"add_attention":@"attention"] forState:UIControlStateNormal];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
@end
