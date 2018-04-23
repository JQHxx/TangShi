//
//  TCInvitationRecordViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/11/14.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCInvitationRecordViewController.h"
#import "TCInvitationRecordTableViewCell.h"
#import "TCInvitationRecordModel.h"

@interface TCInvitationRecordViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray *invitationRecordArr;
    TCBlankView    *blankView;
    NSInteger       invitationRecordPage;
}

@property (nonatomic ,strong)UITableView *invitationRecordTab;

@end

@implementation TCInvitationRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"邀请记录";
    invitationRecordArr = [[NSMutableArray alloc] init];
    invitationRecordPage = 1;
    
    [self.view addSubview:self.invitationRecordTab];
    [self loadInvitationRecordData];
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return invitationRecordArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"TCInvitationRecordTableViewCell";
    TCInvitationRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[TCInvitationRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCInvitationRecordModel *model = invitationRecordArr[indexPath.row];
    [cell cellInvitationRecordModel:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 171;
}

#pragma mark -- Event Response
#pragma mark -- 获取邀请记录的数据
- (void)loadInvitationRecordData{
    
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",invitationRecordPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kGetInviteLists body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSDictionary *pager =[json objectForKey:@"pager"];
        NSInteger total = 0;
        if (kIsDictionary(pager)) {
            total = [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *recordArr = [[NSMutableArray alloc] init];
            for (NSDictionary *invitationDict in result) {
                TCInvitationRecordModel *recordModel = [[TCInvitationRecordModel alloc] init];
                [recordModel setValues:invitationDict];
                [recordArr addObject:recordModel];
            }
            if (invitationRecordPage==1) {
                invitationRecordArr = recordArr;
            } else {
                [invitationRecordArr addObjectsFromArray:recordArr];
            }
            blankView.hidden=invitationRecordArr.count>0;
            self.invitationRecordTab.mj_footer.hidden=(total -invitationRecordPage*20)<=0;
            self.invitationRecordTab.tableFooterView = (total -invitationRecordPage*20)<=0 ? [self tableViewMaxFooterView] : [UIView new];
        }else{
            self.invitationRecordTab.tableFooterView = [UIView new];
            self.invitationRecordTab.mj_footer.hidden = YES;
            blankView.hidden = NO;
        }
        [_invitationRecordTab reloadData];
        [self.invitationRecordTab.mj_header endRefreshing];
        [self.invitationRecordTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.invitationRecordTab.mj_header endRefreshing];
        [self.invitationRecordTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark  获取最新邀请记录数据
- (void)loadInvitationRecordNewData{
    invitationRecordPage = 1;
    [self loadInvitationRecordData];
}
#pragma mark  获取更多邀请亲友数据
- (void)loadInvitationRecordMoreData{
    invitationRecordPage ++;
    [self loadInvitationRecordData];
}
#pragma mark ======  没有更多 =======
- (UIView *)tableViewMaxFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多记录了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    
    return footerView;
}
#pragma mark -- setter or getter
- (UITableView *)invitationRecordTab{
    if (_invitationRecordTab==nil) {
        _invitationRecordTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _invitationRecordTab.backgroundColor = [UIColor bgColor_Gray];
        _invitationRecordTab.delegate = self;
        _invitationRecordTab.dataSource = self;
        _invitationRecordTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadInvitationRecordNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _invitationRecordTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadInvitationRecordMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _invitationRecordTab.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无成功邀请记录"];
        [_invitationRecordTab addSubview:blankView];
        blankView.hidden=YES;
    }

    return _invitationRecordTab;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
