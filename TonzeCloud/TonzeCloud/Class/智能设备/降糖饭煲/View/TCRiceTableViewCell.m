//
//  TCRiceTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/8/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRiceTableViewCell.h"

@interface TCRiceTableViewCell (){
    UIImageView  *imgView;
    UILabel      *riceNameLbl;
    UILabel      *percentLbl;
    UILabel      *descLbl;
    UIImageView  *checkImageView;
}

@end

@implementation TCRiceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 50, 50)];
        [self.contentView addSubview:imgView];
        
        riceNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, 15, 150, 30)];
        riceNameLbl.textColor=[UIColor blackColor];
        riceNameLbl.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:riceNameLbl];
        
        percentLbl=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, riceNameLbl.bottom, 150, 20)];
        percentLbl.textColor=[UIColor lightGrayColor];
        percentLbl.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:percentLbl];
        
        descLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, 30, 60, 25)];
        descLbl.textColor=[UIColor colorWithHexString:@"f39800"];
        descLbl.text=@"上次烹饪";
        descLbl.textAlignment=NSTextAlignmentRight;
        descLbl.font=[UIFont systemFontOfSize:13];
        [self.contentView addSubview:descLbl];
        descLbl.hidden=YES;
        
        checkImageView=[[UIImageView alloc] initWithFrame:CGRectMake(descLbl.right+5, 30, 20, 20)];
        checkImageView.image=[UIImage imageNamed:@"pub_ic_lite_right"];
        [self.contentView addSubview:checkImageView];
        checkImageView.hidden=YES;
    }
    return self;
}


-(void)setRiceModel:(TCRiceModel *)riceModel{
    imgView.image=[UIImage imageNamed:riceModel.riceImage];
    riceNameLbl.text=riceModel.riceName;
    percentLbl.text=[NSString stringWithFormat:@"降糖比约%li%%",(long)[riceModel.lowSugarPercent integerValue]];
    
    descLbl.hidden=!riceModel.isSelected;
    checkImageView.hidden=!riceModel.isSelected;
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
