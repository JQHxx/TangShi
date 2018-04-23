//
//  TCManagerTitleView.h
//  TonzeCloud
//
//  Created by vision on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCManagerTitleView;
@protocol TCManagerTitleViewDelegate <NSObject>

-(void)managerTitleViewGotHistoryData:(TCManagerTitleView *)managerTitleView;

@end

@interface TCManagerTitleView : UIView

@property (nonatomic,assign)id<TCManagerTitleViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
