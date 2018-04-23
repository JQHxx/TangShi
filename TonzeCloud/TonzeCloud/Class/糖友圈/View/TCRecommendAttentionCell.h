//
//  TCRecommendAttentionCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/12/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCNewFriendModel.h"

@protocol TCRecommendAttentionDelegate <NSObject>

- (void)recommendAttentionToClick:(UITableViewCell *)index withFriendMode:(TCNewFriendModel *)model;

@end

@interface TCRecommendAttentionCell : UITableViewCell
///
@property (nonatomic, weak) id  <TCRecommendAttentionDelegate>delegate;

- (void)cellWithNewFriendModel:(TCNewFriendModel *)model;

@end
