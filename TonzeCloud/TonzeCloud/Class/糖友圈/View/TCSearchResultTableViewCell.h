//
//  TCSearchResultTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFriendSearchModel.h"

@protocol TCSeleteResultDelegate <NSObject>
//点击用户头像
-(void)seletedFriendModel:(TCFriendSearchModel *)model;

- (void)seletedMoreFriend;
@end
@interface TCSearchResultTableViewCell : UITableViewCell

@property (nonatomic ,weak)id<TCSeleteResultDelegate>resultDelegate;

- (void)cellFriendSearchResult:(NSArray *)friendArr;

@end
