//
//  ChatHelper.h
//  TangShiService
//
//  Created by vision on 17/5/26.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseSDKHelper.h"

#define kHaveUnreadAtMessage       @"kHaveAtMessage"
#define kAtYouMessage              1
#define kAtAllMessage              2

@interface ChatHelper : NSObject <EMClientDelegate,EMChatManagerDelegate>


singleton_interface(ChatHelper);

- (void)setApnsNickName;//设置当前登录用户的 APNS 昵称

- (void)asyncPushOptions;

- (void)loadAllImExperts;

@end
