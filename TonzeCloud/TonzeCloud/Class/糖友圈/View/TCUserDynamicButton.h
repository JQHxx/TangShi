//
//  TCUserDynamicButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/23.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCUserDynamicButton : UIButton

@property (nonatomic ,strong)NSString *title;

- (instancetype)initWithFrame:(CGRect)frame img:(NSString *)image;

@end
