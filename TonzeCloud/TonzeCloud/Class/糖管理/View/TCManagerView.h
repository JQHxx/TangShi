//
//  TCManagerView.h
//  TonzeCloud
//
//  Created by vision on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCManagerViewDelegate <NSObject>

-(void)managerViewDidClickToolButtonForIndex:(NSInteger)index;
-(void)managerViewAddSugarViewAction;

@end

@interface TCManagerView : UIView

@property (nonatomic,weak)id<TCManagerViewDelegate>delegate;

@property (nonatomic,strong)NSString *periodString;   //时间段

@end
