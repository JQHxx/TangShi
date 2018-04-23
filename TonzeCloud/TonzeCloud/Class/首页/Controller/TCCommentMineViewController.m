//
//  TCCommentMineViewController.m
//  TonzeCloud
//
//  Created by vision on 17/10/11.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCCommentMineViewController.h"
#import "TCBasewebViewController.h"
#import "TCMineSugarFriendViewController.h"
#import "TCMyDynamicViewController.h"
#import "TCCommentNewsModel.h"
#import "TCCommentNewsCell.h"
#import "DownListMenu.h"
#import "TCMenuModel.h"
#import "TCBlankView.h"

@interface TCCommentMineViewController ()<DownListMenuDelegate,UITableViewDelegate,UITableViewDataSource,TCCommentNewsCellDelegate>{
    UIImageView      *arrowImageView;
    DownListMenu     *listMenu;
    UILabel          *titleLab;
    TCBlankView      *blankView;
    
    NSArray          *menuValueArr;
    NSString         *titleStr;
    NSMutableArray   *commentListArr;
    NSInteger        selectIndex;
    NSInteger        commentPage;
}

@property (nonatomic,strong)UIView           *titleView;
@property (nonatomic,strong)UITableView      *commentTableView;

@end

@implementation TCCommentMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenBackBtn=YES;
    
    menuValueArr=@[@"评论我的",@"我评论的"];
    titleStr=@"评论我的";
    commentListArr=[[NSMutableArray alloc] init];
    commentPage=1;
    selectIndex=0;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.commentTableView];
    
    [self requstForCommentArticleData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-05" type:1];
#endif
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (listMenu) {
        [listMenu backUpCoverAction];
        listMenu=nil;
    }
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"004-01-05" type:2];
#endif
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return commentListArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCCommentNewsCell";
    TCCommentNewsCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCCommentNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.cellDelegate=self;
    
    TCCommentNewsModel *model=commentListArr[indexPath.section];
    [cell commentNewsCellDisplayWithModel:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCCommentNewsModel *model=commentListArr[indexPath.section];
    NSDictionary *articleDict=model.article_info;
    NSDictionary *userInfo=@{@"id":[NSNumber numberWithInteger:model.article_id],@"title":articleDict[@"title"],@"cover":articleDict[@"image"]};
    [self pushIntoArticelDetailsVCWithArticleInfo:userInfo];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCCommentNewsModel *model=commentListArr[indexPath.section];
    return [TCCommentNewsCell getCommentNewsCellHeightWithModel:model];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

#pragma mark TCCommentArticleCellDelegate
#pragma mark 跳转到文章详情
-(void)pushIntoArticelDetailsVCWithArticleInfo:(NSDictionary *)info{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"004-01-05-02:%ld",[[info valueForKey:@"id"] integerValue]]];
#endif
    [MobClick event:@"101_003023"];
    TCBasewebViewController *webVC=[[TCBasewebViewController alloc] init];
    webVC.type=BaseWebViewTypeArticle;
    webVC.titleText=@"糖士-糖百科";
    webVC.shareTitle = [info valueForKey:@"title"];
    webVC.image_url = [info valueForKey:@"cover_url"];
    NSInteger article_id=[[info valueForKey:@"id"] integerValue];
    webVC.articleID =article_id;
    webVC.urlStr=[NSString stringWithFormat:@"%@article/%ld",kWebUrl,(long)article_id];
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark 跳转到个人主页
-(void)pushIntoPersonalVCWithIsSelf:(BOOL)isSelf userId:(NSInteger)user_id{
    if (isSelf) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick: [NSString stringWithFormat:@"004-01-05-01:%ld",user_id]];
#endif
        [MobClick event:@"101_003022"];
        TCMineSugarFriendViewController *myPersonalMainVC=[[TCMineSugarFriendViewController alloc] init];
        [self.navigationController pushViewController:myPersonalMainVC animated:YES];
    }else{
        TCMyDynamicViewController *myDynamicVC=[[TCMyDynamicViewController alloc] init];
        myDynamicVC.news_id=user_id;
        [self.navigationController pushViewController:myDynamicVC animated:YES];
    }
}

#pragma mark DownListMenuDelegate
-(void)downListMenuDidSelectedMenu:(NSInteger)index{
    titleStr=menuValueArr[index];
    titleLab.text=[NSString stringWithFormat:@"%@",titleStr];
    CGFloat titleW=[titleLab.text boundingRectWithSize:CGSizeMake(200, 20) withTextFont:titleLab.font].width;
    titleLab.frame=CGRectMake((kScreenWidth-titleW-15)/2, KStatusHeight, titleW, 44);
    arrowImageView.frame=CGRectMake(titleLab.right+5,KStatusHeight + 15, 15, 15);
    
    selectIndex=index;
    [self requstForCommentArticleData];
}

#pragma mark -- Event Response
#pragma mark 标题切换
-(void)selectTitleViewAction{
    if (!listMenu) {
        listMenu=[[DownListMenu alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, menuValueArr.count*44)];
        listMenu.menuArray=[self getMenuListInfo];
        listMenu.viewDelegate=self;
        listMenu.backUpCoverBlock=^(){
            listMenu=nil;
        };
        [listMenu downListMenuShow];
    }else{
        [listMenu backUpCoverAction];
        listMenu=nil;
    }
}

#pragma mark -- Private Methods
#pragma mark 
-(void)loadNewCommentsData{
    commentPage=1;
    [self requstForCommentArticleData];
}

-(void)loadMoreCommentsData{
    commentPage++;
    [self requstForCommentArticleData];
}


#pragma mark 获取评论文章数据
-(void)requstForCommentArticleData{
    NSString *urlStr = nil;
    if (selectIndex==1) { //我评论的
        urlStr = [NSString stringWithFormat:@"%@?page_num=%ld&page_size=20&role_type=0",kMyCommentList,(long)commentPage];
    } else { //评论我的
        urlStr = [NSString stringWithFormat:@"%@?page_num=%ld&page_size=20&role_type_ed=0",kCommentMineList,(long)commentPage];
    }
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithURL:urlStr success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        NSMutableArray *tempCommentArr=[[NSMutableArray alloc] init];
        if (kIsArray(result)) {
            for (NSDictionary *dict in result) {
                TCCommentNewsModel *model=[[TCCommentNewsModel alloc] init];
                [model setValues:dict];
                [tempCommentArr addObject:model];
            }
            if (commentPage==1) {
                commentListArr=tempCommentArr;
            }else{
                [commentListArr addObjectsFromArray:tempCommentArr];
            }
        }
        blankView.hidden=commentListArr.count>0;
        [weakSelf.commentTableView reloadData];
        [weakSelf.commentTableView.mj_header endRefreshing];
        [weakSelf.commentTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.commentTableView.mj_header endRefreshing];
        [weakSelf.commentTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 获取菜单列表信息
-(NSMutableArray *)getMenuListInfo{
    NSMutableArray *tempTitleArr=[[NSMutableArray alloc] init];
    for (NSString *tempTitle in menuValueArr) {
        TCMenuModel *menu=[[TCMenuModel alloc] init];
        menu.menu_name=[NSString stringWithFormat:@"%@",tempTitle];
        menu.isSelected=[tempTitle isEqualToString:titleStr];
        [tempTitleArr addObject:menu];
    }
    return tempTitleArr;
}

#pragma mark -- Setters
#pragma mark 标题栏
-(UIView *)titleView{
    if (!_titleView) {
        _titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
        _titleView.backgroundColor=kSystemColor;
        _titleView.userInteractionEnabled=YES;
        
        UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [backBtn setImage:[UIImage drawImageWithName:@"back.png"size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:backBtn];
        
        titleLab=[[UILabel alloc] initWithFrame:CGRectZero];
        titleLab.font=[UIFont systemFontOfSize:18];
        titleLab.text=[NSString stringWithFormat:@"%@",titleStr];
        titleLab.textColor=[UIColor whiteColor];
        CGFloat titleW=[titleLab.text boundingRectWithSize:CGSizeMake(200, 20) withTextFont:titleLab.font].width;
        titleLab.frame=CGRectMake((kScreenWidth-titleW-15)/2,KStatusHeight, titleW, 44);
        [_titleView addSubview:titleLab];
        
        arrowImageView=[[UIImageView alloc] initWithFrame:CGRectMake(titleLab.right+5,KStatusHeight + 15, 15, 15)];
        arrowImageView.image=[UIImage imageNamed:@"ic_top_arrow_down"];
        [_titleView addSubview:arrowImageView];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTitleViewAction)];
        [_titleView addGestureRecognizer:tapGesture];
        
    }
    return _titleView;
}

#pragma mark 评论文章
-(UITableView *)commentTableView{
    if (!_commentTableView) {
        _commentTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _commentTableView.dataSource=self;
        _commentTableView.delegate=self;
        _commentTableView.tableFooterView=[[UIView alloc] init];
        _commentTableView.backgroundColor=[UIColor bgColor_Gray];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCommentsData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _commentTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCommentsData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _commentTableView.mj_footer = footer;
        footer.hidden=YES;
        
        blankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, kNewNavHeight+30, kScreenWidth, 200) img:@"img_tips_no" text:@"还没有评论记录"];
        [_commentTableView addSubview:blankView];
        blankView.hidden=YES;
    }
    return _commentTableView;
}


@end
