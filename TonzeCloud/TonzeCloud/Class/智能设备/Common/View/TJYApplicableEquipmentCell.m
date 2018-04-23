
//
//  TJYApplicableEquipmentCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//   菜谱详情 -- 适配设备

#import "TJYApplicableEquipmentCell.h"


@implementation TJYApplicableEquipmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _equipmentImg =[[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
        [self.contentView addSubview:_equipmentImg];
        
        _equipmentNameLab=[[UILabel alloc] initWithFrame:CGRectMake(_equipmentImg.right + 10, _equipmentImg.top, kScreenWidth-_equipmentImg.right, 20)];
        _equipmentNameLab.font=kFontWithSize(18);
        _equipmentNameLab.textColor=[UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_equipmentNameLab];
        
        _cookingTimeLab=[[UILabel alloc] initWithFrame:CGRectMake(_equipmentNameLab.left,_equipmentNameLab.bottom + 12 , 200, 15)];
        _cookingTimeLab.font=kFontWithSize(13);
        _cookingTimeLab.textColor=[UIColor colorWithHexString:@"999999"];
        [self.contentView addSubview:_cookingTimeLab];
        
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(15,80 - 0.5, kScreenWidth - 15, 0.5)];
        lineView.backgroundColor=kLineColor;
        [self.contentView addSubview:lineView];
    }
    return self;
}

- (void)cellWithData:(TCEquipmentModel *)model{
    _equipmentImg.image =[UIImage imageNamed:@"img_h_jtfb"];
    _equipmentNameLab.text = model.equipment_name;
    _cookingTimeLab.text = [NSString stringWithFormat:@"烹饪时长：%ld分钟",(long)model.cook_equipment_time];
}

@end
