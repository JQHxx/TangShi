//
//  ConversationViewController.m
//  TangShiService
//
//  Created by vision on 17/5/23.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "ConversationViewController.h"
#import "TCServicingViewController.h"
#import "SystemNewsViewController.h"
#import "TCFamilyBloodViewController.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseEmotionManager.h"
#import "NSDate+Category.h"
#import "ConversationTableViewCell.h"
#import "EaseLocalDefine.h"
#import "TCMineServiceModel.h"
#import "EaseMessageModel.h"
#import "TCSystemNewsModel.h"
#import "TCFamilyBloodModel.h"
#import "TCCommonNewsModel.h"
#import "SVProgressHUD.h"
#import "TCCommentMineViewController.h"
#import "TCDeviceMessageViewController.h"

@interface ConversationViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger            page;
    TCSystemNewsModel    *systemNewsModel;   //系统消息
    TCFamilyBloodModel   *bloodNewsModel;    //亲友血糖
    TCCommonNewsModel    *deviceNewsModel;   //设备消息
    TCCommonNewsModel    *commonNewsModel;   //评论消息
    BOOL                 isUnShowProgress;  //不显示加载器
}
@property (nonatomic,strong)NSMutableArray  *dataArray;
@property (nonatomic,strong)UITableView     *conversationTableView;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"消息";
    
    page=1;
    systemNewsModel = [[TCSystemNewsModel alloc] init];
    bloodNewsModel  = [[TCFamilyBloodModel alloc] init];
    deviceNewsModel = [[TCCommonNewsModel alloc] init];
    deviceNewsModel.hasNewMessages=self.hasNewDeviceMessage;
    commonNewsModel = [[TCCommonNewsModel alloc] init];
    
    [self.view addSubview:self.conversationTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self requestSystemAndFamilyNewsData];
    
}
#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?4:self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"ConversationTableViewCell";
    ConversationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    id model;
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            model=systemNewsModel;
        }else if (indexPath.row==1){
            model=bloodNewsModel;
        }else if (indexPath.row==2){
            deviceNewsModel.newsName=@"设备消息";
            deviceNewsModel.newsImage=@"ic_msg_tips";
            model=deviceNewsModel;
        }else{
            commonNewsModel.newsName=@"评论消息";
            commonNewsModel.newsImage=@"ic_m_pinglun";
            model=commonNewsModel;
        }
    }else{
        model=self.dataArray[indexPath.row];
    }
    [cell conversationCellDisplayWithModel:model];
    return cell;
}


#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    isUnShowProgress=YES;

    if (indexPath.section==0) {
        if (indexPath.row==0) {
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"004-01-03"];
#endif
            [MobClick event:@"101_002001"];
            SystemNewsViewController *systemNewsVC=[[SystemNewsViewController alloc] init];
            [self.navigationController pushViewController:systemNewsVC animated:YES];
        }else if(indexPath.row==1){
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"004-01-04"];
#endif
            [MobClick event:@"101_002002"];
            TCFamilyBloodViewController *familyBloodVC=[[TCFamilyBloodViewController alloc] init];
            [self.navigationController pushViewController:familyBloodVC animated:YES];
            
        }
        else if (indexPath.row==2){
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"004-01-06"];
#endif
            [MobClick event:@"101_002026"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnNotifyWithFlag object:nil userInfo:@{@"receiveNewNotify":[NSNumber numberWithBool:NO]}];
            self.hasNewDeviceMessage=NO;
            TCDeviceMessageViewController *deviceMessageVC=[[TCDeviceMessageViewController alloc] init];
            deviceMessageVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:deviceMessageVC animated:YES];
        }
         else{
#if !DEBUG
            [[TCHelper sharedTCHelper] loginClick:@"004-01-05"];
#endif
            [MobClick event:@"101_002027"];
            TCCommentMineViewController *commentMineVC=[[TCCommentMineViewController alloc] init];
            [self.navigationController pushViewController:commentMineVC animated:YES];
        }
    }else{
#if !DEBUG
        [[TCHelper sharedTCHelper] loginClick:@"004-01-07"];
#endif
        TCMineServiceModel *model=self.dataArray[indexPath.row];
        TCServicingViewController *servicingVC=[[TCServicingViewController alloc] init];
        servicingVC.serviceModel=model;
        [TCHelper sharedTCHelper].expert_id=model.expert_id;
        [self.navigationController pushViewController:servicingVC animated:YES];

        [MobClick event:@"101_002003"];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1&&self.dataArray.count>0) {
        return 40;
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1&&self.dataArray.count>0) {
        return @"我的营养师";
    }else{
        return @"";
    }
}


#pragma mark 获取最后一条消息显示的内容
- (NSString *)latestMessageTitleForConversationModel:(EMConversation *)conversationModel
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversationModel latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            }
                break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            }
                break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[音频]";
            }
                break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            }
                break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"[视频]";
            }
                break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"[文件]";
            }
                break;
            default: {
            }
                break;
        }
    }
    return latestMessageTitle;
}


#pragma mark 获取最后一条消息显示的时间
-(NSString *)latestMessageTimeForConversationModel:(EMConversation *)conversationModel{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel latestMessage];;
    if (lastMessage) {
        latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    return latestMessageTime;
}

#pragma mark -- Private methods
#pragma mark 获取最新会话列表
-(void)loadNewConversationData{
    page=1;
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark 刷新获取会话列表数据
-(void)tableViewDidTriggerHeaderRefresh{
    NSArray *imUsers=[NSUserDefaultsInfos getValueforKey:kIMOrderExperts];
    if (kIsArray(imUsers)&&imUsers.count>0) {
        [self parseConversationWithImUser:imUsers];
        [self.conversationTableView.mj_header endRefreshing];
    }else{
        __weak typeof(self) weakself = self;
        [[TCHttpRequest sharedTCHttpRequest] getMethodWithoutLoadingForURL:kGetServiceExperts success:^(id json) {
            NSArray *result=[json objectForKey:@"result"];
            if (kIsArray(result)&&result.count>0) {
                NSMutableArray *tempImUserArr=[[NSMutableArray alloc] init];
                for (NSDictionary *tempDict in result) {
                    NSDictionary *helperDict=[[NSDictionary alloc] initWithObjectsAndKeys:[tempDict valueForKey:@"im_helpername"],kIMUserNameKey,[tempDict valueForKey:@"im_helperusername"],kIMNickNameKey,nil];
                    [tempImUserArr addObject:helperDict];
                    
                    NSDictionary *expertDict=[[NSDictionary alloc] initWithObjectsAndKeys:[tempDict valueForKey:@"im_expertname"],kIMUserNameKey,[tempDict valueForKey:@"im_expertusername"],kIMNickNameKey,nil];
                    [tempImUserArr addObject:expertDict];
                }
                [NSUserDefaultsInfos putKey:kIMUsers andValue:tempImUserArr];   //保存环信用户昵称在本地
                
                [NSUserDefaultsInfos putKey:kIMOrderExperts andValue:result];   //保存订单专家在本地
                
                [weakself parseConversationWithImUser:result];
                
            }
            [weakself.conversationTableView.mj_header endRefreshing];
        } failure:^(NSString *errorStr) {
            [weakself.conversationTableView.mj_header endRefreshing];
        }];
    }
}

#pragma mark 解析会话
- (void)parseConversationWithImUser:(NSArray *)imUsers{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSArray* sorted = [conversations sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (EMConversation *converstion in sorted) {
        for (NSDictionary *serviceDict in imUsers) {
            TCMineServiceModel *model=[[TCMineServiceModel alloc] init];
            [model setValues:serviceDict];
            model.expert_name=[serviceDict valueForKey:@"im_expertusername"];
            model.head_portrait=[serviceDict valueForKey:@"im_experthead"];
            model.im_username=[NSUserDefaultsInfos getValueforKey:kImUserName];
            
            
            
            if ([model.im_groupid isEqualToString:converstion.conversationId]||[model.im_expertname isEqualToString:converstion.conversationId]) {
                model.lastMsg=[self latestMessageTitleForConversationModel:converstion];
                model.lastMsgTime=[self latestMessageTimeForConversationModel:converstion];
                model.unreadCount=converstion.unreadMessagesCount;
                
                model.lastMsgHeadPic=model.head_portrait;
                model.lastMsgUserName=model.expert_name;
                model.lastMsgLabel=model.im_expertpositional;
                
                if ([model.im_expertname isEqualToString:converstion.conversationId]) {
                    model.im_groupid=@"";
                }
                [tempArr addObject:model];
            }
        }
    }
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:tempArr];
    
    //去掉没用的会话
    if (self.dataArray.count==0&& conversations.count>0) {
        for (EMConversation *conversation in conversations) {
            [conversation markAllMessagesAsRead:nil];
        }
    }
    [self.conversationTableView reloadData];
}

#pragma mark 获取最新系统消息和亲友血糖
-(void)requestSystemAndFamilyNewsData{
    __weak typeof(self) weakself = self;
    if (!isUnShowProgress) {
        [SVProgressHUD show];
    }
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kGetHomeNews body:nil success:^(id json) {
        if (!isUnShowProgress) {
            [SVProgressHUD dismiss];
        }
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            //系统消息
            BOOL isMessageRead=[[result valueForKey:@"message_count"] boolValue];
            NSDictionary *messageInfo=[result valueForKey:@"message_info"];
            if (kIsDictionary(messageInfo)&&messageInfo.count>0) {
                [systemNewsModel setValues:messageInfo];
            }else{
                systemNewsModel = [[TCSystemNewsModel alloc] init];
            }
            systemNewsModel.isRead=isMessageRead;
    
            //亲友血糖
            BOOL isFamilyRead=[[result valueForKey:@"family_count"] boolValue];
            NSDictionary *familyRecord=[result valueForKey:@"family_record"];
            if (kIsDictionary(familyRecord)&&familyRecord.count>0) {
                [bloodNewsModel setValues:familyRecord];
            }else{
                bloodNewsModel  = [[TCFamilyBloodModel alloc] init];
            }
            bloodNewsModel.isRead=isFamilyRead;
            
            commonNewsModel.newsIndex=1;
            NSDictionary *articleInfo=[result valueForKey:@"article_info"];
            BOOL isCommentRead=[[articleInfo valueForKey:@"is_read"] boolValue];
            commonNewsModel.hasNewMessages=isCommentRead;
            
            [weakself.conversationTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        if (!isUnShowProgress) {
            [SVProgressHUD dismiss];
        }
        [weakself.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- setters and getters
#pragma mark 数据数组
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray=[[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark 会话列表
-(UITableView *)conversationTableView{
    if (!_conversationTableView) {
        _conversationTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _conversationTableView.dataSource=self;
        _conversationTableView.delegate=self;
        _conversationTableView.backgroundColor=[UIColor bgColor_Gray];
        _conversationTableView.tableFooterView = [UIView new];
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewConversationData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _conversationTableView.mj_header=header;
    }
    return _conversationTableView;
}

@end
