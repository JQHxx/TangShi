//
//  TCAddFriendResultTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCAddFriendResultTableViewCell.h"
@interface TCAddFriendResultTableViewCell (){
    UILabel    *nickName;
    UIImageView *headImg;
    UIImageView *sexImg;
}

@end
@implementation TCAddFriendResultTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, 42, 42)];
        headImg.layer.cornerRadius = 21;
        headImg.clipsToBounds = YES;
        [self addSubview:headImg];
        
        nickName = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, 19, 100, 20)];
        nickName.font = [UIFont systemFontOfSize:15];
        [self addSubview:nickName];
        
        sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(nickName.right+10, 15, 16, 20)];
        [self addSubview:sexImg];
        
    }
    return self;
}
- (void)cellAddFriendModel:(TCAddFriendModel *)model{
    
    [headImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    
    nickName.text = model.nick_name;
    CGSize size = [nickName.text sizeWithLabelWidth:200 font:[UIFont systemFontOfSize:15]];
    nickName.frame = CGRectMake(headImg.right+10, 19, size.width+5, 20);
    sexImg.frame = CGRectMake(nickName.right,(58-30)/2, 30, 30);
    if (model.sex!=3) {
        sexImg.image =[UIImage imageNamed:model.sex==1?@"ic_m_male":@"ic_m_famale"];
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
