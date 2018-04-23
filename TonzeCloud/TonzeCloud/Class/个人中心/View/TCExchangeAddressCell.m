
//
//  ExchangeAddressCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TCExchangeAddressCell.h"

@implementation TCExchangeAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setExchangeAddressCellUI];
    }
    return self;
}
#pragma mark ====== Bulid UI =======

- (void)setExchangeAddressCellUI{
    
    UIImageView *locationIcon = [[UIImageView alloc]initWithFrame:CGRectMake(12, 14, 11, 14)];
    locationIcon.image = [UIImage imageNamed:@"address_location"];
    [self.contentView addSubview:locationIcon];
    
    _nameLab = [[UILabel alloc]initWithFrame:CGRectMake( locationIcon.right + 12, locationIcon.top, 180, 20)];
    _nameLab.font = kFontWithSize(14);
    _nameLab.textColor = UIColorFromRGB(0x313131);
    [self.contentView addSubview:_nameLab];
    
    _phoneNumberLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 115 , _nameLab.top, 100, 20)];
    _phoneNumberLab.textColor = UIColorFromRGB(0x313131);
    _phoneNumberLab.font = kFontWithSize(13);
    _phoneNumberLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_phoneNumberLab];
    
    _addressLab = [[UILabel alloc]initWithFrame: CGRectMake( 30, _nameLab.bottom + 5, kScreenWidth - 45, 20)];
    _addressLab.numberOfLines = 0;
    _addressLab.textAlignment = NSTextAlignmentLeft;
    _addressLab.font = kFontWithSize(12);
    _addressLab.textColor = UIColorFromRGB(0x959595);
    [self.contentView addSubview:_addressLab];
}
#pragma mark ====== set Data =======

- (void)setExchangeAddressWithModel:(TCExchangeRecordsDetailModel *)model{
    _nameLab.text = model.consignee_name;
    
    CGSize nameStrSize = [model.consignee_name boundingRectWithSize:CGSizeMake(200, 20) withTextFont:kFontWithSize(14)];
    _nameLab.frame = CGRectMake(30, 12, nameStrSize.width, 20);
    _phoneNumberLab.frame = CGRectMake( _nameLab.right + 20, _nameLab.top, 150, 20);
    _phoneNumberLab.text = model.consignee_phone;
    
    NSString *addStr = [NSString stringWithFormat:@"%@%@%@%@",model.consignee_pro,model.consignee_city,model.consignee_area,model.consignee_addr];
    CGSize addStrSize = [addStr boundingRectWithSize:CGSizeMake(kScreenWidth - 45, 50) withTextFont:kFontWithSize(12)];
    if (addStrSize.height > 10) {
        _addressLab.frame = CGRectMake( 30, _nameLab.bottom, kScreenWidth - 45, 40);
         _addressLab.text = [NSString stringWithFormat:@"地址：%@",kIsEmptyString(addStr) ? @"" : addStr];
    }else{
        _addressLab.frame = CGRectMake( 30, _nameLab.bottom + 5, kScreenWidth - 45, 20);
         _addressLab.text = [NSString stringWithFormat:@"地址：%@",kIsEmptyString(addStr) ? @"" : addStr];
    }
}
#pragma mark ====== 计算cell高度 =======

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    CGFloat statusLabelWidth = kScreenWidth - 45;
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:12]];
    return statusLabelSize.height;
}
@end
