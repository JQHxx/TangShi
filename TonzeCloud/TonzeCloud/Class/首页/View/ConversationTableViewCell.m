//
//  ConversationTableViewCell.m
//  TangShiService
//
//  Created by vision on 17/5/31.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "ConversationTableViewCell.h"
#import "TCMineServiceModel.h"
#import "TCSystemNewsModel.h"
#import "TCFamilyBloodModel.h"
#import "TCCommonNewsModel.h"

@interface ConversationTableViewCell (){
    UIImageView   *imgView;
    UILabel       *nameLbl;
    UILabel       *positionLbl;      //职称
    UILabel       *timeLbl;
    UILabel       *messageLbl;
    UILabel       *badgeLbl;
}

@end

@implementation ConversationTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        imgView.layer.cornerRadius=25;
        imgView.clipsToBounds=YES;
        [self.contentView addSubview:imgView];
        
        nameLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        nameLbl.font=[UIFont boldSystemFontOfSize:16];
        nameLbl.textColor=[UIColor blackColor];
        [self.contentView addSubview:nameLbl];
        
        positionLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        positionLbl.backgroundColor=[UIColor colorWithHexString:@"#d2fbeb"];
        positionLbl.textColor=[UIColor colorWithHexString:@"#22d688"];
        positionLbl.textAlignment=NSTextAlignmentCenter;
        positionLbl.font=[UIFont systemFontOfSize:13];
        positionLbl.layer.cornerRadius=8;
        positionLbl.clipsToBounds=YES;
        [self.contentView addSubview:positionLbl];
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        timeLbl.font=[UIFont systemFontOfSize:12];
        timeLbl.textAlignment=NSTextAlignmentRight;
        timeLbl.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:timeLbl];
        
        messageLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        messageLbl.font=[UIFont systemFontOfSize:14];
        messageLbl.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:messageLbl];
        
        badgeLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        badgeLbl.backgroundColor=[UIColor redColor];
        badgeLbl.textColor=[UIColor whiteColor];
        badgeLbl.textAlignment=NSTextAlignmentCenter;
        badgeLbl.font=[UIFont systemFontOfSize:10];
        [self.contentView addSubview:badgeLbl];
        badgeLbl.hidden=YES;
        
    }
    return self;
}



-(void)conversationCellDisplayWithModel:(id )model{
    if ([model isKindOfClass:[TCMineServiceModel class]]) {
        positionLbl.hidden=NO;
        
        TCMineServiceModel *myService=(TCMineServiceModel *)model;
        [imgView sd_setImageWithURL:[NSURL URLWithString:myService.lastMsgHeadPic] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
        nameLbl.text=myService.lastMsgUserName;
        positionLbl.text=myService.lastMsgLabel;
        timeLbl.text=myService.lastMsgTime;
        
        CGFloat timeW=[myService.lastMsgTime boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:timeLbl.font].width;
        timeLbl.frame=CGRectMake(kScreenWidth-timeW-10,10, timeW, 20);
        
        CGFloat nameW=[myService.expert_name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:nameLbl.font].width;
        if (kIsEmptyString(positionLbl.text)) {
            positionLbl.frame=CGRectZero;
            CGFloat totalW=imgView.right+10+nameW+10+timeW+10;
            if (totalW>kScreenWidth) {
                nameLbl.frame=CGRectMake(imgView.right+10, 5,kScreenWidth-imgView.right-10-5-timeW-10, 30);
            }else{
                nameLbl.frame=CGRectMake(imgView.right+10, 5, nameW, 30);
            }
        }else{
            CGFloat positionW=[positionLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:positionLbl.font].width;
            CGFloat totalW=imgView.right+10+nameW+10+positionW+10+timeW+10;
            if (totalW>kScreenWidth) {
                nameLbl.frame=CGRectMake(imgView.right+10, 5,kScreenWidth-imgView.right-10-5-positionW-10-timeW-10, 30);
                positionLbl.frame=CGRectMake(nameLbl.right+5,8, positionW+10, 24);
            }else{
                nameLbl.frame=CGRectMake(imgView.right+10, 5, nameW, 30);
                positionLbl.frame=CGRectMake(nameLbl.right+5, 8, positionW+10, 24);
            }
        }
        
        messageLbl.text=myService.lastMsg;
        
        NSInteger count=myService.unreadCount;
        if (count>0) {
            badgeLbl.hidden=NO;
            NSString *countStr=nil;
            if (count>99) {
                countStr=@"99+";
            }else{
                countStr=[NSString stringWithFormat:@"%ld",(long)count];
            }
            badgeLbl.text=countStr;
            CGSize countSize=[countStr boundingRectWithSize:CGSizeMake(80,60) withTextFont:badgeLbl.font];
            badgeLbl.frame=CGRectMake(kScreenWidth-countSize.width-20, nameLbl.bottom, countSize.width+12, countSize.height+5);
            badgeLbl.layer.cornerRadius=(countSize.height+5)/2.0;
            badgeLbl.clipsToBounds=YES;
            
        }else{
            badgeLbl.hidden=YES;
        }
    }else{
        positionLbl.hidden=YES;
        BOOL isRead=YES;
        if ([model isKindOfClass:[TCSystemNewsModel class]]){
            imgView.image=[UIImage imageNamed:@"ic_msg_tips"];
            nameLbl.text=@"系统消息";
            nameLbl.frame=CGRectMake(imgView.right+10, 5,100, 30);
            
            TCSystemNewsModel *systemNews=(TCSystemNewsModel *)model;
            NSString *msgDate=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:systemNews.send_time format:@"yyyy-MM-dd HH:mm"];
            timeLbl.text=kIsEmptyString(systemNews.send_time)?@"":msgDate;
            CGFloat timeW=[msgDate boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:timeLbl.font].width;
            timeLbl.frame=CGRectMake(kScreenWidth-timeW-10,10, timeW, 20);
            
            messageLbl.text=kIsEmptyString(systemNews.title)?@"暂无":systemNews.title;
            
            isRead=kIsEmptyString(systemNews.title)?YES:systemNews.isRead;
            
        }else if ([model isKindOfClass:[TCFamilyBloodModel class]]){
            imgView.image=[UIImage imageNamed:@"ic_msg_member"];
            nameLbl.text=@"亲友血糖";
            nameLbl.frame=CGRectMake(imgView.right+10, 5,100, 30);
            
            TCFamilyBloodModel *familyNews=(TCFamilyBloodModel *)model;
            NSString *msgDate=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:familyNews.measurement_time format:@"yyyy-MM-dd HH:mm"];
            timeLbl.text=kIsEmptyString(familyNews.measurement_time)?@"":msgDate;
            CGFloat timeW=[msgDate boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:timeLbl.font].width;
            timeLbl.frame=CGRectMake(kScreenWidth-timeW-10,10, timeW, 20);
            
            TCFamilyUserModel *userModel=[[TCFamilyUserModel alloc] init];
            [userModel setValues:familyNews.family_info];
            
            NSString *nickName=kIsEmptyString(userModel.call)?userModel.nick_name:userModel.call;
            double value=[familyNews.glucose doubleValue];
            NSString *timeSlot=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:familyNews.time_slot];
            NSString *statusStr=nil;
            if (familyNews.status==0) {
                statusStr=@"偏低";
            }else if (familyNews.status==1){
                statusStr=@"正常";
            }else{
                statusStr=@"偏高";
            }
            messageLbl.text=value>0.0&&!kIsEmptyString(familyNews.time_slot)?[NSString stringWithFormat:@"%@：%@测量%.1fmmol/L（%@）",nickName,timeSlot,value,statusStr]:@"暂无";
            
            isRead=value>0.0&&!kIsEmptyString(familyNews.time_slot)?familyNews.isRead:YES;
        }else{
            TCCommonNewsModel *commentModel=(TCCommonNewsModel *)model;
            
            imgView.image=[UIImage imageNamed:commentModel.newsImage];
            nameLbl.text=commentModel.newsName;
            nameLbl.frame=CGRectMake(imgView.right+10, 15,100, 30);
            timeLbl.frame=CGRectMake(kScreenWidth-40,10, 30, 20);
            timeLbl.hidden=YES;
            isRead=commentModel.newsIndex>0?commentModel.hasNewMessages:YES;
        }
        
        badgeLbl.hidden=isRead;
        badgeLbl.frame=CGRectMake(kScreenWidth-20, timeLbl.bottom+10, 10, 10);
        badgeLbl.layer.cornerRadius=5;
        badgeLbl.clipsToBounds=YES;
        badgeLbl.text=@"";
    }
    
    messageLbl.frame=CGRectMake(imgView.right+10, nameLbl.bottom, kScreenWidth-imgView.right-badgeLbl.width- 20, 20);
}


@end
