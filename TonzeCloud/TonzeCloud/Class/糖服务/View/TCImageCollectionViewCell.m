//
//  TCImageCollectionViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/9/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCImageCollectionViewCell.h"
@interface TCImageCollectionViewCell (){
    
    UIImageView *caseImg;
    CGFloat      width;
    UILabel     *titleLabel;
    UILabel     *muchLabel;
    UIImageView *SeeMuchLabel;
    UILabel     *payLabel;
    UILabel     *lineLabel;
    UILabel     *nameLabel;
}
@end
@implementation TCImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        
        caseImg = [[UIImageView alloc] initWithFrame:CGRectMake((width-90)/2, 12, 90, 90)];
        caseImg.layer.cornerRadius = 45;
        caseImg.clipsToBounds = YES;
        [self addSubview:caseImg];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, caseImg.bottom+8, width, 15)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor colorWithHexString:@"0xffb237"];
        [self addSubview:nameLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, caseImg.bottom+5, width-10, 30)];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        titleLabel.font  =[UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel.bottom+41+10, width, 0.4)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self addSubview:lineLabel];
        
        SeeMuchLabel= [[UIImageView alloc] initWithFrame:CGRectMake(10, lineLabel.bottom+10, 15, 15)];
        SeeMuchLabel.image = [UIImage imageNamed:@"pub_ic_lite_zhe"];
        [self addSubview:SeeMuchLabel];
        
        muchLabel = [[UILabel alloc] initWithFrame:CGRectMake(SeeMuchLabel.right+5, lineLabel.bottom+10, 70*width/146, 15)];
        muchLabel.textColor = [UIColor colorWithHexString:@"0xe64d34"];
        muchLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:muchLabel];
        
        payLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-60*width/146, lineLabel.bottom+10, 60*width/146, 15)];
        payLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
        payLabel.font = [UIFont systemFontOfSize:10];
        payLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:payLabel];
        
    }
    return self;
}
- (void)cellimageCollectService:(TCImageServiceModel *)model{
    [caseImg sd_setImageWithURL:[NSURL URLWithString:model.head_portrait] placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
    
    nameLabel.text = model.expert_name;
        
    titleLabel.text = model.graphic_speciality;
    CGSize statusLabelSize =[titleLabel.text sizeWithLabelWidth:width-10 font:[UIFont systemFontOfSize:15]];
    if (statusLabelSize.height>50) {
        titleLabel.frame = CGRectMake(5, nameLabel.bottom+5, width-10, 41);
    }else{
        titleLabel.frame = CGRectMake(5, nameLabel.bottom+5, width-10, statusLabelSize.height+5);
    }
    
    SeeMuchLabel.hidden =model.graphic_preferential_price>0?NO:YES;
    SeeMuchLabel.frame =CGRectMake(10, lineLabel.bottom+10, 15, 15);
    
    muchLabel.text = [NSString stringWithFormat:@"￥%.2f",model.graphic_preferential_price>0?model.graphic_preferential_price:model.graphic_price];
    CGSize size = [muchLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:13]];
    muchLabel.frame = CGRectMake(model.graphic_preferential_price>0?SeeMuchLabel.right:5,SeeMuchLabel.top,  size.width, 15);
    
    payLabel.text = [NSString stringWithFormat:@"%ld人付款",(long)model.num];
    CGSize sizePay = [payLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:13]];
    payLabel.frame = CGRectMake(width-sizePay.width-5,SeeMuchLabel.top,sizePay.width, 15);
    
}
@end
