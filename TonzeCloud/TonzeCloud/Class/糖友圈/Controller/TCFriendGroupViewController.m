//
//  TCFriendGroupViewController.m
//  TonzeCloud
//
//  Created by vision on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//


#define KHeadViewHight  (290/2 + 49) * kScreenWidth/375+139   // 头部视图高度


#import "TCFriendGroupViewController.h"
#import "TCMineSugarFriendViewController.h"
#import "TCReleaseDynamicViewController.h"
#import "TCTopicListViewController.h"
#import "TCFriendGroupNavView.h"
#import "TCMyDynamicModel.h"
#import "TCDynamicDetailViewController.h"
#import "TCTopicThatCell.h"
#import "TCSlideView.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "TCMyDynamicViewController.h"
#import "TCTopicListModel.h"
#import "TCTopicDetailsViewController.h"
#import "TCMySugarFriendModel.h"
#import "PPBadgeView.h"
#import "TCFriendSearchViewController.h"
#import "TCSugarFriendsRankView.h"
#import "TCSugarFriendsRankModel.h"
#import "TCRankListViewController.h"
#import "TCNoAttentionCell.h"
#import "TCRecommendAttentionCell.h"
#import "TCNewFriendModel.h"
#import "QLSearchBar.h"
#import "TCFastLoginViewController.h"

static NSString  *noAttentionCellIdentiier = @"TCNoAttentionCell";

@interface TCFriendGroupViewController ()<TCSlideViewDelegate,UITableViewDelegate,UITableViewDataSource,TCTopicCellDelegate,NewPagedFlowViewDelegate,NewPagedFlowViewDataSource,UISearchBarDelegate,TCRecommendAttentionDelegate>
{
    NSInteger   _focusOnPageNum;         // 加载分页
    NSInteger   _recommendPageNum;
    NSInteger   _recentlyPageNum;
    BOOL        _isFocusOnReload;       // 是否已加载过数据
    BOOL        _isRecommendReload;
    BOOL        _isRecentlyReload;
    NSInteger   _recommendTotal;        // 推荐总数
    NSInteger   _focusOnTotal;          // 关注总数
    NSInteger   _recentlyTotal;         // 广场总数
    NSString    *_appType;               // 标题类型
    NSInteger   _selectIndex;            // 当前选中的标题
    NSInteger   messagesNumber;          // 提醒消息数量
    BOOL        _isLoadNewData;          // 是否是重新加载数据
}
/// 消息图标
@property (nonatomic ,strong) PPBadgeLabel     *messageNumLab;
/// 导航栏
@property (nonatomic ,strong) TCFriendGroupNavView *navView;
///
@property (nonatomic ,strong) UITableView *friendGroupTab;
/// 菜单切换按钮
@property (nonatomic ,strong) TCSlideView *slideView;
/// 图片轮播
@property (nonatomic ,strong) NewPagedFlowView *pagedFlowView;
///
@property (nonatomic ,strong) NSMutableArray *focusOnDataArray;
///
@property (nonatomic ,strong) NSMutableArray *recommendDataArray;
///
@property (nonatomic ,strong) NSMutableArray *recentlyDataArray;
/// 广告图片数据
@property (nonatomic ,strong) NSMutableArray *bannerDataArray;
/// 更多话题
@property (nonatomic ,strong) UIButton *moreTopicsBtn;
/// 控糖排行榜
@property (nonatomic ,strong) NSMutableArray *rankListArr;
/// 排行榜
@property (nonatomic ,strong) TCSugarFriendsRankView *sugarFriendRankView;
/// 无数据视图
@property (nonatomic ,strong) TCBlankView *blankView;
/// 搜索框
@property(nonatomic,strong)   QLSearchBar *mySearchBar;
/// 推荐关注数据
@property (nonatomic ,strong) NSMutableArray *recommendAttentionArray;
/// 是否登入
@property (nonatomic, assign) BOOL     isLogin;

@end

@implementation TCFriendGroupViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 发布动态后返回刷新判断
    if ([TCHelper sharedTCHelper].isNewDynamicRecord) {
        _isRecentlyReload = NO;
        if (_selectIndex == 0) {
            _recentlyPageNum = 1;
            _isLoadNewData = YES;
            [self loadFriendGroupDataWithIndex:0];
        }
        [TCHelper sharedTCHelper].isNewDynamicRecord = NO;
    }else if ([TCHelper sharedTCHelper].isFocusOnDynamicListReload){
        _isFocusOnReload = NO;
        if (_selectIndex == 2) {
            _focusOnPageNum = 1;
            _isLoadNewData = YES;
            [self loadFriendGroupDataWithIndex:0];
            [TCHelper sharedTCHelper].isFocusOnDynamicListReload = NO;
        }
    }
    _isLogin =[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if (_isLogin) {
        NSString *headPhoto = [NSUserDefaultsInfos getValueforKey:kUserPhoto];
        [_navView.headImg sd_setImageWithURL:[NSURL URLWithString:headPhoto] placeholderImage:[UIImage drawImageWithName:@"ic_m_head" size:CGSizeMake(24, 24)]];
        [self loadNumberOfMessages];
    }else{
        self.messageNumLab.hidden = YES;
        [_navView.headImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage drawImageWithName:@"ic_m_head" size:CGSizeMake(24, 24)]];
        [self addMessageBadgeNumberNotificationWithBadgeNumber:0];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-01" type:1];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[TCHelper sharedTCHelper] loginAction:@"008-01" type:2];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"糖友圈";
    self.isHiddenNavBar=YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    _recentlyPageNum = _recommendPageNum = _focusOnPageNum = 1;
    
    [self setFriendGroupVC];
}
#pragma mark ====== 布局 UI =======
- (void)setFriendGroupVC{
    [self.friendGroupTab registerNib:[UINib nibWithNibName:@"TCNoAttentionCell" bundle:nil] forCellReuseIdentifier:noAttentionCellIdentiier];
    [self.view addSubview:self.friendGroupTab];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mySearchBar];
    [self loadBannerData];
    [self loadFriendGroupDataWithIndex:0];
}
#pragma mark ====== 话题轮播视图 =======
- (UIView *)tableViewHeader{
    UIView *headrView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, KHeadViewHight)];
    headrView.backgroundColor = UIColorFromRGB(0xF5F9FA);
    // 轮播话题
    [headrView addSubview:self.pagedFlowView];
    // 更多话题
    [headrView addSubview:self.moreTopicsBtn];
    // 排行榜
    [headrView addSubview:self.sugarFriendRankView];
    return headrView;
}
#pragma mark ====== 请求数据 =======
#pragma mark ====== 获取消息提醒数值 =======
- (void)loadNumberOfMessages{
    NSString *body = [NSString stringWithFormat:@"role_type=0"];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KLoadMySugarFriendInfo body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TCMySugarFriendModel *mySugarFriendModel = [[TCMySugarFriendModel alloc] init];
            [mySugarFriendModel setValues:result];
            messagesNumber = mySugarFriendModel.ated + mySugarFriendModel.liked + mySugarFriendModel.new_followed + mySugarFriendModel.commented;
            weakSelf.messageNumLab.hidden = messagesNumber <= 0 ? YES  : NO ;
            weakSelf.messageNumLab.text = messagesNumber > 99 ? @"99+" :[NSString stringWithFormat:@"%ld",(long)messagesNumber];
            [TCHelper sharedTCHelper].dynamicTextNumber = mySugarFriendModel.word_limit;
            [weakSelf addMessageBadgeNumberNotificationWithBadgeNumber:messagesNumber];
        }
    } failure:^(NSString *errorStr) {
    }];
}
- (void)addMessageBadgeNumberNotificationWithBadgeNumber:(NSInteger)BadgeNumber{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendGroupBadgeNumberNotification" object:[NSString stringWithFormat:@"%ld",(long)BadgeNumber]];
}
#pragma mark ====== 加载banner数据 =======
- (void)loadBannerData{
    _rankListArr = [[NSMutableArray alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?page_size=10&page_num=1&is_recommend=1",KTopicLists];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        NSArray *rankListArray = [json objectForKey:@"rank_list"];
        if (kIsArray(rankListArray) && rankListArray.count > 0) {
            for (NSDictionary *dict in rankListArray) {
                TCSugarFriendsRankModel *rankModel = [[TCSugarFriendsRankModel alloc] init];
                [rankModel setValues:dict];
                [_rankListArr addObject:rankModel];
            }
            [_sugarFriendRankView lookSugarFriendData:_rankListArr];
        }else{
            [_rankListArr removeAllObjects];
        }
        
        if (kIsArray(resultArray) && resultArray.count > 0) {
            [weakSelf.bannerDataArray removeAllObjects];
            for (NSDictionary *dic in resultArray) {
                TCTopicListModel *topicListModel = [[TCTopicListModel alloc]initWithDictionary:dic];
                [weakSelf.bannerDataArray addObject:topicListModel];
            }
            [weakSelf.pagedFlowView reloadData];
        }else{
            [weakSelf.bannerDataArray removeAllObjects];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)loadFriendGroupDataWithIndex:(NSInteger)index{
    NSInteger pageNum = 1;
    switch (_selectIndex) {
        case 0:
        {
            pageNum = _recentlyPageNum;
            _appType = @"lately";
        }break;
        case 1:
        {
            pageNum = _recommendPageNum;
            _appType = @"recommend";
        }break;
        case 2:
        {
            pageNum = _focusOnPageNum;
            _appType = @"follow";
        }break;
        default:
            break;
    }
    NSString *url = [NSString stringWithFormat:@"%@?&page_size=15&page_num=%ld&api_type=%@&role_type=0",KfriendGroupList,(long)pageNum,_appType];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        NSInteger totalCount = [[json objectForKey:@"total"] integerValue];
        if (kIsArray(resultArray) && resultArray.count > 0) {
            if (_isLoadNewData) {
                switch (_selectIndex) {
                    case 0:
                    {
                         [weakSelf.recentlyDataArray removeAllObjects];
                    }break;
                    case 1:
                    {
                        [weakSelf.recommendDataArray removeAllObjects];
                    }break;
                    case 2:
                    {
                        [weakSelf.focusOnDataArray removeAllObjects];
                    }break;
                    default:
                        break;
                }
            }
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in resultArray) {
                TCMyDynamicModel *friendGroupModel = [TCMyDynamicModel new];
                [friendGroupModel setValues:dic];
                friendGroupModel.isOpen = NO;
                switch (_selectIndex) {
                    case 0:
                    {
                        _isRecentlyReload = YES;
                        _recentlyTotal = totalCount;
                        weakSelf.friendGroupTab.mj_footer.hidden=(totalCount -_recentlyPageNum*15)<=0;
                        [weakSelf.recentlyDataArray addObject:friendGroupModel];
                        weakSelf.friendGroupTab.tableFooterView = (totalCount -_recentlyPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                    }break;
                    case 1:
                    {
                        _isRecommendReload = YES;
                        _recommendTotal = totalCount;
                        weakSelf.friendGroupTab.mj_footer.hidden=(totalCount -_recommendPageNum*15)<=0;
                        [weakSelf.recommendDataArray addObject:friendGroupModel];
                        weakSelf.friendGroupTab.tableFooterView = (totalCount -_recommendPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                    }break;
                    case 2:
                    {
                        _isFocusOnReload = YES;
                        _focusOnTotal = totalCount;
                        weakSelf.friendGroupTab.mj_footer.hidden=(totalCount -_focusOnPageNum*15)<=0;
                        [weakSelf.focusOnDataArray addObject:friendGroupModel];
                        weakSelf.friendGroupTab.tableFooterView = (totalCount -_focusOnPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                    }break;
                    default:
                        break;
                }
            }
        }else{
            switch (_selectIndex) {
                case 0:
                {
                    [weakSelf.recentlyDataArray removeAllObjects];
                }break;
                case 1:
                {
                    [weakSelf.recommendDataArray removeAllObjects];
                }break;
                case 2:
                {
                    [weakSelf.focusOnDataArray removeAllObjects];
                }break;
                default:
                    break;
            }
            weakSelf.friendGroupTab.tableFooterView = [UIView new];
            weakSelf.friendGroupTab.mj_footer.hidden = YES;
            weakSelf.blankView.hidden = NO;
        }
        
        // -- 推荐关注人数据
        NSArray *recommendFollowArray = [json objectForKey:@"recommend_follow"];
        [weakSelf.recommendAttentionArray removeAllObjects];
        if (kIsArray(recommendFollowArray) && recommendFollowArray.count > 0) {
            for (NSDictionary *dic in recommendFollowArray) {
                TCNewFriendModel *focusOnModel = [TCNewFriendModel new];
                [focusOnModel setValues:dic];
                [weakSelf.recommendAttentionArray addObject:focusOnModel];
            }
            weakSelf.friendGroupTab.tableFooterView = [UIView new];
            weakSelf.blankView.hidden = YES;
        }else{
            [weakSelf.recommendAttentionArray removeAllObjects];
        }
        [weakSelf.friendGroupTab reloadData];
        [weakSelf.friendGroupTab.mj_header endRefreshing];
        [weakSelf.friendGroupTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        switch (_selectIndex) {
            case 0:
            {
                _isRecentlyReload = NO;
                [weakSelf.recentlyDataArray removeAllObjects];
            }break;
            case 1:
            {
                _isRecommendReload = NO;
                [weakSelf.recommendDataArray removeAllObjects];
                
            }break;
            case 2:
            {
                _isFocusOnReload = NO;
                [weakSelf.focusOnDataArray removeAllObjects];
            }break;
            default:
                break;
        }
        [weakSelf.friendGroupTab reloadData];
        weakSelf.blankView.hidden = NO;
        weakSelf.friendGroupTab.mj_footer.hidden = YES;
        [weakSelf.friendGroupTab.mj_header endRefreshing];
        [weakSelf.friendGroupTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 加载最新数据 =======
- (void)newDynamicData{
    [self loadBannerData];
    switch (_selectIndex) {
        case 0:
        {
            _recentlyPageNum = 1;
        }break;
        case 1:
        {
            _recommendPageNum = 1;
        }break;
        case 2:
        {
            _focusOnPageNum =  1;
        }break;
        default:
            break;
    }
    _isLoadNewData = YES;
    [self loadFriendGroupDataWithIndex:_selectIndex];
    [self loadNumberOfMessages];
}
#pragma mark ====== 加载更多数据 =======

- (void)loadMoreDynamicData{
    
    switch (_selectIndex) {
        case 0:
        {
             _recentlyPageNum++;
        }break;
        case 1:
        {
            _recommendPageNum++;
        }break;
        case 2:
        {
            _focusOnPageNum++;
        }break;
        default:
            break;
    }
    _isLoadNewData = NO;
    [self loadFriendGroupDataWithIndex:_selectIndex];
}
#pragma mark ====== NewPagedFlowViewDelegate =======

- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView{
    return CGSizeMake(368/2 * kScreenWidth/375, 234/2 * kScreenWidth/375);
}
- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    [[TCHelper sharedTCHelper] loginClick:@"008-01-04"];
    
    if (_isLogin && _bannerDataArray.count > 0) {
        TCTopicListModel *bannerModel = _bannerDataArray[subIndex];
        TCTopicDetailsViewController *topicDetailsVC = [TCTopicDetailsViewController new];
        topicDetailsVC.hidesBottomBarWhenPushed = YES;
        topicDetailsVC.topicId = bannerModel.topic_id;
        topicDetailsVC.topic = bannerModel.title;
        [self.navigationController pushViewController:topicDetailsVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== NewPagedFlowViewDataSource =======

- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    return _bannerDataArray.count;
}
- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth * 9 / 16)];
        bannerView.tag = index;
    }
    if (_bannerDataArray.count > 0) {
        TCTopicListModel *bannerModel = _bannerDataArray[index];
        //在这里下载网络图片
        [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:bannerModel.default_image] placeholderImage:[UIImage imageNamed:@""]];
        bannerView.contentLab.text = bannerModel.title;
    }
    return bannerView;
}
#pragma mark ======  UITableViewDelegate,UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.recommendAttentionArray.count > 0 ? 2 : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.recommendAttentionArray.count > 0) {
        switch (section) {
            case 0:
            {
                return 1;
            }break;
            case 1:
            {
                return _recommendAttentionArray.count;
            }break;
            default:
                break;
        }
    }else{
        switch (_selectIndex) {
            case 0:
            {
                return _recentlyDataArray.count;
            }break;
            case 1:
            {
                return _recommendDataArray.count;
            }break;
            case 2:
            {
                 return _focusOnDataArray.count;
            }break;
            default:
                break;
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHight;
    if (self.recommendAttentionArray.count > 0) {
        cellHight = 69 + 50;
        switch (indexPath.section) {
            case 0:
            {
                cellHight = 69 + 50;
            }break;
            case 1:
            {
                cellHight = 80;
            }break;
            default:
                break;
        }
    }else{
        TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
        cellHight = myDynamicModel.cellHight;
    }
    return cellHight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.recommendAttentionArray.count > 0) {
        if (section == 0) {
            return 92/2;
        } else {
            return 34;
        }
    } else {
        return 92/2;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 92/2)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    if (self.recommendAttentionArray.count > 0) {
        switch (section) {
            case 0:
            {
                [sectionHeaderView addSubview:self.slideView];
            }break;
            case 1:
            {
                sectionHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 34);
                UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(15,(sectionHeaderView.height - 20)/2 , 4, 20)];
                len.backgroundColor = kSystemColor;
                [sectionHeaderView addSubview:len];
                
                UILabel *recommendAttentionLab = [[UILabel alloc]initWithFrame:CGRectMake(len.right + 5, (sectionHeaderView.height - 20)/2 , 180, 20)];
                recommendAttentionLab.font = kFontWithSize(15);
                recommendAttentionLab.textColor = UIColorFromRGB(0x313131);
                recommendAttentionLab.text = @"为您推荐";
                [sectionHeaderView addSubview:recommendAttentionLab];
                
                UILabel *bottomLens = [[UILabel alloc]initWithFrame:CGRectMake(0, sectionHeaderView.height - 0.5,kScreenWidth, 0.5)];
                bottomLens.backgroundColor = UIColorFromRGB(0xe5e5e5);
                [sectionHeaderView addSubview:bottomLens];
            }break;
            default:
                break;
        }
    }else{
        [sectionHeaderView addSubview:self.slideView];
    }
    return sectionHeaderView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.recommendAttentionArray.count > 0) {
        if (indexPath.section == 0) {
            // 暂无关注人界面
            TCNoAttentionCell *noAttentionCell = [tableView dequeueReusableCellWithIdentifier:noAttentionCellIdentiier];
            noAttentionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return noAttentionCell;
        }else{
            static NSString *recommendcellIdentifier=@"TCRecommendAttentionCell";
            TCRecommendAttentionCell *recommendAttentionCell=[tableView dequeueReusableCellWithIdentifier:recommendcellIdentifier];
            if (!recommendAttentionCell) {
                recommendAttentionCell = [[TCRecommendAttentionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendcellIdentifier];
            }
            recommendAttentionCell.delegate = self;
            TCNewFriendModel *mineModel =self.recommendAttentionArray[indexPath.row];
            [recommendAttentionCell cellWithNewFriendModel:mineModel];
            return recommendAttentionCell;
        }
    }else{
        static NSString *topicThatCellIdentifier = @"cellIdentifier";
        TCTopicThatCell *topicThatCell = [tableView dequeueReusableCellWithIdentifier:topicThatCellIdentifier];
        if (!topicThatCell) {
            topicThatCell = [[TCTopicThatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topicThatCellIdentifier];
        }
        topicThatCell.topicCellDelegate = self;
        topicThatCell.cellType = TopicCellTypeHome;
        TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
        topicThatCell.myDynamicModel = myDynamicModel;
        return topicThatCell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.recommendAttentionArray.count <= 0) {
        [self gotoDynamicDetailVCWithIndexPath:indexPath];
    }else if(self.recommendAttentionArray.count > 0){
        switch (indexPath.section) {
            case 1:
            {
                TCNewFriendModel *friendModel = self.recommendAttentionArray[indexPath.row];
                TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
                userInfoVC.news_id = friendModel.user_id;
                userInfoVC.role_type_ed = friendModel.role_type;
                userInfoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:userInfoVC animated:YES];
            }break;
            default:
                break;
        }
    }
}
#pragma mark ====== TCTopicCellDelegate =======
#pragma mark ====== 点击个人信息 =======
- (void)didClickcPersonalInfoInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
    if (_isLogin) {
        [[TCHelper sharedTCHelper] loginClick:@"008-01-08"];
        [MobClick event:@"105_001008"];
        TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
        userInfoVC.news_id = myDynamicModel.user_id;
        userInfoVC.role_type_ed = myDynamicModel.role_type;
        userInfoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 删除动态 ======
- (void)didClickcDeleteDynamicInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
    [[TCHelper sharedTCHelper] loginClick:@"008-01-12"];
    [MobClick event:@"105_001012"];
    if (_isLogin) {
        UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        kSelfWeak;
        [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *body = [NSString stringWithFormat:@"role_type=0&news_id=%ld",(long)myDynamicModel.news_id];
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KDynamicDelete body:body success:^(id json) {
                    NSInteger status = [[json objectForKey:@"status"] integerValue];
                    if (status == 1 ) {
                        [self.view makeToast:@"删除成功！" duration:1.0 position:CSToastPositionCenter];
                        
                        switch (_selectIndex) {
                            case 0:
                            {
                                [weakSelf.recentlyDataArray removeObjectAtIndex:indexPath.row];
                            }break;
                            case 1:
                            {
                                [weakSelf.recommendDataArray removeObjectAtIndex:indexPath.row];
                            }break;
                            case 2:
                            {
                                [weakSelf.focusOnDataArray removeObjectAtIndex:indexPath.row];
                            }break;
                            default:
                                break;
                        }
                        [weakSelf.friendGroupTab reloadData];
                    }
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }
        }];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 查看全部 =======
- (void)didClickcLookAllContentInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    [self gotoDynamicDetailVCWithIndexPath:indexPath];
}
#pragma mark ====== 点击动态内容 =======
- (void)didClickcDynamicContentInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    [self gotoDynamicDetailVCWithIndexPath:indexPath];
}
#pragma mark ====== 进入动态详情 =======
- (void)gotoDynamicDetailVCWithIndexPath:(NSIndexPath *)indexPath{
    TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
    if (_isLogin) {
        [[TCHelper sharedTCHelper] loginClick:@"008-01-07"];
        [MobClick event:@"105_001007"];
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
        dynamicDetailVC.hidesBottomBarWhenPushed = YES;
        dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
        dynamicDetailVC.news_id = myDynamicModel.news_id;
        dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
        dynamicDetailVC.likeSuccessBlock = ^(NSInteger likeCount, NSInteger like_status) {// 动态详情点赞成功回调刷新数据
            myDynamicModel.like_count = likeCount;
            myDynamicModel.like_status= like_status;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [_friendGroupTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        dynamicDetailVC.commentsSuccessBlock=^(BOOL isDeleteComments){
            // -- 动态详情评论成功回调刷新数据
            myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [_friendGroupTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:dynamicDetailVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 点赞 =======
- (void)didClickLikeButtonInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
    [MobClick event:@"105_001011"];
    [[TCHelper sharedTCHelper] loginClick:@"008-01-11"];
    if (_isLogin) {
        NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=0&is_like=%d",(long)myDynamicModel.news_id,(long)myDynamicModel.user_id,(long)myDynamicModel.role_type,(long)myDynamicModel.like_status == 1 ? 0 : 1];
        kSelfWeak;
        [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KDynamicDoLike body:body success:^(id json) {
            myDynamicModel.like_status = !myDynamicModel.like_status;
            myDynamicModel.like_count =  myDynamicModel.like_status == 1 ? myDynamicModel.like_count + 1 : myDynamicModel.like_count - 1;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [weakSelf.friendGroupTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(NSString *errorStr) {
            // [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 评论 =======
- (void)didClickcCommentButtonInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.friendGroupTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel = [self getDataModelWithIndex:indexPath];
    if (_isLogin) {
        [MobClick event:@"105_001010"];
        [[TCHelper sharedTCHelper] loginClick:@"008-01-10"];
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
        kSelfWeak;
        dynamicDetailVC.commentsSuccessBlock= ^(BOOL isDeleteComments){
            // -- 动态详情评论成功回调刷新数据
            myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [weakSelf.friendGroupTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        dynamicDetailVC.hidesBottomBarWhenPushed = YES;
        dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
        dynamicDetailVC.news_id = myDynamicModel.news_id;
        dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
        [weakSelf.navigationController pushViewController:dynamicDetailVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 点击标记区域 @ || # =======
-(void)didClickTagLinkSeletedContent:(NSString *)string clickStrId:(NSInteger)clickStrId role_type:(NSInteger)role_type topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
    NSString *clickStr = [string substringToIndex:1];
    if (_isLogin) {
        if ([clickStr isEqualToString:@"#"]) {
            // -- 跳转“话题”
            [MobClick event:@"105_001004"];
            TCTopicDetailsViewController *topicDetailsVC = [TCTopicDetailsViewController new];
            topicDetailsVC.hidesBottomBarWhenPushed = YES;
            topicDetailsVC.topicId = clickStrId;
            topicDetailsVC.topic = topic;
            topicDetailsVC.topic_delete_status = topic_delete_status;
            [self.navigationController pushViewController:topicDetailsVC animated:YES];
        }else{
            // -- 跳转“@”的人
            [MobClick event:@"105_001009"];
            [[TCHelper sharedTCHelper] loginClick:@"008-01-09"];
            TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
            userInfoVC.news_id = clickStrId;
            userInfoVC.role_type_ed  = role_type;
            userInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
    }else{
        [self fastLoginAction];
    }
}
#pragma mark ====== 获取当前模型数据 =======
- (TCMyDynamicModel *)getDataModelWithIndex:(NSIndexPath *)indexPath{
    TCMyDynamicModel *myDynamicModel = [TCMyDynamicModel new];
    switch (_selectIndex) {
        case 0:
        {
            myDynamicModel = _recentlyDataArray[indexPath.row];
        }break;
        case 1:
        {
            myDynamicModel =_recommendDataArray[indexPath.row];
        }break;
        case 2:
        {
            myDynamicModel = _focusOnDataArray[indexPath.row];
        }break;
        default:
            break;
    }
    return myDynamicModel;
}
#pragma mark ====== TCRecommendAttentionDelegate =======
- (void)recommendAttentionToClick:(UITableViewCell *)index withFriendMode:(TCNewFriendModel *)model{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%d",model.user_id,model.role_type,model.focus_status == 0?1:2];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kFocusFriend body:body success:^(id json) {
        //刷新请求数据
        [weakSelf.friendGroupTab.mj_header beginRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== TCSlideViewDelegate  =======
- (void)menuView:(TCSlideView *)menuView actionWithIndex:(NSInteger)index{
    [[TCHelper sharedTCHelper] loginClick:@"008-01-06"];
    [MobClick event:@"105_001006"];
    _selectIndex = index;
    switch (index) {
        case 0:
        {
            if (!_isRecentlyReload) {
                _friendGroupTab.tableFooterView = [UIView new];
                [_friendGroupTab reloadData];
                _recentlyPageNum = 1;
                _isLoadNewData = YES;
                [self loadFriendGroupDataWithIndex:index];
            }else{
                if (self.recommendAttentionArray.count > 0) {
                     [self.recommendAttentionArray removeAllObjects];
                    _isFocusOnReload = NO;
                }
                self.blankView.hidden = YES;
                self.friendGroupTab.mj_footer.hidden=(_recentlyTotal -_recentlyPageNum *15)<=0;
                self.friendGroupTab.tableFooterView = (_recentlyTotal -_recentlyPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                [_friendGroupTab reloadData];
            }
        }break;
        case 1:
        {
            if (!_isRecommendReload) {
                _recommendPageNum = 1;
                _isLoadNewData = YES;
                [self loadFriendGroupDataWithIndex:index];
                self.blankView.hidden = YES;
            }else{
                if (self.recommendAttentionArray.count > 0) {
                    [self.recommendAttentionArray removeAllObjects];
                    _isFocusOnReload = NO;
                }
                self.blankView.hidden = YES;
                self.friendGroupTab.mj_footer.hidden=(_recommendTotal - _recommendPageNum*15)<=0;
                self.friendGroupTab.tableFooterView = (_recommendTotal -_recommendPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                [_friendGroupTab reloadData];
            }
        }break;
        case 2:
        {
            if (!_isFocusOnReload || [TCHelper sharedTCHelper].isFocusOnDynamicListReload) {
                self.friendGroupTab.mj_footer.hidden = YES;
                [TCHelper sharedTCHelper].isFocusOnDynamicListReload = NO;
                _friendGroupTab.tableFooterView = [UIView new];
                [_friendGroupTab reloadData];
                _focusOnPageNum = 1;
                _isLoadNewData = YES;
                [self loadFriendGroupDataWithIndex:index];
            }else{
                self.blankView.hidden = YES;
                self.friendGroupTab.mj_footer.hidden=(_focusOnTotal -_focusOnPageNum*15)<=0;
                self.friendGroupTab.tableFooterView = (_focusOnTotal -_focusOnPageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
                [_friendGroupTab reloadData];
            }
        }break;
        default:
            break;
    }
    //    [self.friendGroupTab setContentOffset:CGPointMake(0,0) animated:NO];
}
#pragma mark -- UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [TCHelper sharedTCHelper].isSearchKeyboard = YES;
    TCFriendSearchViewController *searchVC=[[TCFriendSearchViewController alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}
#pragma mark ====== 更多话题 =======
- (void)moreTopic{
    [[TCHelper sharedTCHelper] loginClick:@"008-01-05"];
    [MobClick event:@"105_001005"];
    if (_isLogin) {
        TCTopicListViewController *topicListVC = [TCTopicListViewController new];
        topicListVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topicListVC animated:YES];
    }else{
        [self fastLoginAction];
    }
}

#pragma mark ====== Getter =======
- (UITableView *)friendGroupTab{
    if (!_friendGroupTab) {
        _friendGroupTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight - kNewNavHeight - kTabHeight) style:UITableViewStylePlain];
        _friendGroupTab.delegate = self;
        _friendGroupTab.dataSource = self;
        _friendGroupTab.tableHeaderView = [self tableViewHeader];
        _friendGroupTab.tableFooterView = [UIView new];
        _friendGroupTab.backgroundColor = [UIColor bgColor_Gray];
        _friendGroupTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _friendGroupTab.scrollsToTop = YES;
        
        MJRefreshNormalHeader *mjHeader  = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(newDynamicData)];
        mjHeader.stateLabel.text = @"下拉刷新";
        _friendGroupTab.mj_header = mjHeader;
        
        MJRefreshAutoNormalFooter *mjFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDynamicData)];
        mjFooter.automaticallyRefresh = NO;
        _friendGroupTab.mj_footer = mjFooter;
        mjFooter.hidden = YES;
        
        [_friendGroupTab addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _friendGroupTab;
}
#pragma mark ======  没有更多动态 =======
- (UIView *)tableVieFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footerView.frame];
    unMoreDynamicLab.text = @"没有更多动态了";
    unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
    unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
    unMoreDynamicLab.font = kFontWithSize(15);
    [footerView addSubview:unMoreDynamicLab];
    return footerView;
}
#pragma mark === 菜单栏 ====
-(TCSlideView *)slideView{
    if (_slideView==nil) {
        _slideView=[[TCSlideView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 92/2 - 0.5)];
        _slideView.delegate=self;
        _slideView.menusArray = [NSMutableArray arrayWithObjects:@"广场",@"推荐",@"关注",nil];
    }
    return _slideView;
}
#pragma mark ====== 消息图标 =======
- (UILabel *)messageNumLab{
    if (!_messageNumLab) {
        _messageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( 32, 22, 16, 16)];
        _messageNumLab.hidden = YES;
    }
    return _messageNumLab;
}
#pragma mark 搜索框
-(QLSearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar = [[QLSearchBar alloc]initWithFrame:CGRectMake(60, KStatusHeight + (kNavHeight - 30)/2, kScreenWidth-115, 30) leftImage:[UIImage imageNamed:@"ic_friend_search"] placeholderColor:UIColorFromRGB(0x05d380)];
        _mySearchBar.placeholder = @"搜索";
        _mySearchBar.delegate=self;
        _mySearchBar.hasCentredPlaceholder = NO;
        _mySearchBar.backgroundImage = [UIImage imageWithColor:UIColorFromRGB(0x9cf5d2) size:_mySearchBar.bounds.size];
        _mySearchBar.layer.cornerRadius = 15;
        _mySearchBar.layer.masksToBounds = YES;
    }
    return _mySearchBar;
}
#pragma mark ====== 图片轮播 =======
- (NewPagedFlowView *)pagedFlowView{
    if (!_pagedFlowView) {
        _pagedFlowView = [[NewPagedFlowView alloc]initWithFrame:CGRectMake(0, 7 * kScreenWidth/375, kScreenWidth, 290/2 * kScreenWidth/375)];
        _pagedFlowView.delegate = self;
        _pagedFlowView.dataSource = self;
        _pagedFlowView.backgroundColor = [UIColor whiteColor];
        _pagedFlowView.minimumPageAlpha = 0.01;
        _pagedFlowView.isCarousel = YES;
        _pagedFlowView.leftRightMargin = 57;
        _pagedFlowView.topBottomMargin = 28;
        _pagedFlowView.autoTime = 4.0f;
        _pagedFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
        _pagedFlowView.isOpenAutoScroll = YES;
    }
    return _pagedFlowView;
}
#pragma mark ====== 导航栏 、 我的糖友圈  、 发布 =======
- (TCFriendGroupNavView *)navView{
    if (!_navView) {
        _navView = [[TCFriendGroupNavView alloc]initWithFrame:CGRectMake(0,0, kScreenWidth, kNewNavHeight)];
        kSelfWeak;
        _navView.navBtnClickBlock = ^(NSInteger tag) {
            if (weakSelf.isLogin) {
                switch (tag) {
                    case 1000:
                    {
                        [[TCHelper sharedTCHelper] loginClick:@"008-01-02"];
                        [MobClick event:@"105_001002"];
                        TCMineSugarFriendViewController *mineSugarFriendVC = [[TCMineSugarFriendViewController alloc] init];
                        mineSugarFriendVC.hidesBottomBarWhenPushed = YES;
                        [weakSelf.navigationController pushViewController:mineSugarFriendVC animated:YES];
                    }break;
                    case 1001:
                    {
                        [[TCHelper sharedTCHelper] loginClick:@"008-01-03"];
                        [MobClick event:@"105_001003"];
                        TCReleaseDynamicViewController *releaseDynamicVC = [TCReleaseDynamicViewController new];
                        releaseDynamicVC.hidesBottomBarWhenPushed = YES;
                        releaseDynamicVC.isCanChooseTopic = YES;
                        [weakSelf.navigationController pushViewController:releaseDynamicVC animated:YES];
                    }break;
                    default:
                        break;
                }
            }else{
                [weakSelf fastLoginAction];
            }
        };
        [_navView addSubview:self.messageNumLab];
    }
    return _navView;
}
#pragma mark ====== 更多话题 =======
- (UIButton *)moreTopicsBtn{
    if (!_moreTopicsBtn) {
        _moreTopicsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreTopicsBtn.backgroundColor = [UIColor whiteColor];
        _moreTopicsBtn.frame = CGRectMake(0, self.pagedFlowView.bottom, kScreenWidth , 35 * kScreenWidth/375);
        [_moreTopicsBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
        _moreTopicsBtn.titleLabel.font = kFontWithSize(15);
        [_moreTopicsBtn setTitle:@"更多话题" forState:UIControlStateNormal];
        [_moreTopicsBtn setImage:[UIImage imageNamed:@"green_more"] forState:UIControlStateNormal];
        [_moreTopicsBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        [_moreTopicsBtn addTarget:self action:@selector(moreTopic) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreTopicsBtn;
}
#pragma mark ====== 排行榜 =======
- (TCSugarFriendsRankView *)sugarFriendRankView{
    if (!_sugarFriendRankView) {
        _sugarFriendRankView = [[TCSugarFriendsRankView alloc] initWithFrame:CGRectMake(0, _moreTopicsBtn.bottom+10, kScreenWidth, 129)];
        _sugarFriendRankView.backgroundColor = [UIColor whiteColor];
        kSelfWeak;
        _sugarFriendRankView.lookRankBlock = ^(NSInteger tag){
            if (weakSelf.isLogin) {
                if (tag==105) {
                    [[TCHelper sharedTCHelper]loginClick:@"008-01-14"];
                     [MobClick event:@"105_001014"];
                    TCRankListViewController *rankListVC = [[TCRankListViewController alloc] init];
                    rankListVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:rankListVC animated:YES];
                } else {
                    [MobClick event:@"105_001013"];
                    TCSugarFriendsRankModel *rankModel = weakSelf.rankListArr[tag-100];
                    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"008-01-13:%ld",rankModel.user_id]];
                    TCMyDynamicViewController *myDynamicVC = [[TCMyDynamicViewController alloc] init];
                    myDynamicVC.news_id = rankModel.user_id;
                    myDynamicVC.role_type_ed = rankModel.role_type;
                    myDynamicVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:myDynamicVC animated:YES];
                }
            }else{
                [weakSelf fastLoginAction];
            }
        };
    }
    return _sugarFriendRankView;
}
#pragma mark ====== 无数据视图 =======
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0, KHeadViewHight + 92/2 , kScreenWidth, 200) img:@"un_dynamic" text:@"还没动态哦~"];
    }
    return _blankView;
}
- (NSMutableArray *)recommendDataArray{
    if (!_recommendDataArray) {
        _recommendDataArray = [NSMutableArray array];
    }
    return _recommendDataArray;
}
- (NSMutableArray *)recentlyDataArray{
    if (!_recentlyDataArray) {
        _recentlyDataArray = [NSMutableArray array];
    }
    return _recentlyDataArray;
}
- (NSMutableArray *)focusOnDataArray{
    if (!_focusOnDataArray) {
        _focusOnDataArray = [NSMutableArray array];
    }
    return _focusOnDataArray;
}
- (NSMutableArray *)bannerDataArray{
    if (!_bannerDataArray) {
        _bannerDataArray = [NSMutableArray array];
    }
    return _bannerDataArray;
}
- (NSMutableArray *)recommendAttentionArray{
    if (!_recommendAttentionArray) {
        _recommendAttentionArray = [NSMutableArray array];
    }
    return _recommendAttentionArray;
}
#pragma mark ====== dealloc =======
- (void)dealloc{
    // 不停止退出登录会闪退
    [self.pagedFlowView stopTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

