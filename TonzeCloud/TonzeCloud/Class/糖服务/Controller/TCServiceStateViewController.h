//
//  TCServiceStateViewController.h
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMineServiceModel.h"

@protocol TCServiceStateViewControllerDelegate <NSObject>

//选择cell
-(void)serviceStateVCDidSelectedCellWithModel:(TCMineServiceModel *)myService;
//去评价
-(void)serviceStateVCPushToEvaluateWithModel:(TCMineServiceModel *)myService;

@end


@interface TCServiceStateViewController : UIViewController

@property (nonatomic,weak)id<TCServiceStateViewControllerDelegate>controllerDelegate;


-(void)requestMyServiceStateInfo;

@end
