//
//  TCHealthTestCollectionViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCHealthTestCollectionViewCell : UICollectionViewCell

/// 评估图标
@property (nonatomic ,strong) UIImageView *titleImg;
/// 评估标题
@property (nonatomic ,strong) UILabel *titleLabel;
/// 评估内容
@property (nonatomic ,strong) NSString *content;
@end
