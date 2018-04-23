//
//  TCBloodScrollView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCChartView.h"

@protocol BloodDataSource <NSObject>

@required

-(NSInteger)rowsNumOfChart;

-(NSInteger)linesNumOfChart;

-(CGFloat )eachCellHeight;

-(NSString *)contentOfEachCell:(NSIndexPath *)indexPath;

-(UIColor *)contentColorOfEachCell:(NSIndexPath *)indexPath;

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath;


@end

@protocol BloodDelegate <NSObject>

@required

-(void)chartDidClickAtIndexPath:(NSIndexPath*)indexPath;

@end
@interface TCBloodScrollView : UIScrollView<BloodDataSource>
@property (nonatomic ,weak) id<BloodDataSource> dataSource;
@property (nonatomic ,weak) id<BloodDelegate> chartDelegate;

-(void)reloadChartView;

@end
