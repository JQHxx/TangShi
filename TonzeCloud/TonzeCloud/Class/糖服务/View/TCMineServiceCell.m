 //
//  TCMineServiceCell.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMineServiceCell.h"

@interface TCMineServiceCell (){
    UILabel         *timeLabel;
    UIImageView     *coverImageView;
    UILabel         *schemeNameLabel;
    UILabel         *payMoneyLabel;
    
    UIImageView     *headImgView;
    UILabel         *expertNameLabel;
    UILabel         *positionNameLabel;
    
    NSMutableArray  *scoreArray;
    TCMineServiceModel  *minemodel;
    UIButton            *chatBtn;
}

@end
@implementation TCMineServiceCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *bgLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        bgLabel.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:bgLabel];
        
        chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 124)];
        [chatBtn addTarget:self action:@selector(chatButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:chatBtn];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,bgLabel.bottom+7, kScreenWidth-30, 20)];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLabel];
        
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, timeLabel.bottom+7, kScreenWidth, 1)];
        line1.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:line1];
        
        coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, line1.bottom+10, 60, 60)];
        [self.contentView addSubview:coverImageView];
        
        schemeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(coverImageView.right+10, coverImageView.top, kScreenWidth-100, 20)];
        schemeNameLabel.textColor = [UIColor grayColor];
        schemeNameLabel.font = [UIFont systemFontOfSize:16];
        schemeNameLabel.numberOfLines=0;
        [self.contentView addSubview:schemeNameLabel];
        
        payMoneyLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-105, schemeNameLabel.top, 90, 20)];
        payMoneyLabel.textAlignment=NSTextAlignmentRight;
        payMoneyLabel.textColor=kRGBColor(254, 156, 40);
        payMoneyLabel.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:payMoneyLabel];
        
        self.evaluateServiceBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-75, payMoneyLabel.bottom+10, 60, 30)];
        [self.evaluateServiceBtn setTitle:@"评价" forState:UIControlStateNormal];
        [self.evaluateServiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.evaluateServiceBtn.backgroundColor=kSystemColor;
        self.evaluateServiceBtn.layer.cornerRadius=5;
        self.evaluateServiceBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        self.evaluateServiceBtn.clipsToBounds=YES;
        [self.contentView addSubview:self.evaluateServiceBtn];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [scoreArray addObject:scoreImage];
            [self.contentView addSubview:scoreImage];
        }
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(15,coverImageView.bottom+10, kScreenWidth-30, 1)];
        line2.backgroundColor = kbgBtnColor;
        [self.contentView addSubview:line2];
        
        headImgView=[[UIImageView alloc] initWithFrame:CGRectMake(15, line2.bottom+7, 30, 30)];
        headImgView.layer.cornerRadius=15;
        headImgView.clipsToBounds=YES;
        [self.contentView addSubview:headImgView];
        
        expertNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImgView.right+10, line2.bottom+7, 100, 30)];
        expertNameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:expertNameLabel];
        
        positionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(expertNameLabel.right+10, expertNameLabel.top, 100, 30)];
        positionNameLabel.textColor = [UIColor lightGrayColor];
        positionNameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:positionNameLabel];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, positionNameLabel.top+5, 20, 20)];
        image.image = [UIImage imageNamed:@"ic_pub_arrow_green"];
        [self.contentView addSubview:image];
    }
    return self;
}

#pragma mark -- Event response
- (void)chatButton:(UIButton *)button{

    if ([_serviceDelegate respondsToSelector:@selector(chatDeledalegate:)]) {
        [_serviceDelegate chatDeledalegate:button.tag];
    }

}
-(void)cellDisplayWithDict:(TCMineServiceModel *)myServiceModel index:(NSInteger)index{
    chatBtn.tag = index;
    
    NSString *beginTime = [[TCHelper sharedTCHelper] timeWithTimeIntervalString:myServiceModel.start_time format:@"yyyy-MM-dd HH:mm"];
    NSString *endTime =  [[TCHelper sharedTCHelper] timeWithTimeIntervalString:myServiceModel.end_time format:@"yyyy-MM-dd HH:mm"];
    timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@",beginTime,endTime];
    
    if (myServiceModel.type==2) {
        coverImageView.image=[UIImage imageNamed:@"ic_plan"];
    } else {
        coverImageView.image=[UIImage imageNamed:@"ic_image_text"];
    }
    schemeNameLabel.text = myServiceModel.scheme_name;
    
    double price=[myServiceModel.pay_money doubleValue];
    payMoneyLabel.text=[NSString stringWithFormat:@"¥%.2f",price];
    CGFloat payW=[payMoneyLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:payMoneyLabel.font].width;
    payMoneyLabel.frame=CGRectMake(kScreenWidth-payW-15, coverImageView.top, payW, 20);
    
    CGFloat schemeH=[schemeNameLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-coverImageView.right-100, 60) withTextFont:schemeNameLabel.font].height;
    schemeNameLabel.frame=CGRectMake(coverImageView.right+10, coverImageView.top+5, kScreenWidth-coverImageView.right-100, schemeH);
    
    BOOL isCommented=[myServiceModel.is_commented boolValue];
    
    if (myServiceModel.service_status==2) {
        if (isCommented) {
            self.evaluateServiceBtn.hidden=YES;
            //加星级
            CGSize scoreSize = CGSizeMake(15, 15);
            double scoreNum = [myServiceModel.comment_score doubleValue];
            NSInteger oneScroe=(NSInteger)scoreNum;
            NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
            for (int i = 0; i<scoreArray.count; i++) {
                UIImageView *scoreImage = scoreArray[i];
                scoreImage.hidden=NO;
                [scoreImage setFrame:CGRectMake(kScreenWidth-5*scoreSize.width-10+scoreSize.width*i, payMoneyLabel.bottom+10, scoreSize.width, scoreSize.height)];
                if (i<= num-1) {
                    if ((i==num-1)&&scoreNum>oneScroe) {
                        scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
                    }
                }else{
                    scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
                }
            }
        }else{
            self.evaluateServiceBtn.hidden=NO;
            for (int i = 0; i<scoreArray.count; i++) {
                UIImageView *scoreImage = scoreArray[i];
                scoreImage.hidden=YES;
            }
        }
    } else {
        self.evaluateServiceBtn.hidden=YES;
        //加星级
        CGSize scoreSize = CGSizeMake(15, 15);
        double scoreNum = [myServiceModel.comment_score doubleValue];
        NSInteger oneScroe=(NSInteger)scoreNum;
        NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
        for (int i = 0; i<scoreArray.count; i++) {
            UIImageView *scoreImage = scoreArray[i];
            scoreImage.hidden=YES;
            [scoreImage setFrame:CGRectMake(kScreenWidth-5*scoreSize.width-10+scoreSize.width*i, payMoneyLabel.bottom+10, scoreSize.width, scoreSize.height)];
            if (i<= num-1) {
                if ((i==num-1)&&scoreNum>oneScroe) {
                    scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
                }
            }else{
                scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
            }
        }
    }
    
    [headImgView sd_setImageWithURL:[NSURL URLWithString:myServiceModel.head_portrait] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    expertNameLabel.text = myServiceModel.expert_name;
    CGFloat nameW=[expertNameLabel.text boundingRectWithSize:CGSizeMake(100, 30) withTextFont:expertNameLabel.font].width;
    expertNameLabel.frame=CGRectMake(headImgView.right+10, coverImageView.bottom+17, nameW, 30);
    
    positionNameLabel.text = myServiceModel.positional_titles;
    CGFloat positionW=[positionNameLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-nameW-60, 30) withTextFont:positionNameLabel.font].width;
    positionNameLabel.frame=CGRectMake(expertNameLabel.right+10, expertNameLabel.top, positionW, 30);

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
