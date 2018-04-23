//
//  TCFamilyBloodDetailViewController.m
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFamilyBloodDetailViewController.h"
#import "TCFamilyBloodModel.h"

@interface TCFamilyBloodDetailViewController (){
    TCFamilyUserModel *userModel;
}
@end

@implementation TCFamilyBloodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"血糖详情";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    userModel=[[TCFamilyUserModel alloc] init];
    
    [self requestFamilyBloodNewsDetail];
}
#pragma mark -- Event Response
#pragma mark 提醒亲友
-(void)callFamilyFreindAction{
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",userModel.mobile];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark -- Private Methods
#pragma mark 加载亲友血糖消息详情
-(void)requestFamilyBloodNewsDetail{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"record_family_id=%ld",self.record_family_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFamilyNewsDetail body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            TCFamilyBloodModel *model=[[TCFamilyBloodModel alloc] init];
            [model setValues:result];
            
            [userModel setValues:model.family_info];
            [weakSelf buildDetailUIWithModel:model];
            weakSelf.backBlock();
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark  初始化界面
-(void)buildDetailUIWithModel:(TCFamilyBloodModel *)bloodModel{
    UIView *contentView=[[UIView alloc] init];
    contentView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:contentView];
    
    UIImageView *headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:userModel.image_url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    [contentView addSubview:headImageView];
    
    UILabel *nickNameLbl=[[UILabel alloc] init];
    nickNameLbl.textColor=[UIColor blackColor];
    nickNameLbl.font=[UIFont systemFontOfSize:14];
    nickNameLbl.text=kIsEmptyString(userModel.call)?userModel.nick_name:userModel.call;
    CGFloat nameW=[nickNameLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-headImageView.right-30, 30) withTextFont:nickNameLbl.font].width;
    nickNameLbl.frame=CGRectMake(headImageView.right+10, 15, nameW, 30);
    [contentView addSubview:nickNameLbl];
    
    UIImageView *sexImageView=[[UIImageView alloc] initWithFrame:CGRectMake(nickNameLbl.right+5,nickNameLbl.top, 30, 30)];
    NSString *imgName=userModel.sex==1?@"ic_m_male":@"ic_m_famale";
    sexImageView.image=[UIImage imageNamed:imgName];
    [contentView addSubview:sexImageView];
    
    UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, headImageView.bottom+10, kScreenWidth, 1)];
    line.backgroundColor=[UIColor colorWithHexString:@"0xe5e5e5"];
    [contentView addSubview:line];
    
    UILabel *timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, line.bottom+10, kScreenWidth-20, 25)];
    timeLbl.textColor=[UIColor lightGrayColor];
    timeLbl.font=[UIFont systemFontOfSize:12];
    timeLbl.text=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:bloodModel.measurement_time format:@"yyyy-MM-dd HH:mm"];
    [contentView addSubview:timeLbl];
    
    UILabel *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, timeLbl.bottom, kScreenWidth-20, 30)];
    titleLbl.text=@"您关注的亲友测量了血糖，结果如下：";
    titleLbl.font=[UIFont systemFontOfSize:14];
    titleLbl.textColor=[UIColor lightGrayColor];
    [contentView addSubview:titleLbl];
    
    //血糖值
    UILabel *valueTitleLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, titleLbl.bottom+5, 85, 30)];
    valueTitleLbl.textColor=[UIColor blackColor];
    valueTitleLbl.font=[UIFont boldSystemFontOfSize:16];
    valueTitleLbl.text=@"血  糖  值：";
    [contentView addSubview:valueTitleLbl];
    
    UILabel *valueLbl=[[UILabel alloc] initWithFrame:CGRectMake(valueTitleLbl.right, valueTitleLbl.top, kScreenWidth-valueTitleLbl.right-10, 30)];
    valueLbl.font=[UIFont systemFontOfSize:16];
    valueLbl.textColor=[UIColor blackColor];
    NSString *bloodValueStr=[NSString stringWithFormat:@"%.1f",[bloodModel.glucose doubleValue]];
    NSString *timeSlot=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:bloodModel.time_slot];
    NSString *valueStr=[NSString stringWithFormat:@"%.1fmmol/L（%@）",[bloodValueStr doubleValue],timeSlot];
    UIColor *valueColor=[self getSugarBloodValueColorWithStatus:bloodModel.status];
    if (valueStr.length>0) {
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:valueStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:valueColor range:NSMakeRange(0, bloodValueStr.length)];
        valueLbl.attributedText=attributeStr;
        [contentView addSubview:valueLbl];
    }

    
    //血糖水平
    UILabel *standardTitleLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, valueTitleLbl.bottom+10, valueTitleLbl.width, 20)];
    standardTitleLbl.textColor=[UIColor blackColor];
    standardTitleLbl.font=[UIFont boldSystemFontOfSize:16];
    standardTitleLbl.text=@"血糖水平：";
    [contentView addSubview:standardTitleLbl];
    
    UILabel *standardLbl=[[UILabel alloc] initWithFrame:CGRectMake(standardTitleLbl.right, standardTitleLbl.top, kScreenWidth-standardTitleLbl.right-10, 30)];
    standardLbl.numberOfLines=0;
    standardLbl.font=[UIFont systemFontOfSize:16];
    standardLbl.textColor=[UIColor blackColor];
    NSString *standardStr=[self getSugarBloodStandardWithStatus:bloodModel.status];
    CGFloat standardH=[standardStr boundingRectWithSize:CGSizeMake(kScreenWidth-standardTitleLbl.right-10, kRootViewHeight) withTextFont:standardLbl.font].height;
    standardLbl.frame=CGRectMake(standardTitleLbl.right, standardTitleLbl.top, kScreenWidth-standardTitleLbl.right-10, standardH);
    NSMutableAttributedString *standardAttributeStr=[[NSMutableAttributedString alloc] initWithString:standardStr];
    [standardAttributeStr addAttribute:NSForegroundColorAttributeName value:valueColor range:NSMakeRange(5, 2)];
    standardLbl.attributedText=standardAttributeStr;
    [contentView addSubview:standardLbl];
    
    contentView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, standardLbl.bottom+20);
    
    UIButton  *callBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, contentView.bottom+60, kScreenWidth-80, 40)];
    [callBtn setTitle:@"  提醒亲友" forState:UIControlStateNormal];
    [callBtn setImage:[UIImage imageNamed:@"ic_user_call"] forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    callBtn.backgroundColor=kSystemColor;
    callBtn.layer.cornerRadius=5;
    callBtn.clipsToBounds=YES;
    [callBtn addTarget:self action:@selector(callFamilyFreindAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBtn];
    callBtn.hidden = bloodModel.status==1;
}
#pragma mark 获取血糖标准颜色
-(UIColor *)getSugarBloodValueColorWithStatus:(NSInteger )status{
    if (status==2) {
        return [UIColor colorWithHexString:@"#fa6f6e"];
    }else if (status==3){
        return [UIColor colorWithHexString:@"#ffd03e"];
    }else{
        return [UIColor colorWithHexString:@"#37deba"];
    }
}
#pragma mark 获取血糖标准结果判断
-(NSString *)getSugarBloodStandardWithStatus:(NSInteger )status{
    if (status==2) {
        return @"血糖值处于偏高状态，调整生活模式，控制饮食热量，适当增加运动量，必要时调整药物，及时就医。";
    }else if (status==3){
        return @"血糖值处于偏低状态，请迅速进食粗粮或无糖果汁，15分钟后复测血糖，如果持续无缓解，请及时就医。";
    }else{
        return @"血糖值处于正常状态，血糖控制很好，加油哦，请继续保持。";
    }
}
@end
