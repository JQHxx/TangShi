//
//  TCWorkRankViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWorkRankViewController.h"
#import "AppDelegate.h"
#import "TCIntensityTableViewCell.h"
#import "TCUserTool.h"
#import "TCLaborModel.h"
#import "AppDelegate.h"
#import "BaseTabBarViewController.h"

@interface TCWorkRankViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray      *workArray;
    UITableView         *intensityTabView;
    
    TCLaborModel        *selLabor;
}
@end

@implementation TCWorkRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"劳动强度";
    
    workArray=[[NSMutableArray alloc] init];
    selLabor=[[TCLaborModel alloc] init];

    [self initWorkRankView];
    [self loadLaborData];
}


#pragma mark -- Event Response
#pragma mark -- 完成
- (void)accomplishButton{
    if (selLabor.title.length>0) {
        NSString *infomationString = [NSString stringWithFormat:@"name=%@&sex=%@&birthday=%@&height=%@&weight=%.1f&labour_intensity=%@&doSubmit=1",@"",          [[TCUserTool sharedTCUserTool].userDict objectForKey:@"sex"],
                                      [[TCUserTool sharedTCUserTool].userDict objectForKey:@"age"],
                                      [[TCUserTool sharedTCUserTool].userDict objectForKey:@"height"],
                                      [[[TCUserTool sharedTCUserTool].userDict objectForKey:@"weight"] floatValue],selLabor.title];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kAddMineInformation body:infomationString success:^(id json) {
            
            //计算每日目标摄入
        [[TCHelper sharedTCHelper] calculateTargetIntakeEnergyWithHeight:[[[TCUserTool sharedTCUserTool].userDict objectForKey:@"height"] integerValue] weight:[[[TCUserTool sharedTCUserTool].userDict objectForKey:@"weight"] doubleValue] labor:selLabor.title];
            BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
            AppDelegate *appDelegate=kAppDelegate;
            appDelegate.window.rootViewController=tabbarVC;
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        [self.view makeToast:@"请设置劳动强度" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return workArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCIntensityTableViewCell";
    TCIntensityTableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[TCIntensityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TCLaborModel *labor=workArray[indexPath.row];
    [cell cellDisplayWithLabor:labor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selLabor=workArray[indexPath.row];
    for (TCLaborModel *model in workArray) {
        if ([model.title isEqualToString:selLabor.title]) {
            model.isSelected=[NSNumber numberWithBool:YES];
        }else{
            model.isSelected=[NSNumber numberWithBool:NO];
        }
    }
    [intensityTabView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCLaborModel *labor=workArray[indexPath.row];
    return [TCIntensityTableViewCell getCellHeightWithLabor:labor];
}
#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initWorkRankView{

    intensityTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 10, kScreenWidth,kRootViewHeight - 10) style:UITableViewStylePlain];
    intensityTabView.delegate=self;
    intensityTabView.dataSource=self;
    intensityTabView.showsVerticalScrollIndicator=NO;
    [intensityTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:intensityTabView];

    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, kScreenHeight-80, 150, 40)];
    [nextButton setTitle:@"完成" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    nextButton.backgroundColor = kbgBtnColor;
    [nextButton addTarget:self action:@selector(accomplishButton) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 5;
    [self.view addSubview:nextButton];

}

#pragma mark 加载劳动强度
-(void)loadLaborData{
    NSArray *laborArr=[TCHelper sharedTCHelper].laborInstensityArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in laborArr) {
        TCLaborModel  *labor=[[TCLaborModel alloc] init];
        [labor setValues:dict];
        labor.isSelected=[NSNumber numberWithBool:NO];
        [tempArr addObject:labor];
    }
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    for (int i=0; i<tempArr.count; i++) {
        TCLaborModel  *labor = tempArr[i];
        if (i==1) {
            labor.isSelected = [NSNumber numberWithBool:YES];
        }
        [dataArr addObject:labor];
    }
    workArray=dataArr;
    selLabor=workArray[1];
    [intensityTabView reloadData];}

@end
