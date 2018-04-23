//
//  TCImageConsultViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCImageConsultViewController.h"
#import "TCConsultViewController.h"
#import "TCExpertDetailController.h"
#import "TCPayViewController.h"
#import "TCPlanButton.h"
#import "TCServiceDetailModel.h"
#import "TCImageButton.h"
#import "TCFastLoginViewController.h"

@interface TCImageConsultViewController ()<UIScrollViewDelegate>{
    
    UIScrollView  *consultScroller;
    UIScrollView  *detailScroll;
    TCPlanButton  *planBtn;
    TCImageButton *caseNameBtn;
    TCImageButton *caseTimeBtn;
    TCImageButton *contentNameBtn;
    UILabel       *muchLabel;   //值
    UILabel       *priceMuchLabel;   //值
    UIView        *bgview ;
    TCServiceDetailModel  *serviceDetailModel;
}
@end

@implementation TCImageConsultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"营养服务";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    serviceDetailModel = [[TCServiceDetailModel alloc] init];
    [self initConcultView];
    
    [self requestProgramData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:[NSString stringWithFormat:@"006-04-03:%ld",self.expertId] type:1];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:[NSString stringWithFormat:@"006-04-03:%ld",self.expertId] type:2];
}
#pragma mark -- Event response
#pragma mark -- 专家详情
- (void)detailButton{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"006-04-01"];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        if (self.isHomeIn) {
            [MobClick event:@"101_002015"];
        }else{
            [MobClick event:@"103_002009"];
        }
        
        BOOL flag=NO;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[TCExpertDetailController class]]) {
                flag=YES;
            }
        }
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            TCExpertDetailController *expertDetailVC = [[TCExpertDetailController alloc] init];
            expertDetailVC.expert_id = serviceDetailModel.expert_id;
            expertDetailVC.isHomeIn=YES;
            [self.navigationController pushViewController:expertDetailVC animated:YES];
        }
    }else{
        [self fastLoginAction];
    }
}
#pragma mark -- 立即支付
- (void)payButton{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"006-04-02"];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        if(self.isHomeIn){
            [MobClick event:@"101_002016"];
        }else{
            [MobClick event:@"103_002010"];
        }
        TCPayViewController *payVC = [[TCPayViewController alloc] init];
        payVC.expertId=serviceDetailModel.expert_id;
        payVC.planId=serviceDetailModel.id;
        payVC.payAmount=[serviceDetailModel.customized_price doubleValue];
        payVC.payPriceAmount = [serviceDetailModel.preferential_price doubleValue];
        payVC.planType=2;
        [self.navigationController pushViewController:payVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark -- Event Metnods
#pragma mark -- 请求方案数据
- (void)requestProgramData{
    NSString *url = [NSString stringWithFormat:@"%@?id=%ld&type=2&position=%ld",kServiceDetail,(long)self.expertId,(long)self.position];
    [[TCHttpRequest  alloc] getMethodWithURL:url success:^(id json) {
        NSArray *dataArray = [json objectForKey:@"result"];
        if (dataArray.count>0) {
            NSDictionary *dataDic = [json objectForKey:@"result"][0];
            serviceDetailModel = [[TCServiceDetailModel alloc] init];
            [serviceDetailModel setValues:dataDic];
            [self createContentView];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 服务内容
- (void)createContentView{
    [planBtn.headImage sd_setImageWithURL:[NSURL URLWithString:serviceDetailModel.head_portrait] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    planBtn.expertName.text = serviceDetailModel.expert_name;
    planBtn.workRank.text   = serviceDetailModel.positional_titles;
    caseTimeBtn.contentLab.text = [NSString stringWithFormat:@"%@天",serviceDetailModel.customized_service_time];
    caseNameBtn.titleName.text = [NSString stringWithFormat:@"%@",serviceDetailModel.name];
    
    muchLabel.text  =[NSString stringWithFormat:@"%.2f元",[serviceDetailModel.customized_price doubleValue]];
    
    CGSize size = [muchLabel.text sizeWithLabelWidth:200 font:[UIFont systemFontOfSize:16]];
    muchLabel.frame = CGRectMake(20, kScreenHeight-40, size.width+10, 25);
    priceMuchLabel.frame =CGRectMake(muchLabel.right+5, muchLabel.bottom-18, 80, 15);
    priceMuchLabel.text =[NSString stringWithFormat:@"%.2f元",[serviceDetailModel.delete_price doubleValue]];
    priceMuchLabel.hidden =[serviceDetailModel.delete_price doubleValue]>0?NO:YES;
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:priceMuchLabel.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,priceMuchLabel.text.length)];
    
    priceMuchLabel.attributedText = attributeMarket;
    
    CGFloat imgHeight=0.0;
    CGFloat imageHeight=0.0;
    if (kIsArray(serviceDetailModel.content_images)) {
        if (serviceDetailModel.content_images.count>0) {
            for (NSInteger i=0; i<serviceDetailModel.content_images.count; i++) {
                NSString *imgurl=[[serviceDetailModel.content_images objectAtIndex:i] objectForKey:@"l_url"];
                CGFloat  Width = [[[serviceDetailModel.content_images objectAtIndex:i] objectForKey:@"width"] floatValue];
                CGFloat  Height = [[[serviceDetailModel.content_images objectAtIndex:i] objectForKey:@"height"] floatValue];
                UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,imgHeight, kScreenWidth, (kScreenWidth *Height)/Width)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:imgurl] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                    [imageView setFrame:CGRectMake(0, imageHeight, kScreenWidth, (kScreenWidth *Height)/Width)];
                }];
                if (imgurl.length==0) {
                    imageView.image = [UIImage imageNamed:@"img_bg40x40"];
                    [imageView setFrame:CGRectMake((kScreenWidth-80)/2, imageHeight+40, 80,80)];
                }
                [detailScroll addSubview:imageView];
                imageHeight+=(kScreenWidth *Height)/Width;
                imgHeight+=(kScreenWidth *Height)/Width;
            }
            [detailScroll setFrame:CGRectMake(0, contentNameBtn.bottom, kScreenWidth,imageHeight)];
            [consultScroller setContentSize:CGSizeMake(kScreenWidth, detailScroll.bottom)];

        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2,contentNameBtn.bottom+40, 80, 80)];
            imageView.image = [UIImage imageNamed:@"img_bg40x40"];
            [consultScroller addSubview:imageView];
        }
    }
}
#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initConcultView{
    consultScroller  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-54)];
    consultScroller.delegate = self;
    consultScroller.backgroundColor = [UIColor bgColor_Gray];
    consultScroller.showsVerticalScrollIndicator=NO;
    [self.view addSubview:consultScroller];
    
    planBtn = [[TCPlanButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
    planBtn.backgroundColor = [UIColor whiteColor];
    [planBtn addTarget:self action:@selector(detailButton) forControlEvents:UIControlEventTouchUpInside];
    [consultScroller addSubview:planBtn];

    caseNameBtn = [[TCImageButton alloc] initWithFrame:CGRectMake(0, planBtn.bottom+10, kScreenWidth, 40) dict:nil];
    caseNameBtn.titleName.textColor =[UIColor colorWithHexString:@"#f69b32"];
    caseNameBtn.titleName .font = [UIFont systemFontOfSize:14];
    caseNameBtn.backgroundColor = [UIColor whiteColor];
    [consultScroller addSubview:caseNameBtn];

    caseTimeBtn = [[TCImageButton alloc] initWithFrame:CGRectMake(0, caseNameBtn.bottom+1, kScreenWidth, 40) dict:nil];
    caseTimeBtn.titleName.text = @"服务周期";
    caseTimeBtn.titleName.textColor = [UIColor colorWithHexString:@"#626262"];
    caseTimeBtn.contentLab.textColor = [UIColor colorWithHexString:@"#626262"];
    caseTimeBtn.titleName.font = [UIFont systemFontOfSize:13];
    caseTimeBtn.backgroundColor = [UIColor whiteColor];
    [consultScroller addSubview:caseTimeBtn];

    contentNameBtn = [[TCImageButton alloc] initWithFrame:CGRectMake(0, caseTimeBtn.bottom+10, kScreenWidth, 40) dict:nil];
    contentNameBtn.titleName.text = @"服务内容:";
    contentNameBtn.titleName.textColor = [UIColor colorWithHexString:@"#f69b32"];
    contentNameBtn.titleName.font = [UIFont systemFontOfSize:14];
    contentNameBtn.backgroundColor = [UIColor whiteColor];
    [consultScroller addSubview:contentNameBtn];
    
    detailScroll=[[UIScrollView alloc] initWithFrame:CGRectZero];
    detailScroll.scrollEnabled=NO;
    [consultScroller addSubview:detailScroll];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-54, kScreenWidth, 54)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-54, kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    [self.view addSubview:line];
    
    muchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreenHeight-40, 80, 30)];
    muchLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    muchLabel.textColor = [UIColor colorWithHexString:@"#f69b32"];
    [self.view addSubview:muchLabel];
    
    priceMuchLabel = [[UILabel alloc] initWithFrame:CGRectMake(muchLabel.right, muchLabel.top+10, 80, 20)];
    priceMuchLabel.font = [UIFont systemFontOfSize:14];
    priceMuchLabel.textColor = [UIColor grayColor];
    [self.view addSubview:priceMuchLabel];
    priceMuchLabel.hidden=YES;
    
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-103, kScreenHeight-53,103 , 53)];
    [payBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    payBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    payBtn.backgroundColor = [UIColor orangeColor];
    [payBtn addTarget:self action:@selector(payButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
