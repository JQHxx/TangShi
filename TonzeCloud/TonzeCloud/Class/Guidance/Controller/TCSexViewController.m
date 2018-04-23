//
//  TCSexViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSexViewController.h"
#import "TCSexButton.h"
#import "TCBirthdayViewController.h"
#import "AppDelegate.h"
#import "BaseTabBarViewController.h"
#import "TCUserTool.h"
#import "HeziSDK.h"
#import "CustomeWebView.h"

@interface TCSexViewController ()<HeziTriggerActivePageDelegate>

@end

@implementation TCSexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"性别";
    
    self.isHiddenBackBtn=YES;
    
    self.rigthTitleName=@"跳过";
    
    [self initSexView];
    
    //活动盒子注册触发
    NSString *phone=[NSUserDefaultsInfos getValueforKey:kPhoneNumber];
    NSDictionary *userInfo=@{@"username":phone,@"mobile":phone};
    [HeziTrigger trigger:@"registered" userInfo:userInfo showIconInView:self.view rootController:self delegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"完善个人信息－性别"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"完善个人信息－性别"];
}

#pragma mark -- HeziTriggerActivePageDelegate
- (void)heziTirgger:(HeziTrigger *)trigger triggerError:(NSError *)error{
    //错误回调
    MyLog(@"活动盒子错误回调,error:%ld,%@",error.code,error.localizedDescription);
}

//分享回调
-(void)heziTrigger:(HeziTrigger *)heziSDK share:(HeziShareModel *)shareContent activePage:(UIView *)activePage{
    //用户在这里要调用自己 app 的分享功能,盒子 sdk 只提供分享的内容
    MyLog(@"share title==>%@",shareContent.title);//分享标题
    MyLog(@"share content==>%@",shareContent. content);//分享内容
    MyLog(@"share linkUrl==>%@",shareContent. linkUrl);//分享链接
    MyLog(@"share imageUrl==>%@",shareContent. imgUrl);//分享图标链接
    MyLog(@"share callBack==>%@",shareContent.callBackUrl);//统计分享成功的链接,并且给配置了分享增加次数的活动 增加次数
}

//触发活动打开拦截事件
-(BOOL)heziTriggerWillOpenActivePage:(HeziTrigger *)heziSDK activityURL:(NSString *)url{
    MyLog(@"触发活动打开拦截事件:url==>%@",url);
    CustomeWebView *myWebView = [[CustomeWebView alloc] init];
    
    if([url containsString:@"transparent=1"]){
        //设置透明风格
        //设置模式展示风格
        [myWebView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        //必要配置
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
    }
    [myWebView load:url];
    
    [self presentViewController:myWebView animated:YES completion:nil];
    //拦截了 sdk内部的跳转,转跳到自己的 webview 页面
    return  NO;
}
//盒子活动关闭回调
-(void)heziTriggerDidCloseActivePage:(HeziTrigger *)heziSDK{
    //默认情况下触发的图标点击不会自动关闭,开发者要关闭需要在这里调用关闭的方法
    [heziSDK dismiss];
}


#pragma mark -- Event Response
#pragma mark  选择性别
- (void)sexButtonChoose:(UIButton *)button{
    NSInteger sex=button.tag;
    [[TCUserTool sharedTCUserTool] insertValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
    TCBirthdayViewController *birthdayVC = [[TCBirthdayViewController alloc] init];
    [self.navigationController pushViewController:birthdayVC animated:YES];
}
#pragma mark  跳过
-(void)rightButtonAction{
    BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
    AppDelegate *appDelegate=kAppDelegate;
    appDelegate.window.rootViewController=tabbarVC;
}
#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initSexView{
    
    
    UIView *porpmtView = [[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 50)];
    porpmtView.backgroundColor = [UIColor colorWithHexString:@"0xf7f1da"];
    [self.view addSubview:porpmtView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 10, 30, 30)];
    imgView.image = [UIImage imageNamed:@"data_ic_jifen"];
    [porpmtView addSubview:imgView];
    
    UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, 15, kScreenWidth-imgView.right-10, 20)];
    porpmtLabel.text = @"完善资料拿积分，海量好礼等你兑！";
    porpmtLabel.font = [UIFont systemFontOfSize:15];
    porpmtLabel.textColor = [UIColor colorWithHexString:@"eb6100"];
    [porpmtView addSubview:porpmtLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, porpmtView.bottom, kScreenWidth, 1)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xffa96c"];
    [self.view addSubview:lineLabel];
    
    UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lineLabel.bottom+20, kScreenWidth, 30)];
    sexLabel.text = @"您的性别？";
    sexLabel.font = [UIFont systemFontOfSize:20];
    sexLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sexLabel];
    
    NSDictionary *dict = @{@"image":@"ic_login_male",@"title":@"男"};
    TCSexButton *manBtn = [[TCSexButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, sexLabel.bottom+30, 100, 100) dict:dict];
    manBtn.tag = 1;
    [manBtn addTarget:self action:@selector(sexButtonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:manBtn];
    
    dict = @{@"image":@"ic_login_female",@"title":@"女"};
    TCSexButton *womanBtn = [[TCSexButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, manBtn.bottom+80, 100, 100) dict:dict];
    [womanBtn addTarget:self action:@selector(sexButtonChoose:) forControlEvents:UIControlEventTouchUpInside];
    womanBtn.tag = 2;
    [self.view addSubview:womanBtn];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
