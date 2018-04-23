//
//  TCSetSugarView.h
//  TonzeCloud
//
//  Created by vision on 17/2/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSetSugarView : UIView


@property (nonatomic, copy )NSString *periodStr;   //时间段
@property (nonatomic, strong) void (^sugarValue) (double value);  //血糖值
@property (nonatomic,assign)double initValue;
@property (nonatomic,assign)BOOL isbool;

@property (nonatomic,assign)BOOL isHomeIn;
@property (nonatomic,assign)BOOL way;

@end
