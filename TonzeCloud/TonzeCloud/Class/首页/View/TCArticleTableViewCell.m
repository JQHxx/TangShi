//
//  TCArticleTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/9/4.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCArticleTableViewCell.h"
#import "QLCoreTextManager.h"

@interface TCArticleTableViewCell (){
    UIImageView *iconImageView;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    UILabel *readCountLabel;
}
@end

@implementation TCArticleTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 80)];
        [self.contentView addSubview:iconImageView];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+10, 10, kScreenWidth-iconImageView.right-20, 30)];
        titleLabel.font=[UIFont systemFontOfSize:18];
        titleLabel.textColor=[UIColor colorWithHexString:@"#313131"];
        titleLabel.numberOfLines=0;
        [self.contentView addSubview:titleLabel];
        
        readCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right, 70, kScreenWidth-iconImageView.right-15, 20)];
        readCountLabel.font=[UIFont systemFontOfSize:12];
        readCountLabel.textColor=[UIColor colorWithHexString:@"#939393"];
        readCountLabel.textAlignment=NSTextAlignmentRight;
        [self.contentView addSubview:readCountLabel];
    }
    return self;
}

-(void)cellDisplayWithModel:(TCArticleModel *)articleModel searchText:(NSString *)searchtext{
    NSString *url = [NSString stringWithFormat:@"%@",articleModel.image_url.length>0?articleModel.image_url:articleModel.l_url];
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    
    NSString *textStr=[NSString stringWithFormat:@"%@",articleModel.title];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textStr];
    [QLCoreTextManager setAttributedValue:attString artlcleText:searchtext font:[UIFont systemFontOfSize:18] color:[UIColor redColor]];
   
    CGFloat textHeight=[textStr boundingRectWithSize:CGSizeMake(kScreenWidth-iconImageView.right-20, 60) withTextFont:titleLabel.font].height;
    titleLabel.frame=CGRectMake(iconImageView.right+10, 10, kScreenWidth-iconImageView.right-20, textHeight+5);
    titleLabel.attributedText = attString;

    readCountLabel.text=[NSString stringWithFormat:@"%ld人阅读",(long)articleModel.reading_number>0?articleModel.reading_number:articleModel.reading_num];
}
-(void)layoutSubviews
{
    
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (self.selected) {
                        image.image=[UIImage imageNamed:@"ic_pub_choose_sel"];
                    }
                    else
                    {
                        image.image=[UIImage imageNamed:@"ic_pub_choose_nor"];
                    }
                }
            }
        }
    }
    
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *view in control.subviews)
            {
                if ([view isKindOfClass: [UIImageView class]]) {
                    UIImageView *image=(UIImageView *)view;
                    if (!self.selected) {
                        image.image=[UIImage imageNamed:@"ic_pub_choose_nor"];
                    }
                }
            }
        }
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
