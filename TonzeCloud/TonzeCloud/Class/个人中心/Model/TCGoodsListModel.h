//
//  GoodsListModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGoodsListModel : NSObject
/// 商品ID
@property (nonatomic ,strong) NSNumber *good_id;
///商品名
@property (nonatomic, copy) NSString *good_name;
///商品封面图id
@property (nonatomic, copy) NSString *good_image;
///积分
@property (nonatomic ,strong) NSNumber *change_points;
///封面图url
@property (nonatomic, copy) NSString *image_cover_url;
/// 兑换状态 （1.可兑换，2.已对完，3.已结束）
@property (nonatomic ,strong) NSNumber *status;

@end
