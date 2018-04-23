//
//  TCInstallTableViewCell.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCInstallTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel *textLabel1;
@property(nonatomic,strong)UILabel *textLabel2;

-(void)cellDisplayWithDict:(NSDictionary *)dict;

@end
