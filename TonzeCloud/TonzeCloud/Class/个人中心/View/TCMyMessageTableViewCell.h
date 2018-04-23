//
//  TCMyMessageTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/7/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMyMessageModel.h"

@protocol TCMyMessageDelegate <NSObject>
@required
- (void)MyMessageIndex:(NSInteger)Index apply_family_id:(NSInteger)family_id;
@end
@interface TCMyMessageTableViewCell : UITableViewCell

@property (nonatomic,weak) id <TCMyMessageDelegate> delegate;

- (void)cellMyMessageModel:(TCMyMessageModel *)model;
@end
