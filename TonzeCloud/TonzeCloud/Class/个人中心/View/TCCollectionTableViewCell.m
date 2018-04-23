//
//  TCCollectionTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/13.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCCollectionTableViewCell.h"
@interface TCCollectionTableViewCell ()
{
    UIImageView *_goodsImgView;
    UILabel     *_goodsTitleLab;
    UILabel     *_goodsPriceLab;
    UILabel     *_goodsNumberLab;
    UILabel     *_goodsTpyeLab;
}
@end
@implementation TCCollectionTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _goodsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (100 - 80)/2 * kScreenWidth/375, 80* kScreenWidth/375, 80* kScreenWidth/375)];
        _goodsImgView.layer.borderWidth = 0.5;
        _goodsImgView.layer.borderColor = UIColorFromRGB(0xe5e5e5).CGColor;
        [self.contentView addSubview:_goodsImgView];
        
        _goodsTitleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTitleLab.font = [UIFont systemFontOfSize:13];
        _goodsTitleLab.textColor = UIColorFromRGB(0x313131);
        _goodsTitleLab.numberOfLines = 2;
        [self.contentView addSubview:_goodsTitleLab];
        
        _goodsTpyeLab =[[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTpyeLab.font = [UIFont systemFontOfSize:12];
        _goodsTpyeLab.textColor = UIColorFromRGB(0x999999);
        [self.contentView addSubview:_goodsTpyeLab];
        
        
        _goodsPriceLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsPriceLab.font = [UIFont systemFontOfSize:13];
        _goodsPriceLab.textColor = [UIColor redColor];
        [self.contentView addSubview:_goodsPriceLab];
        
    }
    return self;
}
- (void)initWithShopCollectionModel:(GoodsFavoriteModel *)model{
    
    _goodsImgView.frame = CGRectMake(15, 10, 80, 80);
    [_goodsImgView sd_setImageWithURL:[NSURL URLWithString:[model.goods_pic objectForKey:@"s_url"]] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];
    
    _goodsTitleLab.text = model.goods_name;
    _goodsTitleLab.textColor = [UIColor colorWithHexString:@"0x313131"];
    _goodsTitleLab.font = [UIFont systemFontOfSize:13];
    
    CGSize nameSize = [_goodsTitleLab.text sizeWithLabelWidth:kScreenWidth-_goodsImgView.right- 30 font:[UIFont systemFontOfSize:13]];
    _goodsTitleLab.frame =CGRectMake(_goodsImgView.right+10, _goodsImgView.top+5,kScreenWidth-_goodsImgView.right-60, nameSize.height>36?36:nameSize.height);
    
    _goodsPriceLab.text = [NSString stringWithFormat:@"¥%.2f",model.goods_price];
    _goodsPriceLab.font = [UIFont systemFontOfSize:13];
    _goodsPriceLab.textColor = [UIColor colorWithHexString:@"0xf33f00"];
    CGSize size = [_goodsPriceLab.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    _goodsPriceLab.frame =CGRectMake(_goodsImgView.right+10, _goodsImgView.bottom-25, size.width, 20);
    
    
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
@end
