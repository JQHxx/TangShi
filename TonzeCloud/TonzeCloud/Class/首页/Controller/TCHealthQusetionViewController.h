//
//  TCHealthQusetionViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCHealthQusetionViewController : BaseViewController
//测试内容id
@property (nonatomic ,assign)NSInteger assess_id;
//标题
@property (nonatomic ,strong)NSString *titleStr;

@property (nonatomic ,strong)NSString *imgUrl;
@end
