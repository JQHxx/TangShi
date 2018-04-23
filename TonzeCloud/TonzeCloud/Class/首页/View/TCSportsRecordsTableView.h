//
//  TCSportsRecordsTableView.h
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSportRecordModel.h"

@class TCSportsRecordsTableView;
@protocol TCSportsRecordsTableViewDelegate <NSObject>

-(void)sportsRecordTableView:(TCSportsRecordsTableView *)tableView didSelectStepSportModel:(TCSportRecordModel *)stepModel;

@end

@interface TCSportsRecordsTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak)id<TCSportsRecordsTableViewDelegate>viewDelegate;

@property (nonatomic,strong)NSMutableArray *sportsRecordsArray;

@end
