//
//  TCFocusOnButton.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCFocusOnButton : UIButton

@property (nonatomic ,copy)NSString *numTitle;

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
