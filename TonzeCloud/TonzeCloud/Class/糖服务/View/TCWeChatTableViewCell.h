//
//  TCWeChatTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/3/27.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMessageModel.h"


@interface TCWeChatTableViewCell : UITableViewCell

-(void)wechatCellDisplayWithMessage:(TCMessageModel *)message;

+(CGFloat)wechatCellRowHeightWithMessage:(TCMessageModel *)message;

@end
