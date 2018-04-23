//
//  TCMaxDynamicTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDynamicCommentsModel.h"
#import "TCMyCommentsModel.h"

@protocol linkCommentReplyDelegate <NSObject>
@required

- (void)LinkUserInfoReplyContent:(NSInteger)expert_id role_type:(NSInteger)role_type role_type_ed:(NSInteger)role_type_ed;      //个人信息

- (void)lookAtTheOriginalDynamic;

@end
@interface TCMaxDynamicTableViewCell : UITableViewCell

@property (nonatomic,weak) id <linkCommentReplyDelegate> delegate;

- (void)cellMaxDynamicDict:(NSDictionary *)dict;

+ (CGFloat)tableView:(UITableView *)tableView rowMaxDynamicForObject:(id)object;

@end
