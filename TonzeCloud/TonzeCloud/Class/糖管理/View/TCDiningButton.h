//
//  TCDiningButton.h
//  TonzeCloud
//
//  Created by vision on 17/2/24.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDiningButton : UIButton

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@property (nonatomic, copy )NSString *valueString;

@end
