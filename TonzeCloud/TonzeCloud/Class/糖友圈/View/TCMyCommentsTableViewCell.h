//
//  TCMyCommentsTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyCommentsModel.h"
@protocol TCMyCommentsDelegate <NSObject>
@required
- (void)myCommentsContentModel:(TCMyCommentsModel *)model; //个人信息

- (void)mydynamicDetailModel:(TCMyCommentsModel *)model;

- (void)myLinkMoreModel:(TCMyCommentsModel *)model;     //查看更多区域

- (void)myLinkSeleted:(TCMyCommentsModel *)model;  //查看选择区域

@end
@interface TCMyCommentsTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCMyCommentsDelegate> delegate;

- (void)cellMyCommentsModel:(TCMyCommentsModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView rowCommentsHeightForObject:(id)object;

@end
