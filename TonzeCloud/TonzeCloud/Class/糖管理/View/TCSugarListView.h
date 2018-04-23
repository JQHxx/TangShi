//
//  TCSugarListView.h
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSugarModel.h"

@protocol TCSugarListViewDelegate <NSObject>

-(void)sugarListViewDidSelectModel:(TCSugarModel *)model;

@end

@interface TCSugarListView : UIView


@property (nonatomic,weak)id<TCSugarListViewDelegate>viewDelegate;

@property (nonatomic, copy)NSString *headTitleStr;

@property (nonatomic,strong)NSMutableArray *sugarRecordList;

@end
