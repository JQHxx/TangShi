//
//  TCFriendSearchTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCDeleteHistoryDelegate <NSObject>

//开始滑动
-(void)deleteSerachHistory:(NSString *)historyStr;

@end
@interface TCFriendSearchTableViewCell : UITableViewCell

@property (nonatomic ,weak)id<TCDeleteHistoryDelegate>deleteSearchDelegate;

@property (nonatomic ,strong)UILabel *nameLabel;

@end
