//
//  TCSugarButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/6/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSugarButton : UIButton

@property (nonatomic ,copy)NSString *title;

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image color:(NSString *)color title:(NSString *)title;

@end
