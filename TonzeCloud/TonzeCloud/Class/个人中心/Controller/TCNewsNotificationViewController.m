//
//  TCNewsNotificationViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCNewsNotificationViewController.h"
#import "TCMineButton.h"

@interface TCNewsNotificationViewController (){
    UIScrollView *rootScrollView;
    NSInteger    fun_type;
}
@end

@implementation TCNewsNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"消息通知";
    
    [self initNewsNotificationView];
    
    [self requestFreindReminderDataForType:0 isOpen:NO];

}

#pragma mark -- Event Response
#pragma mark 声音／震动
-(void)switchAction:(UISwitch *)sender{
    BOOL isButtonOn = [sender isOn];
    if (sender.tag==101) {
        [MobClick event:@"104_003013"];

        NSNumber *soundOn=[NSNumber numberWithBool:isButtonOn];
        [SSKeychain setPassword:[NSString stringWithFormat:@"%@",soundOn] forService:kPushPlaySound account:kSetPushOption];
    }else if (sender.tag==102){
        [MobClick event:@"104_003014"];

        NSNumber *vebrationOn=[NSNumber numberWithBool:isButtonOn];
        [SSKeychain setPassword:[NSString stringWithFormat:@"%@",vebrationOn] forService:kPushPlayVebration account:kSetPushOption];
    }else{
        fun_type=sender.tag-102;
        NSString *eventId=[NSString stringWithFormat:@"104_0030%ld",(long)fun_type+14];
        [MobClick event:eventId];
        
        [self requestFreindReminderDataForType:1 isOpen:isButtonOn];
    }
}

#pragma mark -- Private Methods
#pragma mark 糖友圈提醒查看
-(void)requestFreindReminderDataForType:(NSInteger)type isOpen:(BOOL)isOpen{
    NSString *body=nil;
    if (type==0) {
        body=@"doSubmit=0&role_type=0";
    }else{
        body=[NSString stringWithFormat:@"doSubmit=1&role_type=0&fun_type=%ld&is_news_attr=%d",fun_type,isOpen];
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kattr_setUpdate body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        for (UIButton *btn in rootScrollView.subviews) {
            if ([btn isKindOfClass:[TCMineButton class]]) {
                UISwitch *followSwitch=(UISwitch *)[btn viewWithTag:103];
                [followSwitch setOn: [[result valueForKey:@"is_news_follow"] boolValue]];
                
                UISwitch *atSwitch=(UISwitch *)[btn viewWithTag:104];
                [atSwitch setOn: [[result valueForKey:@"is_news_at"] boolValue]];
                
                UISwitch *commentSwitch=(UISwitch *)[btn viewWithTag:105];
                [commentSwitch setOn: [[result valueForKey:@"is_news_comment"] boolValue]];
                
                UISwitch *likeSwitch=(UISwitch *)[btn viewWithTag:106];
                [likeSwitch setOn: [[result valueForKey:@"is_news_like"] boolValue]];
                
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 初始化界面
-(void)initNewsNotificationView{
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    rootScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:rootScrollView];
    
    NSString *contentStr=[self isNotificationSettings]?@"已启用":@"已关闭";
    NSDictionary *dict = @{@"title":@"新消息通知",@"content":contentStr,@"image":@""};
    TCMineButton *newsBtn = [[TCMineButton alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 48) dict:dict];
    newsBtn.backgroundColor = [UIColor whiteColor];
    [rootScrollView addSubview:newsBtn];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    descLabel.text = @"请在iPhone的“设置” - “通知”中找到“糖士”，并允许通知";
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor grayColor];
    descLabel.numberOfLines=0;
    CGFloat descH=[descLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:descLabel.font].height;
    descLabel.frame=CGRectMake(10, newsBtn.bottom+5, kScreenWidth-20, descH+5);
    [rootScrollView addSubview:descLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, descLabel.bottom+10, kScreenWidth/2, 30)];
    titleLabel.text = @"聊天消息通知";
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor grayColor];
    [rootScrollView addSubview:titleLabel];
    
    UILabel *freindLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+10+48*2, kScreenWidth/2, 30)];
    freindLabel.text = @"糖友圈提醒";
    freindLabel.font = [UIFont systemFontOfSize:15];
    freindLabel.textColor = [UIColor grayColor];
    [rootScrollView addSubview:freindLabel];
    
    
    NSString *sound=[SSKeychain passwordForService:kPushPlaySound account:kSetPushOption];
    NSString *vebration=[SSKeychain passwordForService:kPushPlayVebration account:kSetPushOption];
    NSArray *newsValueArr = nil;
    if (!kIsEmptyString(sound)&&!kIsEmptyString(vebration)) {
        newsValueArr=@[sound,vebration];
    }
    NSArray *reminderArr=@[@"声音",@"震动",@"新朋友提醒",@"@我的提醒",@"评论我的提醒",@"赞我的提醒"];
    for (NSInteger i=0; i<reminderArr.count; i++) {
        dict=@{@"title":reminderArr[i],@"content":@"",@"image":@""};
        TCMineButton *customBtn;
        if (i<2) {
            customBtn = [[TCMineButton alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5+48*i, kScreenWidth, 48) dict:dict];
        }else {
            customBtn=[[TCMineButton alloc] initWithFrame:CGRectMake(0, freindLabel.bottom+5+48*(i-2), kScreenWidth, 48) dict:dict];
        }
        customBtn.backgroundColor = [UIColor whiteColor];
        [rootScrollView addSubview:customBtn];
        
        UISwitch *customSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 48, 30)];
        [customSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        customSwitch.tag =101+i;
        [customBtn addSubview:customSwitch];
        if (i<2) {
            [customSwitch setOn:[newsValueArr[i] boolValue]];
        }
    }
}

#pragma mark 判断是否开启通知
-(BOOL)isNotificationSettings{
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone == setting.types) {
        MyLog(@"推送关闭 8.0");
        return NO;
    }else{
        MyLog(@"推送打开 8.0");
        return YES;
    }
}



@end
