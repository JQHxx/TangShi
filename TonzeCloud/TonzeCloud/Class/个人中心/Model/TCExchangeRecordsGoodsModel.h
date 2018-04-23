//
//  ExchangeRecordsGoodsModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCExchangeRecordsGoodsModel : NSObject
/// 商品id
@property (nonatomic ,strong) NSNumber *good_id;
/// 商品名称
@property (nonatomic, copy) NSString *good_name;
///
@property (nonatomic, copy) NSString *good_image;
/// 积分
@property (nonatomic ,strong) NSNumber *change_points;
/// 图片链接
@property (nonatomic, copy) NSString *image_url;

@end
/*
 goods": {
 "good_id": 9,
 "good_name": "大白菜",
 "good_image": "bcf08cf38fcec8a2aa7b799bcb344247",
 "change_points": 11,
 "image_url": "http://360tjy-health.oss-cn-shanghai.aliyuncs.com/image/test/201705/e04ce029fa28a6f7814a6ac1902bb18e.png"
 }
 */
