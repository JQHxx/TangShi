//
//  GoodsDetailImgsModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGoodsDetailImgsModel : NSObject

/// 图片链接
@property (nonatomic, copy) NSString *image_url;
/// 图片id
@property (nonatomic ,strong) NSNumber *image_id;

@end
