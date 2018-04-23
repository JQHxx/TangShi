//
//  TCHomeCenterView.h
//  TonzeCloud
//
//  Created by vision on 17/10/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCHomeCenterModel.h"

@protocol TCHomeCenterViewDelegate <NSObject>

-(void)homeCenterViewDidClickWithTag:(NSInteger)tag;

@end

@interface TCHomeCenterView : UIView

@property(nonatomic,weak)id<TCHomeCenterViewDelegate>delegate;

- (void)homeCenterData:(NSArray *)homeCenterArr;
@end
