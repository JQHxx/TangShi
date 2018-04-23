//
//  TCRiceTypeViewController.h
//  TonzeCloud
//
//  Created by vision on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"
#import "TCRiceModel.h"

typedef void(^DidSelectRiceCallback)(TCRiceModel *rice);


@interface TCRiceTypeViewController : BaseViewController

@property (nonatomic,strong)TCRiceModel   *selRiceModel;
@property (nonatomic, copy )DidSelectRiceCallback selRiceCallBack;

@end
