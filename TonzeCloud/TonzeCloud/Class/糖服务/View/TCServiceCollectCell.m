//
//  TCServiceCollectCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceCollectCell.h"

@interface TCServiceCollectCell (){

    UIImageView *caseImg;
    CGFloat      width;
    UILabel     *titleLabel;
    UILabel     *muchLabel;
    UIImageView *SeeMuchLabel;
    UILabel     *payLabel;
    UILabel     *line;
    UIImageView *headImg;
    UILabel     *nameLabel;
    UILabel     *contentLabel;
}
@end
@implementation TCServiceCollectCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        
        caseImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [self addSubview:caseImg];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, caseImg.bottom+5, width-10, 30)];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        titleLabel.font  =[UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        
        SeeMuchLabel= [[UIImageView alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+5, 15, 15)];
        SeeMuchLabel.image = [UIImage imageNamed:@"pub_ic_lite_zhe"];
        [self addSubview:SeeMuchLabel];
        
        muchLabel = [[UILabel alloc] initWithFrame:CGRectMake(SeeMuchLabel.right+5, titleLabel.bottom+5, 70*width/146, 15)];
        muchLabel.textColor = [UIColor colorWithHexString:@"0xe64d34"];
        muchLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:muchLabel];
        
        payLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-60*width/146, titleLabel.bottom+5, 60*width/146, 15)];
        payLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        payLabel.font = [UIFont systemFontOfSize:10];
        payLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:payLabel];
        
        line = [[UILabel alloc] initWithFrame:CGRectMake(0, SeeMuchLabel.bottom+5, width, 1)];
        line.backgroundColor = [UIColor bgColor_Gray];
        [self addSubview:line];
        
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, line.bottom+5, 28, 28)];
        headImg.clipsToBounds=YES;
        headImg.layer.cornerRadius = 14;
        [self addSubview:headImg];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, headImg.top, width-headImg.right, 15)];
        nameLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:nameLabel];
        
        contentLabel =[[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, nameLabel.bottom, width-headImg.right, 15)];
        contentLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        contentLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:contentLabel];

    }
    return self;
}
- (void)cellDisCollectService:(TCServiceModel *)model{

    [caseImg sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imageNamed:@"img_bg_head"]];
    titleLabel.text = model.shceme_name;
    CGSize statusLabelSize =[titleLabel.text sizeWithLabelWidth:width-10 font:[UIFont systemFontOfSize:15]];
    if (statusLabelSize.height>50) {
        titleLabel.frame = CGRectMake(5, caseImg.bottom+5, width-10, 41);
    }else{
    titleLabel.frame = CGRectMake(5, caseImg.bottom+5, width-10, statusLabelSize.height+5);
    }

    SeeMuchLabel.hidden =model.preferential_price>0?NO:YES;
    SeeMuchLabel.frame =CGRectMake(10, caseImg.bottom+50, 15, 15);
    
    muchLabel.text = [NSString stringWithFormat:@"￥%.2f",model.preferential_price>0?model.preferential_price:model.customized_price];
    CGSize size = [muchLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:13]];
    muchLabel.frame = CGRectMake(model.preferential_price>0?SeeMuchLabel.right:5,SeeMuchLabel.top,  size.width, 15);
    
    payLabel.text = [NSString stringWithFormat:@"%ld人付款",(long)model.num];
    CGSize sizePay = [payLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:13]];
    payLabel.frame = CGRectMake(width-sizePay.width-5,SeeMuchLabel.top,sizePay.width, 15);
    
    
    line.frame =CGRectMake(0, SeeMuchLabel.bottom+10, width, 1);

    [headImg sd_setImageWithURL:[NSURL URLWithString:model.head_portrait] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    headImg.frame = CGRectMake(10, line.bottom+10, 30, 30);
    
    nameLabel.text = model.expert_name;
    nameLabel.frame = CGRectMake(headImg.right+10, headImg.top, width-headImg.right, 15);
    
    contentLabel.text = model.positional_titles;
    contentLabel.frame =CGRectMake(headImg.right+10, nameLabel.bottom, width-headImg.right, 15);

}

@end
