//
//  TCMessageModel.h
//  TonzeCloud
//
//  Created by vision on 17/3/27.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 消息类型
 */
typedef NS_OPTIONS(NSUInteger, MessageType) {
    MessageTypeText=0,    //文字
    MessageTypeVoice,     //语音
};

/*
 消息发送方
 */
typedef NS_OPTIONS(NSUInteger, MessageSenderType) {
    MessageSenderTypeUser=0,
    MessageSenderTypeTuring
};


@interface TCMessageModel : NSObject

@property (nonatomic, assign) MessageType         messageType;
@property (nonatomic, assign) MessageSenderType   messageSenderType;

/*
 用户头像
 */
@property (nonatomic, retain) NSString    *logoUrl;

/*
 是否显示小时的时间
 */
@property (nonatomic, assign) BOOL   showMessageTime;

/*
 消息时间  2017-09-11 11:11
 */
@property (nonatomic, retain) NSString    *messageTime;

/*
 消息文本内容
 */
@property (nonatomic, retain) NSString    *messageText;

/*
 音频时间
 */
@property (nonatomic, assign) NSInteger   duringTime;
/*
 消息音频url
 */
@property (nonatomic, retain) NSString    *voiceUrl;


@end
