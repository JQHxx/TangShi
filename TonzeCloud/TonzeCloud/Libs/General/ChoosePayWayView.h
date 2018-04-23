//
//  ChoosePayWayView.h
//  TonzeCloud
//
//  Created by vision on 18/4/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChoosePayWayViewDelegate <NSObject>

- (void)didSelectedPayWay:(NSInteger)payType;

@end


@interface ChoosePayWayView : UIView

@property (nonatomic , weak )id <ChoosePayWayViewDelegate> delegate;

@end
