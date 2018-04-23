//
//  TCPlanConsultViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPlanConsultViewController.h"
#import "TCPayViewController.h"
#import "TCFastLoginViewController.h"
#import "TCPlanButton.h"
#import "TCExpertDetailController.h"
#import "TCPlanModel.h"

@interface TCPlanConsultViewController (){
    UIScrollView    *rootScrollView;
    UILabel         *muchLabel;   //付钱数量
    UILabel       *priceMuchLabel;   //值
    double        customized_price;  //付款金额
    double        preferential_price;  //折扣金额
    NSString        *orderSn;
    TCPlanModel   *planModel;
    TCPlanButton  *planBtn;
    UIView        *bgView;
    UILabel       *contentLabel;
    UIButton      *lookAllButton;
    UIView        *imageView;
    BOOL           lsLookAll;
    NSInteger      imageHeight;
}

@end

@implementation TCPlanConsultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"图文咨询";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    lsLookAll = YES;
    
    [self initImageScriptView];
    [self requestGraphicData];
}

#pragma mark -- Event response
#pragma mark  立即支付
- (void)payButton{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"006-03-02"];
#endif
    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        TCPayViewController *payVC = [[TCPayViewController alloc] init];
        payVC.planType=1;
        payVC.expertId=self.expert_id;
        payVC.payAmount=customized_price;
        [self.navigationController pushViewController:payVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}

#pragma mark -- Private Methods
#pragma mark  获取图文数据
- (void)requestGraphicData{
    NSString *url = [NSString stringWithFormat:@"%@?id=%ld&type=1",kServiceDetail,(long)self.expert_id];
    [[TCHttpRequest  alloc] getMethodWithURL:url success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            planModel = [[TCPlanModel alloc] init];
            [planModel setValues:result];
            [self createImageContentView];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark 方案内容
- (void)createImageContentView{
    [planBtn.headImage sd_setImageWithURL:[NSURL URLWithString:planModel.head_portrait] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    planBtn.expertName.text = planModel.expert_name;
    planBtn.workRank.text   = planModel.positional_titles;
    
    NSString *content = [NSString stringWithFormat:@"%@",planModel.graphic_speciality];
    if (content.length>0) {
        contentLabel.text = content;
        CGSize size = [content sizeWithLabelWidth:kScreenWidth-30 font:[UIFont systemFontOfSize:15]];
        if (size.height>36) {
            contentLabel.frame = CGRectMake(15, 35, kScreenWidth-30, 36);
            lookAllButton.hidden = NO;
        } else {
            contentLabel.frame = CGRectMake(15, 35, kScreenWidth-30, size.height);
            lookAllButton.hidden = YES;
        }
    }

    customized_price=planModel.graphic_price;
    preferential_price=planModel.delete_price;
    muchLabel.text  =[NSString stringWithFormat:@"%.2f元",customized_price];
    
    CGSize size = [muchLabel.text sizeWithLabelWidth:200 font:[UIFont systemFontOfSize:16]];
    muchLabel.frame = CGRectMake(20, kScreenHeight-40, size.width+10, 25);
    priceMuchLabel.frame =CGRectMake(muchLabel.right+5, muchLabel.top+7, 80, 15);
    priceMuchLabel.text =[NSString stringWithFormat:@"%.2f元",preferential_price];
    priceMuchLabel.hidden =preferential_price>0?NO:YES;
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:priceMuchLabel.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,priceMuchLabel.text.length)];
    
    priceMuchLabel.attributedText = attributeMarket;
    
    NSArray *contentImages=planModel.content_images;
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    for (NSInteger i=0; i<contentImages.count; i++) {
        NSDictionary *dict=contentImages[i];
        width = [[dict objectForKey:@"width"] floatValue];
        height = [[dict objectForKey:@"height"] floatValue];
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0,imageHeight, kScreenWidth, kScreenWidth/width*height)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:dict[@"image_url"]] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        [imageView addSubview:imgView];
        imageHeight =imageHeight+kScreenWidth/width*height;
    }
    imageView.frame = CGRectMake(0, bgView.bottom, kScreenWidth,imageHeight);
    [rootScrollView setContentSize:CGSizeMake(kScreenWidth, imageHeight+bgView.bottom)];
}
#pragma 展开／收回
- (void)lookAllButton:(UIButton *)button{
    button.selected = !button.selected;
    lsLookAll = !lsLookAll;
    if (lsLookAll==NO) {
        CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-30 font:[UIFont systemFontOfSize:15]];
        contentLabel.frame = CGRectMake(15, 35, kScreenWidth-30, size.height);
        bgView.frame = CGRectMake(0, planBtn.bottom+10, kScreenWidth, 80+size.height-36);
        imageView.frame = CGRectMake(0, bgView.bottom, kScreenWidth,imageHeight);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, imageHeight+bgView.bottom)];
    } else {
        contentLabel.frame = CGRectMake(15, 35, kScreenWidth-30, 36);
        bgView.frame = CGRectMake(0, planBtn.bottom+10, kScreenWidth, 80);
        imageView.frame = CGRectMake(0, bgView.bottom, kScreenWidth,imageHeight);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, imageHeight+bgView.bottom)];
    }

}
#pragma mark 专家详情
- (void)detailButton{

    BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (isLogin) {
        
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
            expertDetailVC.expert_id = planModel.id;
            expertDetailVC.isHomeIn=YES;
            [self.navigationController pushViewController:expertDetailVC animated:YES];
        }
    }else{
       [self fastLoginAction];
    }
}
#pragma mark  初始化界面
- (void)initImageScriptView{
    rootScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight-54)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:rootScrollView];
    
    planBtn = [[TCPlanButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
    planBtn.backgroundColor = [UIColor whiteColor];
    [planBtn addTarget:self action:@selector(detailButton) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:planBtn];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, planBtn.bottom+10, kScreenWidth, 80)];
    bgView.backgroundColor = [UIColor whiteColor];
    [rootScrollView addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 50, 20)];
    titleLabel.text = @"擅长";
    titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:titleLabel];
    
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLabel.bottom+5, kScreenWidth-30, 20)];
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:contentLabel];
    
    lookAllButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 10, 30, 20)];
    [lookAllButton setImage:[UIImage imageNamed:@"ic_list_arrow_down"] forState:UIControlStateNormal];
    [lookAllButton setImage:[UIImage imageNamed:@"ic_list_arrow_up"] forState:UIControlStateSelected];
    [lookAllButton addTarget:self action:@selector(lookAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:lookAllButton];
    lookAllButton.hidden = YES;

    imageView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.bottom, kScreenWidth, 0)];
    [rootScrollView addSubview:imageView];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-54, kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    [self.view addSubview:line];
    
    muchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreenHeight-40, 100, 25)];
    muchLabel.font = [UIFont systemFontOfSize:15];
    muchLabel.textColor = [UIColor colorWithHexString:@"0xf69b32"];
    [self.view addSubview:muchLabel];
    
    priceMuchLabel = [[UILabel alloc] initWithFrame:CGRectMake(muchLabel.right, muchLabel.top+7, 80, 15)];
    priceMuchLabel.font = [UIFont systemFontOfSize:14];
    priceMuchLabel.textColor = [UIColor grayColor];
    [self.view addSubview:priceMuchLabel];
    priceMuchLabel.hidden=YES;
    
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-103, kScreenHeight-KTabbarSafeBottomMargin-53,103 , 53)];
    [payBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    payBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    payBtn.backgroundColor = kbgBtnColor;
    [payBtn addTarget:self action:@selector(payButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
