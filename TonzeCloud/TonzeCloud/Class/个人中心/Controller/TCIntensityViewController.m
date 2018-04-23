//
//  TCIntensityViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCIntensityViewController.h"
#import "TCIntensityTableViewCell.h"
#import "TCLaborModel.h"

@interface TCIntensityViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray   *workArray;
    UITableView      *intensityTabView;
}
@end
@implementation TCIntensityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"劳动强度";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    workArray =[[NSMutableArray alloc] init];

    [self initIntensityView];
    [self getLaborIntensityData];
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TCLaborModel *model=workArray[indexPath.row];
    [cell cellDisplayWithLabor:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCLaborModel *model=workArray[indexPath.row];
    [self.controllerDelegate intensityViewControllerDidSelectLaborIntensity:model.title];
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCLaborModel *labor=workArray[indexPath.row];
    return [TCIntensityTableViewCell getCellHeightWithLabor:labor];
}

#pragma mark 获取劳动强度数据
-(void)getLaborIntensityData{
    NSArray *laborArr=[TCHelper sharedTCHelper].laborInstensityArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in laborArr) {
        TCLaborModel *labor=[[TCLaborModel alloc] init];
        [labor setValues:dict];
        if ([self.laborIntensity isEqualToString:labor.title]) {
            labor.isSelected=[NSNumber numberWithBool:YES];
        }else{
            labor.isSelected=[NSNumber numberWithBool:NO];
        }
        [tempArr addObject:labor];
    }
    workArray=tempArr;
    [intensityTabView reloadData];
}

#pragma mark--初始化界面
- (void)initIntensityView{
    intensityTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 10, kScreenWidth,kRootViewHeight - 10) style:UITableViewStylePlain];
    intensityTabView.delegate=self;
    intensityTabView.dataSource=self;
    intensityTabView.showsVerticalScrollIndicator=NO;
    [intensityTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:intensityTabView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
