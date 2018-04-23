//
//  TCFoodTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/3/2.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFoodTableViewCell.h"
#import "QLCoreTextManager.h"

@interface TCFoodTableViewCell (){
    TCFoodAddModel  *foodModel;
}

@end

@implementation TCFoodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setCellType:(NSInteger)cellType{
    _cellType=cellType;
}

-(void)cellDisplayWithFood:(TCFoodAddModel *)model  searchText:(NSString *)searchText{
    foodModel=model;
    
    [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    self.foodNameLabel.text=model.name;
    self.caloryLabel.text=[NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal];
    
    if (!kIsEmptyString(searchText)) {
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.name]];
        [QLCoreTextManager setAttributedValue:attString text:searchText font:[UIFont systemFontOfSize:15] color:[UIColor redColor]];
        self.foodNameLabel.attributedText = attString;
    }

    if (![model.isSelected boolValue]) {
        self.foodWeightLabel.hidden=YES;
        self.chooseBtn.hidden=YES;
    }else{
        self.foodWeightLabel.hidden=NO;
        self.chooseBtn.hidden=NO;
        self.foodWeightLabel.text=[NSString stringWithFormat:@"%@克",model.weight];
        if (_cellType==1) {
            [self.chooseBtn setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
        }
    }
}


- (IBAction)deleteFoodAction:(id)sender {
    if (_cellType==1) {
        if ([_cellDelegate respondsToSelector:@selector(foodTableViewCellDeleteFood:)]) {
            [_cellDelegate foodTableViewCellDeleteFood:foodModel];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
