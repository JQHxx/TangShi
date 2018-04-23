//
//  TCInvitationRecordTableViewCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInvitationRecordTableViewCell.h"

@interface TCInvitationRecordTableViewCell (){

    UILabel *contentLabel;
    UILabel *timeLabel;
    UIImageView *oneImgView;
    UIImageView *twoImgView;
    UIImageView *threeImgView;
    UIView      *oneView;
    UIView      *twoView;
    UIView      *threeView;
    
    UILabel     *porpmtLabel;
}
@end

@implementation TCInvitationRecordTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(18, 10, 5, 15)];
        headView.backgroundColor = kbgBtnColor;
        [self.contentView addSubview:headView];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(headView.right+5, headView.top+2, kScreenWidth-headView.right, 15)];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        [self.contentView addSubview:contentLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabel.left, contentLabel.bottom+6, contentLabel.width, 15)];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor colorWithHexString:@"0x939393"];
        [self.contentView addSubview:timeLabel];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(headView.left, timeLabel.bottom+10, kScreenWidth-headView.left, 1)];
        line.backgroundColor = kLineColor;
        [self.contentView addSubview:line];
        
        oneView = [[UIView alloc] initWithFrame:CGRectMake(65+30, line.bottom+24+14, (kScreenWidth/2-110)/2, 2)];
        oneView.backgroundColor = kbgBtnColor;
        [self.contentView addSubview:oneView];
        
        twoView = [[UIView alloc] initWithFrame:CGRectMake(oneView.right, oneView.top, (kScreenWidth/2-110)/2, 2)];
        twoView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self.contentView addSubview:twoView];
        
        threeView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2+15, oneView.top, kScreenWidth/2-110, 2)];
        threeView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self.contentView addSubview:threeView];
        
        for (int i=0; i<3; i++) {
            if (i==0) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i==2?kScreenWidth-120:40+i*(kScreenWidth/2-80), line.bottom+24+30+15, 80, 15)];
                titleLabel.font = [UIFont systemFontOfSize:15];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
                titleLabel.text = @"填手机号";
                [self.contentView addSubview:titleLabel];

                oneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(65, line.bottom+24, 30, 30)];
                oneImgView.image = [UIImage imageNamed:@"pub_ic_invite_finish"];
                [self.contentView addSubview:oneImgView];
            } else if(i==1){
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i==2?kScreenWidth-120:40+i*(kScreenWidth/2-80), line.bottom+24+30+15, 80, 15)];
                titleLabel.font = [UIFont systemFontOfSize:15];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
                titleLabel.text = @"下载并注册";
                [self.contentView addSubview:titleLabel];

                twoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-30)/2, line.bottom+24, 30, 30)];
                twoImgView.image = [UIImage imageNamed:@"pub_ic_invite_02"];
                [self.contentView addSubview:twoImgView];
            }else{
                porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(i==2?kScreenWidth-120:40+i*(kScreenWidth/2-80), line.bottom+24+30+15, 80, 15)];
                porpmtLabel.font = [UIFont systemFontOfSize:15];
                porpmtLabel.textAlignment = NSTextAlignmentCenter;
                porpmtLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
                porpmtLabel.text = @"获得奖励";
                [self.contentView addSubview:porpmtLabel];

                threeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-95, line.bottom+24, 30, 30)];
                threeImgView.image = [UIImage imageNamed:@"pub_ic_invite_03"];
                [self.contentView addSubview:threeImgView];
            }
        }

        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 161, kScreenWidth, 10)];
        bgView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:bgView];
    }
    return self;
}
- (void)cellInvitationRecordModel:(TCInvitationRecordModel *)model{
    contentLabel.text = model.invited_mobile;
    timeLabel.text = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.add_time format:@"yyyy-MM-dd HH:mm"];
    if (model.status==1) {
        twoImgView.image = [UIImage imageNamed:@"pub_ic_invite_02"];
        threeImgView.image = [UIImage imageNamed:@"pub_ic_invite_03"];
        twoView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        threeView.backgroundColor =  [UIColor colorWithHexString:@"0xe5e5e5"];
        porpmtLabel.text = @"获得奖励";
        porpmtLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
    }else if (model.status==3){
        twoImgView.image = [UIImage imageNamed:@"pub_ic_invite_finish"];
        threeImgView.image = [UIImage imageNamed:@"pub_ic_invite_out"];
        porpmtLabel.text = @"奖励达月限";
        porpmtLabel.textColor =[UIColor redColor];
        twoView.backgroundColor =kbgBtnColor;
        threeView.backgroundColor =  kbgBtnColor;
    } else {
        twoImgView.image = [UIImage imageNamed:@"pub_ic_invite_finish"];
        threeImgView.image = [UIImage imageNamed:@"pub_ic_invite_finish"];
        porpmtLabel.text = @"获得奖励";
        porpmtLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        twoView.backgroundColor =kbgBtnColor;
        threeView.backgroundColor =  kbgBtnColor;
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
