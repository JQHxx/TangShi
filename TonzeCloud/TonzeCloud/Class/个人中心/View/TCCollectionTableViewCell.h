//
//  TCCollectionTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/3/13.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsFavoriteModel.h"

@interface TCCollectionTableViewCell : UITableViewCell

- (void)initWithShopCollectionModel:(GoodsFavoriteModel *)model;
@end
