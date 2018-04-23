//
//  TCExpertDetailController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/20.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCExpertDetailController.h"
#import "TCDetailButton.h"
#import "TCImageConsultViewController.h"
#import "TCPlanConsultViewController.h"
#import "TCExpertDetailModel.h"
#import "TCEvaluateModel.h"
#import "TCEvaluateTableViewCell.h"
#import "TCEvaluateListViewController.h"

@interface TCExpertDetailController ()<UITableViewDelegate,UITableViewDataSource>{
    
    UIView       *bgView;
    UIImageView  *headImg;      //头像
    UIButton     *careButton;   //＋关注
    UILabel      *expertDetail; //专家详情
    UILabel      *nameLabel;    //姓名
    UILabel      *titleLabel;   //职业
    UILabel      *careLabel;    //关注人数
    UILabel      *serviceLabel; //服务人数
    UILabel      *contentLabel;
    UILabel      *expertText;   //专家详情
    UIView       *bgwhiteView;
    BOOL          isCare;       //是否关注
    
    
    TCExpertDetailModel  *expertDetailModel;
    NSMutableArray  *newMessageArray;
}
@property (nonatomic,strong)UIScrollView         *rootScrollView;    //根滚动视图
@property (nonatomic,strong)UITableView          *tableView;
@end

@implementation TCExpertDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"专家详情";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    expertDetailModel=[[TCExpertDetailModel alloc] init];
    
    [self initDetailView];
    [self requestExpertDetailData];
    
    if (!kIsLogined &&self.isNeedLogin) {
        [self fastLoginAction];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-04-01" type:1];
#endif
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"006-04-01" type:2];
#endif
}
- (void)leftButtonAction{
    if (self.leftActionBlock) {
        self.leftActionBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --UITableViewDelegate or UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return expertDetailModel.commentNum>5?5:newMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCEvaluateTableViewCell";
    TCEvaluateTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCEvaluateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCEvaluateModel *model=newMessageArray[indexPath.row];
    cell.evaluateModel=model;
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCEvaluateModel *model=newMessageArray[indexPath.row];
    return [TCEvaluateTableViewCell getEvaluateCellHeightWithModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return expertDetailModel.commentNum>5?40:0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    footView.backgroundColor = [UIColor whiteColor];
    if (expertDetailModel.commentNum>5) {
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-15, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [footView addSubview:line];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, kScreenWidth, 25)];
        NSString *buttonTitle = [NSString stringWithFormat:@"全部评价(%ld)",(long)expertDetailModel.commentNum];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextNewMessageBtn) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:button];
    }
    
    return footView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    headView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth/2, 15)];
    textLabel.text = @"评价";
    textLabel.font = [UIFont systemFontOfSize:15];
    textLabel.textColor = [UIColor grayColor];
    [headView addSubview:textLabel];
    
    return headView;
    
}

#pragma mark -- Event response
#pragma mark -- 添加关注
- (void)carebutton{
    [MobClick event:@"101_003017"];
    
    isCare = !isCare;
    kSelfWeak;
    NSString *urlString = [NSString stringWithFormat:@"focus=%d&expert_id=%ld",isCare==0?2:1,(long)_expert_id];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kCancleCare body:urlString success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSInteger focus_status = [[result objectForKey:@"focus_status"] integerValue];
            if (focus_status!=2) {
                [careButton setTitle: focus_status==0?@"＋关注":@"已关注" forState:UIControlStateNormal];
            }else{
                [careButton setTitle:@"互相关注" forState:UIControlStateNormal];
            }
        }
        [TCHelper sharedTCHelper].isCancleCare = YES;
        [self requestExpertDetailData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- 全部评论
- (void)nextNewMessageBtn{
    TCEvaluateListViewController *evaluateListVC = [[TCEvaluateListViewController alloc] init];
    evaluateListVC.expert_id = self.expert_id;
    [self.navigationController pushViewController:evaluateListVC animated:YES];
    
}
#pragma mark -- 图文咨询和疗养方案
- (void)imageConsult:(UIButton *)button{
    if (button.tag == 101) {
        if (expertDetailModel.graphic_status!=0) {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"006-03-01"];
#endif
            [MobClick event:@"101_003018"];
            TCPlanConsultViewController *planConsultVC = [[TCPlanConsultViewController alloc] init];
            planConsultVC.expert_id=expertDetailModel.id;
            [self.navigationController pushViewController:planConsultVC animated:YES];
        }
    } else {
        if (expertDetailModel.customized_status!=0) {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"006-03-03"];
#endif
            [MobClick event:@"101_003019"];
            
            TCImageConsultViewController *imageConsultVC = [[TCImageConsultViewController alloc] init];
            imageConsultVC.expertId = expertDetailModel.id;
            imageConsultVC.position =2;
            [self.navigationController pushViewController:imageConsultVC animated:YES];
        }
    }
}


#pragma mark -- Event methods
#pragma mark -- 获取专家详情数据
- (void)requestExpertDetailData{
    kSelfWeak;
    NSString *urlString = [NSString stringWithFormat:@"%@?expert_id=%ld",kExpertDetail,(long)_expert_id];
    [[TCHttpRequest  sharedTCHttpRequest] getMethodWithURL:urlString success:^(id json) {
        NSDictionary *dataDic = [json objectForKey:@"result"];
        if (kIsDictionary(dataDic)) {
            [expertDetailModel setValues:dataDic];
            
            NSString *url = expertDetailModel.head_portrait;
            [headImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
            
            nameLabel.text =expertDetailModel.name;    
            titleLabel.text =expertDetailModel.positional_titles;
            careLabel.text =[NSString stringWithFormat:@"%ld",(long)expertDetailModel.attention_count];
            serviceLabel.text = [NSString stringWithFormat:@"%ld",(long)expertDetailModel.service_num];
            expertDetail.text =expertDetailModel.brief_introduction;
            if (expertDetailModel.focus_status!=2) {
                [careButton setTitle: expertDetailModel.focus_status==0?@"＋关注":@"已关注" forState:UIControlStateNormal];
            }else{
                [careButton setTitle:@"互相关注" forState:UIControlStateNormal];
            }
            careButton.titleLabel.font = [UIFont systemFontOfSize:15];
            isCare =expertDetailModel.focus_status;
            [self createTitleView];
        }else{
            contentLabel.frame = CGRectMake(15, expertText.bottom+20, kScreenWidth/3, 25);
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark 获取最新数据
-(void)requestNewHomeData{
    [MobClick event:@"101_001012"];

    if (expertDetailModel.commentList.count>0) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSDictionary *dict in expertDetailModel.commentList) {
            
            TCEvaluateModel *model=[[TCEvaluateModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        newMessageArray=tempArr;
        [self.tableView reloadData];
        self.tableView.frame = CGRectMake(0, contentLabel.bottom+160, kScreenWidth, _tableView.contentSize.height);
        self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.tableView.bottom+10);
    }
}
#pragma mark --创建Foot视图
- (void)createTitleView{
    NSMutableParagraphStyle *paraStyle=[[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment=NSTextAlignmentLeft;
    paraStyle.headIndent=0.0f;
    CGFloat emptylen=contentLabel.font.pointSize*2;
    paraStyle.firstLineHeadIndent=emptylen; //首行缩进
    paraStyle.lineSpacing=2.0f;//行间距
    
    NSAttributedString *attrText=[[NSAttributedString alloc] initWithString:expertDetail.text attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    expertDetail.attributedText=attrText;
    
    CGFloat contentHeight=[expertDetail.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:expertDetail.font,NSFontAttributeName,nil] context:nil].size.height;
    if ([expertDetail.text isEqualToString:@""]) {
        contentHeight = 0;
        expertDetail.frame=CGRectMake(15, expertText.bottom+10, 0, 0);
    } else {
        expertDetail.frame=CGRectMake(15, expertText.bottom+10, kScreenWidth-30, contentHeight+20);
    }
    bgwhiteView.frame = CGRectMake(0, expertDetail.top-10, kScreenWidth,contentHeight+40);
    contentLabel.frame = CGRectMake(15, bgwhiteView.bottom, kScreenWidth/3, 25);
    
    for (int i=0; i<2; i++) {
        TCDetailButton *imageBtn = [[TCDetailButton alloc] initWithFrame:CGRectMake(kScreenWidth/2*i, contentLabel.bottom, kScreenWidth/2,140)];
        imageBtn.tag = 101+i;
        imageBtn.backgroundColor = [UIColor whiteColor];
        if (i==0) {
            imageBtn.headImage.image = expertDetailModel.graphic_status==1?[UIImage imageNamed:@"fw_img_zixun"]:[UIImage imageNamed:@"fw_img_zixun_un"];
        } else {
              imageBtn.headImage.image =expertDetailModel.customized_status==1?[UIImage imageNamed:@"fw_img_plan"]:[UIImage imageNamed:@"fw_img_plan_un"];
        }
        imageBtn.expertName.text = i==0?@"图文咨询":@"营养服务";
        [imageBtn addTarget:self action:@selector(imageConsult:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:imageBtn];
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, imageBtn.bottom);
    }
    [self.rootScrollView addSubview:self.tableView];
    [self requestNewHomeData];

}

#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initDetailView{
    self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kRootViewHeight)];
    self.rootScrollView.showsVerticalScrollIndicator=NO;
    self.rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:self.rootScrollView];
    
    UIView *whiteview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    whiteview.backgroundColor = [UIColor whiteColor];
    [self.rootScrollView addSubview:whiteview];
    
    headImg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-31,20, 62, 62)];
    headImg.clipsToBounds=YES;
    headImg.layer.cornerRadius = 31;
    [self.rootScrollView addSubview:headImg];
    
    careButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80,20, 65, 25)];
    [careButton setTitleColor:kbgBtnColor forState:UIControlStateNormal];
    careButton.layer.cornerRadius = 4;
    [careButton.layer setBorderWidth:1]; //设置边界宽度
    [careButton setTitle:@"+关注" forState:UIControlStateNormal];
    careButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){5.0/256, 211.0/256, 128.0/256,1 });
    [careButton.layer setBorderColor:colorref];//边框颜色
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(colorref);
    [careButton addTarget:self action:@selector(carebutton) forControlEvents:UIControlEventTouchUpInside];
    [self.rootScrollView addSubview:careButton];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, headImg.bottom+15, kScreenWidth-20, 20)];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.rootScrollView addSubview:nameLabel];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nameLabel.bottom+5, kScreenWidth-20, 20)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.rootScrollView addSubview:titleLabel];
    whiteview.frame = CGRectMake(0, 0, kScreenWidth, titleLabel.bottom+5);
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, whiteview.bottom+1, kScreenWidth, 70)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollView addSubview:bgView];
    
    careLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth/2, 20)];
    careLabel.textColor = [UIColor colorWithHexString:@"#ffd655"];
    careLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:careLabel];
    
    serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 10, kScreenWidth/2, 20)];
    serviceLabel.textColor = kbgBtnColor;
    serviceLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:serviceLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 7, 1, bgView.height-14)];
    lineLabel.backgroundColor = [UIColor bgColor_Gray];
    [bgView addSubview:lineLabel];
    
    for (int i=0; i<2; i++) {
        UILabel *careText = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2*i, serviceLabel.bottom,kScreenWidth/2, 20)];
        careText.text = i==0? @"关注人数": @"服务人数";
        careText.textColor = i==0?[UIColor colorWithHexString:@"#ffd655"]:kbgBtnColor;
        careText.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:careText];
    }
    
    expertText = [[UILabel alloc] initWithFrame:CGRectMake(15, bgView.bottom, kScreenWidth/2, 26)];
    expertText.text = @"专家简介";
    expertText.font = [UIFont systemFontOfSize:12];
    expertText.textColor = [UIColor colorWithHexString:@"#707070"];
    [self.rootScrollView addSubview:expertText];
    
    //专家简介
    bgwhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, expertText.bottom+5, kScreenWidth, 0)];
    bgwhiteView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollView addSubview:bgwhiteView];
    
    expertDetail= [[UILabel alloc] initWithFrame:CGRectZero];
    expertDetail.backgroundColor = [UIColor whiteColor];
    expertDetail.numberOfLines = 0;
    expertDetail.font = [UIFont systemFontOfSize:12];
    [self.rootScrollView addSubview:expertDetail];

    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, expertDetail.bottom+10, kScreenWidth/3, 20)];
    contentLabel.text = @"服务内容";
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.textColor = [UIColor grayColor];
    [self.rootScrollView addSubview:contentLabel];
    
}

#pragma mark -- setter
- (UITableView *)tableView{
    if (_tableView==nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
@end
