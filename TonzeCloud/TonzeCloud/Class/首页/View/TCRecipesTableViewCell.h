//
//  TCRecipesTableViewCell.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCRecipeModel.h"

@interface TCRecipesTableViewCell : UITableViewCell

-(void)cellRealodActionWithRecipe:(TCRecipeModel *)recipe;

@end
