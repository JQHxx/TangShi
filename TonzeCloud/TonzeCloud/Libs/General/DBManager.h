//
//  DMManger.h
//  Newests
//
//  Created by AllenKwok on 15/9/8.
//  Copyright (c) 2015年 AllenKwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "TCDeviceMessageModel.h"

#define MaxRecord 50


@interface DBManager : NSObject

+(instancetype)shareManager;

/*******消息*****/
/*
 *插入一条消息
 */
-(void)insertMessage:(TCDeviceMessageModel *)model;
/*
 *查询消息
 */
-(NSArray*)readAllMessages;
/*
 *删除一条消息
 */
-(void)deleteMessage:(TCDeviceMessageModel *)model;





@end
