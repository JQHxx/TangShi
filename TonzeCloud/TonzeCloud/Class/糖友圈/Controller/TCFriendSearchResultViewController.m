//
//  TCFriendSearchResultViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/12.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCFriendSearchResultViewController.h"
#import "TCMyDynamicModel.h"
#import "TCBlankView.h"
#import "TCMyDynamicTableViewCell.h"
#import "TCFriendSearchModel.h"
#import "TCSearchResultTableViewCell.h"
#import "TCDynamicDetailViewController.h"
#import "TCTopicDetailsViewController.h"
#import "TCMyDynamicViewController.h"

@interface TCFriendSearchResultViewController ()<UITableViewDelegate,UITableViewDataSource,TCSeleteResultDelegate,TCMyDynamicDelegate>{
    NSMutableArray      *mydamicArr;
    NSMutableArray      *friendArr;

    TCBlankView         *blankView;
    
    NSInteger            news_id;
    NSInteger            role_types;
}
@end
@interface TCFriendSearchResultViewController ()

@end

@implementation TCFriendSearchResultViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    mydamicArr=[[NSMutableArray alloc] init];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (kIsArray(friendArr)) {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }
    return mydamicArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        static NSString *cellIdntifier=@"TCSearchResultTableViewCell";
        TCSearchResultTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
        if (cell==nil) {
            cell=[[TCSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdntifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.resultDelegate = self;
        [cell cellFriendSearchResult:friendArr];
        return cell;
    }
    static NSString *cellIdntifier=@"TCMyDynamicTableViewCell";
    TCMyDynamicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[TCMyDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdntifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    TCMyDynamicModel *mynamicModel=mydamicArr[indexPath.row];
    [cell cellMyDynamicModel:mynamicModel];
    
    // 查看评论
    cell.reviewClick = ^(NSInteger btnIndex) {
        if ([_friendSearchDelegate respondsToSelector:@selector(lookDynamicDetailModel:)]) {
            [_friendSearchDelegate lookDynamicDetailModel:mynamicModel];
        }
    };
    // 点击动态内容文字
    cell.dynamicContentClickBlock = ^{
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
        dynamicDetailVC.commentsSuccessBlock= ^(BOOL isDeleteComments){
            // -- 动态详情评论成功回调刷新数据
            mynamicModel.comment_count = isDeleteComments == YES ? mynamicModel.comment_count - 1: mynamicModel.comment_count + 1;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        dynamicDetailVC.likeSuccessBlock = ^(NSInteger likeCount, NSInteger like_status) {
            // 动态详情点赞成功回调刷新数据
            mynamicModel.like_count = likeCount;
            mynamicModel.like_status= like_status;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        if ([_friendSearchDelegate respondsToSelector:@selector(lookDynamicDetailModel:)]) {
            [_friendSearchDelegate lookDynamicDetailModel:mynamicModel];
        }
    };
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return friendArr.count>0?110:0.01;
    }
    TCMyDynamicModel *myDynamicModel =mydamicArr[indexPath.row];
    CGFloat height = [TCMyDynamicTableViewCell getDynamicContentTextHeightWithDynamic:myDynamicModel];
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return section==0?48:58;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return friendArr.count>0?0.01:110;
    }
    return mydamicArr.count>0?40:200;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, section==1?58:48)];
    if (section==1) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"0xdcdcdc"];
        [headView addSubview:bgView];
    }
    
    UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(10,section==1?24:14 , 2, 20)];
    lens.backgroundColor = kSystemColor;
    [headView addSubview:lens];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, section==1?24:14, kScreenWidth/2, 20)];
    titleLabel.text = section==0?@"糖友搜索结果":@"动态搜索结果";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [headView addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, section==0?47:57, kScreenWidth, 1)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xdcdcdc"];
    [headView addSubview:lineLabel];
    
    return headView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, section==0?110:200)];
    
    for (UIView *view in footView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    if (friendArr.count==0&&section==0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 20)];
        titleLabel.text = @"未找到相关糖友";
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [footView addSubview:titleLabel];
    }else if(section==1){
        if (mydamicArr.count>0) {
            footView.frame = CGRectMake(0, 0, kScreenWidth, 40);
            
            UILabel *unMoreDynamicLab = [[UILabel alloc]initWithFrame:footView.frame];
            unMoreDynamicLab.text = @"没有更多了";
            unMoreDynamicLab.textAlignment = NSTextAlignmentCenter;
            unMoreDynamicLab.textColor = UIColorFromRGB(0x959595);
            unMoreDynamicLab.font = kFontWithSize(15);
            [footView addSubview:unMoreDynamicLab];
        }else{
            [footView addSubview:blankView];
        }
    }
    return footView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        TCMyDynamicModel *mynamicModel=mydamicArr[indexPath.row];
        if ([_friendSearchDelegate respondsToSelector:@selector(lookDynamicDetailModel:)]) {
            [_friendSearchDelegate lookDynamicDetailModel:mynamicModel];
        }
    }
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_friendSearchDelegate respondsToSelector:@selector(friendSearchResultViewControllerBeginDraggingAction)]) {
        [_friendSearchDelegate friendSearchResultViewControllerBeginDraggingAction];
    }
}
#pragma mark -- TCSeleteResultDelegate
#pragma mark -- 更多
- (void)seletedMoreFriend{
     if ([_friendSearchDelegate respondsToSelector:@selector(seletedMoreFriendResult)]) {
        [_friendSearchDelegate seletedMoreFriendResult];
    }
}
#pragma mark -- 选择糖友
- (void)seletedFriendModel:(TCFriendSearchModel *)model{
    if ([_friendSearchDelegate respondsToSelector:@selector(seleteSearchFriendResult:)]) {
        [_friendSearchDelegate seleteSearchFriendResult:model];
    }
}
#pragma mark -- TCMyDynamicDelegate
#pragma mark -- 查看全部
- (void)lookAllContent:(TCMyDynamicModel *)model{
    if ([_friendSearchDelegate respondsToSelector:@selector(lookDynamicDetailModel:)]) {
        [_friendSearchDelegate lookDynamicDetailModel:model];
    }
}
#pragma mark -- 删除
-(void)deleteContent:(NSInteger)expert_id role_type:(NSInteger)role_type{
    news_id = expert_id;
    role_types = role_type;
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark -- 点击标记区域
- (void)myLinSeletedContent:(NSInteger)user_id role_type:(NSInteger)role_type{
    
    if ([_friendSearchDelegate respondsToSelector:@selector(seleteFriendResult:role_type:)]) {
        [_friendSearchDelegate seleteFriendResult:user_id role_type:role_type];
    }
}
#pragma mark -- 查看话题
- (void)myLookTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
    
    if ([_friendSearchDelegate respondsToSelector:@selector(seleteLookTopicDetail:topic_delete_status:topic:)]) {
        [_friendSearchDelegate seleteLookTopicDetail:topic_id topic_delete_status:topic_delete_status topic:topic];
    }
}
#pragma mark -- 点击用户头像
- (void)myLinkUserInfo:(TCMyDynamicModel *)model{
    
    if ([_friendSearchDelegate respondsToSelector:@selector(seleteMydynamicFriendResult:)]) {
        [_friendSearchDelegate seleteMydynamicFriendResult:model];
    }
}
#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        kSelfWeak;
        NSString *body = [NSString stringWithFormat:@"news_id=%ld&role_type=%ld",news_id,role_types];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDelete body:body success:^(id json) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (TCMyDynamicModel *model in mydamicArr) {
                if (model.news_id != news_id) {
                    [array addObject:model];
                }
            }
            mydamicArr = array;
            [self.tableView reloadData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }

}
#pragma mark -- 点赞
- (void)myPreiseDynamic:(TCMyDynamicModel *)model{
    NSMutableArray *praiseArr = [[NSMutableArray alloc] init];
    for (TCMyDynamicModel *myDynamicModel in mydamicArr) {
        if (myDynamicModel.news_id == model.news_id) {
            if (myDynamicModel.like_status==1) {
                myDynamicModel.like_count = myDynamicModel.like_count-1;
            } else {
                myDynamicModel.like_count = myDynamicModel.like_count+1;
            }
            myDynamicModel.like_status=!myDynamicModel.like_status;
        }
        [praiseArr addObject:myDynamicModel];
    }
    mydamicArr = praiseArr;
    [self.tableView reloadData];
}

#pragma mark -- Private Methods
-(void)setKeyword:(NSString *)keyword{
    _keyword=keyword;
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)_keyword,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                         kCFStringEncodingUTF8);
    NSString *url=KSugarFriendSerarch;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&keywords=%@&role_type=0",(long)_page,baseString];
    
    CFRelease((__bridge CFTypeRef)(baseString));
    
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:url body:body success:^(id json) {
        if (_page==1) {
            friendArr = [[NSMutableArray alloc] init];
        }
        NSInteger pager=[[json objectForKey:@"total"] integerValue];
        self.tableView.mj_footer.hidden=(pager-_page*20)<=0;
        
        NSArray *friendArray = [json objectForKey:@"friends"];
        if (friendArray.count>0) {
            for (NSDictionary *dict in friendArray) {
                TCFriendSearchModel *friendSearchModel=[[TCFriendSearchModel alloc] init];
                [friendSearchModel setValues:dict];
                [friendArr addObject:friendSearchModel];
            }
        }else{
            if (_page==1) {
                [friendArr removeAllObjects];
            }
        }
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *dynamicArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMyDynamicModel *myDynamicModel = [[TCMyDynamicModel alloc] init];
                [myDynamicModel setValues:dict];
                [dynamicArr addObject:myDynamicModel];
            }
            if (_page==1) {
                mydamicArr = dynamicArr;
                blankView.hidden = dynamicArr.count>0;
            } else {
                [mydamicArr addObjectsFromArray:dynamicArr];
            }
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }else{
            [mydamicArr removeAllObjects];
            self.tableView.tableFooterView = [UIView new];
            blankView.hidden = NO;
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSString *errorStr) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        blankView.hidden = NO;
        [mydamicArr removeAllObjects];
        [self.tableView reloadData];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 加载最新数据
-(void)loadNewSearchFoodData{
    _page =1;
    [self setKeyword:_keyword];
    
}
#pragma mark -- 加载更多数据
-(void)loadMoreSearchFoodData{
    _page++;
    [self setKeyword:_keyword];
    
}
#pragma mark -- Setters and Getters
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.backgroundColor=[UIColor bgColor_Gray];
        _tableView.tableFooterView=[[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSearchFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _tableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSearchFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden=YES;
        
       blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight) img:@"img_none" text:@"未找到相关动态"];
        blankView.hidden=YES;
        
    }
    return _tableView;
}




@end
