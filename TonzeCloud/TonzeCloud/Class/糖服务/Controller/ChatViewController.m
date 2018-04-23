//
//  ChatViewController.m
//  TangShiService
//
//  Created by vision on 17/5/24.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "ChatViewController.h"
#import "TCPaySuccessViewController.h"
#import "TCExpertDetailController.h"
#import "TCInformationViewController.h"
#import "EaseMessageSystemCell.h"
#import "EaseEmoji.h"
#import "EaseEmotionManager.h"
#import "TCChatWebViewController.h"
#import "TCChatModel.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseSDKHelper.h"
#import "EaseMessageQuestionnarieCell.h"

@interface ChatViewController ()<EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource>{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_recallItem;
}

@property (nonatomic) NSMutableDictionary *emotionDic;

@property (nonatomic,strong)UIButton  *buyServiceBtn;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    self.showRefreshHeader=YES;
    
    [self.view addSubview:self.buyServiceBtn];
    self.buyServiceBtn.hidden=self.serviceModel.service_status==1;
    
    MyLog(@"chat--user:%@",self.conversation.conversationId);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"对话"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"对话"];
}

#pragma mark -- EaseMessageViewControllerDelegate
#pragma mark 点击cell链接时
- (void)messageViewController:(UITableView *)tableView didSelectLinkWithURL:(NSURL *)url{
    if ([_chatdelegate respondsToSelector:@selector(chatVCDidClickWithUrl:)]) {
        [_chatdelegate chatVCDidClickWithUrl:url];
    }
}


#pragma mark 点击消息cell
-(void)messageViewController:(EaseMessageViewController *)viewController didSelectCellWithExt:(NSDictionary *)ext{
    if ([_chatdelegate respondsToSelector:@selector(chatVCDidSelectCellWithExt:)]) {
        [_chatdelegate chatVCDidSelectCellWithExt:ext];
    }
}

#pragma mark 获取消息自定义cell
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:@"sys"]) {
        NSString *cellIdentifier=@"EaseMessageSystemCell";
        EaseMessageSystemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[EaseMessageSystemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
        cell.cellTitle = body.text;
        return cell;
    }else if ([ext objectForKey:@"msg_type"]){
        NSString *CellIdentifier = @"EaseMessageQuestionnarieCell";
        EaseMessageQuestionnarieCell *cell = (EaseMessageQuestionnarieCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EaseMessageQuestionnarieCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:messageModel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = messageModel;
        return cell;
    }
    return nil;
}

#pragma mark 获取消息cell高度
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:@"sys"]) {
        EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
        return [EaseMessageSystemCell getMessageSystemCellHeightWithText:body.text];
    }else if([ext objectForKey:@"msg_type"]){
        return [EaseMessageQuestionnarieCell cellHeightWithModel:messageModel];
    }
    return 0;
}

#pragma mark 是否允许长按
-(BOOL)messageViewController:(EaseMessageViewController *)viewController canLongPressRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark 触发长按手势
-(BOOL)messageViewController:(EaseMessageViewController *)viewController didLongPressRowAtIndexPath:(NSIndexPath *)indexPath{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    return YES;
}

#pragma mark 点击消息头像
- (void)messageViewController:(EaseMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    MyLog(@"nickname:%@",messageModel.nickname);
    if ([_chatdelegate respondsToSelector:@selector(chatVCDidSelectUserAtavarWithName:)]) {
        [_chatdelegate chatVCDidSelectUserAtavarWithName:messageModel.nickname];
    }
}


#pragma mark -- EaseMessageViewControllerDataSource
#pragma mark 将EMMessage类型转换为符合<IMessageModel>协议的类型
-(id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController modelForMessage:(EMMessage *)message{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"ic_m_head"];
    if ([model.nickname isEqualToString:self.serviceModel.im_username]) {
        model.avatarURLPath = [NSUserDefaultsInfos getValueforKey:kUserPhoto];
        model.nickname = [NSUserDefaultsInfos getValueforKey:kNickName];
    }else if([model.nickname isEqualToString:self.serviceModel.im_expertname]){
        model.avatarURLPath = self.serviceModel.head_portrait;
        model.nickname = self.serviceModel.expert_name;
    }else if([model.nickname isEqualToString:self.serviceModel.im_helpername]){
        model.avatarURLPath = self.serviceModel.im_helperhead;
        model.nickname = self.serviceModel.im_helperusername;
    }
    return model;
}

#pragma mark 获取表情列表
- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];
    
    NSMutableArray *emotionGifs = [NSMutableArray array];
    _emotionDic = [NSMutableDictionary dictionary];
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",@"icon_013",@"icon_018",@"icon_019",@"icon_020",@"icon_021",@"icon_022",@"icon_024",@"icon_027",@"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    int index = 0;
    for (NSString *name in names) {
        index++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:[NSString stringWithFormat:@"[示例%d]",index] emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [_emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    EaseEmotionManager *managerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    return @[managerDefault,managerGif];
}

#pragma mark 判断消息是否为表情消息
- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

#pragma mark 根据消息获取表情信息
- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

#pragma mark 获取发送表情消息的扩展字段
- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark 保存消息到APP服务器
-(void)messageViewController:(EaseMessageViewController *)viewController sendToMyServerForMessage:(EMMessage *)message{
    EMMessageBodyType type=message.body.type;
    NSString *info=nil;
    int duration=0;
    NSString *typeStr=nil;
    if (type==EMMessageBodyTypeText) {
        EMTextMessageBody *body = (EMTextMessageBody*)message.body;
        typeStr=@"txt";
        info=body.text;
    }else if (type==EMMessageBodyTypeImage){
        EMImageMessageBody *body=(EMImageMessageBody *)message.body;
        NSData *imageData = [NSData dataWithContentsOfFile: [body localPath]];
        info = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        typeStr=@"pic";
    }else if (type==EMMessageBodyTypeVoice){
        EMVoiceMessageBody *body=(EMVoiceMessageBody *)message.body;
        NSData *voiceData = [NSData dataWithContentsOfFile: [body localPath]];
        info = [voiceData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        typeStr=@"voice";
        duration=body.duration;
    }
    
    NSString *body=[NSString stringWithFormat:@"group_id=%@&from=%@&type=%@&info=%@&seconds=%d&timestamp=%lld&case_type=%@",self.serviceModel.im_groupid,message.from,typeStr,info,duration,message.timestamp,self.serviceModel.type==1?@"pic":@"case"];
    [[TCHttpRequest sharedTCHttpRequest] postMethodWithoutLoadingForURL:kAddChatMessage body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- Event response
#pragma mark 购买服务
-(void)buyServiceAgainAction{
    if ([_chatdelegate respondsToSelector:@selector(chatVCDidBuyServiceAction)]) {
        [_chatdelegate chatVCDidBuyServiceAction];
    }
}

#pragma mark Setters
-(UIButton *)buyServiceBtn{
    if (!_buyServiceBtn) {
        _buyServiceBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-154, kScreenWidth, 50)];
        _buyServiceBtn.backgroundColor=kSystemColor;
        [_buyServiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buyServiceBtn setTitle:@"购买服务" forState:UIControlStateNormal];
        [_buyServiceBtn addTarget:self action:@selector(buyServiceAgainAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyServiceBtn;
}

@end
