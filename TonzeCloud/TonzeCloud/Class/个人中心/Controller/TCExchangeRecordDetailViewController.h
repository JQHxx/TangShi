//
//  ExchangeRecordsDetailVC.h
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef enum:NSInteger{
    Shipped, /// 已发货
    NotShipped, /// 未发货
}ShipTpye;

@interface TCExchangeRecordDetailViewController : BaseViewController
/// 发货状态
@property (nonatomic, assign)   ShipTpye shipType;
///
@property (nonatomic, assign) NSInteger  order_id;

@end
