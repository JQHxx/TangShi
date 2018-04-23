//
//  TCHomeShopView.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/5.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCHomeShopView.h"

@interface TCHomeShopView (){

    UIButton *shopButton1;
    UIButton *shopButton2;
    UIButton *moreButton;
    
    NSDictionary *shopDict;
}
@end

@implementation TCHomeShopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(10, 25/2, 4, 15)];
        headView.backgroundColor = kbgBtnColor;
        [self addSubview:headView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(headView.right+2, 10, kScreenWidth/2, 20)];
        titleLabel.text = @"商城";
        titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:titleLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self addSubview:lineLabel];
        
        shopButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, lineLabel.bottom, kScreenWidth/2, kScreenWidth/2)];
        [shopButton1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        shopButton1.tag = 100;
        [shopButton1 addTarget:self action:@selector(shopButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shopButton1];
        
        UILabel *leftLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, lineLabel.bottom, 1, kScreenWidth/2)];
        leftLineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self addSubview:leftLineLabel];
        
        shopButton2 = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, lineLabel.bottom, kScreenWidth/2-1, kScreenWidth/4)];
        [shopButton2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        shopButton2.tag = 101;
        [shopButton2 addTarget:self action:@selector(shopButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shopButton2];
        
        UILabel *rightLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, shopButton2.bottom, kScreenWidth/2, 1)];
        rightLineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self addSubview:rightLineLabel];
        
        moreButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, rightLineLabel.bottom, kScreenWidth/2-1, kScreenWidth/4-1)];
        [moreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        moreButton.tag = 102;
        [moreButton addTarget:self action:@selector(shopButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreButton];
    }
    return self;
}

- (void)homeShopData:(NSDictionary *)homeCenterDict{
    shopDict = homeCenterDict;
    
    [shopButton1 sd_setImageWithURL:[NSURL URLWithString:[homeCenterDict objectForKey:@"goods_pic1_url"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"store_ad_01_nor"]];
    [shopButton2 sd_setImageWithURL:[NSURL URLWithString:[homeCenterDict objectForKey:@"goods_pic2_url"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"store_ad_02_nor"]];
    [moreButton sd_setImageWithURL:[NSURL URLWithString:[homeCenterDict objectForKey:@"target_pic_url"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"store_ad_03_nor"]];

}

- (void)shopButton:(UIButton *)button{
  
    if ([_delegate respondsToSelector:@selector(homeShopViewDidClickWithTag:Shop_id:)]) {
        [_delegate homeShopViewDidClickWithTag:button.tag Shop_id:button.tag==100?[[shopDict objectForKey:@"goods_sn1"] integerValue]:[[shopDict objectForKey:@"goods_sn2"] integerValue]];
    }


}

@end
