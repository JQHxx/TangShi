//
//  TCMyDynamicButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyDynamicButton.h"
@interface TCMyDynamicButton (){
    
    UIImageView     *headImgView;
    UILabel         *nickName;
    UIImageView     *sexImg;
    UILabel         *sugarType;
    UIImageView     *positionImg;
    UILabel         *positionLabel;

}
@end
@implementation TCMyDynamicButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
        headImgView.clipsToBounds = YES;
        headImgView.layer.cornerRadius = 24;
        [self addSubview:headImgView];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImgView.right+15, headImgView.top, 60, 20)];
        nickName.font = [UIFont systemFontOfSize:15];
        [self addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right, headImgView.top, 20, 20)];
        sexImg.layer.cornerRadius =10;
        [self addSubview:sexImg];
        
        
        sugarType = [[UILabel alloc] initWithFrame:CGRectMake(headImgView.right+15, nickName.bottom+10, kScreenWidth/2, 20)];
        sugarType.font = [UIFont systemFontOfSize:14];
        sugarType.textColor = [UIColor grayColor];
        [self addSubview:sugarType];
        
        positionImg = [[UIImageView alloc] initWithFrame:CGRectMake(sugarType.right, sugarType.top, 20, 20)];
        positionImg.image = [UIImage imageNamed:@""];
        [self addSubview:positionImg];
        
        
        positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionImg.right+15, positionImg.top, kScreenWidth/2, 20)];
        positionLabel.font = [UIFont systemFontOfSize:14];
        positionLabel.textColor = [UIColor grayColor];
        [self addSubview:positionLabel];


    }
    return self;
}
- (void)buttonMyDynamicModel:(TCMyDynamicModel *)model{

//    [headImgView sd_setImageWithURL:[NSURL URLWithString:model.headImage] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
//    nickName.text = model.nickName;
//    CGSize size = [nickName.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
//    nickName.frame = CGRectMake(headImgView.right+15, headImgView.top, size.width, 20);
//    
//    if (model.sex!=3) {
//        sexImg.image = [UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
//    }
//    sexImg.frame =CGRectMake(nickName.right, headImgView.top, 20, 20);
//    
//    sugarType.text = model.sugarType;
//    size = [sugarType.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
//    sugarType.frame =CGRectMake(headImgView.right+15, nickName.bottom+10,size.width, 20);
//    positionImg.frame =CGRectMake(sugarType.right+10, sugarType.top, 20, 20);
//    positionLabel.text = model.position;
//    positionLabel.frame =CGRectMake(positionImg.right, positionImg.top, kScreenWidth/2, 20);
    
}
@end
