//
//  TCShopCollectionViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/5.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCShopCollectionViewCell.h"

@interface TCShopCollectionViewCell (){

    UIImageView *shopImgView;
    UILabel     *shopNameLabel;
    UILabel     *shopBrifeLabel;
    UILabel     *shopPriceLabel;
    UILabel     *shopMkbpriceLabel;

    CGFloat      width;
}

@end

@implementation TCShopCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        width = frame.size.width;
        
        shopImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [self addSubview:shopImgView];
        
        shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, shopImgView.bottom+5, width-10, 20)];
        shopNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:shopNameLabel];
        
        shopBrifeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, shopNameLabel.bottom, width-10, 20)];
        shopBrifeLabel.font = [UIFont systemFontOfSize:13];
        shopBrifeLabel.textColor = [UIColor grayColor];
        [self addSubview:shopBrifeLabel];
        
        shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopPriceLabel.textColor = [UIColor redColor];
        shopPriceLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:shopPriceLabel];
        
        shopMkbpriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopMkbpriceLabel.textColor = [UIColor grayColor];
        shopMkbpriceLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:shopMkbpriceLabel];
    }
    return self;
}
- (void)initShopCellModel:(ShopModel *)model{
    
    NSDictionary *imgdict =model.image;
    if (kIsDictionary(imgdict)) {
        NSString *urlstr = [NSString stringWithFormat:@"%@",[imgdict objectForKey:@"s_url"]];
        [shopImgView sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:[UIImage imageNamed:@"store_pd_nor"]];
    }
    
    shopNameLabel.text = model.name;
    shopBrifeLabel.text = model.brief;
    shopPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",model.price];
    CGSize priceSize = [shopPriceLabel.text sizeWithLabelWidth:width font:[UIFont systemFontOfSize:16]];
    shopPriceLabel.frame = CGRectMake(10, shopBrifeLabel.bottom, priceSize.width, 20);
    
    shopMkbpriceLabel.text = [NSString stringWithFormat:@" ¥%.2f ",model.mktprice];
    shopMkbpriceLabel.frame =CGRectMake(shopPriceLabel.right+10, shopBrifeLabel.bottom+5, width-shopPriceLabel.right-10, 15);
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:shopMkbpriceLabel.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,shopMkbpriceLabel.text.length)];
    shopMkbpriceLabel.attributedText = attributeMarket;
}

@end
