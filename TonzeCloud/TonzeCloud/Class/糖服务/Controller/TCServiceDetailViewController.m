//
//  TCServiceDetailViewController.m
//  TonzeCloud
//
//  Created by vision on 17/6/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceDetailViewController.h"
#import "TCServiceEvaluateViewController.h"
#import "TCevaluateDetailView.h"

@interface TCServiceDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray                *serviceTitleArr;
    NSMutableArray         *serviceValueArr;
    UILabel                *evaluateTimeLab;       //评价时间
    TCevaluateDetailView   *evaluateDetailView;    //评价服务
    UILabel                *contentLabel;          //评价说明
    UILabel                *noneEvaluateLab;
    UIButton               *evaluateButton;
}

@property (nonatomic,strong)UIScrollView  *rootScrollView;    //根滚动视图
@property (nonatomic,strong)UITableView   *detailTableView;   //服务详情
@property (nonatomic,strong)UIView        *evaluateView;       //评价

@end

@implementation TCServiceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"服务详情";
    
    serviceTitleArr=self.myService.type==1?@[@"服务类型",@"专家姓名",@"开始时间",@"结束时间",@"订单价格"]:@[@"服务类型",@"方案名称",@"专家姓名",@"开始时间",@"结束时间",@"订单价格"];
    serviceValueArr=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.detailTableView];
    [self.rootScrollView addSubview:self.evaluateView];
    
    [self parserServiceDetailInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TCHelper sharedTCHelper].isReloadMyServiceDetail) {
        [self parserServiceDetailInfo];
        [TCHelper sharedTCHelper].isReloadMyServiceDetail=NO;
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return serviceTitleArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=serviceTitleArr[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    if (serviceValueArr.count>0) {
        cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",serviceValueArr[indexPath.row]];
        if (indexPath.row==serviceTitleArr.count-1) {
            cell.detailTextLabel.textColor=kRGBColor(254, 156, 40);
        }
    }
    return cell;
}

#pragma mark 评价
-(void)gotoEvaluateServiceAction{
    TCServiceEvaluateViewController *evaluateVC=[[TCServiceEvaluateViewController alloc] init];
    evaluateVC.order_id=self.myService.order_id;
    [self.navigationController pushViewController:evaluateVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 获取服务详情数据
-(void)parserServiceDetailInfo{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"order_sn=%@",self.myService.order_sn];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kOrderDetail body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            TCMineServiceModel *serviceModel=[[TCMineServiceModel alloc] init];
            [serviceModel setValues:result];
            
            NSString *serviceType=serviceModel.type==1?@"图文咨询":@"疗养方案";
            [serviceValueArr addObject:serviceType];
            if (serviceModel.type!=1) {
                [serviceValueArr addObject:weakSelf.myService.scheme_name];
            }
            [serviceValueArr addObject:serviceModel.expert_name];
            NSString *serviceStartDate=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:serviceModel.start_time format:@"yyyy-MM-dd HH:mm:ss"];
            [serviceValueArr addObject:serviceStartDate];
            NSString *serviceEndDate=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:serviceModel.end_time format:@"yyyy-MM-dd HH:mm:ss"];
            [serviceValueArr addObject:serviceEndDate];
            double price=[serviceModel.pay_money doubleValue];
            [serviceValueArr addObject:[NSString stringWithFormat:@"¥%.2f",price]];
            
            
            if (serviceModel.service_status==2) {
                BOOL isCommented=[serviceModel.is_commented boolValue];
                if (isCommented) {
                    evaluateDetailView.hidden=evaluateTimeLab.hidden=NO;
                    noneEvaluateLab.hidden=evaluateButton.hidden=YES;
                    evaluateDetailView.myService=serviceModel;
                    
                    //评价时间
                    evaluateTimeLab.text=[[TCHelper sharedTCHelper] timeWithTimeIntervalString:serviceModel.comment_time format:@"yyyy-MM-dd"];
                    //评价内容
                    contentLabel.text=serviceModel.msg;
                    CGFloat contentH=[serviceModel.msg boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:14]].height;
                    contentLabel.frame=CGRectMake(10, evaluateDetailView.bottom, kScreenWidth-20, contentH+10);
                    
                    weakSelf.evaluateView.frame=CGRectMake(0,serviceTitleArr.count*44+10, kScreenWidth, 65+contentH+100);
                    weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, weakSelf.evaluateView.top+weakSelf.evaluateView.height);
                }else{
                    evaluateDetailView.hidden=evaluateTimeLab.hidden=YES;
                    noneEvaluateLab.hidden=evaluateButton.hidden=NO;
                }
            }else{
                noneEvaluateLab.hidden=NO;
                evaluateButton.hidden=YES;
            }
        
            [weakSelf.detailTableView reloadData];
            
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  -- Gettsers
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark 服务详情
-(UITableView *)detailTableView{
    if (!_detailTableView) {
        _detailTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,serviceTitleArr.count*44) style:UITableViewStylePlain];
        _detailTableView.delegate=self;
        _detailTableView.dataSource=self;
        _detailTableView.scrollEnabled=NO;
        _detailTableView.backgroundColor=[UIColor whiteColor];
        _detailTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _detailTableView;
}

#pragma mark 评价
-(UIView *)evaluateView{
    if (!_evaluateView) {
        _evaluateView=[[UIView alloc] initWithFrame:CGRectMake(0, serviceTitleArr.count*44+10, kScreenWidth, 240)];
        _evaluateView.backgroundColor=[UIColor whiteColor];
        
        UILabel   *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 30)];
        titleLab.text=@"评价";
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textColor=[UIColor blackColor];
        [_evaluateView addSubview:titleLab];
        
        evaluateTimeLab=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, 5, 110, 30)];
        evaluateTimeLab.textAlignment=NSTextAlignmentRight;
        evaluateTimeLab.font=[UIFont systemFontOfSize:14];
        evaluateTimeLab.textColor=[UIColor lightGrayColor];
        [_evaluateView addSubview:evaluateTimeLab];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLab.bottom+5, kScreenWidth, 0.5)];
        line.backgroundColor=kLineColor;
        [_evaluateView addSubview:line];
        
        evaluateDetailView=[[TCevaluateDetailView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 100)];
        [_evaluateView addSubview:evaluateDetailView];
        evaluateDetailView.hidden=YES;
        
        contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,evaluateDetailView.bottom+10, kScreenWidth-20, 30)];
        contentLabel.font=[UIFont systemFontOfSize:14];
        contentLabel.textColor=[UIColor blackColor];
        contentLabel.numberOfLines=0;
        [_evaluateView addSubview:contentLabel];
        
        noneEvaluateLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 80, kScreenWidth-40, 30)];
        noneEvaluateLab.textAlignment=NSTextAlignmentCenter;
        noneEvaluateLab.textColor=[UIColor lightGrayColor];
        noneEvaluateLab.font=[UIFont systemFontOfSize:14];
        noneEvaluateLab.text=@"暂无评价";
        [_evaluateView addSubview:noneEvaluateLab];
        noneEvaluateLab.hidden=YES;
        
        evaluateButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, noneEvaluateLab.bottom+10, 150, 30)];
        [evaluateButton setTitle:@"评价" forState:UIControlStateNormal];
        evaluateButton.backgroundColor=kSystemColor;
        evaluateButton.layer.cornerRadius=5;
        evaluateButton.clipsToBounds=YES;
        [evaluateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [evaluateButton addTarget:self action:@selector(gotoEvaluateServiceAction) forControlEvents:UIControlEventTouchUpInside];
        [_evaluateView addSubview:evaluateButton];
        evaluateButton.hidden=YES;
        
    }
    return _evaluateView;
}

@end
