    //
//  TCLookForMyViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCLookForMyViewController.h"
#import "TCFocusOnViewController.h"
#import "TCBeFocusOnViewController.h"
#import "TCLookFoMyModel.h"
#import "TCUserinfoViewController.h"
#import "TCDynamicDetailViewController.h"
#import "TCLookForMyTableViewCell.h"
#import "TCSetUpViewController.h"
#import "TCMyDynamicViewController.h"
#import "TCTopicDetailsViewController.h"

@interface TCLookForMyViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,TCLookForMyDelegate>{
    
    UIImageView           *sugarTypeImgView;
    UIImageView           *_sexImgView;
    UIImageView           *_headImageView;
    UILabel               *_nickNameLabel;
    TCBlankView           *blankView;
    NSMutableArray        *myDynamicArray;
    NSInteger             lookPage;
}

@property (nonatomic ,strong) UITableView  *myDynamicTab;
@property (nonatomic ,strong) UIView       *navigationView;
@end

@implementation TCLookForMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = @"@我的动态";
    self.rigthTitleName = @"设置";
    myDynamicArray = [[NSMutableArray alloc] init];
    lookPage= 1;
    
    [self initMyDynamicView];
    [self loadMyDynamicData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([TCHelper sharedTCHelper].isDeleteDynamic==YES) {
        [self loadMyDynamicData];
        [TCHelper sharedTCHelper].isDeleteDynamic = NO;
    }
    [[TCHelper sharedTCHelper] loginAction:@"008-13" type:1];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-13" type:2];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return myDynamicArray.count>0?myDynamicArray.count:0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier=@"TCLookForMyTableViewCell";
    TCLookForMyTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCLookForMyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCLookFoMyModel *myDynamicModel =myDynamicArray[indexPath.row];
    [cell cellLookForMyModel:myDynamicModel];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

        TCLookFoMyModel *myDynamicModel =myDynamicArray[indexPath.row];
    CGFloat height = [TCLookForMyTableViewCell tableView:tableView rowLookForMyHeightForModel:myDynamicModel];
        return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [MobClick event:@"105_003016"];
    [[TCHelper sharedTCHelper] loginClick:@"008-13-04"];
    TCLookFoMyModel *myDynamicModel =myDynamicArray[indexPath.row];
    TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
    dynamicDetailVC.news_id = myDynamicModel.news_id;
    dynamicDetailVC.commented_user_id = myDynamicModel.at_user_id;
    dynamicDetailVC.role_type_ed = [[myDynamicModel.news_info objectForKey:@"role_type"] integerValue];
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- TCMyDynamicDelegate
#pragma mark -- 查看话题
- (void)myLinkTopic:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{

    TCTopicDetailsViewController *topicVC = [[TCTopicDetailsViewController alloc] init];
    topicVC.topic_delete_status = topic_delete_status;
    topicVC.topic = topic;
    topicVC.topicId = topic_id;
    [self.navigationController pushViewController:topicVC animated:YES];
}
#pragma mark -- 查看评论
- (void)commentsLookForMyContent:(NSInteger)expert_id User_id:(NSInteger)user_id role_type_ed:(NSInteger)role_type_ed{
    [MobClick event:@"105_003017"];
    [[TCHelper sharedTCHelper] loginClick:@"008-13-05"];
    TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
    dynamicDetailVC.news_id = expert_id;
    dynamicDetailVC.commented_user_id = user_id;
    dynamicDetailVC.role_type_ed = role_type_ed;
    dynamicDetailVC.keyboradType = 1;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}

#pragma mark -- 点击头像／名字
- (void)myDynamicLookForMyContent:(TCLookFoMyModel *)model{
    [MobClick event:@"105_003014"];
    [[TCHelper sharedTCHelper] loginClick:@"008-13-02"];
    TCMyDynamicViewController *dynamicDetailVC = [[TCMyDynamicViewController alloc] init];
    dynamicDetailVC.news_id = model.at_user_id;
    dynamicDetailVC.role_type_ed = model.role_type;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];

}
#pragma mark -- 点击其他区域
- (void)myLinkLookForMyMoreContent:(NSInteger)expert_id User_id:(NSInteger)user_id role_type_ed:(NSInteger)role_type_ed{
    [[TCHelper sharedTCHelper] loginClick:@"008-13-04"];
    [MobClick event:@"105_003016"];
    TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
    dynamicDetailVC.news_id = expert_id;
    dynamicDetailVC.commented_user_id = user_id;
    dynamicDetailVC.role_type_ed =role_type_ed;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- 点击标记区域
- (void)myLinkSeletedClickContent:(TCLookFoMyModel *)model{
    [[TCHelper sharedTCHelper] loginClick:@"008-13-03"];
    [MobClick event:@"105_003015"];
    TCMyDynamicViewController *dynamicDetailVC = [[TCMyDynamicViewController alloc] init];
    dynamicDetailVC.news_id = model.ated_user_id;
    dynamicDetailVC.role_type_ed = model.role_type_ed;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- 点赞
- (void)myPraiseDynamic:(TCLookFoMyModel *)model{
    
    NSMutableArray *praiseArr = [[NSMutableArray alloc] init];
    for (TCLookFoMyModel *lookForMyModel in myDynamicArray) {
        if (lookForMyModel.news_id == model.news_id) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:model.news_info];
;
            if ([[dict objectForKey:@"is_like"] integerValue]==1) {
                [dict setValue:[NSString stringWithFormat:@"%ld",[[dict objectForKey:@"like_count"] integerValue]-1] forKey:@"like_count"];
            }else{
                [dict setValue:[NSString stringWithFormat:@"%ld",[[dict objectForKey:@"like_count"] integerValue]+1] forKey:@"like_count"];
                
            }
            [dict setValue:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"is_like"] integerValue]==1?0:1] forKey:@"is_like"];
            lookForMyModel.news_info = dict;
        }
        [praiseArr addObject:lookForMyModel];
    }
    myDynamicArray = praiseArr;
    [self.myDynamicTab reloadData];
}
#pragma mark -- Event response
#pragma mark -- 设置
- (void)rightButtonAction{
    [[TCHelper sharedTCHelper] loginClick:@"008-13-01"];
    [MobClick event:@"105_003013"];
    TCSetUpViewController *setUpVC = [[TCSetUpViewController alloc] init];
    setUpVC.type = 2;
    [self.navigationController pushViewController:setUpVC animated:YES];
}
#pragma mark -- 获取我的动态
- (void)loadMyDynamicData{
    
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=15&role_type_ed=0",lookPage];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KLoadAtedList body:body success:^(id json) {
        NSArray *lookArr = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(lookArr)&&lookArr.count>0) {
            NSMutableArray *lookFoMyArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in lookArr) {
                TCLookFoMyModel *lookForMyModel = [[TCLookFoMyModel alloc] init];
                [lookForMyModel setValues:dict];
                [lookFoMyArr addObject:lookForMyModel];
            }
            if (lookPage==1) {
                myDynamicArray = lookFoMyArr;
            } else {
                [myDynamicArray addObjectsFromArray:lookFoMyArr];
            }
            self.myDynamicTab.mj_footer.hidden= (total -lookPage*20)<=0;
            self.myDynamicTab.tableFooterView = (total -lookPage*20)<=0 ? [self tableLookForMyFooterView] : [UIView new];
            blankView.hidden=myDynamicArray.count>0;
        }else{
            [myDynamicArray removeAllObjects];
            self.myDynamicTab.tableFooterView = [UIView new];
            self.myDynamicTab.mj_footer.hidden = YES;
            blankView.hidden = NO;
        }
        [_myDynamicTab reloadData];
        [self.myDynamicTab.mj_header endRefreshing];
        [self.myDynamicTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.myDynamicTab.mj_header endRefreshing];
        [self.myDynamicTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark  获取最新回复数据
-(void)loadAtForMeNewData{
    lookPage=1;
    [self loadMyDynamicData];
}

#pragma mark  获取更多回复数据
-(void)loadAtForMeMoreData{
    lookPage++;
    [self loadMyDynamicData];
}
#pragma mark ======  没有更多动态 =======

- (UIView *)tableLookForMyFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    
    return footerView;
}
#pragma mark -- setter
- (void)initMyDynamicView{
    
    _myDynamicTab=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
    _myDynamicTab.backgroundColor=[UIColor bgColor_Gray];
    _myDynamicTab.delegate=self;
    _myDynamicTab.dataSource=self;
    _myDynamicTab.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_myDynamicTab];
    _myDynamicTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadAtForMeNewData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    _myDynamicTab.mj_header=header;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadAtForMeMoreData)];
    footer.automaticallyRefresh = NO;// 禁止自动加载
    _myDynamicTab.mj_footer = footer;
    footer.hidden=YES;
    
    blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"还没有@我的记录"];
    [_myDynamicTab addSubview:blankView];
    blankView.hidden=YES;

}
@end
