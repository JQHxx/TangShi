//
//  NewsTableViewCell.h
//  TangShiService
//
//  Created by vision on 17/7/10.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TCSystemNewsModel.h"


@interface NewsTableViewCell : UITableViewCell

@property (nonatomic,strong)TCSystemNewsModel  *model;

+(CGFloat)getCellHeightWithNews:(TCSystemNewsModel *)model;

@end
