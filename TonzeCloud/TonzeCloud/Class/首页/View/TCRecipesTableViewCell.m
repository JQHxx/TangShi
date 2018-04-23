//
//  TCRecipesTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRecipesTableViewCell.h"

@interface TCRecipesTableViewCell (){
    UIImageView     *imgView;
    UILabel         *titleLabel;
    UILabel         *ingredientsLabel;
}

@end

@implementation TCRecipesTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        [self.contentView addSubview:imgView];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+5, 5, kScreenWidth-imgView.right-15, 25)];
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:titleLabel];
        
        ingredientsLabel=[[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom+5,titleLabel.width, 20)];
        ingredientsLabel.font=[UIFont systemFontOfSize:13.0f];
        ingredientsLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:ingredientsLabel];
        
    }
    return self;
}
-(void)cellRealodActionWithRecipe:(TCRecipeModel *)recipe{
    [imgView sd_setImageWithURL:[NSURL URLWithString:recipe.img] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    titleLabel.text=recipe.name;
    ingredientsLabel.text=[NSString stringWithFormat:@"%@",recipe.amount];
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
