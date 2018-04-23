
//
//  TJYMenuDetailsRemarksCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuDetailsRemarksCell.h"

@implementation TJYMenuDetailsRemarksCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _remarksLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, kScreenWidth - 40, 1000)];
        _remarksLabel.font=kFontWithSize(14);
        _remarksLabel.textColor=[UIColor colorWithHexString:@"666666"];
        _remarksLabel.numberOfLines = 0;
        [self.contentView addSubview:_remarksLabel];
    }
    return self;
}


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    CGFloat statusLabelWidth = [UIScreen mainScreen].bounds.size.width - 40;
    // 字符串分类提供方法，计算字符串的高度
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:14]];
    return statusLabelSize.height;
}

- (void)cellInitWithData:(NSString *)str{
    CGSize textSize = [str boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 1000) withTextFont:kFontWithSize(14)];
    _remarksLabel.frame = CGRectMake(20, 8, kScreenWidth - 40, textSize.height);
    _remarksLabel.text = str;
}
@end
