//
//  GoodsDetailModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGoodsDetailModel : NSObject

/// 积分
@property (nonatomic ,strong) NSNumber *change_points;
///
@property (nonatomic ,strong) NSNumber *good_id;
/// 商品数量
@property (nonatomic ,strong) NSNumber *good_num;
/// 图片id
@property (nonatomic, copy) NSString *good_image ;
///
@property (nonatomic, copy) NSString *good_name ;
/// 商品图片
@property (nonatomic, copy) NSString *image_cover_url ;
/// 商品详情图片
@property (nonatomic, strong) NSArray *images ;
/// 兑换结束时间
@property (nonatomic, copy) NSString *shelf_time ;
/// 兑换状态 （1.可兑换，2.已对完，3.已结束）
@property (nonatomic ,strong) NSNumber *status;


@end
