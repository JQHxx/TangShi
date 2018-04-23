//
//  TCMyDynamicViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/8/7.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCMyDynamicViewController.h"
#import "TCUserDynamicButton.h"
#import "TCMyDynamicTableViewCell.h"
#import "TCFocusOnViewController.h"
#import "TCBeFocusOnViewController.h"
#import "TCMyDynamicModel.h"
#import "TCFocusOnButton.h"
#import "TCUserinfoViewController.h"
#import "TCDynamicDetailViewController.h"
#import "TCFilesViewController.h"
#import "TCMineDynamicModel.h"
#import "TCTopicDetailsViewController.h"

@interface TCMyDynamicViewController ()<UITableViewDelegate,UITableViewDataSource,TCMyDynamicDelegate,UIAlertViewDelegate,UIAlertViewDelegate>{
    
    UIImageView               *sugarTypeImgView;
    UIImageView               *_sexImgView;
    UIButton                  *_headImageButton;  //头像
    UILabel                   *_nickNameLabel;
    TCUserDynamicButton       *sugarTypeButton;
    
    NSMutableArray            *myDynamicArray;
    
    TCFocusOnButton           *FocusOnButton;
    TCFocusOnButton           *beFocusOnButton;
    UILabel                   *textTitle;
    UIButton              *_focusOnTypeBtn;      // 关注状态
    
    NSInteger                 myDynamicPage;
    NSInteger                 newsid;
    NSInteger                 roletype;
    TCMineDynamicModel *mySugarFriendModel;
    NSInteger                 followType;       // 0: 未关注 1：已关注 2：互相关注
    NSInteger                 total;
}

@property (nonatomic ,strong) UITableView  *myDynamicTab;
@property (nonatomic ,strong) UIView       *navigationView;
@property (nonatomic ,strong) UIImageView  *actImageView;
@property (nonatomic ,strong) TCBlankView  *myDynamicBlankView;


@end

@implementation TCMyDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.isHiddenNavBar = YES;
    myDynamicArray = [[NSMutableArray alloc] init];
    myDynamicPage = 1;
    
    [self initMyDynamicView];
    [self setNavagationView];
    [self loadMineUserInfo];
    [self loadMyDynamicData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if (!self.isMyDynamic) {
        [[TCHelper sharedTCHelper] loginAction:@"008-07" type:2];
    }
    [MobClick endLogPageView:self.isMyDynamic?@"我的动态":@"他人的个人主页"];
    if ([TCHelper sharedTCHelper].isDeleteDynamic==YES) {
        [self loadMyDynamicData];
        [TCHelper sharedTCHelper].isDeleteDynamic=NO;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.isMyDynamic) {
        [[TCHelper sharedTCHelper] loginAction:@"008-07" type:1];
    }
    [MobClick beginLogPageView:self.isMyDynamic?@"我的动态":@"他人的个人主页"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return myDynamicArray.count>0?myDynamicArray.count:0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"TCMyDynamicTableViewCell";
    TCMyDynamicTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TCMyDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    TCMyDynamicModel *myDynamicModel =myDynamicArray[indexPath.row];
    [cell cellMyDynamicModel:myDynamicModel];
    
    // 查看评论
    kSelfWeak;
    cell.reviewClick = ^(NSInteger btnIndex) {
        [MobClick event:@"105_002040"];
        [[TCHelper sharedTCHelper] loginClick:@"008-07-05"];
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
//        dynamicDetailVC.commentsSuccessBlock= ^(BOOL isDeleteComments){
//            // -- 动态详情评论成功回调刷新数据
//            myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
//            NSIndexPath *indexP=[NSIndexPath indexPathForRow:indexPath.row inSection:1];
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
//        };
        dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
        dynamicDetailVC.news_id = myDynamicModel.news_id;
        dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
        [weakSelf.navigationController pushViewController:dynamicDetailVC animated:YES];
    };
    // 点击动态内容文字
    cell.dynamicContentClickBlock = ^{
        [MobClick event:@"105_001007"];
        [[TCHelper sharedTCHelper] loginClick:@"008-07-04"];
        TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
        dynamicDetailVC.commentsSuccessBlock= ^(BOOL isDeleteComments){
            // -- 动态详情评论成功回调刷新数据
            myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        dynamicDetailVC.likeSuccessBlock = ^(NSInteger likeCount, NSInteger like_status) {
            // 动态详情点赞成功回调刷新数据
            myDynamicModel.like_count = likeCount;
            myDynamicModel.like_status= like_status;
            NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
        };
        dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
        dynamicDetailVC.news_id = myDynamicModel.news_id;
        dynamicDetailVC.role_type_ed =  myDynamicModel.role_type;
        [weakSelf.navigationController pushViewController:dynamicDetailVC animated:YES];
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    TCMyDynamicModel *myDynamicModel =myDynamicArray[indexPath.row];
    CGFloat height = [TCMyDynamicTableViewCell getDynamicContentTextHeightWithDynamic:myDynamicModel];
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
        return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    headView.backgroundColor = [UIColor whiteColor];
    if (section==0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth/2, 20)];
        titleLabel.text = [NSString stringWithFormat:@"全部动态（%ld）",(unsigned long)total];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor grayColor];
        [headView addSubview:titleLabel];
        
        UILabel *linelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 0.3)];
        linelabel.backgroundColor = [UIColor grayColor];
        [headView addSubview:linelabel];
    }
    return headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[TCHelper sharedTCHelper] loginClick:@"008-07-04"];
    [MobClick event:@"105_002039"];
    TCMyDynamicModel *myDynamicModel =myDynamicArray[indexPath.row];
    TCDynamicDetailViewController *dynamicDetailVC = [[TCDynamicDetailViewController alloc] init];
    dynamicDetailVC.likeSuccessBlock = ^(NSInteger likeCount, NSInteger like_status) {  // 动态详情点赞成功回调刷新数据
        myDynamicModel.like_count = likeCount;
        myDynamicModel.like_status= like_status;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
    };
    dynamicDetailVC.commentsSuccessBlock= ^(BOOL isDeleteComments){
        // -- 动态详情评论成功回调刷新数据
        myDynamicModel.comment_count = isDeleteComments == YES ? myDynamicModel.comment_count - 1: myDynamicModel.comment_count + 1;
        NSIndexPath *indexP=[NSIndexPath indexPathForRow:0 inSection:indexPath.row];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexP] withRowAnimation:UITableViewRowAnimationNone];
    };
    dynamicDetailVC.news_id = myDynamicModel.news_id;
    dynamicDetailVC.commented_user_id = myDynamicModel.user_id;
    dynamicDetailVC.role_type_ed = myDynamicModel.role_type;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- TCMyDynamicDelegate
#pragma mark -- 查看全部
- (void)lookAllContent:(TCMyDynamicModel *)model{
    TCDynamicDetailViewController *dynamicDetailVC = [TCDynamicDetailViewController new];
    dynamicDetailVC.commented_user_id = model.user_id;
    dynamicDetailVC.news_id = model.news_id;
    dynamicDetailVC.role_type_ed =  model.role_type;
    [self.navigationController pushViewController:dynamicDetailVC animated:YES];
}
#pragma mark -- 删除
-(void)deleteContent:(NSInteger)expert_id role_type:(NSInteger)role_type{
    newsid = expert_id;
    roletype = role_type;
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark -- 点击标记区域
- (void)myLinSeletedContent:(NSInteger)user_id role_type:(NSInteger)role_type{
    
    self.news_id = user_id;
    self.role_type_ed = role_type;
    [self loadMineUserInfo];
    [self loadMyDynamicData];
}
#pragma mark -- 查看话题
- (void)myLookTopicDetail:(NSInteger)topic_id topic_delete_status:(BOOL)topic_delete_status topic:(NSString *)topic{
    TCTopicDetailsViewController *topicDetailVC = [[TCTopicDetailsViewController alloc] init];
    topicDetailVC.topicId = topic_id;
    topicDetailVC.topic_delete_status = topic_delete_status;
    topicDetailVC.topic = topic;
    [self.navigationController pushViewController:topicDetailVC animated:YES];
}
#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        kSelfWeak;
        NSString *body = [NSString stringWithFormat:@"news_id=%ld&role_type=%ld",newsid,roletype];
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:KDynamicDelete body:body success:^(id json) {
            [weakSelf loadMyDynamicData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark -- 点赞
- (void)myPreiseDynamic:(TCMyDynamicModel *)model{
    NSMutableArray *praiseArr = [[NSMutableArray alloc] init];
    for (TCMyDynamicModel *myDynamicModel in myDynamicArray) {
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
    myDynamicArray = praiseArr;
    [self.myDynamicTab reloadData];
}
#pragma mark -- UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y=scrollView.contentOffset.y;
    if (y < -kImgViewHeight) {
        CGRect frame=sugarTypeImgView.frame;
        frame.origin.y=y;
        frame.size.height=-y;
        sugarTypeImgView.frame=frame;
    }
    
    if (scrollView.contentOffset.y >  -kImgViewHeight+130) {
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            // 导航条加颜色（不再透明）
            _navigationView.backgroundColor = kbgBtnColor;
            textTitle.hidden = NO;
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            //导航条透明
            _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
            textTitle.hidden = YES;
        }];
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat y=scrollView.contentOffset.y;
    if (y<-kImgViewHeight-70) {
        myDynamicPage=1;
        [self loadMyDynamicData];
    }
}
#pragma mark -- Event response
#pragma mark ====== 关注/ 取消关注 状态 =======
- (void)focusOnClick{
    [[TCHelper sharedTCHelper] loginClick:@"008-07-01"];
    [MobClick event:@"105_002036"];
    followType = mySugarFriendModel.is_follow == 0 ? 1 : 2;
    NSString  *body = [NSString stringWithFormat:@"followed_user_id=%ld&role_type=0&role_type_ed=%ld&focus=%ld",mySugarFriendModel.user_id,mySugarFriendModel.role_type_ed,followType];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kFocusFriend body:body success:^(id json) {
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        FocusOnButton.enabled = YES;
        if (status) {
            [weakSelf loadMineUserInfo];
        }
        [TCHelper sharedTCHelper].isFocusOnDynamicListReload = YES;
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma MARK -- 关注／被关注
- (void)focusButton:(UIButton *)button{
    if (button.tag==100) {
        [[TCHelper sharedTCHelper] loginClick:@"008-07-02"];
        [MobClick event:@"105_002037"];
        TCFocusOnViewController *focusOnVC = [[TCFocusOnViewController alloc] init];
        focusOnVC.user_id = self.news_id;
        focusOnVC.role_type = self.role_type_ed;
        focusOnVC.type = 2;
        [self.navigationController pushViewController:focusOnVC animated:YES];
    } else {
        [[TCHelper sharedTCHelper] loginClick:@"008-07-03"];
        [MobClick event:@"105_002038"];
        TCBeFocusOnViewController *brFocusOnVC = [[TCBeFocusOnViewController alloc] init];
        brFocusOnVC.user_id = self.news_id;
        brFocusOnVC.type = 2;
        brFocusOnVC.role_type = self.role_type_ed;
        [self.navigationController pushViewController:brFocusOnVC animated:YES];
    }
}
#pragma mark -- 获取个人信息
- (void)loadMineUserInfo{
    
    NSString *body = [NSString stringWithFormat:@"%@?user_id=%ld&role_type=0&role_type_ed=%ld",KLoadFriendUserInfo,self.news_id,self.role_type_ed];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithoutLoadingForURL:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            mySugarFriendModel = [[TCMineDynamicModel alloc] init];
            [mySugarFriendModel setValues:result];
            //用户
            [_headImageButton sd_setImageWithURL:[NSURL URLWithString:mySugarFriendModel.head_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_m_head_156"]];
            
            _nickNameLabel.text =mySugarFriendModel.nick_name;
            textTitle.text =mySugarFriendModel.nick_name;
            CGSize size = [_nickNameLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:16]];
            _nickNameLabel.frame =CGRectMake(_headImageButton.right+15,_headImageButton.top +4,size.width, 20);
            _sexImgView.frame =CGRectMake(_nickNameLabel.right,_nickNameLabel.top-5 , 30, 30);
            
            if (mySugarFriendModel.sex!=3) {
                _sexImgView.image =[UIImage imageNamed:mySugarFriendModel.sex==1?@"ic_m_male1":@"ic_m_famale1"];
            }
            NSString *sugarTitle =mySugarFriendModel.diabetes_type;
            NSString *timeString =mySugarFriendModel.diagnosis_time;
            if (sugarTitle.length>0) {
                if ([sugarTitle isEqualToString:@"其他"]||[sugarTitle isEqualToString:@"正常"]) {
                    sugarTypeButton.title = [NSString stringWithFormat:@"%@",sugarTitle];
                }else{
                    sugarTypeButton.title = [NSString stringWithFormat:@"%@ %@",sugarTitle,timeString];
                }
            }else{
                sugarTypeButton.title = @"未知";
            }
            FocusOnButton.numTitle = [NSString stringWithFormat:@"%ld",(long)mySugarFriendModel.follow_num];
            beFocusOnButton.numTitle =[NSString stringWithFormat:@"%ld",(long)mySugarFriendModel.followed_num];
            // 关注状态
            if (mySugarFriendModel.is_follow == 0 && mySugarFriendModel.is_self != 1) {
                [_focusOnTypeBtn setImage:[UIImage imageNamed:@"add_focuse"] forState:UIControlStateNormal];
            }else if(mySugarFriendModel.is_follow == 1 && mySugarFriendModel.is_self != 1){
                [_focusOnTypeBtn setImage:[UIImage imageNamed:@"focused"] forState:UIControlStateNormal];
            }else if(mySugarFriendModel.is_follow == 2 && mySugarFriendModel.is_self != 1 ){
                [_focusOnTypeBtn setImage:[UIImage imageNamed:@"focusOnEachOther"] forState:UIControlStateNormal];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取我的动态
- (void)loadMyDynamicData{
    kSelfWeak;
    [self.actImageView startAnimating];
    NSString *body = [NSString stringWithFormat:@"%@?page_size=15&page_num=%ld&api_type=home&user_id=%ld&role_type=0&role_type_ed=%ld",KfriendGroupList,myDynamicPage,self.news_id,self.role_type_ed];
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithoutLoadingForURL:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        total = [[json objectForKey:@"total"] integerValue];

        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *dynamicArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                TCMyDynamicModel *myDynamicModel = [[TCMyDynamicModel alloc] init];
                [myDynamicModel setValues:dict];
                [dynamicArr addObject:myDynamicModel];
            }
            if (myDynamicPage==1) {
                myDynamicArray = dynamicArr;
                weakSelf.myDynamicBlankView.hidden = dynamicArr.count>0;
            } else {
                [myDynamicArray addObjectsFromArray:dynamicArr];
            }
            self.myDynamicTab.mj_footer.hidden=(total -myDynamicPage*20)<=0;
            self.myDynamicTab.tableFooterView = (total -myDynamicPage*20)<=0 ? [self tableDynamicFooterView] : [UIView new];
            [weakSelf.myDynamicTab performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }else{
            [myDynamicArray removeAllObjects];
            self.myDynamicTab.tableFooterView = [UIView new];
            self.myDynamicTab.mj_footer.hidden = YES;
            weakSelf.myDynamicBlankView.hidden = NO;
            [weakSelf.myDynamicTab reloadData];
        }
        [weakSelf.actImageView stopAnimating];
        [self.myDynamicTab.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.actImageView stopAnimating];
        [self.myDynamicTab.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 查看大图
- (void)lookBigImage{
    [[TCHelper sharedTCHelper] scanBigImageWithImageView:_headImageButton.imageView];
}
#pragma mark 上啦加载
- (void)loadMyDynamicMoreData{
    myDynamicPage++;
    [self loadMyDynamicData];
}
#pragma mark ======  没有更多动态 =======
- (UIView *)tableDynamicFooterView{
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
#pragma mark -- Enent Methon
#pragma mark -- 初始化界面
-(void)setNavagationView{
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
    _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
    [self.view addSubview:_navigationView];
    
    textTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, KStatusHeight, 150, 44)];
    textTitle.textAlignment = NSTextAlignmentCenter;
    textTitle.font = [UIFont systemFontOfSize:18];
    textTitle.textColor = [UIColor whiteColor];
    [_navigationView addSubview:textTitle];
    textTitle.hidden = YES;
    
    UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 22, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:backBtn];
}

- (void)initMyDynamicView{
    _myDynamicTab=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _myDynamicTab.backgroundColor=[UIColor bgColor_Gray];
    _myDynamicTab.delegate=self;
    _myDynamicTab.dataSource=self;
    _myDynamicTab.showsVerticalScrollIndicator=NO;
    _myDynamicTab.contentInset=UIEdgeInsetsMake(kImgViewHeight, 0, 0, 0);
    _myDynamicTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myDynamicTab];
    _myDynamicTab.tableFooterView=[[UIView alloc] init];
    
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMyDynamicMoreData)];
    footer.automaticallyRefresh = NO;// 禁止自动加载
    _myDynamicTab.mj_footer = footer;
    footer.hidden=YES;
    //背景图片
    sugarTypeImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -kImgViewHeight, kScreenWidth, kImgViewHeight)];
    sugarTypeImgView.image = [UIImage imageNamed:@"background"];
    sugarTypeImgView.userInteractionEnabled=YES;
    [_myDynamicTab addSubview:sugarTypeImgView];
    sugarTypeImgView.autoresizesSubviews=YES;   //设置autoresizesSubviews让子类自动布局
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 80, 64, 64)];
    bgImgView.layer.cornerRadius = 32;
    bgImgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bgImgView.image = [UIImage imageNamed:@"head"];
    [sugarTypeImgView addSubview:bgImgView];
    
    //头像和昵称
    _headImageButton=[[UIButton alloc] initWithFrame:CGRectMake(25, 83 , 58, 58)];
    _headImageButton.layer.cornerRadius=29;
    _headImageButton.backgroundColor = [UIColor bgColor_Gray];
    _headImageButton.clipsToBounds=YES;
    _headImageButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;  //自动布局
    [_headImageButton addTarget:self action:@selector(lookBigImage) forControlEvents:UIControlEventTouchUpInside];
    [sugarTypeImgView addSubview:_headImageButton];
    
    
    _nickNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(_headImageButton.right+15,_headImageButton.top +7, kScreenWidth/2, 20)];
    _nickNameLabel.textColor=[UIColor whiteColor];
    _nickNameLabel.font=[UIFont systemFontOfSize:16];
    _nickNameLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [sugarTypeImgView addSubview:_nickNameLabel];
    
    _sexImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_nickNameLabel.right,_nickNameLabel.top-5 , 30, 30)];
    _sexImgView.layer.cornerRadius = 15;
    _sexImgView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;
    [sugarTypeImgView addSubview:_sexImgView];
    
    sugarTypeButton = [[TCUserDynamicButton alloc] initWithFrame:CGRectMake(_headImageButton.right+15, _nickNameLabel.bottom+10, 119, 27) img:@"time"];
    sugarTypeButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [sugarTypeImgView addSubview:sugarTypeButton];
    
    // 转圈菊花
    [sugarTypeImgView addSubview:self.actImageView];
    
    // 关注状态
    _focusOnTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _focusOnTypeBtn.frame = CGRectMake(kScreenWidth - 94,sugarTypeButton.top, 74, 27);
    _focusOnTypeBtn.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [_focusOnTypeBtn addTarget:self action:@selector(focusOnClick) forControlEvents:UIControlEventTouchUpInside];
    [sugarTypeImgView addSubview:_focusOnTypeBtn];
    
    UIView *blackBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kImgViewHeight-55, kScreenWidth, 55)];
    blackBgView.backgroundColor = [UIColor blackColor];
    blackBgView.alpha = 0.1;
    blackBgView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;
    [sugarTypeImgView addSubview:blackBgView];
    
    UILabel *blackBgLine = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, kImgViewHeight-42, 1, 29)];
    blackBgLine.backgroundColor = [UIColor colorWithHexString:@"#191c1b"];
    blackBgLine.alpha = 0.2;
    blackBgLine.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;
    [sugarTypeImgView addSubview:blackBgLine];
    
    FocusOnButton = [[TCFocusOnButton alloc] initWithFrame:CGRectMake(0, kImgViewHeight-55, kScreenWidth/2, 55) title:@"关注"];
    FocusOnButton.tag = 100;
    FocusOnButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;
    [FocusOnButton addTarget:self action:@selector(focusButton:) forControlEvents:UIControlEventTouchUpInside];
    [sugarTypeImgView addSubview:FocusOnButton];
    
    beFocusOnButton = [[TCFocusOnButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, kImgViewHeight-55, kScreenWidth/2,55) title:@"被关注"];
    beFocusOnButton.tag = 101;
    beFocusOnButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;
    [beFocusOnButton addTarget:self action:@selector(focusButton:) forControlEvents:UIControlEventTouchUpInside];
    [sugarTypeImgView addSubview:beFocusOnButton];
    [_myDynamicTab addSubview:self.myDynamicBlankView];
    self.myDynamicBlankView.hidden=YES;
}
#pragma mark -- Setters and Getters

-(UIImageView *)actImageView{
    if (!_actImageView) {
        _actImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-40, 40, 20, 20)];
        _actImageView.animationImages=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"friend_01"],[UIImage imageNamed:@"friend_02"],[UIImage imageNamed:@"friend_03"],[UIImage imageNamed:@"friend_04"],[UIImage imageNamed:@"friend_05"],[UIImage imageNamed:@"friend_06"],[UIImage imageNamed:@"friend_07"],[UIImage imageNamed:@"friend_08"], nil];
        _actImageView.animationDuration=1.0f;
    }
    return _actImageView;
}
#pragma mark 空白页

-(TCBlankView *)myDynamicBlankView{
    if (_myDynamicBlankView==nil) {
        _myDynamicBlankView=[[TCBlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"un_dynamic" text:@"还未发布动态"];
    }
    return _myDynamicBlankView;
}
@end
