//
//  TCChartView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/1.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChartDataSource <NSObject>

@required

-(NSString *)contentOfEachCell:(NSIndexPath *)indexPath;

-(UIColor *)contentColorOfEachCell:(NSIndexPath *)indexPath;

-(BOOL)indexOfRowNeedRedTriangle:(NSIndexPath *)indexPath;

@end

@interface TCChartView : UIView

@property(nonatomic,assign)NSInteger rows;
@property(nonatomic,assign)NSInteger lines;
@property(nonatomic,assign)CGFloat rowHeight;
@property(nonatomic,weak)id <ChartDataSource> dataSource;


@end
