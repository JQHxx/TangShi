//
//  TCReleaseDynamicCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCReleaseDynamicCell : UICollectionViewCell


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;


- (UIView *)snapshotView;

@end
