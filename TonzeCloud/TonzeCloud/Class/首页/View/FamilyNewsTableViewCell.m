//
//  FamilyNewsTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "FamilyNewsTableViewCell.h"

@interface FamilyNewsTableViewCell (){
    UIImageView      *headImageView;
    UILabel          *nickNameLbl;
    UIImageView      *sexImageView;
    UILabel          *contentLbl;
    UILabel          *timeLbl;
    UILabel          *badgeLbl;
    
}

@end


@implementation FamilyNewsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        headImageView.layer.cornerRadius=30;
        headImageView.backgroundColor=[UIColor lightGrayColor];
        [self.contentView addSubview:headImageView];
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        timeLbl.textColor=[UIColor lightGrayColor];
        timeLbl.font=[UIFont systemFontOfSize:12];
        timeLbl.textAlignment=NSTextAlignmentRight;
        NSString *contentStr=@"2017-04-19 11:00";
        CGFloat w=[contentStr boundingRectWithSize:CGSizeMake(kScreenWidth-60,25) withTextFont:timeLbl.font].width;
        timeLbl.frame=CGRectMake(kScreenWidth-w-15, 5, w+10, 25);
        [self.contentView addSubview:timeLbl];
        
        nickNameLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        nickNameLbl.textColor=[UIColor blackColor];
        nickNameLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:nickNameLbl];
        
        sexImageView=[[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:sexImageView];
        
        contentLbl=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, 35, kScreenWidth-headImageView.right-40, 20)];
        contentLbl.textColor=[UIColor lightGrayColor];
        contentLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:contentLbl];
        
        
        
        badgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-15, timeLbl.bottom+5, 8, 8)];
        badgeLbl.layer.cornerRadius=4;
        badgeLbl.clipsToBounds=YES;
        badgeLbl.backgroundColor=[UIColor redColor];
        [self.contentView addSubview:badgeLbl];
        badgeLbl.hidden=YES;
    }
    return self;
}


-(void)setModel:(TCFamilyBloodModel *)model{
    _model=model;
    NSDictionary *familyInfo=model.family_info;
    TCFamilyUserModel *userModel=[[TCFamilyUserModel alloc] init];
    [userModel setValues:familyInfo];
    
    [headImageView sd_setImageWithURL:[NSURL URLWithString:userModel.image_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    timeLbl.text=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measurement_time format:@"yyyy-MM-dd HH:mm"];
    
    nickNameLbl.text=kIsEmptyString(userModel.call)?userModel.nick_name:userModel.call;
    CGFloat nameW=[nickNameLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-headImageView.right-timeLbl.width-50, 30) withTextFont:nickNameLbl.font].width;
    nickNameLbl.frame=CGRectMake(headImageView.right+10, 5, nameW, 30);
    
    sexImageView.frame=CGRectMake(nickNameLbl.right+5, 5, 30, 30);
    NSString *imgName=userModel.sex==1?@"ic_m_male":@"ic_m_famale";
    sexImageView.image=[UIImage imageNamed:imgName];
    
    UIColor *valueColor=[self getSugarBloodValueColorWithStatus:model.status];
    NSString *statusStr=[self getStatusResultWthStatus:model.status];
    NSString *valueStr=[NSString stringWithFormat:@"%.1f",[model.glucose floatValue]];
    NSString *timeSlot=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:model.time_slot];
    NSString *tempStr=[NSString stringWithFormat:@"%@测量：%.1fmmol/L（%@）",timeSlot,[valueStr doubleValue],statusStr];
    NSMutableAttributedString *attributeAtr=[[NSMutableAttributedString alloc] initWithString:tempStr];
    [attributeAtr addAttribute:NSForegroundColorAttributeName value:valueColor range:NSMakeRange(6,valueStr.length)];
    [attributeAtr addAttribute:NSForegroundColorAttributeName value:valueColor range:NSMakeRange(tempStr.length-3, 2)];
    contentLbl.attributedText=attributeAtr;
    
    badgeLbl.hidden=[model.is_read boolValue];
}


-(UIColor *)getSugarBloodValueColorWithStatus:(NSInteger )status{
    if (status==2) {
        return [UIColor colorWithHexString:@"#fa6f6e"];
    }else if (status==3){
        return [UIColor colorWithHexString:@"#ffd03e"];
    }else{
        return [UIColor colorWithHexString:@"#37deba"];
    }
}


-(NSString *)getStatusResultWthStatus:(NSInteger)status{
    if (status==2) {
        return @"偏高";
    }else if (status==3){
        return @"偏低";
    }else{
        return @"正常";
    }
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
