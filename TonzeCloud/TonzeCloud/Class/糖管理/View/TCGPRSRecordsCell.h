//
//  TCGPRSRecordsCell.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/11/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGPRSRecordsModel.h"

@interface TCGPRSRecordsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *bloodSugarLevelsLab;

@property (weak, nonatomic) IBOutlet UILabel *timeLab;

- (void)cellDisplayWithRecord:(TCGPRSRecordsModel *)model;

@end
