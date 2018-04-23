//
//  ChatHelper.m
//  TangShiService
//
//  Created by vision on 17/5/26.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "ChatHelper.h"
#import "SVProgressHUD.h"
#import "EMCDDeviceManager.h"
#import <UserNotifications/UserNotifications.h>
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "XLinkExportObject.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";

static ChatHelper *helper = nil;

@interface ChatHelper ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation ChatHelper

+(ChatHelper *)sharedChatHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[ChatHelper alloc] init];
    });
    return helper;
}

#pragma mark 初始化
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

#pragma mark -- Private Methods
#pragma mark 初始化
- (void)initHelper{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
}

#pragma mark 清除数据
- (void)_clearHelper{
    [[EMClient sharedClient] logout:NO];
}

#pragma mark 播放铃声和震动
-(void)playSoundAndVibrationWithMessage:(EMMessage *)message{
    MyLog(@"playSoundAndVibration");
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    NSString *sound=[SSKeychain passwordForService:kPushPlaySound account:kSetPushOption];
    if (kIsEmptyString(sound)) {
        [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    }else{
        if ([sound integerValue]>0) {
            [[EMCDDeviceManager sharedInstance] playNewMessageSound];
        }
    }
    
    NSArray *imUsers=[NSUserDefaultsInfos getValueforKey:kIMUsers];
    if (kIsArray(imUsers)&&imUsers.count>0) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSDictionary *userDict in imUsers) {
            NSString *imUserName=[userDict valueForKey:kIMUserNameKey];
            if ([imUserName isEqualToString:message.from]) {
                [tempArr addObject:imUserName];
                break;
            }
        }
        
        if (tempArr.count==0) {
            [self loadAllImExperts];
        }
    }
    
    // 收到消息时，震动
    NSString *vebration=[SSKeychain passwordForService:kPushPlayVebration account:kSetPushOption];
    if (kIsEmptyString(vebration)) {
        [[EMCDDeviceManager sharedInstance] playVibration];
    }else{
        if ([vebration integerValue]>0) {
            [[EMCDDeviceManager sharedInstance] playVibration];
        }
    }
}

#pragma mark 显示推送消息
-(void)showNotificationWithMessage:(EMMessage *)message{
    EMMessageBody *messageBody = message.body;
    NSString *messageStr = nil;
    switch (messageBody.type) {
        case EMMessageBodyTypeText:
        {
            messageStr = ((EMTextMessageBody *)messageBody).text;
            messageStr = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:messageStr];
        }
            break;
        case EMMessageBodyTypeImage:
        {
            messageStr = @"[图片]";
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            messageStr = @"[位置]";
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            messageStr = @"[语音]";
        }
            break;
        case EMMessageBodyTypeVideo:{
            messageStr = @"[视频]";
        }
            break;
        default:
            break;
    }
    
    NSString *alertBody=[NSString stringWithFormat:@"%@",messageStr];
    NSArray *imUsers=[NSUserDefaultsInfos getValueforKey:kIMUsers];
    if (kIsArray(imUsers)&&imUsers.count>0) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSDictionary *userDict in imUsers) {
            NSString *imUserName=[userDict valueForKey:kIMUserNameKey];
            if ([imUserName isEqualToString:message.from]) {
                [tempArr addObject:imUserName];
                NSString *nickName=[userDict valueForKey:kIMNickNameKey];
                alertBody=[NSString stringWithFormat:@"%@：%@",nickName,messageStr];
                break;
            }
        }
        
        if (tempArr.count==0) {
            [self loadAllImExperts];
        }
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        MyLog(@"UNUserNotificationCenter");
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body =alertBody;
        content.userInfo = userInfo;
        
         [UIApplication sharedApplication].applicationIconBadgeNumber +=1;
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"推送已添加成功 %@", request);
            }else {
                MyLog(@"UNUserNotificationCenter---error:%@",error.localizedDescription);
            }
        }];
    }else {
        MyLog(@"UILocalNotification");
        
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        notification.userInfo = userInfo;
        //发送通知
         [UIApplication sharedApplication].applicationIconBadgeNumber +=1;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}

#pragma mark 获取所有环信专家，并保存
- (void)loadAllImExperts{
    [[TCHttpRequest sharedTCHttpRequest] getMethodWithoutLoadingForURL:kGetServiceExperts success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)&&result.count>0) {
            
            [NSUserDefaultsInfos putKey:kIMOrderExperts andValue:result];
            
            //保存环信用户昵称在本地
            NSMutableArray *tempImUserArr=[[NSMutableArray alloc] init];
            for (NSDictionary *tempDict in result) {
                NSDictionary *helperDict=[[NSDictionary alloc] initWithObjectsAndKeys:[tempDict valueForKey:@"im_helpername"],kIMUserNameKey,[tempDict valueForKey:@"im_helperusername"],kIMNickNameKey,nil];
                [tempImUserArr addObject:helperDict];
                
                NSDictionary *expertDict=[[NSDictionary alloc] initWithObjectsAndKeys:[tempDict valueForKey:@"im_expertname"],kIMUserNameKey,[tempDict valueForKey:@"im_expertusername"],kIMNickNameKey,nil];
                [tempImUserArr addObject:expertDict];
            }
            [NSUserDefaultsInfos putKey:kIMUsers andValue:tempImUserArr];
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark - EMClientDelegate
#pragma mark 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    MyLog(@"didConnectionStateChanged");
}

#pragma mark 自动登录完成时的回调
- (void)autoLoginDidCompleteWithError:(EMError *)error{
    if (error) {
        MyLog(@"自动登录失败,code:%u,error:%@",error.code,error.errorDescription);
    } else if([[EMClient sharedClient] isConnected]){
        MyLog(@"自动登录成功");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL flag = [[EMClient sharedClient] migrateDatabaseToLatestSDK];
            if (flag) {
                [self setApnsNickName];
                [self loadAllImExperts];
            }
        });
    }
}

#pragma mark 当前登录账号已经被从服务器端删除时会收到该回调
- (void)userAccountDidRemoveFromServer
{
    [self _clearHelper];
}

#pragma mark 服务被禁用
- (void)userDidForbidByServer
{
    [self _clearHelper];
}

#pragma mark 当前登录账号被强制退出时会收到该回调
- (void)userAccountDidForcedToLogout:(EMError *)aError
{
    [self _clearHelper];
}

#pragma mark - EMChatManagerDelegate
#pragma mark 会话列表发生变化
-(void)conversationListDidUpdate:(NSArray *)aConversationList{
    MyLog(@"conversationListDidUpdate");
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetMessagesUnread object:nil];
}

#pragma mark 收到消息
-(void)messagesDidReceive:(NSArray *)aMessages{
    MyLog(@"messagesDidReceive");
    for(EMMessage *message in aMessages){
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state==UIApplicationStateActive) {
            [self playSoundAndVibrationWithMessage:message];
        }else{
            [self showNotificationWithMessage:message];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetMessagesUnread object:nil];
}


#pragma mark -- Publc methods
#pragma mark 设置APNS昵称
-(void)setApnsNickName{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *nickName=[NSUserDefaultsInfos getValueforKey:kNickName];
        EMError *error=[[EMClient sharedClient] setApnsNickname:nickName];
        
        if (!error) {
            MyLog(@"成功设置APNS昵称：%@",nickName);
        }else{
            MyLog(@"设置APNS昵称失败，code:%u,error:%@",error.code,error.errorDescription);
        }
    });
}

#pragma mark 从服务器获取推送属性
- (void)asyncPushOptions{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMPushOptions *options =[[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
        options.displayStyle=EMPushDisplayStyleMessageSummary;
        
        EMError *error2 = [[EMClient sharedClient] updatePushOptionsToServer]; // 更新配置到服务器，该方法为同步方法，如果需要，请放到单独线程
        if (!error2) {
            MyLog(@"设置推送显示详情成功");
        }else{
            MyLog(@"设置推送显示详情失败:code:%u,error:%@",error2.code,error2.errorDescription);
        }
    });
}


- (void)dealloc{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

@end
