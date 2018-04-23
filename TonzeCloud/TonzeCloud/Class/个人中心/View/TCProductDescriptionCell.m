//
//  ProductDescriptionCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/6.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCProductDescriptionCell.h"

@implementation TCProductDescriptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setProductDescriptionCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======
- (void)setProductDescriptionCellUI{
    _commodityImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 240 * kScreenWidth/375)];
    [self.contentView addSubview:_commodityImg];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, _commodityImg.bottom, kScreenWidth, 8)];
    len.backgroundColor = [UIColor bgColor_Gray];
//    [self.contentView addSubview:len]; // 隐藏线条
}
- (void)setImgUrl:(NSString *)imgUrl{
    [_commodityImg sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@""]];
}

@end
