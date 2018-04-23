//
//  TCFocusOnTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFocusOnModel.h"
#import "TCBeFocusModel.h"
#import "TCNewFriendModel.h"

@protocol TCFocusOnDelegate <NSObject>
@required
- (void)returnFocusOnIndex:(NSInteger)index;
@end

@interface TCFocusOnTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCFocusOnDelegate> delegate;

- (void)cellFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index;

- (void)cellBeFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index;

- (void)cellMoreFocusOnModel:(TCFocusOnModel *)model index:(NSInteger)index;

- (void)cellNewFriendModel:(TCNewFriendModel *)model;

@end
