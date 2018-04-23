//
//  TCMessageTableViewCell.m
//  TonzeCloud
//
//  Created by vision on 17/8/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMessageTableViewCell.h"
#import "TCMainDeviceHelper.h"

@interface TCMessageTableViewCell (){
    UILabel    *titleLbl;
    UILabel    *descLbl;
    UILabel    *timeLbl;
    UILabel    *stateLbl;
}

@end

@implementation TCMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        titleLbl.textColor=[UIColor blackColor];
        titleLbl.font=[UIFont systemFontOfSize:14];
        titleLbl.numberOfLines=0;
        [self.contentView addSubview:titleLbl];
        
        descLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        descLbl.textColor=[UIColor lightGrayColor];
        descLbl.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:descLbl];
        
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 35, 150, 20)];
        timeLbl.textColor=[UIColor lightGrayColor];
        timeLbl.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:timeLbl];
        
        stateLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        stateLbl.textColor=[UIColor lightGrayColor];
        stateLbl.font=[UIFont systemFontOfSize:14];
        stateLbl.textAlignment=NSTextAlignmentRight;
        [self.contentView addSubview:stateLbl];
    }
    return self;
}

-(void)cellDisplayWithMessage:(TCDeviceMessageModel *)message type:(MessageType)type{
     if (type==MessageTypeDeviceShare){
        NSString *deviceName=[[TCMainDeviceHelper sharedTCMainDeviceHelper] getDeviceNameFormDeviceID:message.device_id];
         deviceName=kIsEmptyString(deviceName)?@"设备":deviceName;
        NSInteger userID=[XL_USER_ID integerValue];
        if (userID==message.from_id) {  //我分享给别人的
            if (message.user_id!=0) {
                titleLbl.text=[NSString stringWithFormat:@"您向%@分享了%@",message.to_name,deviceName];
            }else{
                titleLbl.text=[NSString stringWithFormat:@"您通过二维码分享了%@",deviceName];
            }
        }else{  //别人分享给我的
            titleLbl.text=[NSString stringWithFormat:@"%@向您分享了%@",message.from_name,deviceName];
        }
        timeLbl.text=[[TCHelper sharedTCHelper] timeSPToTime:message.gen_date];
        stateLbl.text=[self getMessageStateWithState:message.state];
        
        if ([stateLbl.text isEqualToString:@"等待处理 >>"]) {
            stateLbl.textColor=UIColorFromRGB(0xff8314);
        }else{
            stateLbl.textColor=UIColorFromRGB(0xAEAEAE);
        }
        
        CGFloat stateW=[stateLbl.text boundingRectWithSize:CGSizeMake(200, 20) withTextFont:stateLbl.font].width;
        stateLbl.frame=CGRectMake(kScreenWidth-stateW-10, 20, stateW, 20);
        
        CGFloat titleW=[titleLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-stateW-20, 30) withTextFont:titleLbl.font].width;
        titleLbl.frame=CGRectMake(10, 5, titleW, 30);
    }else{
        stateLbl.textColor=message.isWorkError?[UIColor redColor]:[UIColor lightGrayColor];
        
        titleLbl.text=message.deviceName;
        stateLbl.text=message.state;
        descLbl.text=message.deviceType;
        timeLbl.text=message.gen_date;
        
        CGFloat stateW=[stateLbl.text boundingRectWithSize:CGSizeMake(200, 20) withTextFont:stateLbl.font].width;
        stateLbl.frame=CGRectMake(kScreenWidth-stateW-10, 20, stateW, 20);
        
        CGFloat descW=[descLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-stateW-60, 30) withTextFont:descLbl.font].width;
        CGFloat titleW=[titleLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-stateW-descW-20, 30) withTextFont:titleLbl.font].width;
        titleLbl.frame=CGRectMake(10, 5, titleW, 30);
        descLbl.frame=CGRectMake(titleLbl.right+5, 5, descW, 30);
    }
}


-(NSString *)getMessageStateWithState:(NSString *)state{
    NSString *messageStateStr=nil;
    if ([state isEqualToString:@"pending"]) {
        //等待处理
        messageStateStr=@"等待处理 >>";
    }else if([state isEqualToString:@"accept"]){
        messageStateStr=@"已分享";
    }else if([state isEqualToString:@"deny"]){
        messageStateStr=@"已拒绝";
    }else if([state isEqualToString:@"cancel"]){
        messageStateStr=@"已取消";
    }else if([state isEqualToString:@"overtime"]){
        messageStateStr=@"已失效";
    }
    return messageStateStr;
}


@end
