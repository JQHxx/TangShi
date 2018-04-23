//
//  TCMyPraiseViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyPraiseViewController.h"
#import "TCMyPraiseTableViewCell.h"
#import "TCDynamicDetailViewController.h"
#import "TCSetUpViewController.h"
#import "TCMyPraiseModel.h"
#import "TCMyDynamicViewController.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCMyPraiseViewController ()<UITableViewDelegate,UITableViewDataSource,TCMyPraiseDelegate>{
    
    TCBlankView           *blankView;

    NSMutableArray  *myPraiseArray;
    NSInteger       myPraisePage;
}

@property (nonatomic ,strong)UITableView *myPraiseTab;
@end

@implementation TCMyPraiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = self.type==1?@"我赞的":@"赞我的";
    self.rigthTitleName =self.type==1?@"":@"设置";
    
    myPraiseArray = [[NSMutableArray alloc] init];
    myPraisePage = 1;
    
    [self.view addSubview:self.myPraiseTab];
    [self loadMyPraiseData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([TCHelper sharedTCHelper].isDeleteDynamic==YES) {
        [self loadMyPraiseData];
        [TCHelper sharedTCHelper].isDeleteDynamic=NO;
    }
    [[TCHelper sharedTCHelper] loginAction:self.type==1?@"008-12":@"008-15" type:1];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:self.type==1?@"008-12":@"008-15" type:2];
 
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  myPraiseArray.count>0?myPraiseArray.count:0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TCMyPraiseModel *myPraiseModel = myPraiseArray[indexPath.row];
    static NSString *cellIdentifier=@"TCMyPraiseTableViewCell";
    TCMyPraiseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCMyPraiseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell cellMyPraiseModel:myPraiseModel type:self.type];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-12-02"];
        [MobClick event:@"105_003012"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-15-03"];
        [MobClick event:@"105_003025"];
    }
    TCMyPraiseModel *myPraiseModel = myPraiseArray[indexPath.row];
    if (myPraiseModel.news_info.count>0) {
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_comment_id = [[myPraiseModel.comment_info objectForKey:@"news_comment_id"] integerValue];
        dynamicDetailVC.news_id =[[myPraiseModel.news_info objectForKey:@"news_id"] integerValue];
        dynamicDetailVC.commented_user_id = [[myPraiseModel.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[myPraiseModel.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    }else{
        [self.view makeToast:@"该动态已被删除" duration:1.0 position:CSToastPositionCenter];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    TCMyPraiseModel *myPraiseModel = myPraiseArray[indexPath.row];
    if (myPraiseModel.type==1) {
        NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[myPraiseModel.comment_info objectForKey:@"content"]];
        NSString *replyStr = [NSString stringWithFormat:@"%@：%@",[[myPraiseModel.comment_info objectForKey:@"comment_user_info"] objectForKey:@"nick_name"],contentStr];
        float height = [TCMyPraiseTableViewCell tableView:tableView rowPraiseForObject:replyStr];
        return 183+height;
    } else {
        return 183;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
        return 0.01;
}

#pragma mark -- TCMyPraiseDelegate
- (void)myPraiseContent:(TCMyPraiseModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-12-02"];
        [MobClick event:@"105_003012"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-15-03"];
        [MobClick event:@"105_003025"];
    }
    if (model.news_info.count>0) {
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_id =[[model.news_info objectForKey:@"news_id"] integerValue];
        dynamicDetailVC.commented_user_id = [[model.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[model.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    } else {
        [self.view makeToast:@"该动态已被删除" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- 点击用户头像
- (void)myPraiseUserInfoContent:(NSInteger)expert_id role_type:(NSInteger)role_type{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-12-01"];
        [MobClick event:@"105_003011"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-15-02"];
        [MobClick event:@"105_003024"];
    }
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = expert_id;
    userInfoVC.role_type_ed =role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark -- 点击评论标记区域
- (void)myPraiseLinkSeleted:(NSInteger)user_id role_type:(NSInteger)role_type{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-12-01"];
        [MobClick event:@"105_003011"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-15-02"];
        [MobClick event:@"105_003024"];
    }
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = user_id;
    userInfoVC.role_type_ed =role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark -- 点击评论未标记区域
- (void)myPraiseLinkMoreText:(TCMyPraiseModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-12-02"];
        [MobClick event:@"105_003012"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-15-03"];
        [MobClick event:@"105_003025"];
    }
    if (model.news_info.count>0) {
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_comment_id = [[model.comment_info objectForKey:@"news_comment_id"] integerValue];
        dynamicDetailVC.news_id =[[model.news_info objectForKey:@"news_id"] integerValue];
        dynamicDetailVC.commented_user_id = [[model.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[model.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    } else {
        [self.view makeToast:@"该动态已被删除" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark -- Event response
#pragma mark -- 设置
- (void)rightButtonAction{
    [[TCHelper sharedTCHelper] loginClick:@"008-15-01"];
    [MobClick event:@"105_003023"];
    TCSetUpViewController *setUpVC = [[TCSetUpViewController alloc] init];
    setUpVC.type = 4;
    [self.navigationController pushViewController:setUpVC animated:YES];
}
#pragma mark -- 获取赞的数据
- (void)loadMyPraiseData{
    NSString *body = nil;
    if (self.type==1) {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type=0",myPraisePage];
    } else {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type_ed=0",myPraisePage];
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:self.type==1?kLoadLikeList:kLoadLikedList body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *praiseArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMyPraiseModel *myPraiseModel = [[TCMyPraiseModel alloc] init];
                [myPraiseModel setValues:dict];
                [praiseArr addObject:myPraiseModel];
            }
            if (myPraisePage==1) {
                myPraiseArray = praiseArr;
            } else {
                [myPraiseArray addObjectsFromArray:praiseArr];
            }
            blankView.hidden=myPraiseArray.count>0;
            self.myPraiseTab.mj_footer.hidden=(total -myPraisePage*20)<=0;
            self.myPraiseTab.tableFooterView = (total -myPraisePage*20)<=0 ? [self tableViewFooterView] : [UIView new];
        }else{
            [myPraiseArray removeAllObjects];
            blankView.hidden = NO;
            self.myPraiseTab.tableFooterView = [UIView new];
            self.myPraiseTab.mj_footer.hidden = YES;
        }
        [_myPraiseTab reloadData];
        [self.myPraiseTab.mj_header endRefreshing];
        [self.myPraiseTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.myPraiseTab.mj_header endRefreshing];
        [self.myPraiseTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark  获取最新回复数据
-(void)loadMyPraiseNewData{
    myPraisePage=1;
    [self loadMyPraiseData];
}

#pragma mark  获取更多回复数据
-(void)loadMyPraiseMoreData{
    myPraisePage++;
    [self loadMyPraiseData];
}
#pragma mark ======  没有更多 =======

- (UIView *)tableViewFooterView{
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
#pragma mark -- getter
- (UITableView *)myPraiseTab{
    if (_myPraiseTab==nil) {
        _myPraiseTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myPraiseTab.delegate = self;
        _myPraiseTab.dataSource = self;
        _myPraiseTab.showsVerticalScrollIndicator = NO;
        _myPraiseTab.backgroundColor = [UIColor bgColor_Gray];
        _myPraiseTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMyPraiseNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myPraiseTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMyPraiseMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myPraiseTab.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"还没有点赞记录"];
        [_myPraiseTab addSubview:blankView];
        blankView.hidden=YES;

    }
    return _myPraiseTab;
}

@end
