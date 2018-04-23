//
//  TCDiseaseTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDiseaseTableViewCell.h"
#import "TCLaborModel.h"

@interface TCDiseaseTableViewCell (){
    UILabel    *titleLabel;
    UIButton   *selectButton;
}

@end
@implementation TCDiseaseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth/3*2, 20)];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        
        selectButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, (44-25)/2, 25, 25)];
        [selectButton setImage:[UIImage imageNamed:@"ic_pub_choose_nor"] forState:UIControlStateNormal];
        [selectButton setImage:[UIImage imageNamed:@"ic_pub_choose_sel"] forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
    }
    return self;
}
-(void)cellDiseasenameWithLabor:(NSDictionary *)dict{
    titleLabel.text=[dict objectForKey:@"title"];
    NSString *imageSelted =[dict objectForKey:@"image"];
    [selectButton setImage:[UIImage imageNamed:[imageSelted isEqualToString:@"1"]?@"ic_pub_choose_nor":@"ic_pub_choose_sel"] forState:UIControlStateNormal];
}
@end
