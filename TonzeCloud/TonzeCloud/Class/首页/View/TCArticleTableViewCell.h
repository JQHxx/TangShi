//
//  TCArticleTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/9/4.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCArticleModel.h"

@interface TCArticleTableViewCell : UITableViewCell

-(void)cellDisplayWithModel:(TCArticleModel *)articleModel searchText:(NSString *)searchtext;

@end
