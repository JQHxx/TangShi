//
//  TCPersonalViewController.m
//  TonzeCloud
//
//  Created by vision on 16/10/9.
//  Copyright © 2016年 tonze. All rights reserved.
//

#import "TCPersonalViewController.h"
#import "TCInstallViewController.h"
#import "TCUserinfoViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "TCInformationViewController.h"
#import "TCFilesViewController.h"
#import "TCMineServiceViewController.h"
#import "TCBasewebViewController.h"
#import "ActionSheetView.h"
#import "TCBindingViewController.h"
#import "TCMyFriendViewController.h"
#import "TCPointslMallViewController.h"
#import "TCIntegralTaskNoticeView.h"
#import "TCTodayMissionViewController.h"
#import "TCIntegralTaskListModel.h"
#import "TCCheckInDailyViewController.h"
#import "BaseTabBarViewController.h"
#import "AppDelegate.h"
#import "TCSugarDeviceViewController.h"
#import "TCRecordSugarViewController.h"
#import "TCRecordDietViewController.h"
#import "TCRecordSportViewController.h"
#import "TCAddBloodViewController.h"
#import "TCPertainViewController.h"
#import "TCCheckListViewController.h"
#import "TCArticleLibraryViewController.h"
#import "TCScanFriendViewController.h"
#import "TCIdeaBackViewController.h"
#import "TCMyMessageModel.h"
#import "TCReleaseDynamicViewController.h"
#import "TCInvitationFriendViewController.h"
#import "TCIntelligentDeviceViewController.h"
#import "TCFastLoginViewController.h"
#import "OrderGroupView.h"
#import "AddressManagerViewController.h"
#import "OrderViewController.h"
#import "OrderCountMode.h"
#import "TCCollectionViewController.h"
#import "TCCouponViewController.h"
#import "TCChooseCouponViewController.h"

@interface TCPersonalViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate,NoticeViewDelegate,OrderGroupViewDelegate>{
    UITableView           *_menuTableView;
    UIImageView           *_zoomImageView;
    UIImageView           *_headImageView;
    UILabel               *_nickNameLabel;
    UIButton              *loginBtn;
    UILabel               *pormptLabel;
    UIView                *contentView;
    UIImageView           *_sexImg;              // 性别
    NSArray               *_titleArray;
    NSArray               *_imagesArray;
    BOOL                   isLogin;
    BOOL                  familyIsRead;        //好友新增血糖是否已读
    BOOL                  isFriendApplyRead;   //好友申请是否已读
    NSInteger             sexInt;
}
/// 任务跑马灯
@property (nonatomic ,strong) TCIntegralTaskNoticeView *noticeView;;
/// 任务列表
@property (nonatomic ,strong) NSMutableArray *tastListArray;
/// 任务标题
@property (nonatomic ,strong) NSMutableArray *taskTitleArray;
/// 任务id
@property (nonatomic ,strong) NSMutableArray *actionTypeArray;
/// 订单类型视图
@property (nonatomic,strong)  OrderGroupView     *groupView;
/// 订单数据
@property (nonatomic ,strong) NSMutableArray *orderNumArr;

@end
@implementation TCPersonalViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    if ([TCHelper sharedTCHelper].isUserReload) {
        [self requestMineData];
        [TCHelper sharedTCHelper].isUserReload=NO;
    }
    if (isLogin) {
        self.noticeView.hidden = NO;
        if ([TCHelper sharedTCHelper].isPersonalTaskListRecord) {
            [self getTaskListData];
            [TCHelper sharedTCHelper].isPersonalTaskListRecord = NO;
        }
        [self loadFriendUnreadMessageInfo];
        [self requestOrderCount];
    }else{
        self.noticeView.hidden = YES;
        NSArray *orderNumArr= @[@"0",@"0",@"0",@"0"];
        self.groupView.orderNumArr = orderNumArr;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[TCHelper sharedTCHelper] loginAction:@"003" type:2];
#endif
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle=@"我的";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    familyIsRead=isFriendApplyRead=YES;

    _titleArray=@[@[@"我的订单",@""],@[@"收货地址管理"],@[@"基本信息",@"糖档案",@"我的服务",@"我的亲友",@"我的收藏"],@[@"糖友邀请",@"积分兑换"],@[@"智能设备"],@[@"分享好友",@"设置"]];
 _imagesArray=@[@[@"ic_m_order",@""],@[@"ic_m_address"],@[@"ic_m_02",@"ic_m_01",@"ic_m_03",@"ic_m_bangding_bg",@"ic_m_collect"],@[@"min_ic_invite",@"ic_m_06"],@[@"ic_m_service"],@[@"ic_m_04",@"ic_m_05"]];
    
    isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
    
    [self initMineView];
    [self requestMineData];
    
    [TCHelper sharedTCHelper].isPersonalTaskListRecord = YES;
}
#pragma mark ====== 查询订单数量 =======
- (void)requestOrderCount{
    [self.orderNumArr removeAllObjects];
    NSString *memberId = [NSUserDefaultsInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&platform=ts",memberId];
    kSelfWeak;
    [[TCHttpRequest sharedTCHttpRequest]postShopMethodWithoutLoadingURL:KOrderCount body:body success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        if (kIsDictionary(dic)) {
            OrderCountMode *orderModer = [OrderCountMode new];
            [orderModer setValues:dic];
            [weakSelf.orderNumArr addObject:orderModer.nopayed_count];
            [weakSelf.orderNumArr addObject:orderModer.nodelivery_count];
            [weakSelf.orderNumArr addObject:orderModer.noreceived_count];
            [weakSelf.orderNumArr addObject:@"0"];
            weakSelf.groupView.orderNumArr = weakSelf.orderNumArr;
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark --UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titleArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titleArray[section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            return  124 - 49;
        }
    }
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"personalCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.imageView.image=[UIImage imageNamed:_imagesArray[indexPath.section][indexPath.row]];
    cell.textLabel.text=_titleArray[indexPath.section][indexPath.row];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font=[UIFont systemFontOfSize:16.0];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.separatorInset=UIEdgeInsetsMake(0, 20, 0, 0);
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag==100 || view.tag == 101) {
            [view removeFromSuperview];
        }
    }
    if (indexPath.section== 0) {
        if (indexPath.row== 0) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.imageView.image=[UIImage imageNamed:_imagesArray[indexPath.section][indexPath.row]];
            cell.textLabel.text=@"我的订单";
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font=[UIFont systemFontOfSize:16.0];
            cell.detailTextLabel.text=@"查看全部订单";
            cell.detailTextLabel.font=[UIFont systemFontOfSize:14.0];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 22, 0, 0);
        }else if(indexPath.row == 1){
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.contentView addSubview:self.groupView];
        }
    }else   if (indexPath.section == 2) {
        if ( indexPath.row==3) {
            UILabel *badgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-40, 18, 8, 8)];
            badgeLbl.backgroundColor=[UIColor redColor];
            badgeLbl.layer.cornerRadius=4;
            badgeLbl.clipsToBounds=YES;
            badgeLbl.tag=100;
            [cell.contentView addSubview:badgeLbl];
            badgeLbl.hidden=familyIsRead&&familyIsRead;
            cell.imageView.image=[UIImage imageNamed:_imagesArray[indexPath.section][indexPath.row]];
            cell.textLabel.text=_titleArray[indexPath.section][indexPath.row];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"003-16-01"];
#endif
        [MobClick event:@"104_001012"];
        if (isLogin) {
            OrderViewController *orderVC=[[OrderViewController alloc] init];
            orderVC.indexStatu = 0;
            orderVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:orderVC animated:YES];
        }else{
            [self loginBtn];
        }
    }else if (indexPath.section == 1) {
        if (isLogin) {
            if (indexPath.row == 0) {
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"003-16-06"];
#endif
                [MobClick event:@"104_001017"];
                AddressManagerViewController *addressManagerVC = [[AddressManagerViewController alloc]init];
                addressManagerVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addressManagerVC animated:YES];
            }
            // 优惠券入口
//            else if (indexPath.row == 1){
//                TCCouponViewController *couponVC = [[TCCouponViewController alloc]init];
//                couponVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:couponVC animated:YES];
//            }
        }else{
            [self loginBtn];
        }
    }else  if (indexPath.section == 2) {
        if (isLogin) {
            if (indexPath.row == 0) {
                [MobClick event:@"104_001004"];
                TCInformationViewController *informationVC = [[TCInformationViewController alloc] init];
                informationVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:informationVC animated:YES];
            }else if (indexPath.row == 1){
                [MobClick event:@"104_001005"];
                TCFilesViewController *fileVC = [[TCFilesViewController alloc] init];
                fileVC.hidesBottomBarWhenPushed=YES;
                fileVC.sex=sexInt;
                [self.navigationController pushViewController:fileVC animated:YES];
            }else if (indexPath.row == 2){
                [MobClick event:@"104_001006"];
                
                TCMineServiceViewController *mineServiceVC = [[TCMineServiceViewController alloc] init];
                mineServiceVC.hidesBottomBarWhenPushed = YES;
                mineServiceVC.isPersonIn=YES;
                [self.navigationController pushViewController:mineServiceVC animated:YES];
            }else if (indexPath.row == 3){
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"003-13"];
#endif
                [MobClick event:@"104_001007"];
                TCMyFriendViewController *myfriendVC = [[TCMyFriendViewController alloc] init];
                myfriendVC.hidesBottomBarWhenPushed = YES;
                myfriendVC.isApplyRead=isFriendApplyRead;
                [self.navigationController pushViewController:myfriendVC animated:YES];
            }else if (indexPath.row == 4){
                // 收藏
                [[TCHelper sharedTCHelper] loginClick:@"003-19"];
                [MobClick event:@"104_001018"];
                TCCollectionViewController *collectionVC = [[TCCollectionViewController alloc] init];
                collectionVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:collectionVC animated:YES];
            }
        }else{
            [self loginBtn];
        }
    } else if(indexPath.section==3){
        if (indexPath.row == 0) {
            if (isLogin) {
#if !DEBUG
                [[TCHelper sharedTCHelper] loginClick:@"003-14"];
#endif
                [MobClick event:@"104_001010"];
                TCInvitationFriendViewController *invitationVC = [[TCInvitationFriendViewController alloc] init];
                invitationVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:invitationVC animated:YES];
                
            }else{
                [self loginBtn];
            }
        }else{
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"007-01"];
#endif
            [MobClick event:@"104_001008"];
            TCPointslMallViewController *pointsMallVC = [TCPointslMallViewController new];
            pointsMallVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pointsMallVC animated:YES];
        }
    }else if (indexPath.section==4){
            if (indexPath.row==0) {
                if (isLogin) {
        #if !DEBUG
                    [[TCHelper sharedTCHelper] loginClick:@"003-15"];
        #endif
                    [MobClick event:@"104_001011"];
                    TCIntelligentDeviceViewController *deviceVC=[[TCIntelligentDeviceViewController alloc] init];
                    deviceVC.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:deviceVC animated:YES];
                }else{
                    [self loginBtn];
                }
            }
        }else{
            if (indexPath.row==0) {
                [[TCHelper sharedTCHelper] loginClick:@"003-07"];
                [self sharefriend];
            } else {
                [MobClick event:@"104_001009"];

                TCInstallViewController *installVC= [[TCInstallViewController alloc] init];
                installVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:installVC animated:YES];
            }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    return  view;
}
#pragma mark -- UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat y=scrollView.contentOffset.y;
    if (y < -kImageViewHeight) {
        CGRect frame=_zoomImageView.frame;
        frame.origin.y=y;
        frame.size.height=-y;
        _zoomImageView.frame=frame;
    }
}
#pragma mark OrderGroupViewDelegate
-(void)orderGroupViewBtnActionWithIndex:(NSInteger)index{
    if (isLogin) {
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:[NSString stringWithFormat:@"003-16-0%ld",2+index]];
#endif
        NSString  *clickId = [NSString stringWithFormat:@"104_00101%ld", 3 + index];
        [MobClick event:clickId];
        
        OrderViewController *orderVC=[[OrderViewController alloc] init];
        orderVC.indexStatu = index+1;
        orderVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:orderVC animated:YES];
    }else{
        [self loginBtn];
    }
}
#pragma mark ====== NoticeViewDelegate =======
#pragma mark ====== 任务列表点击 =========
- (void)gyChangeTextView:(TCIntegralTaskNoticeView *)textView didTapedAtIndex:(NSInteger)index{

#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-11"];
#endif
    
    if (self.actionTypeArray.count > 0) {
        NSInteger actionType  = [self.actionTypeArray[index] integerValue];
        MyLog(@"点击了%ld",(long)actionType);
        
        switch (actionType) {
            case 1:
            {// 签到
                TCCheckInDailyViewController *checkInDailyVC = [TCCheckInDailyViewController new];
                checkInDailyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:checkInDailyVC animated:YES];
            }break;
            case 2:
            {// 完善资料
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithURL:kGetUserInfo body:@"" success:^(id json) {
                    NSDictionary *result = [json objectForKey:@"result"];
                    if (kIsDictionary(result)) {
                        NSString *birthday = [result objectForKey:@"birthday"];
                        NSInteger height = [[result objectForKey:@"height"] integerValue];
                        NSString *labour_intensity = [result objectForKey:@"labour_intensity"];
                        NSInteger sex = [[result objectForKey:@"sex"] integerValue];
                        NSInteger weight = [[result objectForKey:@"weight"]integerValue];
                        if (!kIsEmptyString(birthday) && !kIsEmptyString(labour_intensity) && height > 0 && sex > 0 && weight > 0) {
                            [self getTaskPointsWithActionType:2 isTaskList:YES taskAleartViewClickBlock:^(NSInteger clickIndex,BOOL isBack) {
                                if (clickIndex == 1001 || isBack) {
                                    [weakSelf.tastListArray removeAllObjects];
                                    [weakSelf.taskTitleArray removeAllObjects];
                                    [weakSelf.noticeView removeFromSuperview];
                                    weakSelf.noticeView = [[TCIntegralTaskNoticeView alloc]initWithFrame:CGRectMake( 30, _zoomImageView.height - 60, kScreenWidth - 60, 36)];
                                    weakSelf.noticeView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
                                    [_zoomImageView addSubview:self.noticeView];
                                    [weakSelf getTaskListData];
                                }
                            }];
                        }else{
                            // 跳转到个人信息界面
                            TCInformationViewController *informationVC = [TCInformationViewController new];
                            informationVC.hidesBottomBarWhenPushed = YES;
                            [weakSelf.navigationController pushViewController:informationVC animated:YES];
                        }
                    }
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }break;
            case 3:
            {// 购买方案
                BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                tabbarVC.selectedIndex = 3;
                AppDelegate *appDelegate=kAppDelegate;
                appDelegate.window.rootViewController=tabbarVC;
            }break;
            case 4:
            case 5:
            {// 使用血糖仪 || 血糖仪测量血糖
                TCSugarDeviceViewController *sugarDeviceVC = [TCSugarDeviceViewController new];
                sugarDeviceVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:sugarDeviceVC animated:YES];
            }break;
            case 6:
            {// 手动记录血糖
                TCRecordSugarViewController *recordSugarVC = [TCRecordSugarViewController  new];
                recordSugarVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:recordSugarVC animated:YES];
            }break;
            case 7:
            {// 记录饮食
                TCRecordDietViewController *recordDietVC = [TCRecordDietViewController new];
                recordDietVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:recordDietVC animated:YES];
            }break;
            case 8:
            {// 记录运动
                TCRecordSportViewController *recordSportVC = [TCRecordSportViewController new];
                recordSportVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:recordSportVC animated:YES];
            }break;
            case 9:
            {// 记录血压
                TCAddBloodViewController *addBolldVC = [TCAddBloodViewController new];
                addBolldVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addBolldVC animated:YES];
            }break;
            case 10:
            {// 记录糖化血红蛋白
                TCPertainViewController *pertainVC = [TCPertainViewController new];
                pertainVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pertainVC animated:YES];
            }break;
            case 11:
            {// 上传检查单
                TCCheckListViewController *checkListVC = [TCCheckListViewController new];
                checkListVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:checkListVC animated:YES];
            }break;
            case 12:
            case 13:
            {// 阅读文章 || 分享文章
                TCArticleLibraryViewController *articleLibaryVC = [TCArticleLibraryViewController new];
                articleLibaryVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:articleLibaryVC animated:YES];
            }break;
            case 14:
            {// 添加亲友
                TCScanFriendViewController *addFriendVC = [TCScanFriendViewController new];
                addFriendVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addFriendVC animated:YES];
            }break;
            case 15:
            {// 提交意见反馈
                TCIdeaBackViewController  *ideaBackVC = [TCIdeaBackViewController new];
                ideaBackVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ideaBackVC animated:YES];
            }break;
            case 16:
            {// 发布动态
                TCReleaseDynamicViewController *releaseDynamicVC = [TCReleaseDynamicViewController new];
                releaseDynamicVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:releaseDynamicVC animated:YES];
            }break;
            case 17:
            {
                // App版本信息
                NSString *version = [NSString getAppVersion];
                NSString *body = [NSString stringWithFormat:@"action_type=17&app_version=%@",version];
                kSelfWeak;
                [[TCHttpRequest sharedTCHttpRequest]postMethodWithoutLoadingForURL:KIntegralTask body:body success:^(id json) {
                    [weakSelf.view makeToast:@"注册积分已补领" duration:1.0 position:CSToastPositionCenter];
                    [weakSelf getTaskListData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }break;
            case 18:
            {// 评论糖友圈或者文章
                NSInteger x = arc4random() % 2;
                if (x == 1) {
                    BaseTabBarViewController *tabbarVC=[[BaseTabBarViewController alloc] init];
                    tabbarVC.selectedIndex = 2;
                    AppDelegate *appDelegate=kAppDelegate;
                    appDelegate.window.rootViewController=tabbarVC;
                }else{
                    TCArticleLibraryViewController *articleLibaryVC = [TCArticleLibraryViewController new];
                    articleLibaryVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:articleLibaryVC animated:YES];
                }
            }break;
            case 19:
            {// 邀请好友
                TCInvitationFriendViewController *invitationFriendVC =[TCInvitationFriendViewController new];
                invitationFriendVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:invitationFriendVC animated:YES];
            }break;
            default:
                break;
        }
    }
}
#pragma mark ====== 今日任务 =======
- (void)taskListTapClcik{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-12"];
#endif
    
    [MobClick event:@"104_001003"];
    TCTodayMissionViewController *todayMissionVC = [TCTodayMissionViewController new];
    todayMissionVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:todayMissionVC animated:YES];
}
#pragma mark -- Event response
#pragma mark -- 获取用户数据
- (void)requestMineData{
    _headImageView.hidden = isLogin == NO?YES:NO;
    _nickNameLabel.hidden = isLogin == NO?YES:NO;
    loginBtn.hidden= isLogin == NO?NO:YES;
    pormptLabel.hidden = isLogin == NO?NO:YES;
    _sexImg.hidden = isLogin == NO ? YES :NO;
    _menuTableView.mj_header.hidden = isLogin == NO ? YES : NO; 
    if (isLogin== YES) {
        __weak typeof(self) weakSelf=self;
        [[TCHttpRequest sharedTCHttpRequest] postMethodWithURL:kGetUserInfo body:@"" success:^(id json) {
            NSDictionary *result = [json objectForKey:@"result"];
            if (kIsDictionary(result)) {
                NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,w_70",[result objectForKey:@"photo"]];
                [_headImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
                [NSUserDefaultsInfos putKey:@"headimage" andValue:imgUrl];
                NSString *nickStr = [result objectForKey:@"nick_name"];
                if (kIsEmptyString(nickStr)) {
                    NSString *phoneStr =[[NSUserDefaultsInfos getValueforKey:@"phoneNumber"] substringFromIndex:7];
                    _nickNameLabel.text = [NSString stringWithFormat:@"糖友_%@",phoneStr];
                }else{
                    _nickNameLabel.text = [result objectForKey:@"nick_name"];
                }
                sexInt = [[result objectForKey:@"sex"] integerValue];
                CGSize nickStrSize = [_nickNameLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontWithSize(15)];

                if (sexInt<3&&sexInt>0) {
                    _nickNameLabel.frame = CGRectMake((kScreenWidth - (nickStrSize.width +30))/2,_headImageView.bottom + 15, nickStrSize.width, 24);
                    _sexImg.hidden=NO;
                    _sexImg.image = [UIImage imageNamed:sexInt==1?@"ic_m_male1":@"ic_m_famale1"];
                    _sexImg.frame = CGRectMake(_nickNameLabel.right, _nickNameLabel.top, 24, 24);
                }else{
                    _nickNameLabel.frame = CGRectMake((kScreenWidth - nickStrSize.width)/2,_headImageView.bottom + 15, nickStrSize.width, 20);
                    _sexImg.hidden=YES;
                }
                [NSUserDefaultsInfos putKey:kNickName andValue:_nickNameLabel.text];
                
                [_menuTableView reloadData];
            }
            [_menuTableView.mj_header endRefreshing];
        } failure:^(NSString *errorStr) {
            [_menuTableView.mj_header endRefreshing];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark -- Event response
#pragma mark -- 跳转个人信息
-(void)gettoUserInfoVC{
    if (isLogin) {
        [MobClick event:@"104_001002"];

        TCUserinfoViewController *tcUserInfoVC = [[TCUserinfoViewController alloc] init];
        tcUserInfoVC.hidesBottomBarWhenPushed=YES;
        tcUserInfoVC.sex=sexInt;
        [self.navigationController pushViewController:tcUserInfoVC animated:YES];
    }else{
        [self loginBtn];
    }
}
#pragma mark -- 登陆
- (void)loginBtn{
#if !DEBUG
    [[TCHelper sharedTCHelper] loginClick:@"003-01"];
#endif
    
   [self fastLoginAction];
}
#pragma mark ====== 获取积分任务列表数据 =======
- (void)getTaskListData{
    
    if (isLogin) {
        [self.tastListArray removeAllObjects];
        [self.taskTitleArray removeAllObjects];
        
        kSelfWeak;
        // App版本信息
        NSString *version = [NSString getAppVersion];
        NSString *url = [NSString stringWithFormat:@"%@?app_version=%@",KIntegralTaskList,version];
        [[TCHttpRequest sharedTCHttpRequest]getMethodWithURL:url success:^(id json) {
            NSDictionary *resultDic = [json objectForKey:@"result"];
            NSArray *taskListArray = [resultDic objectForKey:@"task_list"];
            if (kIsArray(taskListArray) && taskListArray.count > 0) {
                for (NSDictionary *dic in taskListArray) {
                    TCIntegralTaskListModel *taskListModel = [TCIntegralTaskListModel new];
                    [taskListModel setValues:dic];
                    [weakSelf.tastListArray addObject:taskListModel];
                }
            }
            // 任务数据处理
            if (weakSelf.tastListArray.count > 0) {
                for (NSInteger i = 0; i < weakSelf.tastListArray.count; i++) {
                    TCIntegralTaskListModel *taskListModel = weakSelf.tastListArray[i];
                    if (taskListModel.status == 0) {
                        [weakSelf.taskTitleArray addObject:taskListModel.action_name];
                        [weakSelf.actionTypeArray addObject:taskListModel.action_type];
                        MyLog(@"----%@",taskListModel.action_name);
                    }
                }
                weakSelf.noticeView.titleArray = weakSelf.taskTitleArray;
                weakSelf.noticeView.taskListArray = taskListArray;
                weakSelf.noticeView.carryOutNum = taskListArray.count - weakSelf.taskTitleArray.count;
            }
            [_menuTableView.mj_header endRefreshing];
        } failure:^(NSString *errorStr) {
            [_menuTableView.mj_header endRefreshing];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark -- 分享好友
- (void)sharefriend{
    
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
    NSArray *wayArr = @[@"2",@"3",@"5",@"1",@"4"];
    [[TCHelper sharedTCHelper] loginShare:0 index:[wayArr[btnTag] integerValue] shareType:0 target_name:@"下载糖士"];
        if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
            //分享代码
            [self shareWeixin:btnTag];
            
        }else if (btnTag==4){
            [self shareSina];
        }else{
            
        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}
#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)index{
    
    NSString *shareUrl=@"http://app.360tj.com/tangshi";
    NSArray* imageArray = @[[UIImage imageNamed:@"shareLogin"]];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (imageArray) {
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"专业的糖尿病健康管理平台健康饮食、有效控糖"]
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:@"下载糖士"
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    if (index==0) {
        [MobClick event:@"301_002001"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else if (index==1){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            //微信
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }else{
            [self.view makeToast:@"请先安装微信客户端" duration:1.0 position:CSToastPositionCenter];
        }
        [MobClick event:@"301_002002"];
        
    }else if (index==2){
        [MobClick event:@"301_002003"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
        
    }else{
        [MobClick event:@"301_002004"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }else{
            [self.view makeToast:@"请先安装QQ客户端" duration:1.0 position:CSToastPositionCenter];
        }
    }
}
#pragma mark -- 分享新浪
- (void)shareSina{
    [MobClick event:@"301_002005"];

    NSString *shareUrl=@"http://app.360tj.com/tangshi";
    NSArray* imageArray = @[[UIImage imageNamed:@"ic_tangshi_logo"]];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (imageArray) {
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"专业的糖尿病健康管理平台健康饮食、有效控糖%@",[NSURL URLWithString:shareUrl]]
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:@"下载糖士"
                                           type:SSDKContentTypeAuto];
    }
    
    [shareParams SSDKEnableUseClientShare];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Sinaweibo://"]]) {
        //新浪微博
        [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
    }else{
        [self.view makeToast:@"请先安装新浪微博客户端" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark -- 分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)index{
    if (index==1) {
        [self.view makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
    }else if (index==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark-- Custom Methods
#pragma mark 获取好友未读消息信息
-(void)loadFriendUnreadMessageInfo{
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kMessageUnread body:nil success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            familyIsRead=[[result valueForKey:@"family_poi"] boolValue];
            isFriendApplyRead=[[result valueForKey:@"apply_family_poi"] boolValue];
            [_menuTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- 初始化界面
-(void)initMineView{
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 350)];
    contentView.backgroundColor =[UIColor whiteColor];
    
    _menuTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-49) style:UITableViewStyleGrouped];
    _menuTableView.backgroundColor=[UIColor bgColor_Gray];
    _menuTableView.delegate=self;
    _menuTableView.dataSource=self;
    _menuTableView.showsVerticalScrollIndicator=NO;
    _menuTableView.contentInset=UIEdgeInsetsMake(kImageViewHeight, 0, 0, 0);
    [self.view addSubview:_menuTableView];
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestMineData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    _menuTableView.mj_header=header;
    
    _menuTableView.tableFooterView=[[UIView alloc] init];
    
    //背景图片
    _zoomImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -kImageViewHeight, kScreenWidth, kImageViewHeight)];//mine_bg
    _zoomImageView.image=[UIImage imageNamed:@"mine_background"];
    _zoomImageView.userInteractionEnabled=YES;
    [_menuTableView addSubview:_zoomImageView];
    _zoomImageView.autoresizesSubviews=YES;   //设置autoresizesSubviews让子类自动布局
    
    // 积分任务“跑马灯”
    _noticeView = [[TCIntegralTaskNoticeView alloc]initWithFrame:CGRectMake(10, _zoomImageView.height - 50, kScreenWidth-20, 30)];
    _noticeView.titleFont = 13;
    _noticeView.isCanScroll = NO;
    _noticeView.delegate = self;
    _noticeView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    _noticeView.titleColor = [UIColor whiteColor];
    [_noticeView addTimer];
    [_zoomImageView addSubview:_noticeView];
    
    
    //头像和昵称
    _headImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-70)/2, 45 , 70, 70)];
    _headImageView.layer.cornerRadius=35;
    _headImageView.backgroundColor = [UIColor bgColor_Gray];
    _headImageView.clipsToBounds=YES;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;  //自动布局，自使用顶部
    [_zoomImageView addSubview:_headImageView];
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gettoUserInfoVC)];
    [_headImageView addGestureRecognizer:tap];
    
    _nickNameLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    _nickNameLabel.textColor=[UIColor whiteColor];
    _nickNameLabel.font=[UIFont systemFontOfSize:15];
    _nickNameLabel.textAlignment = NSTextAlignmentLeft;
    _nickNameLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [_zoomImageView addSubview:_nickNameLabel];
    
    // 性别
    _sexImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    _sexImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_zoomImageView addSubview:_sexImg];
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2- 117/2,100 , 117, 72/2)];
    loginBtn.hidden = YES;
    [loginBtn setImage:[UIImage imageNamed:@"signIn_bg"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtn) forControlEvents:UIControlEventTouchUpInside];
    [_zoomImageView addSubview:loginBtn];
    
    pormptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginBtn.bottom+20, kScreenWidth, 20)];
    pormptLabel.text = @"立即登录，享受贴心服务。";
    pormptLabel.font = [UIFont systemFontOfSize:12];
    pormptLabel.textColor = [UIColor whiteColor];
    pormptLabel.textAlignment = NSTextAlignmentCenter;
    pormptLabel.hidden = YES;
    [_zoomImageView addSubview:pormptLabel];
}
#pragma mark 我的订单
-(OrderGroupView *)groupView{
    if (!_groupView) {
        _groupView=[[OrderGroupView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 124- 49)];
        _groupView.delegate=self;
        _groupView.tag = 101;
    }
    return _groupView;
}
#pragma mark ====== Getter =======
- (NSMutableArray *)taskTitleArray{
    if (!_taskTitleArray) {
        _taskTitleArray = [NSMutableArray array];
    }
    return _taskTitleArray;
}
- (NSMutableArray *)tastListArray{
    if (!_tastListArray) {
        _tastListArray = [NSMutableArray array];
    }
    return _tastListArray;
}
- (NSMutableArray *)actionTypeArray{
    if (!_actionTypeArray) {
        _actionTypeArray  = [NSMutableArray array];
    }
    return _actionTypeArray;
}
- (NSMutableArray *)orderNumArr{
    if (!_orderNumArr) {
        _orderNumArr = [NSMutableArray array];
    }
    return _orderNumArr;
}
@end
