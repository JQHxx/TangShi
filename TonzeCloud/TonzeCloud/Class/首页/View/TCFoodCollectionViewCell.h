//
//  TCFoodCollectionViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFoodClassModel.h"

@interface TCFoodCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImage;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
-(void)cellDisplayWithDict:(TCFoodClassModel *)classModel;

@end
