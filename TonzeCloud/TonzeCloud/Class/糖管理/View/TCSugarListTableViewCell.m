//
//  TCSugarListTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarListTableViewCell.h"

@interface TCSugarListTableViewCell (){
    UIImageView  *imgView;
    UILabel      *timeLbl;
    UILabel      *valueLbl;
}

@end

@implementation TCSugarListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat cellWidth=kScreenWidth-60;
        CGFloat labWidth=(cellWidth-50)/2.0;
        
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 30, 30)];
        [self.contentView addSubview:imgView];
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, 10, labWidth, 22)];
        timeLbl.textAlignment=NSTextAlignmentCenter;
        timeLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:timeLbl];
        
        valueLbl=[[UILabel alloc] initWithFrame:CGRectMake(timeLbl.right, 10, labWidth, 22)];
        valueLbl.textAlignment=NSTextAlignmentCenter;
        valueLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:valueLbl];
        
    }
    return self;
}

-(void)listCellDisplayWithModel:(TCSugarModel *)model{
    imgView.image=[UIImage imageNamed:[model.way integerValue]==1?@"ic_n_tang_luru":@"ic_n_tang_shebei"];
    
    timeLbl.text= [[TCHelper sharedTCHelper] timeWithTimeIntervalString:model.measurement_time format:@"HH:mm"];
    
    NSString *period=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:model.time_slot];
    double value=[model.glucose doubleValue];
    valueLbl.textColor=[[TCHelper sharedTCHelper] getTextColorWithSugarValue:value period:period];
    valueLbl.text=[NSString stringWithFormat:@"%.1f",value];
}


@end
