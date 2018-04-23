//
//  TCTopicDetailsViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/8.
//  Copyright © 2017年 tonze. All rights reserved.
//

#define kImageViewHeight 160 * kScreenWidth/375

#import "TCTopicDetailsViewController.h"
#import "TCTopicThatCell.h"
#import "TCReleaseDynamicViewController.h"
#import "TCDynamicDetailViewController.h"
#import "TCMyDynamicViewController.h"
#import "TCTopicListModel.h"
#import "TCTopicDetailDescCell.h"

@interface TCTopicDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,TCTopicCellDelegate>
{
    UILabel                         *_navTitltLab;          /// 导航栏标题
    UILabel                         *_topicTitleLab;        /// 话题标题
    UILabel                         *_readLab;              /// 阅读量
    UILabel                         *_discussLab;           /// 讨论量
    UILabel                         *_descLabel;            /// 摘要
    UILabel                         *_discussTotalLabe;     /// 讨论热度
    CGFloat                         _navbar_change_point;
    UIImageView                     *_headImgView;          /// 头部图片
    UIVisualEffectView              *_effectView;     // 图片毛玻璃效果
    NSInteger                       _pageNum;
    TCTopicListModel                *_topicModel;      // 话题数据模型
    NSInteger                       _totalNumber;            // 话题总数
    BOOL                             _isLogin;               // 是否登入
    UIButton                        *_writingDynamicBtn;       // 发布
    UIActivityIndicatorView   *_activityIndicator; // 菊花加载
}
@property (nonatomic,strong) UITableView *topicDetailTab;
/// 导航视图
@property (nonatomic ,strong) UIView *navBarView;
///
@property (nonatomic ,strong) NSMutableArray *topicDetailsArray;
///
@property (nonatomic ,strong) TCBlankView *blankView;
/// 动画图片
@property (nonatomic ,strong) UIImageView *animationImageView;
/// 请求网络返回数据
@property (nonatomic ,strong) NSArray *resultArray;

@end

@implementation TCTopicDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenNavBar = YES;
    
    _navbar_change_point = 0;
    _pageNum =  1;
    self.resultArray = [NSArray array];
    
    [self setTopicDetailsVC];
    if (!self.topic_delete_status) {
        [self requestTopicDetailsData];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"话题详情"];
    [[TCHelper sharedTCHelper] loginAction:@"008-04" type:1];
    if ([TCHelper sharedTCHelper].isNewDynamicRecord) {
        [self newTopicDynamicData];
    }
    _isLogin =[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"话题详情"];
    [[TCHelper sharedTCHelper] loginAction:@"008-04" type:2];
}
- (void)setTopicDetailsVC{
    [self initTopicDetailTab];
    [self.view addSubview:self.navBarView];
}
#pragma mark ====== 请求话题详情 =======
- (void)requestTopicDetailsData{
    NSString *url = [NSString stringWithFormat:@"%@?id=%ld&role_type=0",KTopicDetail,(long)self.topicId];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic) && !weakSelf.topic_delete_status) {
            [weakSelf loadTopicData];
            _writingDynamicBtn.hidden = NO;
            weakSelf.blankView.hidden = YES;
            _topicModel = [TCTopicListModel new];
            [_topicModel setValues:resultDic];
            _topicModel.desc = [resultDic objectForKey:@"desc"];
            [_headImgView sd_setImageWithURL:[NSURL URLWithString:_topicModel.default_image] placeholderImage:[UIImage imageNamed:@"topicDetail_loadingHeadImg"]];
            _readLab.text = [NSString stringWithFormat:@"%ld 阅读",(long)_topicModel.read_num];
        }else{
            [weakSelf.topicDetailsArray removeAllObjects];
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf performSelector:@selector(stopImage) withObject:nil afterDelay:1];
        [weakSelf.topicDetailTab reloadData];
        [weakSelf.topicDetailTab.mj_header endRefreshing];
        [weakSelf.topicDetailTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf performSelector:@selector(stopImage) withObject:nil afterDelay:1];
        weakSelf.topicDetailTab.mj_footer.hidden = YES;
        [weakSelf.topicDetailTab.mj_header endRefreshing];
        [weakSelf.topicDetailTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取话题数据
- (void)loadTopicData{
    NSString *url = [NSString stringWithFormat:@"%@?&page_size=15&page_num=%ld&api_type=topic&topic_id=%ld",KfriendGroupList,(long)_pageNum,(long)self.topicId];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
        weakSelf.resultArray = [json objectForKey:@"result"];
        _totalNumber = [[json objectForKey:@"total"] integerValue];
        _discussLab.text = [NSString stringWithFormat:@"%ld 讨论",(long)_totalNumber];
        if (kIsArray(weakSelf.resultArray) && weakSelf.resultArray.count > 0) {
            weakSelf.topicDetailTab.mj_footer.hidden=(_totalNumber - _pageNum*15)<=0;
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in weakSelf.resultArray) {
                TCMyDynamicModel *topicModel = [TCMyDynamicModel new];
                [topicModel setValues:dic];
                topicModel.isOpen = NO;
                [weakSelf.topicDetailsArray addObject:topicModel];
            }
            weakSelf.topicDetailTab.tableFooterView = (_totalNumber - _pageNum*15)<=0 ? [self tableVieFooterView] : [UIView new];
        }else{
            weakSelf.topicDetailTab.tableFooterView = [UIView new];
            [weakSelf.topicDetailsArray removeAllObjects];
            weakSelf.blankView.hidden = NO;
        }
        [_activityIndicator stopAnimating];
        [weakSelf.topicDetailTab reloadData];
        [weakSelf.topicDetailTab.mj_header endRefreshing];
        [weakSelf.topicDetailTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [_activityIndicator stopAnimating];
        weakSelf.blankView.hidden = NO;
        weakSelf.topicDetailTab.mj_footer.hidden = YES;
        [weakSelf.topicDetailTab.mj_header endRefreshing];
        [weakSelf.topicDetailTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 停止加载图片转圈 =======
- (void)stopImage{
    [self.animationImageView stopAnimating];
}
#pragma mark ====== 重新加载话题 =======
-(void)newTopicDynamicData{
    if (!self.topic_delete_status) {
        _pageNum = 1;
        [self.topicDetailsArray removeAllObjects];
        [self loadTopicData];
    }else{
        [self stopImage];
    }
}
#pragma mark ====== 加载更多话题 =======
- (void)loadMoreTopicDynamicData{
    _pageNum++;
    [self loadTopicData];
}
#pragma mark -- Enent response
#pragma mark ====== nav 返回 || 发布动态 =======
- (void)navBtnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1000:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }break;
        case 1001:
        {
            [MobClick event:@"105_002019"];
            [[TCHelper sharedTCHelper] loginClick:@"008-04-01"];
            if (!_topicModel.is_limit) {
                TCReleaseDynamicViewController *releastDynamicVC = [TCReleaseDynamicViewController new];
                releastDynamicVC.topicTiele = _topicModel.title;
                releastDynamicVC.topicId = _topicModel.topic_id;
                releastDynamicVC.isCanChooseTopic = NO;
                [self.navigationController pushViewController:releastDynamicVC animated:YES];
            }else{
                [self.view makeToast:@"此话题已关闭讨论" duration:1.0 position:CSToastPositionCenter];
            }
        }break;
        default:
            break;
    }
}
#pragma mark ====== UIScrlllviewDelegate =======
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y < -kImageViewHeight) {
        CGRect frame= _headImgView.frame;
        frame.origin.y=y;
        frame.size.height=-y;
        _headImgView.frame=frame;
        _effectView.frame = _headImgView.frame;
        // 对应调整毛玻璃的效果
        _effectView.alpha = 1 + (y + kImageViewHeight) / kImageViewHeight ;
    }
    if (y > - kImageViewHeight - 80) {
        CGFloat alpha = MIN(1, 1 - ((_navbar_change_point - y) / 64));
        _navBarView.backgroundColor = UIColorHex_Alpha(0x05d380, alpha);
        [_navTitltLab setTextColor:[UIColor colorWithWhite:1.0 alpha:alpha]];
    }else{
        [_navTitltLab setTextColor:[UIColor clearColor]];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat y=scrollView.contentOffset.y;
    if (y<-kImageViewHeight- 70) {
        [_activityIndicator startAnimating];
        [self newTopicDynamicData];
    }
}
#pragma mark ====== UITableViewDelegate,UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topicDetailsArray.count > 0 ? self.topicDetailsArray.count : 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.topicDetailsArray.count > 0) {
        TCMyDynamicModel *mynamicMode = self.topicDetailsArray[indexPath.row];
        return mynamicMode.cellHight;
    }
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGSize descSize = [_topicModel.desc boundingRectWithSize:CGSizeMake(kScreenWidth - 40, kScreenHeight) withTextFont:kFontWithSize(15)];
    return  descSize.height > 0 ? 28 + 40 + descSize.height : 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGSize descSize = [_topicModel.desc boundingRectWithSize:CGSizeMake(kScreenWidth - 40, kScreenHeight) withTextFont:kFontWithSize(15)] ;
    UIView *descView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, descSize.height + 28 + 40 )];
    descView.backgroundColor = [UIColor whiteColor];
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 16,kScreenWidth - 40, descSize.height)];
    descLabel.textColor = UIColorFromRGB(0x959595);
    descLabel.font = kFontWithSize(15);
    descLabel.text = _topicModel.desc;
    descLabel.numberOfLines = 0;
    [descView addSubview:descLabel];

    UIView *discussView = [[UIView alloc]initWithFrame:CGRectMake(0, descView.height - 40, kScreenWidth, 40)];
    discussView.backgroundColor =[UIColor bgColor_Gray];
    [descView addSubview:discussView];
    
    UILabel  *discussTotalLabe =[[UILabel alloc]initWithFrame:CGRectMake(20, 10 , kScreenWidth - 40,20)];
    discussTotalLabe.textColor = UIColorFromRGB(0x959595);
    discussTotalLabe.font = kFontWithSize(15);
    discussTotalLabe.text = [NSString stringWithFormat:@"讨论热度（%ld）",(long)_totalNumber];
    [discussView addSubview:discussTotalLabe];
    
    return descView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
#pragma mark ====  查看评论 / 动态内容点击 ====
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *topicThatCellidentifier  = @"TCTopicThatCell";
        TCTopicThatCell *topicThatCell  = [tableView dequeueReusableCellWithIdentifier:topicThatCellidentifier];
        if (!topicThatCell) {
            topicThatCell = [[TCTopicThatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topicThatCellidentifier];
        }
        topicThatCell.topicCellDelegate = self;
        topicThatCell.cellType = TopicCellTypeTopicDetail;
        if (self.topicDetailsArray.count > 0) {
            TCMyDynamicModel  *topicLisModel = self.topicDetailsArray[indexPath.row];
            topicThatCell.myDynamicModel = topicLisModel;
    }
    return topicThatCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
       [self gotoDynamicDetailVCWithIndexPath:indexPath];
}
#pragma mark ====== TCTopicCellDelegate =======
#pragma mark ====== 点击个人信息 =======
-(void)didClickcPersonalInfoInCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel =self.topicDetailsArray[indexPath.row]; ;
    TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
    userInfoVC.news_id = myDynamicModel.user_id;
    userInfoVC.role_type_ed = myDynamicModel.role_type;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
#pragma mark ====== 点击标记区域 =======
- (void)didClickTagLinkSeletedContent:(NSString *)string clickStrId:(NSInteger)clickStrId role_type:(NSInteger)role_type topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
        NSString *clickStr = [string substringToIndex:1];
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
            TCMyDynamicViewController *userInfoVC = [[TCMyDynamicViewController alloc] init];
            userInfoVC.news_id = clickStrId;
            userInfoVC.role_type_ed  = role_type;
            userInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
}
#pragma mark ====== 点赞 =======
- (void)didClickLikeButtonInCell:(UITableViewCell *)cell{
    [MobClick event:@"105_002022"];
    [[TCHelper sharedTCHelper]loginClick:@"008-04-04"];
    
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel =self.topicDetailsArray[indexPath.row];
    NSString *body = [NSString stringWithFormat:@"nc_id=%ld&liked_user_id=%ld&role_type=0&role_type_ed=%ld&type=0&is_like=%d",(long)myDynamicModel.news_id,(long)myDynamicModel.user_id,(long)myDynamicModel.role_type,(long)myDynamicModel.like_status == 1 ? 0 : 1];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KDynamicDoLike body:body success:^(id json) {
        myDynamicModel.like_status = !myDynamicModel.like_status;
        myDynamicModel.like_count =  myDynamicModel.like_status == 1 ? myDynamicModel.like_count + 1 : myDynamicModel.like_count - 1;
        [weakSelf.topicDetailTab reloadData];
    } failure:^(NSString *errorStr) {
        //                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 评论 =======
- (void)didClickcCommentButtonInCell:(UITableViewCell *)cell{
    [[TCHelper sharedTCHelper] loginClick:@"008-04-03"];
    [MobClick event:@"105_002021"];
    
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
    TCMyDynamicModel *myDynamicModel =self.topicDetailsArray[indexPath.row];
    TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
    kSelfWeak;
    dynamicDetailVC.commentsSuccessBlock=^(BOOL isDeleteComments){
        // -- 动态详情评论成功回调刷新数据
        myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [weakSelf.topicDetailTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
    };
    dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
    dynamicDetailVC.news_id = myDynamicModel.news_id;
    dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
    [weakSelf.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark ====== 查看全部 =======
- (void)didClickcLookAllContentInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
    [self gotoDynamicDetailVCWithIndexPath:indexPath];
}
#pragma mark ====== 动态内容 =======
- (void)didClickcDynamicContentInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
    [self gotoDynamicDetailVCWithIndexPath:indexPath];
}
#pragma mark ====== 删除动态 =======
- (void)didClickcDeleteDynamicInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.topicDetailTab indexPathForCell:cell];
     TCMyDynamicModel *topicLisModel =self.topicDetailsArray[indexPath.row];
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    kSelfWeak;
    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *body = [NSString stringWithFormat:@"role_type=%ld&news_id=%ld",(long)topicLisModel.role_type,(long)topicLisModel.news_id];
            [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:KDynamicDelete body:body success:^(id json) {
                NSInteger status = [[json objectForKey:@"status"] integerValue];
                if (status == 1) {
                    [weakSelf.view makeToast:@"删除成功！" duration:1.0 position:CSToastPositionCenter];
                    [weakSelf.topicDetailsArray removeObjectAtIndex:indexPath.row];
                    [TCHelper sharedTCHelper].isNewDynamicRecord = YES;
                    NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                    [weakSelf.topicDetailTab deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationMiddle];
                }
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }];
}
#pragma mark ====== 进入动态详情 =======
- (void)gotoDynamicDetailVCWithIndexPath:(NSIndexPath *)indexPath{
    [[TCHelper sharedTCHelper] loginClick:@"008-04-02"];
    [MobClick event:@"105_002020"];
    
    TCMyDynamicModel *myDynamicModel =self.topicDetailsArray[indexPath.row];
    TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
    dynamicDetailVC.hidesBottomBarWhenPushed = YES;
    dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
    dynamicDetailVC.news_id = myDynamicModel.news_id;
    dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
    kSelfWeak;
    dynamicDetailVC.likeSuccessBlock = ^(NSInteger likeCount, NSInteger like_status) {  // 动态详情点赞成功回调刷新数据
        myDynamicModel.like_count = likeCount;
        myDynamicModel.like_status= like_status;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [weakSelf.topicDetailTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
    };
    dynamicDetailVC.commentsSuccessBlock=^(BOOL isDeleteComments){
        // -- 动态详情评论成功回调刷新数据
        myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [weakSelf.topicDetailTab reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark ====== Getter =======
- (void)initTopicDetailTab{
    _topicDetailTab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _topicDetailTab.delegate = self;
    _topicDetailTab.dataSource = self;
    _topicDetailTab.backgroundColor = [UIColor bgColor_Gray];
    _topicDetailTab.tableFooterView = [UIView new];
    _topicDetailTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _topicDetailTab.contentInset = UIEdgeInsetsMake(kImageViewHeight, 0, 0, 0);
    [self.view addSubview:_topicDetailTab];
    
    MJRefreshAutoNormalFooter *mjFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopicDynamicData)];
    mjFooter.automaticallyRefresh = NO;
    _topicDetailTab.mj_footer = mjFooter;
    mjFooter.hidden = YES;
    
    [_topicDetailTab addSubview:self.blankView];
    
    // -- 头部视图
    _headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -kImageViewHeight, kScreenWidth, kImageViewHeight)];
    [_headImgView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"untopicList_bg"]];
    _headImgView.userInteractionEnabled = YES;
    _headImgView.autoresizesSubviews = YES;
    _headImgView.clipsToBounds = YES;
    _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    [_topicDetailTab addSubview:_headImgView];
    
    //模糊遮罩
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _effectView.frame = _headImgView.frame; // 加到相应的位置即可
    [_topicDetailTab addSubview:_effectView];
    
    // 菊花
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.frame = CGRectMake(kScreenWidth - 40, kNewNavHeight + 20, 30, 30);
    [_effectView.contentView addSubview:_activityIndicator];
    
    _topicTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, (_headImgView.height - 20)/2, kScreenWidth - 20, 30)];
    _topicTitleLab.textAlignment = NSTextAlignmentCenter;
    _topicTitleLab.textColor = [UIColor whiteColor];
    _topicTitleLab.font = kFontWithSize(25);
    _topicTitleLab.text = [NSString stringWithFormat:@"#%@#",self.topic];
    _topicTitleLab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_effectView.contentView addSubview:_topicTitleLab];
    
    _readLab = [[UILabel alloc]initWithFrame:CGRectMake(0, kImageViewHeight - 40, kScreenWidth/2 - 20, 20)];
    _readLab.textColor = [UIColor whiteColor];
    _readLab.font = kFontWithSize(15);
    _readLab.text = @"0阅读";
    _readLab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _readLab.textAlignment = NSTextAlignmentRight;
    [_effectView.contentView  addSubview:_readLab];
    
    _discussLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2 + 20, _readLab.top , kScreenWidth/2 - 20, 20)];
    _discussLab.textAlignment = NSTextAlignmentLeft;
    _discussLab.font = kFontWithSize(15);
    _discussLab.text = @"0讨论";
    _discussLab.textColor = [UIColor whiteColor];
    _discussLab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_effectView.contentView  addSubview:_discussLab];
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
#pragma mark ====== 无数据视图 =======
- (TCBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[TCBlankView alloc]initWithFrame:CGRectMake(0,  140 , kScreenWidth, 200) img:@"un_dynamic" text:self.topic_delete_status ?@"该话题不存在": @"暂无动态"];
        _blankView.hidden = !self.topic_delete_status;
    }
    return _blankView;
}
#pragma mark ====== 导航视图 =======
- (UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
        _navBarView.backgroundColor =UIColorHex_Alpha(0x05d380, 0);
        // -- 返回
        UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, KStatusHeight+2, 40, 40)];
        [backBtn setImage:[UIImage drawImageWithName:@"back.png"size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
        backBtn.tag = 1000;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(navBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:backBtn];
        // -- 标题
        _navTitltLab = [[UILabel alloc]initWithFrame:CGRectMake(45,KStatusHeight+ 12, kScreenWidth - 90, 20)];
        _navTitltLab.textColor = [UIColor clearColor];
        _navTitltLab.textAlignment = NSTextAlignmentCenter;
        _navTitltLab.font = kFontWithSize(18);
          _navTitltLab.text = [NSString stringWithFormat:@"#%@#",self.topic];
        [_navBarView addSubview:_navTitltLab];
        // -- 发布
        _writingDynamicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _writingDynamicBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, KStatusHeight + 2, 40, 40)];
        [_writingDynamicBtn setImage:[UIImage drawImageWithName:@"ic_top_publish"size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
        _writingDynamicBtn.tag = 1001;
        [_writingDynamicBtn addTarget:self action:@selector(navBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _writingDynamicBtn.hidden = YES;
        [_navBarView addSubview:_writingDynamicBtn];
    }
    return _navBarView;
}
- (NSMutableArray *)topicDetailsArray{
    if (!_topicDetailsArray) {
        _topicDetailsArray = [NSMutableArray array];
    }
    return _topicDetailsArray;
}

@end
