//
//  TCProgramButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/12/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProgramButton : UIButton

@property (nonatomic ,strong)UILabel *titleLab;

@property (nonatomic ,strong)UILabel *descLab;

@property (nonatomic ,strong)NSString *imgName;

- (instancetype)initWithFrame:(CGRect)frame titleColor:(NSString *)color;

@end
