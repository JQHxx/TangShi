//
//  TCChatModel.h
//  TonzeCloud
//
//  Created by vision on 17/11/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCChatModel : NSObject

@property (nonatomic, copy )NSString *from;

@property (nonatomic, copy )NSString *type;

@property (nonatomic, copy )NSString *info;

@property (nonatomic, copy )NSString *add_time;

@property (nonatomic, copy )NSString *to;

@property (nonatomic,strong)NSNumber *seconds;

@property (nonatomic,strong)NSNumber *timestamp;

@property (nonatomic,strong)NSDictionary *ext;

@property (nonatomic,strong)NSString   *msg_id;

@end
