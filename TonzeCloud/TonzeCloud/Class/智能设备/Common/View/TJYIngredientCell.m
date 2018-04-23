
//
//  TJYIngredientCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYIngredientCell.h"

@implementation TJYIngredientCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _ingredientNameLab = [[UILabel alloc] initWithFrame:CGRectMake(15,20/2 , 200, 20)];
        _ingredientNameLab.font=kFontWithSize(13);
        _ingredientNameLab.textColor=[UIColor colorWithHexString:@"313131"];
        [self.contentView addSubview:_ingredientNameLab];
        
        _ingredientWeightLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 165,20/2 , 150, 20)];
        _ingredientWeightLab.font=kFontWithSize(13);
        _ingredientWeightLab.textColor=[UIColor colorWithHexString:@"313131"];
        _ingredientWeightLab.textAlignment=NSTextAlignmentRight;
        [self.contentView addSubview:_ingredientWeightLab];
    }
    return self;
}

- (void)cellInitWithData:(TJYCookIngredientModel *)model{
    _ingredientNameLab.text = model.ingredient_name;
    _ingredientWeightLab.text = [NSString stringWithFormat:@"%ld克",(long)model.ingredient_weight];
}
@end
