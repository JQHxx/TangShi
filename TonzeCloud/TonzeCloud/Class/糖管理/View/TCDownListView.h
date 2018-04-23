//
//  TCDownListView.h
//  TonzeCloud
//
//  Created by vision on 17/5/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCDownListViewDelegate <NSObject>

-(void)selectObjectForIndex:(NSInteger)index;

@end

@interface TCDownListView : UIView

@property (nonatomic,weak)id<TCDownListViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame list:(NSArray *)list;

@end
