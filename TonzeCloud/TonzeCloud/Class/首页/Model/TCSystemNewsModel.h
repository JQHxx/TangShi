//
//  TCSystemNewsModel.h
//  TonzeCloud
//
//  Created by vision on 17/7/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSystemNewsModel : NSObject

@property (nonatomic,assign)NSInteger   message_user_id;
@property (nonatomic,assign)NSInteger   message_id;
@property (nonatomic, copy )NSString    *title;
@property (nonatomic, copy )NSString    *send_time;
@property (nonatomic,strong)NSNumber    *is_read;
@property (nonatomic,assign)BOOL        isRead;
@property (nonatomic,assign)NSInteger   type;              //1、文章   2、系统消息
@property (nonatomic, copy )NSString    *image_url;

@end
