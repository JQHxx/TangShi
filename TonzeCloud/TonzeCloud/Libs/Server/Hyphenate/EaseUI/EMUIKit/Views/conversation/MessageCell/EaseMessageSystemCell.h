//
//  EaseMessageSystemCell.h
//  TonzeCloud
//
//  Created by vision on 17/11/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseMessageSystemCell : UITableViewCell

@property (nonatomic, copy )NSString  *cellTitle;

+(CGFloat)getMessageSystemCellHeightWithText:(NSString *)text;

@end
