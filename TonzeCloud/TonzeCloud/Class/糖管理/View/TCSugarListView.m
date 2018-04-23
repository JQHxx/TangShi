//
//  TCSugarListView.m
//  TonzeCloud
//
//  Created by vision on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSugarListView.h"
#import "TCSugarListTableViewCell.h"

@interface TCSugarListView ()<UITableViewDelegate,UITableViewDataSource>{
    UILabel    *headLbl;
}

@property (nonatomic,strong)UIView      *headView;
@property (nonatomic,strong)UITableView *listTableView;

@end

@implementation TCSugarListView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headView];
        [self addSubview:self.listTableView];
    }
    return self;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sugarRecordList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"TCSugarListTableViewCell";
    TCSugarListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[TCSugarListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    TCSugarModel *model=self.sugarRecordList[indexPath.row];
    [cell listCellDisplayWithModel:model];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCSugarModel *model=self.sugarRecordList[indexPath.row];
    if ([_viewDelegate respondsToSelector:@selector(sugarListViewDidSelectModel:)]) {
        [_viewDelegate sugarListViewDidSelectModel:model];
    }
}

#pragma mark -- getters
#pragma mark 头部视图
-(UIView *)headView{
    if (!_headView) {
        _headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60)];
        _headView.backgroundColor=[UIColor whiteColor];
        
        headLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, _headView.width-20, 30)];
        headLbl.text=self.headTitleStr;
        headLbl.textAlignment=NSTextAlignmentCenter;
        headLbl.font=[UIFont boldSystemFontOfSize:15];
        [_headView addSubview:headLbl];
        
        UILabel *timeHeadLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, headLbl.bottom, (self.width-50)/2.0, 30)];
        timeHeadLbl.text=@"时间";
        timeHeadLbl.textAlignment=NSTextAlignmentCenter;
        timeHeadLbl.font=[UIFont systemFontOfSize:14];
        [_headView addSubview:timeHeadLbl];
        
        UILabel *valueHeadLbl=[[UILabel alloc] initWithFrame:CGRectMake(timeHeadLbl.right, headLbl.bottom, (self.width-50)/2.0, 30)];
        valueHeadLbl.text=@"血糖值";
        valueHeadLbl.textAlignment=NSTextAlignmentCenter;
        valueHeadLbl.font=[UIFont systemFontOfSize:14];
        [_headView addSubview:valueHeadLbl];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 59, kScreenWidth, 0.5)];
        line.backgroundColor=kLineColor;
        [_headView addSubview:line];
    }
    return _headView;
}

#pragma mark 血糖数值表
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 60,self.width, self.height-60) style:UITableViewStylePlain];
        _listTableView.dataSource=self;
        _listTableView.delegate=self;
        _listTableView.tableFooterView=[[UIView alloc] init];
    }
    return _listTableView;
}


-(void)setHeadTitleStr:(NSString *)headTitleStr{
    _headTitleStr=headTitleStr;
    headLbl.text=headTitleStr;
}



@end
