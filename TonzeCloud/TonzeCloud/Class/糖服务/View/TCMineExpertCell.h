//
//  TCMineExpertCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMineExpertModel.h"
@protocol TCMineExpertDelegate <NSObject>
@required
- (void)returnIndex:(NSInteger)index;
@end
@interface TCMineExpertCell : UITableViewCell
-(void)cellDisplayWithDict:(TCMineExpertModel *)expertModel Index:(NSInteger)index;

@property (nonatomic,weak) id <TCMineExpertDelegate> delegate;

@end
