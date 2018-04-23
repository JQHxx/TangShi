//
//  TCRespondDynamicTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/10.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyCommentsModel.h"
@protocol TCRespondDynamicDelegate <NSObject>
@required
- (void)respondDynamicContentModel:(TCMyCommentsModel *)model;//个人信息

- (void)respondDynamicDetailContentModel:(TCMyCommentsModel *)model;//查看动态

- (void)didDespondUserContent:(NSInteger)news_id role_type:(NSInteger)role_type;      //点击回复／被回复人

- (void)linkMoreModel:(TCMyCommentsModel *)model;  //点击其他区域

@end
@interface TCRespondDynamicTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCRespondDynamicDelegate> delegate;

- (void)cellRespondModel:(TCMyCommentsModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView rowrespondHeightForObject:(id)object;

+ (CGFloat)tableView:(UITableView *)tableView rowDetailHeightForObject:(id)object array:(NSArray *)arr;
@end
