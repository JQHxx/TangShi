//
//  TCDynamicImageCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCDynamicImageCellDelegate <NSObject>

- (void)didSelectImgeAction:(NSInteger)number indexRow:(NSInteger)indexRow;

- (void)reloadTableViewWithRemovePhotoArrayIndex:(NSInteger )index;

@end

@interface TCDynamicImageCell : UITableViewCell
///
@property (nonatomic, weak) id<TCDynamicImageCellDelegate>delegate;

- (void)cellWithImageArray:(NSMutableArray *)imageArray selectedAssets:(NSMutableArray *)selectedAssets;


@end
