//
//  TCRecordSugarDetailsViewController.m
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCRecordSugarDetailsViewController.h"
#import "TCRecordDietViewController.h"
#import "TCRecordSportViewController.h"
#import "TCEditAndAddRemindViewController.h"
#import "TCTaskTableViewCell.h"

@interface TCRecordSugarDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UILabel          *contentlbl;
    UILabel          *reminderLbl;
    NSMutableArray   *taskListArr;
}
@property (nonatomic,strong)UIScrollView  *rootScrollView;
@property (nonatomic,strong)UIView        *sugarInfoView;    //血糖信息
@property (nonatomic,strong)UIView        *contentView;      //判断结果
@property (nonatomic,strong)UITableView   *taskTableView;    //推荐任务

@end

@implementation TCRecordSugarDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"血糖详情";
    self.isHiddenBackBtn=YES;
    self.rigthTitleName=@"确定";
    
    taskListArr=[[NSMutableArray alloc] init];
    
    [self initRecordSugarDetailsView];
    
    if (self.isDeviceMesureIn) {
        [self reloadSugarBloodDetailViewWithResult:self.sugarDict];
    }else{
       [self requestSugarResultInfo];
    }
    
    //获取积分
    if (!self.isEditSugarRecord) {
        [self requestForGetIntegral];
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return taskListArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"TCTaskTableViewCell";
    TCTaskTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[TCTaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryNone;

    NSDictionary *taskDict=taskListArr[indexPath.row];
    [cell taskCellDisplayWithDict:taskDict];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *taskDict=taskListArr[indexPath.row];
    NSString *taskStr=taskDict[@"key"];
    if ([taskStr isEqualToString:@"task1"]) {
        TCRecordDietViewController *recordDietVC=[[TCRecordDietViewController alloc] init];
        [self.navigationController pushViewController:recordDietVC animated:YES];
    }else if ([taskStr isEqualToString:@"task2"]){
        TCRecordSportViewController *recordSportsVC=[[TCRecordSportViewController alloc] init];
        [self.navigationController pushViewController:recordSportsVC animated:YES];
    }else if([taskStr isEqualToString:@"task3"]){
        TCEditAndAddRemindViewController *addRemindersVC=[[TCEditAndAddRemindViewController alloc] init];
        addRemindersVC.remindType=BloodSugarRemind;
        addRemindersVC.minutesLater=[taskDict[@"minute"] integerValue];
        [self.navigationController pushViewController:addRemindersVC animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (taskListArr.count>0) {
        UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        headView.backgroundColor=[UIColor bgColor_Gray];
        
        UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(15, 20, (kScreenWidth-30-100)/2, 1)];
        line1.backgroundColor=[UIColor colorWithHexString:@"#999999"];
        [headView addSubview:line1];
        
        UILabel *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(line1.right, 5, 100, 30)];
        titleLbl.textColor=[UIColor colorWithHexString:@"#999999"];
        titleLbl.textAlignment=NSTextAlignmentCenter;
        titleLbl.font=[UIFont systemFontOfSize:14];
        titleLbl.text=@"推荐任务";
        [headView addSubview:titleLbl];
        
        UILabel *line2=[[UILabel alloc] initWithFrame:CGRectMake(titleLbl.right, 20, (kScreenWidth-30-100)/2, 1)];
        line2.backgroundColor=[UIColor colorWithHexString:@"#999999"];
        [headView addSubview:line2];
        
        return headView;
    }else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (taskListArr.count>0) {
        return 40;
    }else{
        return 0.01;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

#pragma mark -- Event Response
-(void)rightButtonAction{
    [TCHelper sharedTCHelper].isSugarDetailBack = YES;
    if (self.isDeviceMesureIn) {
         [self.navigationController popViewControllerAnimated:YES];
    }else if (self.isSugarData){
        UIViewController *viewCtl = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:viewCtl animated:YES];
    }else if(self.isEditSugarRecord){
        UIViewController *viewCtl = self.navigationController.viewControllers[2];
        [self.navigationController popToViewController:viewCtl animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -- Private Methods
#pragma mark 初始化界面
-(void)initRecordSugarDetailsView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.sugarInfoView];
    [self.rootScrollView addSubview:self.contentView];
    [self.rootScrollView addSubview:self.taskTableView];
}

#pragma mark 获取血糖判断详情
-(void)requestSugarResultInfo{
    kSelfWeak;
    NSString *body=[NSString stringWithFormat:@"time_slot=%@&glucose=%.1f",self.timeSlotStr,self.sugarValue];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kBloodSugarResult body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            [weakSelf reloadSugarBloodDetailViewWithResult:result];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  获取积分
-(void)requestForGetIntegral{
    [self getTaskPointsWithActionType:6 isTaskList:NO taskAleartViewClickBlock:^(NSInteger clickIndex, BOOL isBack) {
        
    }]; // 获取积分
    NSString *periodString = [[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:_timeSlotStr];
    NSDictionary *normalRangeDict=[[TCHelper sharedTCHelper] getNormalValueDictWithPeriodString:periodString];
    double normalMinValue=[normalRangeDict[@"min"] doubleValue];
    double normalMaxValue=[normalRangeDict[@"max"] doubleValue];
    NSInteger messageTitle = 0;
    if (self.sugarValue<normalMinValue) {
        messageTitle = 3;
    }else if (self.sugarValue>=normalMinValue&&self.sugarValue<=normalMaxValue){
        messageTitle = 1;
    }else{
        messageTitle = 2;
    }
    NSInteger timeString =[[TCHelper sharedTCHelper] timeSwitchTimestamp:[[TCHelper sharedTCHelper] getCurrentDateTime] format:@"yyyy-MM-dd HH:mm"];
    NSString *messageBody = [NSString stringWithFormat:@"time_slot=%@&glucose=%.1f&status=%ld&measurement_time=%ld",self.timeSlotStr,self.sugarValue,(long)messageTitle,timeString];
    [[TCHttpRequest  sharedTCHttpRequest] postMethodWithURL:kV1_3SendMessage body:messageBody success:^(id json) {
        MyLog(@"-------------%@",json);
    } failure:^(NSString *errorStr) {
        
    }];//发送血糖提醒
}

#pragma mark 更新界面
-(void)reloadSugarBloodDetailViewWithResult:(NSDictionary *)result{
    //文字内容
    contentlbl.text=[result valueForKey:@"info"];
    CGFloat contentH=[contentlbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:contentlbl.font].height;
    contentlbl.frame=CGRectMake(15, 0, kScreenWidth-30, contentH);
    
    //图片
    NSArray *imagesArr=[result valueForKey:@"images"];
    CGFloat totalImageHeight=0.0;
    if (kIsArray(imagesArr)&&imagesArr.count>0) {
        for (NSInteger i=0; i<imagesArr.count; i++) {
            NSDictionary *imageDict=imagesArr[i];
            CGFloat imgH=[imageDict[@"height"] floatValue];
            CGFloat imgW=[imageDict[@"width"] floatValue];
            CGFloat imageHeight=(kScreenWidth-30)*(imgH/imgW);
            UIImageView *coverImageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, contentlbl.bottom+10+totalImageHeight, kScreenWidth-30, imageHeight)];
            [coverImageView sd_setImageWithURL:[NSURL URLWithString:imageDict[@"image_url"]] placeholderImage:[UIImage imageNamed:@""]];
            [self.contentView addSubview:coverImageView];
            totalImageHeight+=imageHeight;
        }
    }
    
    reminderLbl.frame=CGRectMake(15, contentH+20+totalImageHeight, kScreenWidth-30, 44);
    
    self.contentView.frame=CGRectMake(0, self.sugarInfoView.bottom, kScreenWidth, contentH+10+totalImageHeight+50);
    
    //推荐任务
    NSArray *arr=[result valueForKey:@"tasks"];
    taskListArr=[NSMutableArray arrayWithArray:arr];
    self.taskTableView.frame=CGRectMake(0, self.contentView.bottom+10, kScreenWidth, taskListArr.count*70+40);
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.taskTableView.top+self.taskTableView.height);
    [self.taskTableView reloadData];
}

#pragma mark -- Getters
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight)];
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator=NO;
    }
    return _rootScrollView;
}

#pragma mark 血糖记录信息
-(UIView *)sugarInfoView{
    if (!_sugarInfoView) {
        _sugarInfoView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        
        NSString *periodStr=[[TCHelper sharedTCHelper] getPeriodChNameForPeriodEn:self.timeSlotStr];
        
        UIImageView *bgImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, 10, 150, 150)];
        bgImageView.image=[UIImage imageNamed:[[TCHelper sharedTCHelper] getBgImageNameWithSugarValue:self.sugarValue period:periodStr]];
        [_sugarInfoView addSubview:bgImageView];
        
        UILabel *sugarValueLbl=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2+10, (150-50)/2+10, 130, 40)];
        sugarValueLbl.textAlignment=NSTextAlignmentCenter;
        sugarValueLbl.font=[UIFont boldSystemFontOfSize:48];
        sugarValueLbl.textColor=[[TCHelper sharedTCHelper] getTextColorWithSugarValue:self.sugarValue period:periodStr];
        sugarValueLbl.text=[NSString stringWithFormat:@"%.1f",self.sugarValue];
        [_sugarInfoView addSubview:sugarValueLbl];
        
        
        UILabel *unitLbl=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, sugarValueLbl.bottom, 100, 30)];
        unitLbl.textAlignment=NSTextAlignmentCenter;
        unitLbl.text=@"mmol/L";
        unitLbl.font=[UIFont systemFontOfSize:15];
        unitLbl.textColor=[UIColor colorWithHexString:@"#999999"];
        [_sugarInfoView addSubview:unitLbl];
        
        UILabel *timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(30,bgImageView.bottom, kScreenWidth-60, 30)];
        timeLbl.textAlignment=NSTextAlignmentCenter;
        timeLbl.font=[UIFont systemFontOfSize:14];
        timeLbl.textColor=[UIColor colorWithHexString:@"#999999"];
        timeLbl.text=[NSString stringWithFormat:@"%@ %@",self.measureTimeStr,periodStr];
        [_sugarInfoView addSubview:timeLbl];
        
    }
    return _sugarInfoView;
}

#pragma mark 判断结果
-(UIView *)contentView{
    if (!_contentView) {
        _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, self.sugarInfoView.bottom, kScreenWidth, 30)];
        
        contentlbl=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 30)];
        contentlbl.textColor=[UIColor blackColor];
        contentlbl.font=[UIFont systemFontOfSize:16];
        contentlbl.numberOfLines=0;
        [_contentView addSubview:contentlbl];
        
        reminderLbl=[[UILabel alloc] initWithFrame:CGRectMake(15, contentlbl.bottom+10,kScreenWidth-30, 44)];
        reminderLbl.backgroundColor=[UIColor colorWithHexString:@"#fff4eb"];
        reminderLbl.textAlignment=NSTextAlignmentCenter;
        reminderLbl.numberOfLines=2;
        reminderLbl.font=[UIFont systemFontOfSize:13];
        reminderLbl.textColor=[UIColor colorWithHexString:@"#fc7a5c"];
        reminderLbl.text=@"以上建议为糖士系统为您定制，仅供参考，\n特殊情况请遵医嘱。";
        [_contentView addSubview:reminderLbl];
        
    }
    return _contentView;
}

#pragma mark 推荐任务
-(UITableView *)taskTableView{
    if (!_taskTableView) {
        _taskTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.contentView.bottom, kScreenWidth, 120) style:UITableViewStylePlain];
        _taskTableView.dataSource=self;
        _taskTableView.delegate=self;
        _taskTableView.scrollEnabled=NO;
        _taskTableView.backgroundColor=[UIColor bgColor_Gray];
        _taskTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _taskTableView;
}


@end
