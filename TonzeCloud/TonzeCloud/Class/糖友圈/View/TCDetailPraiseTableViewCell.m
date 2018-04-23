//
//  TCDetailPraiseTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDetailPraiseTableViewCell.h"

@interface TCDetailPraiseTableViewCell (){

    UIImageView *headImage;
    UILabel     *nameLabel;
    UILabel     *typeLabel;
}
@end
@implementation TCDetailPraiseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        headImage = [[UIImageView alloc] initWithFrame:CGRectMake(18, 10, 30, 30)];
        headImage.clipsToBounds = YES;
        headImage.layer.cornerRadius = 15;
        [self.contentView addSubview:headImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+8, 15, kScreenWidth/2, 20)];
        nameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:nameLabel];
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.right+15, 15, 40, 20)];
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.font = [UIFont systemFontOfSize:13];
        typeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:typeLabel];
    }
    return self;
}

- (void)cellDetailPraiseModel:(TCDynamicPraiseModel *)model{
    [headImage sd_setImageWithURL:[NSURL URLWithString:model.head_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nameLabel.text = model.nick_name;
    CGSize size = [nameLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
    nameLabel.frame =CGRectMake(headImage.right+8, 15, size.width+5, 20);
    
    CGSize labelSize = [model.label boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(13)];
    if (!kIsEmptyString(model.label) && ![model.label isEqualToString:@"官方"]) {
        typeLabel.text = model.label;
        typeLabel.hidden = NO;
        typeLabel.frame = CGRectMake(nameLabel.right, 35/2, labelSize.width+10, 16);
        typeLabel.backgroundColor = UIColorFromRGB(0xf9c92b);
    }else if (!kIsEmptyString(model.label) && [model.label isEqualToString:@"官方"]){
        typeLabel.hidden = NO;
        typeLabel.text = model.label;
        typeLabel.frame = CGRectMake(nameLabel.right, 35/2, labelSize.width+10, 16);
        typeLabel.backgroundColor = kSystemColor;
    }else{
        typeLabel.hidden = YES;
    }
}
@end
