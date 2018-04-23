//
//  TCMineExpertCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMineExpertCell.h"
@interface TCMineExpertCell (){
    UIImageView   *headImage;
    UILabel       *nameLabel;
    UILabel       *occupationLabel;
    UIButton       *cancelBtn;
}
@end
@implementation TCMineExpertCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        headImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 14, 80-28, 80-28)];
        headImage.clipsToBounds=YES;
        headImage.layer.cornerRadius = (80-28)/2;
        [self addSubview:headImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+15, headImage.top, 60, 20)];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:nameLabel];
        
        occupationLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImage.right+15, nameLabel.bottom+10, kScreenWidth/2, 20)];
        occupationLabel.font = [UIFont systemFontOfSize:14];
        occupationLabel.textColor = [UIColor grayColor];
        [self addSubview:occupationLabel];
        
        cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-75, 14, 60, 25)];
        [cancelBtn setTitle:@"取消关注" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:kbgBtnColor forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn.layer setBorderWidth:1];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){5.0/256, 211.0/256, 128.0/256,1 });
        [cancelBtn.layer setBorderColor:colorref];//边框颜色
        cancelBtn.layer.cornerRadius = 2;
        CGColorSpaceRelease(colorSpace);
        CGColorRelease(colorref);
        [self addSubview:cancelBtn];
    }
    return self;
}
-(void)cellDisplayWithDict:(TCMineExpertModel *)expertModel Index:(NSInteger)index{
    
   [headImage sd_setImageWithURL:[NSURL URLWithString:expertModel.head_portrait] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nameLabel.text =expertModel.name;
    occupationLabel.text = expertModel.positional_titles;
    cancelBtn.tag = expertModel.expert_id;
 }
#pragma mark -- 取消关注
- (void)cancelBtn:(UIButton *)button{
    
    [self.delegate returnIndex:button.tag];

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
