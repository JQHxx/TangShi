    //
//  TCMyCommentsViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/9.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyCommentsViewController.h"
#import "TCMyCommentsModel.h"
#import "TCMyCommentsTableViewCell.h"
#import "TCMyDynamicViewController.h"
#import "TCRespondDynamicTableViewCell.h"
#import "TCDynamicDetailViewController.h"
#import "TCMaxDynamicViewController.h"
#import "TCSetUpViewController.h"
#import "TCMyDynamicViewController.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface TCMyCommentsViewController ()<UITableViewDelegate,UITableViewDataSource,TCMyCommentsDelegate,TCRespondDynamicDelegate>{

    NSMutableArray  *myCommentsArray;
    NSInteger        commentsPage;
    TCBlankView     *blankView;
}

@property (nonatomic ,strong)UITableView *myCommentsTab;
@end

@implementation TCMyCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.type==1?@"我评论的":@"评论我的";
    self.rigthTitleName =self.type==1?@"":@"设置";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    myCommentsArray = [[NSMutableArray alloc] init];
    commentsPage = 1;
    [self.view addSubview:self.myCommentsTab];
    [self loadMyCommentsData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([TCHelper sharedTCHelper].isDeleteDynamic==YES) {
        [self loadMyCommentsData];
        [TCHelper sharedTCHelper].isDeleteDynamic=NO;
    }
    if ([TCHelper sharedTCHelper].isMaxDynamicReload == YES) {
        [self loadMyCommentsData];
        [TCHelper sharedTCHelper].isMaxDynamicReload=NO;
    }
    [[TCHelper sharedTCHelper] loginAction:self.type==1?@"008-11":@"008-14" type:1];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:self.type==1?@"008-11":@"008-14" type:2];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return myCommentsArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCMyCommentsModel *myCommentModel = myCommentsArray[indexPath.row];
    if (myCommentModel.parent_id==0) {
        static NSString *cellIdentifier=@"TCMyCommentsTableViewCell";
        TCMyCommentsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCMyCommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell cellMyCommentsModel:myCommentModel];
        return cell;
    }else{
        static NSString *cellIdentifier=@"TCRespondDynamicTableViewCell";
        TCRespondDynamicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TCRespondDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell cellRespondModel:myCommentModel];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    TCMyCommentsModel *myCommentModel = myCommentsArray[indexPath.row];
    if (myCommentModel.parent_id==0) {

        if (self.type==1) {
            [[TCHelper sharedTCHelper] loginClick:@"008-11-02"];
            [MobClick event:@"105_003009"];
        }else{
            [[TCHelper sharedTCHelper] loginClick:@"008-14-09"];
            [MobClick event:@"105_003021"];
        }

        if ([myCommentModel.news_info count]==0) {
            [self.view makeToast:@"该内容已不存在" duration:1.0 position:CSToastPositionCenter];
        }else{
            TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
            dynamicDetailVC.news_id = myCommentModel.news_id;
            dynamicDetailVC.role_type_ed = [[myCommentModel.news_info objectForKey:@"role_type"] integerValue];
            dynamicDetailVC.commented_user_id = [[myCommentModel.news_info objectForKey:@"user_id"] integerValue];
            dynamicDetailVC.news_comment_id = myCommentModel.news_comment_id;
            [self.navigationController pushViewController:dynamicDetailVC animated:YES];
        }
    } else {
        if (self.type==1) {
            [[TCHelper sharedTCHelper] loginClick:@"008-11-03"];
            [MobClick event:@"105_003010"];
        }else{
            [[TCHelper sharedTCHelper] loginClick:@"008-14-10"];
            [MobClick event:@"105_003022"];
        }
        if (myCommentModel.parent_comment_status==0) {
            [self.view makeToast:@"该内容已不存在" duration:1.0 position:CSToastPositionCenter];
        } else if(myCommentModel.parent_comment_status==2){
            [self.view makeToast:@"该内容已被删除" duration:1.0 position:CSToastPositionCenter];
        }else{
            TCMaxDynamicViewController *maxDynamicVC = [[TCMaxDynamicViewController alloc] init];
            maxDynamicVC.news_id = myCommentModel.parent_id;
            maxDynamicVC.newscomment_id = myCommentModel.news_comment_id;
            [self.navigationController pushViewController:maxDynamicVC animated:YES];
        }

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    TCMyCommentsModel *myCommentModel = myCommentsArray[indexPath.row];
    if (myCommentModel.parent_id==0) {
        CGFloat statusHeight = [TCMyCommentsTableViewCell tableView:tableView rowCommentsHeightForObject:[NSString stringWithFormat:@"%@",myCommentModel.content]];
        return 54+statusHeight+85;
    } else {
        if ([[myCommentModel.before_comment objectForKey:@"parent_id"] integerValue]==0) {
            NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:myCommentModel.content];
            CGFloat statusHeight = [TCRespondDynamicTableViewCell tableView:tableView rowrespondHeightForObject:[NSString stringWithFormat:@"回复%@：%@",[myCommentModel.commented_user_info objectForKey:@"nick_name"],contentStr]];
            contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[myCommentModel.before_comment objectForKey:@"content"]];
            CGFloat statusHeight1 = [TCRespondDynamicTableViewCell tableView:tableView rowDetailHeightForObject:contentStr array:nil];
            return 54+statusHeight+85+statusHeight1;
 
        } else {
            NSString *contentStr=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:myCommentModel.content];
            CGFloat statusHeight = [TCRespondDynamicTableViewCell tableView:tableView rowrespondHeightForObject:[NSString stringWithFormat:@"回复%@：%@",[myCommentModel.commented_user_info objectForKey:@"nick_name"],contentStr]];
            
           NSString *content=[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[myCommentModel.before_comment objectForKey:@"content"]];
            NSString *commentsStr =[[myCommentModel.before_comment objectForKey:@"comment_user_info"] objectForKey:@"nick_name"];
            NSString *beCommentsStr =[[myCommentModel.before_comment objectForKey:@"commented_user_info"] objectForKey:@"nick_name"];
            NSArray *arr = [NSArray arrayWithObjects:commentsStr,beCommentsStr, nil];
            CGFloat statusHeight1 = [TCRespondDynamicTableViewCell tableView:tableView rowDetailHeightForObject:[NSString stringWithFormat:@"%@回复%@：%@",commentsStr,beCommentsStr,content] array:arr];
            return 54+statusHeight+85+statusHeight1;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.01;
}

#pragma mark -- TCMyCommentsDelegate
#pragma mark 评论动态点击文本未标记区域
- (void)myLinkMoreModel:(TCMyCommentsModel *)model{
    if ([model.news_info count]==0) {
        [self.view makeToast:@"该内容已不存在" duration:1.0 position:CSToastPositionCenter];
    } else {
        if (self.type==1) {
            [[TCHelper sharedTCHelper] loginClick:@"008-11-02"];
            [MobClick event:@"105_003009"];
        }else{
            [[TCHelper sharedTCHelper] loginClick:@"008-14-09"];
            [MobClick event:@"105_003021"];
        }
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_id = model.news_id;
        dynamicDetailVC.news_comment_id = model.news_comment_id;
        dynamicDetailVC.commented_user_id = [[model.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[model.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    }
}
#pragma mark  评论动态点击文本标记区域
- (void)myLinkSeleted:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-01"];
        [MobClick event:@"105_003008"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-08"];
        [MobClick event:@"105_003020"];
    }
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = model.comment_user_id;
    userInfoVC.role_type_ed = model.role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark 评论动态查看用户信息
- (void)myCommentsContentModel:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-01"];
       [MobClick event:@"105_003008"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-08"];
       [MobClick event:@"105_003020"];
    }
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = model.comment_user_id;
    userInfoVC.role_type_ed =model.role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark 评论动态查看动态详情
- (void)mydynamicDetailModel:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-02"];
        [MobClick event:@"105_003009"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-09"];
        [MobClick event:@"105_003021"];
    }
    if ([model.news_info count]==0) {
        [self.view makeToast:@"该内容已不存在" duration:1.0 position:CSToastPositionCenter];
    } else {
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_id = model.news_id;
        dynamicDetailVC.commented_user_id = [[model.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[model.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    }
}
#pragma mark --TCRespondDynamicDelegate
#pragma mark 回复评论点击文本未标记区域
- (void)linkMoreModel:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-03"];
        [MobClick event:@"105_003010"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-10"];
        [MobClick event:@"105_003022"];
    }
    TCMaxDynamicViewController *maxDynamicVC = [[TCMaxDynamicViewController alloc] init];
    maxDynamicVC.news_id = model.parent_id;
    maxDynamicVC.newscomment_id = model.news_comment_id;
    [self.navigationController pushViewController:maxDynamicVC animated:YES];
}
#pragma mark 回复评论点查看用户信息
- (void)respondDynamicContentModel:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-01"];
        [MobClick event:@"105_003008"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-08"];
        [MobClick event:@"105_003020"];
    }
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = [[model.comment_user_info objectForKey:@"user_id"] integerValue] ;
    userInfoVC.role_type_ed = model.role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark  回复评论点查看动态详情
-(void)respondDynamicDetailContentModel:(TCMyCommentsModel *)model{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-02"];
        [MobClick event:@"105_003009"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-09"];
        [MobClick event:@"105_003021"];
    }
    if ([model.news_info count]==0) {
        [self.view makeToast:@"该内容已不存在" duration:1.0 position:CSToastPositionCenter];
    } else {
        TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
        dynamicDetailVC.news_id = model.news_id;
        dynamicDetailVC.commented_user_id = [[model.news_info objectForKey:@"user_id"] integerValue];
        dynamicDetailVC.role_type_ed = [[model.news_info objectForKey:@"role_type"] integerValue];
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    }
}
#pragma mark  回复评论点查看回复／被回复用户信息
- (void)didDespondUserContent:(NSInteger)news_id role_type:(NSInteger)role_type{
    if (self.type==1) {
        [[TCHelper sharedTCHelper] loginClick:@"008-11-01"];
        [MobClick event:@"105_003008"];
    }else{
        [[TCHelper sharedTCHelper] loginClick:@"008-14-08"];
        [MobClick event:@"105_003020"];
    }
    TCMyDynamicViewController *mineSugarFriendVC = [[TCMyDynamicViewController alloc] init];
    mineSugarFriendVC.news_id = news_id;
    mineSugarFriendVC.role_type_ed = role_type;
    [self.navigationController pushViewController:mineSugarFriendVC animated:YES];
    
}
#pragma mark -- Event response
#pragma mark  设置
- (void)rightButtonAction{
    [[TCHelper sharedTCHelper] loginClick:@"008-14-07"];
    [MobClick event:@"105_003019"];
    TCSetUpViewController *setUpVC = [[TCSetUpViewController alloc] init];
    setUpVC.type = 3;
    [self.navigationController pushViewController:setUpVC animated:YES];
}
#pragma mark  获取我评论的数据
- (void)loadMyCommentsData{
    NSString *body = nil;
    if (self.type==1) {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type=0",commentsPage];
    } else {
        body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&role_type_ed=0",commentsPage];
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:self.type==1?KLoadMyCommentsList:KLoadCommentsMyList body:body success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *commentsArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMyCommentsModel *myCommentModel = [[TCMyCommentsModel alloc] init];
                [myCommentModel setValues:dict];
                [commentsArr addObject:myCommentModel];
            }
            if (commentsPage==1) {
                myCommentsArray = commentsArr;
            } else {
                [myCommentsArray addObjectsFromArray:commentsArr];
            }
            blankView.hidden=myCommentsArray.count>0;
            self.myCommentsTab.mj_footer.hidden= (total -commentsPage*20)<=0;
            self.myCommentsTab.tableFooterView = (total -commentsPage*20)<=0 ? [self tableCommentFooterView] : [UIView new];
        }else{
            [myCommentsArray removeAllObjects];
            self.myCommentsTab.tableFooterView = [UIView new];
            self.myCommentsTab.mj_footer.hidden = YES;
            blankView.hidden = NO;
        }
        [_myCommentsTab reloadData];
        [self.myCommentsTab.mj_header endRefreshing];
        [self.myCommentsTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.myCommentsTab.mj_header endRefreshing];
        [self.myCommentsTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];

}
#pragma mark  获取最新评论数据
-(void)loadCommentsNewData{
    commentsPage=1;
    [self loadMyCommentsData];
}

#pragma mark  获取更多评论数据
-(void)loadCommentsMoreData{
    commentsPage++;
    [self loadMyCommentsData];
}
#pragma mark ======  没有更多评论 =======

- (UIView *)tableCommentFooterView{
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
- (UITableView *)myCommentsTab{
    if (_myCommentsTab==nil) {
        _myCommentsTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _myCommentsTab.delegate = self;
        _myCommentsTab.dataSource = self;
        _myCommentsTab.showsVerticalScrollIndicator = NO;
        _myCommentsTab.backgroundColor = [UIColor bgColor_Gray];
        _myCommentsTab.tableFooterView = [[UIView alloc] init];
        _myCommentsTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadCommentsNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _myCommentsTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadCommentsMoreData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _myCommentsTab.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+49, kScreenWidth, 200) img:@"img_tips_no" text:@"还没有评论记录"];
        [_myCommentsTab addSubview:blankView];
        blankView.hidden=YES;

    }
    return _myCommentsTab;
}

@end
