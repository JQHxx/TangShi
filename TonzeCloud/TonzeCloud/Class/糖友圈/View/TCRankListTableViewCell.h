//
//  TCRankListTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSugarFriendsRankModel.h"

@protocol TCRankListFocusOnDelegate <NSObject>
@required
- (void)returnFocusOnRankList;
@end
@interface TCRankListTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCRankListFocusOnDelegate> rankListDelegate;

- (void)cellRankListModel:(TCSugarFriendsRankModel *)rankModel rank:(NSInteger)rank;
@end
