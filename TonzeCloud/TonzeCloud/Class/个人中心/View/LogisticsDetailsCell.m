//
//  LogisticsDetailsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "LogisticsDetailsCell.h"

@interface LogisticsDetailsCell ()

@end

@implementation LogisticsDetailsCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *tagIcon = [[UILabel alloc]initWithFrame:CGRectMake(30 + 4, 3, 8, 8)];
        tagIcon.backgroundColor = UIColorFromRGB(0xc5c5c5);
        tagIcon.layer.cornerRadius = 4;
        tagIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:tagIcon];
        
        _orderInfoLab = [[UILabel alloc]initWithFrame:CGRectMake(tagIcon.right + 16, tagIcon.top - 5, kScreenWidth - 75, 20)];
        _orderInfoLab.numberOfLines = 0;
        _orderInfoLab.textColor = UIColorFromRGB(0x999999);
        _orderInfoLab.font = kFontWithSize(13);
        [self.contentView addSubview:_orderInfoLab];
        
        _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(_orderInfoLab.left, _orderInfoLab.bottom , _orderInfoLab.width, 20)];
        _timeLab.font = kFontWithSize(13);
        _timeLab.textColor = UIColorFromRGB(0x999999);
        [self.contentView addSubview:_timeLab];
        
        _lens = [[CALayer alloc]init];
        _lens.frame = CGRectMake(37,tagIcon.bottom, 0.5, 50);
        _lens.backgroundColor = UIColorFromRGB(0xc5c5c5).CGColor;
        [self.contentView.layer addSublayer:_lens];
        
        _statusImg = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, 16, 16)];
        _statusImg.image = [UIImage imageNamed:@"pd_ic_point_on"];
        [self.contentView addSubview:_statusImg];
    }
    return self;
}
- (void)cellWithTrajectoryModel:(TrajectoryModel *)model{

    CGSize size = [model.AcceptStation boundingRectWithSize:CGSizeMake(kScreenWidth - 71 , 100) withTextFont:kFontWithSize(13)];
    _orderInfoLab.frame = CGRectMake(56 , 0 , kScreenWidth - 45 - 15, size.height > 19 ? size.height : 15);
    
    _lens.frame = CGRectMake(37.6, 11 , 0.6, size.height > 19 ?  35 + size.height : 50);
    
    _orderInfoLab.text = model.AcceptStation;

    _timeLab.text = [[TCHelper sharedTCHelper]timeWithTimeIntervalString:model.AcceptTime format:@"yyyy-MM-dd HH:mm:ss"];
    _timeLab.frame = CGRectMake(_orderInfoLab.left, _orderInfoLab.bottom + 2, _orderInfoLab.width, 20);
}

+(CGFloat)cellHeightForRowAtIndexPath:(NSString *)str{
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(kScreenWidth - 71 , 100) withTextFont:kFontWithSize(13)];
    CGFloat higth = size.height > 19 ? size.height : 15;
    return  35 + higth;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
