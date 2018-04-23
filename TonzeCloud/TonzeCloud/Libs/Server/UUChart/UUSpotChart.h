//
//  UUSpotChart.h
//  TonzeCloud
//
//  Created by vision on 17/3/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUChartConst.h"

@interface UUSpotChart : UIView

@property (strong, nonatomic) NSArray      * xLabels;
@property (strong, nonatomic) NSDictionary * yValues;


-(void)strokeChart;

- (NSArray *)chartLabelsForX;

@end
