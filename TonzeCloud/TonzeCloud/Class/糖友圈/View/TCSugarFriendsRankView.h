//
//  TCSugarFriendsRankView.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LookRankBlock)(NSInteger tag);

@interface TCSugarFriendsRankView : UIView

@property (nonatomic, copy) LookRankBlock lookRankBlock ;

- (void)lookSugarFriendData:(NSArray *)dataArray;
@end
