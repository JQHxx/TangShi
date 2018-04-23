//
//  TCRemindTimeViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/7/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CheckImgBlock)(NSArray *checkImgArr);

@interface TCRemindTimeViewController : BaseViewController
///
@property (nonatomic ,strong) NSMutableArray *checkImgArr;
///
@property (nonatomic, copy) CheckImgBlock checkImgBlock;

@end
