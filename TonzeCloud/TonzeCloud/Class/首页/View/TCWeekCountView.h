//
//  TCWeekCountView.h
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCWeekCountView : UIView

@property (nonatomic,assign)NSInteger weekCount;        //次数
@property (nonatomic, copy )NSString  *percentageStr;   //百分比
@property (nonatomic,strong)UIColor   *color;           //颜色
@property (nonatomic, copy )NSString  *stateString;     //状态 ，偏高、正常、偏低


@end
