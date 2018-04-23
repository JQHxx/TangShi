//
//  TCReplyContentTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMaxDynamicModel.h"

@protocol linkReplyContentDelegate <NSObject>
@required

- (void)linkReplyContent:(NSInteger)news_id role_type:(NSInteger)role_type;          //点击被标记区域

@end
@interface TCReplyContentTableViewCell : UITableViewCell

@property (nonatomic,weak) id <linkReplyContentDelegate> delegate;

- (void)cellReplyContentModel:(TCMaxDynamicModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView rowReplyContentForObject:(id)object;

@end
