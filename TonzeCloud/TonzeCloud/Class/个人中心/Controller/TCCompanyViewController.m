//
//  TCCompanyViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCompanyViewController.h"

@interface TCCompanyViewController (){
    UIScrollView     *rootScrollView;
}
@end

@implementation TCCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle=_isCompany==YES?@"公司简介":@"平台介绍";
    
    NSString *content=_isCompany==YES?@"创立于2016年\n深圳天际云科技有限公司是由广东天际电器股份有限公司（股票代码：002759）全资控股的子公司。\n\n主营业务\n专注于互联网／物联网领域的技术开发及技术服务，为慢性病人群和关注健康的人群，提供一体化健康解决方案。是一家智能厨房、健康食疗、健康体疗为一体的整体方案提供商。\n\n产品特点\n天际云平台基于用户身体健康数据采集，通过专业的分析，为用户提供针对性的营养健康改善方案，同时便捷的提供给用户食材、食材包、烹饪器具选择，个性化烹饪定制、后期效果评定和改善方案，并为您构建系统性闭环生态链，保障用户身体、身心健康。\n\n发展优势\n依托于总公司天际电器在小家电领域的品牌知名度和制造业优势，结合天际云以健康为核心，以平台为依托，以产品为支撑，以服务为引导，创建和整合以健康为核心的产业集群，致力打造专业的健康食疗和健康体疗服务系统提供商平台品牌。":@"专业的糖尿病营养健康管理平台，掌握科学营养饮食，轻松有效控制血糖，提供前沿营养咨询，与所有糖友一起轻松控糖。\n\2在线咨询营养专家，帮助糖友实现自我管理、学习控制，有效掌控糖尿病。\n\2根据糖友每日所需的总热量以及身体状况和个人喜好，为糖友搭配健康又美味的控糖餐。精准的记录每天每时每刻的血糖数值，并且为糖友保存精准的历史血糖数据，以便糖友轻松掌控血糖数值做到变化趋势掌上控制。";
    
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
    [self.view addSubview:rootScrollView];
    
    UIImageView *imgView=[[UIImageView alloc] init];
    if (!_isCompany) {
        imgView.frame =CGRectMake((kScreenWidth - 150)/2, 20, 150, 80);
    }else{
        imgView.frame = CGRectMake((kScreenWidth - 250)/2, 20, 250, 140);
    }
    imgView.image=[UIImage imageNamed:_isCompany==YES?@"公司logo":@"糖士logo"];
    [rootScrollView addSubview:imgView];
    
    UILabel *contentLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font=[UIFont systemFontOfSize:14];
    contentLabel.numberOfLines=0;
    
    NSMutableParagraphStyle *paraStyle=[[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment=NSTextAlignmentLeft;
    paraStyle.headIndent=0.0f;
    CGFloat emptylen=contentLabel.font.pointSize*2;
    paraStyle.firstLineHeadIndent=emptylen; //首行缩进
    paraStyle.lineSpacing=2.0f;//行间距
    
    NSAttributedString *attrText=[[NSAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    contentLabel.attributedText=attrText;
    
    CGFloat contentHeight=[contentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font,NSFontAttributeName,nil] context:nil].size.height;
    
    contentLabel.frame=CGRectMake(20, imgView.bottom, kScreenWidth-40, contentHeight+100);
    [rootScrollView addSubview:contentLabel];
    
    rootScrollView.contentSize=CGSizeMake(kScreenWidth, contentLabel.bottom+20);
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:_isCompany==YES?@"003-10-04":@"003-10-05" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:_isCompany==YES?@"003-10-04":@"003-10-05" type:2];
#endif
}

@end
