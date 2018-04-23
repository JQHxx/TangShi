//
//  TCMessageTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDeviceMessageModel.h"


@interface TCMessageTableViewCell : UITableViewCell

-(void)cellDisplayWithMessage:(TCDeviceMessageModel *)message type:(MessageType)type;

@end
