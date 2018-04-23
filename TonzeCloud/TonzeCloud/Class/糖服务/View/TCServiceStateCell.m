//
//  TCServiceStateCell.m
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceStateCell.h"

@interface TCServiceStateCell (){
    UILabel         *serviceTimeLabel;
    UIImageView     *serviceImageView;
    UILabel         *titleLabel;
    UILabel         *moneyLabel;
    
    NSMutableArray  *scoreArray;
}

@end



@implementation TCServiceStateCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor=[UIColor bgColor_Gray];
        
        UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        line1.backgroundColor=kLineColor;
        [self.contentView addSubview:line1];
        
        UIView *rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, 119)];
        rootView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:rootView];
        
        
        serviceTimeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-20, 30)];
        serviceTimeLabel.font=[UIFont systemFontOfSize:14];
        serviceTimeLabel.textColor=[UIColor lightGrayColor];
        [rootView addSubview:serviceTimeLabel];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(10, serviceTimeLabel.bottom+5, kScreenWidth-10, 1)];
        line.backgroundColor=kLineColor;
        [rootView addSubview:line];
        
        serviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, serviceTimeLabel.bottom+15, 60, 60)];
        [rootView addSubview:serviceImageView];
        
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(serviceImageView.right+10, serviceTimeLabel.bottom+20, kScreenWidth-serviceImageView.right-100, 20)];
        titleLabel.font=[UIFont systemFontOfSize:16];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.numberOfLines=0;
        [rootView addSubview:titleLabel];
        
        moneyLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, serviceTimeLabel.bottom+10, 80, 30)];
        moneyLabel.font=[UIFont systemFontOfSize:16];
        moneyLabel.textColor=kRGBColor(254, 156, 40);
        moneyLabel.textAlignment=NSTextAlignmentRight;
        [rootView addSubview:moneyLabel];
        
        self.evaluateBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-70, moneyLabel.bottom+10, 60, 30)];
        [self.evaluateBtn setTitle:@"评价" forState:UIControlStateNormal];
        [self.evaluateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.evaluateBtn.backgroundColor=kSystemColor;
        self.evaluateBtn.layer.cornerRadius=5;
        self.evaluateBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        self.evaluateBtn.clipsToBounds=YES;
        [rootView addSubview:self.evaluateBtn];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [scoreArray addObject:scoreImage];
            [rootView addSubview:scoreImage];
        }
        
        UILabel *verLine=[[UILabel alloc] initWithFrame:CGRectMake(0, 120, kScreenWidth, 1)];
        verLine.backgroundColor=kLineColor;
        [self.contentView addSubview:verLine];
        
    }
    return self;
}


-(void)setMyService:(TCMineServiceModel *)myService{
    _myService=myService;
    
    NSString *startTimeStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:myService.start_time format:@"yyyy-MM-dd HH:mm"];
    NSString *endTimeStr=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:myService.end_time format:@"yyyy-MM-dd HH:mm"];
    serviceTimeLabel.text=[NSString stringWithFormat:@"%@至%@",startTimeStr,endTimeStr];
    
    if (myService.type==2) {
        serviceImageView.image=[UIImage imageNamed:@"ic_plan"];
    } else {
        serviceImageView.image=[UIImage imageNamed:@"ic_image_text"];
    }
    titleLabel.text=myService.scheme_name;
    
    double value=[myService.pay_money doubleValue];
    moneyLabel.text=[NSString stringWithFormat:@"¥%.2f",value];
    
    CGFloat labW=[moneyLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:moneyLabel.font].width;
    moneyLabel.frame=CGRectMake(kScreenWidth-labW-10, serviceTimeLabel.bottom+10, labW, 30);
    
    CGFloat titleH=[titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-serviceImageView.right-100, 120) withTextFont:titleLabel.font].height;
    titleLabel.frame=CGRectMake(serviceImageView.right+10, serviceTimeLabel.bottom+20,kScreenWidth-serviceImageView.right-100 , titleH);
    
    BOOL isCommented=[myService.is_commented boolValue];
    if (myService.service_status==2) {
        if (isCommented) {
            self.evaluateBtn.hidden=YES;
            //加星级
            CGSize scoreSize = CGSizeMake(15, 15);
            double scoreNum = [myService.comment_score doubleValue];
            NSInteger oneScroe=(NSInteger)scoreNum;
            NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
            for (int i = 0; i<scoreArray.count; i++) {
                UIImageView *scoreImage = scoreArray[i];
                scoreImage.hidden=NO;
                [scoreImage setFrame:CGRectMake(kScreenWidth-5*scoreSize.width-10+scoreSize.width*i, moneyLabel.bottom+10, scoreSize.width, scoreSize.height)];
                if (i<= num-1) {
                    if ((i==num-1)&&scoreNum>oneScroe) {
                        scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
                    }
                }else{
                    scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
                }
            }
        }else{
            self.evaluateBtn.hidden=NO;
            for (int i = 0; i<scoreArray.count; i++) {
                UIImageView *scoreImage = scoreArray[i];
                scoreImage.hidden=YES;
            }
        }
    } else {
        self.evaluateBtn.hidden=YES;
        //加星级
        CGSize scoreSize = CGSizeMake(15, 15);
        double scoreNum = [myService.comment_score doubleValue];
        NSInteger oneScroe=(NSInteger)scoreNum;
        NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
        for (int i = 0; i<scoreArray.count; i++) {
            UIImageView *scoreImage = scoreArray[i];
            scoreImage.hidden=YES;
            [scoreImage setFrame:CGRectMake(kScreenWidth-5*scoreSize.width-10+scoreSize.width*i, moneyLabel.bottom+10, scoreSize.width, scoreSize.height)];
            if (i<= num-1) {
                if ((i==num-1)&&scoreNum>oneScroe) {
                    scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
                }
            }else{
                scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
            }
        }
    }
//
//    if (isCommented) {
//        self.evaluateBtn.hidden=YES;
//        //加星级
//        CGSize scoreSize = CGSizeMake(15, 15);
//        double scoreNum = [myService.comment_score doubleValue];
//        NSInteger oneScroe=(NSInteger)scoreNum;
//        NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
//        for (int i = 0; i<scoreArray.count; i++) {
//            UIImageView *scoreImage = scoreArray[i];
//            scoreImage.hidden=NO;
//            [scoreImage setFrame:CGRectMake(kScreenWidth-5*scoreSize.width-10+scoreSize.width*i, moneyLabel.bottom+10, scoreSize.width, scoreSize.height)];
//            if (i<= num-1) {
//                if ((i==num-1)&&scoreNum>oneScroe) {
//                    scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
//                }
//            }else{
//                scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
//            }
//        }
//    }else{
//        self.evaluateBtn.hidden=NO;
//        for (int i = 0; i<scoreArray.count; i++) {
//            UIImageView *scoreImage = scoreArray[i];
//            scoreImage.hidden=YES;
//        }
//    }
    
}

@end
