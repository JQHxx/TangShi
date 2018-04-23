//
//  ConversationModel.h
//  TangShiService
//
//  Created by vision on 17/5/31.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversationModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *head_portrait;

@property (nonatomic, copy) NSString *phone;

@property (nonatomic, copy) NSString *im_username;

@property (nonatomic, copy) NSString *positional_titles;

@property (nonatomic, copy)NSString *lastMsg;

@property (nonatomic, copy)NSString *lastMsgTime;

@property (nonatomic,assign)NSInteger unreadCount;

@end
