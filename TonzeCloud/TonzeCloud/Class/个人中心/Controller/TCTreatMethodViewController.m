//
//  TCTreatMethodViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCTreatMethodViewController.h"
#import "TCTreatTableViewCell.h"
#import "TCFilesViewController.h"

@interface TCTreatMethodViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
        UITableView    *treatMethodTabView;
        NSArray        *_titleArray;
}
@end

@implementation TCTreatMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"治疗方式";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    _titleArray=@[@"口服药",@"胰岛素",@"饮食控制",@"运动控制",@"中成药"];
    self.rigthTitleName = @"保存";
    [self inittreatMethodView];
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCTreatTableViewCell";
    TCTreatTableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[TCTreatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dict=nil;
    dict=@{@"title":_titleArray[indexPath.row],
           @"image":_imageArray[indexPath.row]};
      [cell cellDisplayWithDict:dict];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_imageArray[indexPath.row] isEqualToString:@"1"]) {
        [_imageArray replaceObjectAtIndex:indexPath.row withObject:@"0"];
    } else {
        [_imageArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
    }
    [treatMethodTabView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}
#pragma mark -- Event response
#pragma mark 导航栏右侧按钮事件
-(void)rightButtonAction{
    
    [self.delegate returnName:_imageArray];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- Custom Methods
#pragma mark--初始化界面
- (void)inittreatMethodView{
    treatMethodTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight + 10, kScreenWidth,kRootViewHeight - 10) style:UITableViewStylePlain];
    treatMethodTabView.delegate=self;
    treatMethodTabView.dataSource=self;
    treatMethodTabView.showsVerticalScrollIndicator=NO;
    treatMethodTabView.backgroundColor = kbgView;
    [treatMethodTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    treatMethodTabView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.view addSubview:treatMethodTabView];
}
@end
