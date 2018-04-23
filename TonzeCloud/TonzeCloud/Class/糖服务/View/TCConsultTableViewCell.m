//
//  TCConsultTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCConsultTableViewCell.h"
@interface TCConsultTableViewCell (){
    UIImageView   *headImg;
    UILabel       *nameLabel;
    UILabel       *textLabel;
    UILabel       *detailLabel;

}

@end

@implementation TCConsultTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        headImg.clipsToBounds=YES;
        headImg.layer.cornerRadius = 30;
        [self addSubview:headImg];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, headImg.top+5, 100, 20)];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:nameLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right+10, nameLabel.bottom+10, kScreenWidth-headImg.right-20, 20)];
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.textColor = [UIColor grayColor];
        [self addSubview:textLabel];
        
          }
    return self;
}
-(void)cellConsultWithDict:(TCConsultModel *)consultModel{

     [headImg sd_setImageWithURL:[NSURL URLWithString:consultModel.head_portrait] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nameLabel.text =consultModel.name;
    textLabel.text = consultModel.positional_titles;
    
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
