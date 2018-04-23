//
//  TCMyPraiseTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyPraiseModel.h"
@protocol TCMyPraiseDelegate <NSObject>
@required

- (void)myPraiseUserInfoContent:(NSInteger)expert_id role_type:(NSInteger)role_type;      //个人信息

- (void)myPraiseContent:(TCMyPraiseModel *)model;              //查看动态

- (void)myPraiseLinkSeleted:(NSInteger)user_id role_type:(NSInteger)role_type;              //点击选中区域

- (void)myPraiseLinkMoreText:(TCMyPraiseModel *)model; //查看动态

@end
@interface TCMyPraiseTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCMyPraiseDelegate> delegate;

- (void)cellMyPraiseModel:(TCMyPraiseModel *)model type:(NSInteger)type;

+ (CGFloat)tableView:(UITableView *)tableView rowPraiseForObject:(id)object;

@end
