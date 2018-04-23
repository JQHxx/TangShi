//
//  TCShareTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCShareTableViewCell.h"

@interface TCShareTableViewCell (){
    UILabel       *nameLbl;
    UILabel       *timeLbl;
    
}

@end

@implementation TCShareTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-80, 30)];
        nameLbl.textColor=[UIColor blackColor];
        nameLbl.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLbl];
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, nameLbl.bottom, nameLbl.width, 30)];
        timeLbl.textColor=[UIColor lightGrayColor];
        timeLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:timeLbl];
        
    }
    return self;
}

-(void)setShareModel:(TCShareModel *)shareModel{
    nameLbl.text=shareModel.user_nickname;
    NSString *timespStr=[NSString stringWithFormat:@"%@",shareModel.create_date];
    timeLbl.text=[[TCHelper sharedTCHelper] timeSPToTime:timespStr];
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
